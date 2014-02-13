/*
Question template
*/

package ramen.page {
	
	import com.nudoru.lms.InteractionObject;
	import flash.accessibility.AccessibilityImplementation;
	import flash.geom.Point;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class QuestionTemplate extends Template {
		
		// vars
		protected var _State					:int;
		protected var _Questions				:Array;
		protected var _CurrentQuestion			:int;
		protected var _Animate					:Boolean = true;
		protected var _RetryState				:Boolean;
		protected var _FeedbackBox				:Feedback;
		// conts
		public static const LETTER_LIST			:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
		public static const STATE_INIT			:int = 0;
		public static const STATE_READY			:int = 1;
		public static const STATE_CORRECT		:int = 2;
		public static const STATE_WRONG			:int = 3;
		public static const STATE_NEUTRAL		:int = 4;
		public static const STATE_DISABLED		:int = 5;
		
		// events
		public static const STAGE_CHANGE		:String = "stage_change";
		public static const MARK_CORRECT		:String = "mark_correct";
		public static const MARK_WRONG			:String = "mark_wrong";
		public static const MARK_NEUTRAL		:String = "mark_neutral";
		
		// getters/setters
		public function get state():int { return _State }
		public function set state(s:int) {
			if (_State == s) return;
			_State = s;
			dispatchEvent(new Event(STAGE_CHANGE));
		}
		
		public function get numQuestions():int { return _Questions.length }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// init
		
		// constructor
		public function QuestionTemplate():void {
			// initialized the template and will trigger renderPageCustomContent()
			super();
		}
		
		// all template specific stuff goes here
		override protected function renderInteraction():void {
			state = STATE_INIT;

			_CurrentQuestion = 0;
			
			// get the XML from the pages' <customcontent> block
			parseQuestions(_PageRenderer.interactionXML);			
			renderChoices();

			configureButtons();
		}
		
		protected function parseQuestions(x:XMLList) {
			_Questions = new Array();
			var len:int = x.question.length();
			for (var i:int = 0; i < len; i++) {
				_Questions.push(new Question(x.question[i]));
			}
		}
		
		override protected function startInteraction():void {
			//trace("start interaction");

			var enable:Boolean = true;
			var showanswers:Boolean = true;
			
			// is it scored and can we reanswer it?
			if (hasPageBeenPreviouslyCompleted() && isPageScored && Settings.getInstance().allowScoredReanswer) {
				trace("$$$, prev completed, is scored and allow reanswer");
				enable = true;
			} else if(hasPageBeenPreviouslyCompleted() && isPageScored && !Settings.getInstance().allowScoredReanswer) {
				trace("$$$, prev completed, is scored and don't allow reanswer");
				enable = false;
			}

			/* Disabled 11/6/09
			 * 
			 * if(showanswers) {
				if (pageEntryStats == ObjectStatus.PASSED || pageEntryStats == ObjectStatus.COMPLETED) {
					// passed doesn't worry about the inteaction object since there is only 1 correct pattern
					trace("$$$ interaction answered correctly");
					setToCorrectAnswer(); 
				} if ( pageEntryStats == ObjectStatus.FAILED) {
					// failed
					trace("$$$ interaction answered incorrectly");
					// check to see if there is a learner respsone pattern in history
					if (_Questions[_CurrentQuestion].hasQuestionBeenSubmittedToAssmntMgr() && Settings.getInstance().interactionUseIObj) {
						trace("$$$ interaction exists in assmnt mgr");
						resetQuestionToLastAnsweredIntrObj(_CurrentQuestion);
					} else {
						// no pattern found, just allow reanswer
					}
				}
			}*/

			if (enable) {
				state = STATE_READY;
				_Questions[_CurrentQuestion].start();
			} else {
				state = STATE_DISABLED;
				disableAllQuestions();
			}
			
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// on init state set
		
		// these are primarily for MC questions, move to that template and leave shell here?
		protected function resetQuestionToLastAnsweredIntrObj(qidx:int = 0):void {
			// disabled 11/6/09
			return;
			
			var iObj:InteractionObject = _Questions[qidx].getInteractionObject();
			if (!iObj) {
				trace("$$$ error, prev state interaction object not returned");
				return;
			}
			var lrsp:Array = iObj.learnerResponse.split(",");
			for (var i:int = 0; i < lrsp.length; i++) {
				setChoice(qidx, int(lrsp[i]));
			}
		}
		
		protected function setToCorrectAnswer(qidx:int = 0):void {
			resetAllChoices(qidx);
			var len:int = _Questions[qidx].numChoices;
			for (var i:int = 0; i < len; i++) {
				if (_Questions[qidx].getChoiceCorrect(i)) {
					setChoice(qidx, i);
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// judging
		
		protected function judgeAll():void {
			if (_Questions[_CurrentQuestion].isCorrect()) {
				trace("right!");
				disableInteraction(false);
				_Questions[_CurrentQuestion].state = Question.STATE_CORRECT;
				_Questions[_CurrentQuestion].stop();
				showCorrectAnswers(_CurrentQuestion);
				_RetryState = false;
				showFeedback(true, false, _Questions[_CurrentQuestion].getCA());
				
				dispatchEvent(new Event(MARK_CORRECT));
				dispatchEvent(new PageStatusEvent(PageStatusEvent.PASSED));
			} else {
				trace("wrong! ...");
				if (_Questions[_CurrentQuestion].nextTry()) {
					_RetryState = true;
					trace("another try left");
					disableInteraction(true);
					showFeedback(false, true, _Questions[_CurrentQuestion].getWA());
				} else {
					trace("no more tries");
					disableInteraction(false);
					_Questions[_CurrentQuestion].state = Question.STATE_WRONG;
					_Questions[_CurrentQuestion].stop();
					_RetryState = false;
					showCorrectAnswers(_CurrentQuestion);
					showFeedback(false, false, _Questions[_CurrentQuestion].getWA());
					
					dispatchEvent(new Event(MARK_WRONG));
					dispatchEvent(new PageStatusEvent(PageStatusEvent.FAILED));
				}
			}
		}
		
		protected function showFeedback(c:Boolean, b:Boolean, t:String):void {
			if (debugMode && standaloneMode) {
				showStandAloneFeedback(c, b, t);
				return;
			}
			
			if (c) showCAPopup(t);
				else showWAPopup(t,b);
		}

		protected function showCAPopup(m:String):void {
			createPopUp(PopUpType.FB_CORRECT, "", m)
		}
		
		protected function showWAPopup(m:String,rtry:Boolean=false):void {
			createPopUp(PopUpType.FB_INCORRECT, "", m)
		}
		
		protected function shownNeutralPopup(m:String):void {
			createPopUp(PopUpType.FB_NEUTRAL, "", m)
		}
		
		// called when the feedback window is closed
		protected function retryFromFeedback():void {
			enableInteraction(_Questions[_CurrentQuestion].resetOnWA);
			// if the retainCAsOnReset flag is set, choices may still be selected after a reset
			updateButtons();
		}

		protected function showCorrectAnswers(q:int):void { }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		
		protected function showStandAloneFeedback(c:Boolean, b:Boolean, t:String) {
			if (_FeedbackBox) removeStandAloneFeedback();
			_FeedbackBox = new Feedback();
			
			if (c) _FeedbackBox.icon_mc.gotoAndStop("correct");
				else _FeedbackBox.icon_mc.gotoAndStop("wrong");
				
			if (!b) _FeedbackBox.retry_btn.visible = false;
			
			_FeedbackBox.text_txt.autoSize = TextFieldAutoSize.LEFT;
			_FeedbackBox.text_txt.wordWrap = true;
			_FeedbackBox.text_txt.multiline = true;
			_FeedbackBox.text_txt.htmlText = t;
			
			var h:int = _FeedbackBox.text_txt.height + 20;
			if (b) h += 10 + _FeedbackBox.retry_btn.height;
			_FeedbackBox.retry_btn.y = _FeedbackBox.text_txt.height + 20;
			if (h < 100) {
				h = 100;
				if (b) _FeedbackBox.retry_btn.y = 100 - 10 - _FeedbackBox.retry_btn.height;
			}
			
			_FeedbackBox.bg_mc.scaleY = h * .01;

			_FeedbackBox.x = (_PageRenderer.pageCenterX - _FeedbackBox.width/2);
			_FeedbackBox.y = _PageRenderer.pageBottom - h;
			
			if (b) _FeedbackBox.retry_btn.addEventListener(MouseEvent.CLICK, onRetryClick);
			
			_PageRenderer.messageLayer.addChild(_FeedbackBox);
			
			if (_Animate) {
				var oy:int = _FeedbackBox.y;
				_FeedbackBox.alpha = 0;
				_FeedbackBox.y -= 50;
				TweenLite.to(_FeedbackBox, 1, { alpha:1, y:oy, ease:Quadratic.easeOut } );
			}
		}
		
		// TODO make more accessible
		protected function onRetryClick(e:Event):void {
			removeStandAloneFeedback();
			retryFromFeedback();
		}
		
		protected function removeStandAloneFeedback():void {
			TweenLite.to(_FeedbackBox, .5, { alpha:0, y:(_FeedbackBox.y + 50), ease:Back.easeIn, onComplete:deleteFeedback } );
		}
		
		protected function deleteFeedback():void {
			_PageRenderer.messageLayer.removeChild(_FeedbackBox);
			if (_FeedbackBox.retry_btn.visible) _FeedbackBox.retry_btn.removeEventListener(MouseEvent.CLICK, onRetryClick);
			_FeedbackBox = null;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		// must be overridden by subclasses
		protected function renderChoices():void { }
		
		// must be overridden by subclasses
		protected function enableChoice(q:int, c:int):void { }
		
		protected function enableAllChoices(q:int, r:Boolean=true):void {
			if(r) resetAllChoices(q);
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				enableChoice(q, i);
			}
		}
		
		// must be overridden by subclasses
		protected function disableChoice(q:int, c:int):void { }
		
		protected function disableAllChoices(q:int):void {
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				disableChoice(q, i);
			}
		}
		
		// must be overridden by subclasses
		protected function setChoice(q:int, c:int):void { }
		
		protected function resetChoice(q:int, c:int):void { }
		
		// hard reset ignores any retain settings from the question
		protected function resetChoiceHard(q:int, c:int):void { }
		
		protected function resetAllChoices(q:int, hard:Boolean=false):void {
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				if (hard) resetChoiceHard(q, i)
					else resetChoice(q, i)
			}
		}
		
		// must be overridden by subclasses
		protected function onChoiceOver(e:Event):void { }
		
		// must be overridden by subclasses
		protected function onChoiceOut(e:Event):void { }
		
		// must be overridden by subclasses
		protected function onChoiceClick(e:Event):void { }
		
		protected function disableInteraction(fade:Boolean = true):void {
			if (debugMode && !standaloneMode) return;
			disableSubmit();
			disableAllQuestions();
			if(fade) TweenLite.to(_PageRenderer.interactionLayer, 5, { alpha:.75, ease:Quadratic.easeIn } );
		}
		
		protected function enableInteraction(f:Boolean=true):void {
			enableAllQuestions(f);
			if(_PageRenderer.interactionLayer.alpha < 1) TweenLite.to(_PageRenderer.interactionLayer, .5, { alpha:1, ease:Quadratic.easeOut } );
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		// must be overridden by subclasses
		protected function configureButtons():void { }
		
		// must be overridden by subclasses
		protected function updateButtons():void {}
		
		// must be overridden by subclasses
		protected function enableSubmit():void { }
		
		// must be overridden by subclasses
		protected function disableSubmit():void { }
		
		// must be overridden by subclasses
		protected function onSubmitClick(e:Event):void { }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// util
		
		protected function enableAllQuestions(f:Boolean=true):void {
			var len:int = _Questions.length;
			for (var i:int = 0; i < len; i++) {
				enableAllChoices(i, f);
			}
		}
		
		protected function disableAllQuestions():void {
			var len:int = _Questions.length;
			for (var i:int = 0; i < len; i++) {
				disableAllChoices(i);
			}
		}
		
		protected function stopAllQuestions():void {
			var len:int = _Questions.length;
			for (var i:int = 0; i < len; i++) {
				_Questions[i].stop();
			}
		}
		
		// for DND types
		protected function getLocalizedMousePoint():Point {
			var mp:Point = new Point(this.stage.mouseX, this.stage.mouseY);
			var lp:Point = _PageRenderer.interactionLayer.globalToLocal(mp);
			//trace("global: " + mp.x + ", " + mp.y);
			//trace("   local: " + lp.x + ", " + lp.y+", dif: "+(mp.x-lp.x)+","+(mp.y-lp.y));
			
			return mp;
		}
		
		protected function showInstructions():void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createInstructionsPopUpXML(PopUpType.SIMPLE, "Instructions", _Questions[_CurrentQuestion].instruction, "", false, false)));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// from player
		
		protected function createPopUp(type:String,t:String, m:String, mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(type, t, m, "", mdl, pmdl, pst)));
		}
		
		protected function message(t:String, m:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.SIMPLE, t, m, "", mdl, pst)));
		}

		protected function createPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_BOTTOM+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		protected function createCentPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_HIGH_MIDDLE+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		protected function createInstructionsPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='intr_instructions' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_RIGHT+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_TOP+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		override public function handlePopUpEvent(e:PopUpEvent):void {
			trace("template from PM, type: " + e.type + ", from: " + e.data + " to: " + e.callingobj + " about: " + e.buttondata);
			trace("retry? " + _RetryState);
			if (_RetryState) retryFromFeedback();
		}
		
		override public function handleKeyPress(k:int, isAlt:Boolean = false, isCtrl:Boolean = false, isShift:Boolean = false, l:int=0):void {
			//trace("template from PM, keycode: " + k + " alt: " + isAlt + " ctrl: " + isCtrl + " shift: " + isShift + " location: " + l);
			// A-z
			if(k >= KeyDict.ALPHA_START && k <= KeyDict.ALPHA_END) {
				var pressed:int = k-KeyDict.ALPHA_START;
				setChoice(_CurrentQuestion, pressed);
			}
			// control + enter
			//if (k == KeyDict.ENTER && isCtrl) onSubmitClick(undefined);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			// destroy interaction specific content in subclasses
			super.destroy();
		}
		
	}
}