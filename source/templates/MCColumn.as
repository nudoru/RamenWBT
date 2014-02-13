/*
Multiple Choice question template

[ ] set interaction object
[ ] resume from interaction object
[ ] access/key support

*/

package {
	
	import com.nudoru.lms.InteractionObject;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	public class MCColumn extends QuestionTemplate {

		public function MCColumn():void {
			super();
			
			headerrow_mc.visible = false;
			scenariomask_mc.visible = false;
			scenario_mc.visible = false;
		}

		// all template specific stuff goes here
		override protected function renderInteraction():void {
			state = STATE_INIT;

			_CurrentQuestion = 0;
			
			// get the XML from the pages' <customcontent> block
			parseQuestions(_PageRenderer.interactionXML);			
			renderChoices();
			configureButtons();
			if (_Questions[_CurrentQuestion].hasScenario()) {
				configureScenario();
				scenario_btn.enabled = true;
				scenario_btn.addEventListener(MouseEvent.CLICK, onShowScenarioClick);
				scenario_mc.close_btn.addEventListener(MouseEvent.CLICK, onCloseScenarioClick);
				scenario_mc.title_txt.htmlText = _Questions[_CurrentQuestion].scenarioTitle;
				scenario_mc.text_txt.htmlText = _Questions[_CurrentQuestion].scenarioText;
				
				if (!_Questions[_CurrentQuestion].showScenarioButton) {
					scenario_btn.visible = false;
				}
				
				showScenario();
			} else {
				scenario_btn.visible = false;
				scenario_btn.enabled = false;
			}
		}
		
		protected function configureScenario():void {
			_PageRenderer.addMCToMessageLayer(scenariomask_mc);
			_PageRenderer.addMCToMessageLayer(scenario_mc);
			
			scenariomask_mc.scaleX = _PageRenderer.pageWidth*.01;
			scenariomask_mc.scaleY = _PageRenderer.pageHeight * .01;
			scenario_mc.x = int(_PageRenderer.pageWidth/2);
			scenario_mc.y = int(_PageRenderer.pageHeight/2);
		}
		
		protected function onShowScenarioClick(e:Event):void {
			showScenario();
		}
		
		protected function onCloseScenarioClick(e:Event):void {
			if(scenario_btn.enabled) closeScenario();
		}
		
		protected function showScenario():void {
			scenariomask_mc.visible = true;
			scenario_mc.visible = true;
			scenariomask_mc.alpha = 0;
			scenario_mc.y = int(_PageRenderer.pageHeight / 2);
			scenario_mc.alpha = 0;
			scenario_mc.scaleX = 2;
			scenario_mc.scaleY = 2;
			scenario_mc.rotation = rnd( -20, 20);
			TweenLite.to(scenariomask_mc, .5, { alpha:1, ease:Quad.easeOut } );
			TweenLite.to(scenario_mc, 1, { alpha:1, scaleX:1, scaleY:1, rotation:rnd( -5, 5), delay:.25, ease:Bounce.easeOut } );
		}
		
		protected function closeScenario():void {
			//scenariomask_mc.visible = false;
			//scenario_mc.visible = false;
			TweenLite.to(scenariomask_mc, 2, { alpha:0, ease:Quad.easeOut, onComplete:onScenarioMaskOutComplete } );
			TweenLite.to(scenario_mc, 1, { alpha:0, y:"500", rotation:rnd( -20, 20), ease:Back.easeIn, onComplete:onScenarioOutComplete } );
		}
		
		protected function onScenarioMaskOutComplete():void {
			scenariomask_mc.visible = false;
		}
		
		protected function onScenarioOutComplete():void {
			scenario_mc.visible = false;
		}
		
		protected function disableScenarioButton():void {
			scenario_btn.enabled = false;
			TweenLite.to(scenario_btn, .5, { alpha:.5, ease:Quad.easeOut } );
			scenario_btn.removeEventListener(MouseEvent.CLICK, onShowScenarioClick);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		override protected function configureButtons():void {
			submit_btn.addEventListener(MouseEvent.CLICK, onSubmitClick);
			disableSubmit();
		}
	
		override protected function enableSubmit():void {
			submit_btn.enabled = true;
			TweenLite.to(submit_btn, .5, { alpha:1, ease:Quad.easeOut } );
			//AccessibilityManager.getInstance().addActivityItem(submit_btn, "Submit button");
		}
		
		override protected function disableSubmit():void {
			submit_btn.enabled = false;
			TweenLite.to(submit_btn, .5, { alpha:.5, ease:Quad.easeOut } );
			//AccessibilityManager.getInstance().removeItemBySprite(submit_btn);
		}
		
		override protected function updateButtons():void {
			if (_Questions[_CurrentQuestion].anyChoicesSelected()) enableSubmit();
				else disableSubmit();
		}
		
		override protected function onSubmitClick(e:Event):void {
			if(submit_btn.enabled) judgeAll();
		}
		
		override protected function showCorrectAnswers(q:int):void {
			disableScenarioButton();
			
			if (!_Questions[q].showAnswers) return;
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				if (_Questions[q].getChoiceType(i) == Choice.HEADER) continue;
				
				var mc:MovieClip = _Questions[q].getChoiceRefMC(i);
				var isC:Boolean = _Questions[q].getChoiceCorrect(i);
				var isS:Boolean = _Questions[q].getChoiceIsSelected(i);
				trace(i + " correct? " + isC + " selected? " + isS);
				if (isC && isS) {
					// correct and selected
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quad.easeOut } );
				} else if (!isC && isS) {
					// not correct and selected
					mc.x_mc.visible = true;
					TweenLite.to(mc.x_mc, .5, { alpha:1, ease:Quad.easeIn } );
				} else if (isC && !isS) {
					// correct AND not selected
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quad.easeIn } );
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			headerrow_mc.visible = true;
			
			headerrow_mc.x = _PageRenderer.getPageCenteredX(700);
			headerrow_mc.y = _PageRenderer.bodyTFBottomY + 20;
			
			var x:int = headerrow_mc.x;
			var y:int = headerrow_mc.y;
			var ySpc:int = 0;
			
			var len:int = _Questions[_CurrentQuestion].numChoices;
			
			for (var i:int = 0; i < len; i++) {
				var c:*;
				
				if(_Questions[_CurrentQuestion].getChoiceType(i) == Choice.HEADER) {
					c = new ChoiceHeader();
					c.x = x;
					c.y = y;
					
					c.text_txt.autoSize = TextFieldAutoSize.CENTER;
					c.text_txt.wordWrap = true;
					c.text_txt.multiline = true;
					c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(i);
					_PageRenderer.changeTextFieldSize(c.text_txt);
					c.bg_mc.scaleY = (c.text_txt.height + ySpc) * .01;
					c.choicebg_mc.scaleY = c.choicebg2_mc.scaleY = (c.text_txt.height + ySpc) * .01;
					c.line_mc.y = (c.text_txt.height + ySpc);
					if (i == len - 1) c.line_mc.visible = false;
				} else {
					c = new ChoiceItem();
					_Questions[_CurrentQuestion].setChoiceCurrentSetMatch(i, -1);
					c.questionIdx = _CurrentQuestion;
					c.choiceIdx = i;
					c.check_mc.visible = false;
					c.check_mc.alpha = 0;
					c.x_mc.visible = false;
					c.x_mc.alpha = 0;
					
					c.x = x;
					c.y = y;
					
					c.text_txt.autoSize = TextFieldAutoSize.LEFT;
					c.text_txt.wordWrap = true;
					c.text_txt.multiline = true;
					c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(i);
					_PageRenderer.changeTextFieldSize(c.text_txt);
				
					c.bg_mc.scaleY = (c.text_txt.height + ySpc) * .01;
					c.choicebg_mc.scaleY = (c.text_txt.height + ySpc) * .01;
					
					c.choice_mc.y = ((c.text_txt.height + ySpc) / 2) - (c.choice_mc.height / 2)+2;
					
					c.check_mc.x = c.choice_mc.x - 18;
					c.x_mc.x = c.choice_mc.x - 17;
					c.check_mc.y = c.x_mc.y = c.choice_mc.y + 2;
					
					c.line_mc.y = (c.text_txt.height + ySpc);
					if (i == len - 1) c.line_mc.visible = false;
					if (i % 2) {
						c.bg_mc.alpha *= .5
						c.choicebg_mc.alpha *= .5
					}
					
					_Questions[_CurrentQuestion].setChoiceRefMC(i, c);
				}
				
				_PageRenderer.interactionLayer.addChild(c);
				
				
				if (_Animate) {
					c.alpha = 0;
					TweenLite.to(c, 1, { alpha:1, delay:(i*.2), ease:Quad.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, i] } );
				} else {
					enableChoice(_CurrentQuestion, i);
				}
				
				y += (c.text_txt.height + ySpc)+1;
			}
			
			headerrow_mc.bg_mc.scaleY = (y-headerrow_mc.y+1) * .01;

			submit_btn.x = headerrow_mc.x+500;
			submit_btn.y = y + 5;
			
			scenario_btn.x = headerrow_mc.x-3;
			scenario_btn.y = submit_btn.y;
		}
		
		override protected function enableChoice(q:int, c:int):void {
			if (_Questions[q].getChoiceType(c) == Choice.HEADER) return;
			
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.check_mc.visible = false;
			mc.check_mc.alpha = 0;
			mc.x_mc.visible = false;
			mc.x_mc.alpha = 0;
			mc.choice_mc.buttonMode = true;
			mc.choice_mc.mouseChildren = false;
			mc.choice_mc.addEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice_mc.addEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice_mc.addEventListener(MouseEvent.CLICK, onChoiceClick);
			//AccessibilityManager.getInstance().addActivityItem(mc, "Question Choice "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableChoice(q:int, c:int):void {
			if (_Questions[q].getChoiceType(c) == Choice.HEADER) return;
			
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.choice_mc.buttonMode = false;
			mc.choice_mc.removeEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice_mc.removeEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice_mc.removeEventListener(MouseEvent.CLICK, onChoiceClick);
			//AccessibilityManager.getInstance().removeItemBySprite(mc);
		}

		override protected function setChoice(q:int, c:int):void {
			trace("setChoice called. use setChoice2");
		}
		
		protected function setChoice2(q:int, c:int, m:int):void {
			// check to see if toggling choice
			if (_Questions[q].getChoiceCurrentSetMatch(c) == m) {
				resetChoiceHard(q, c);
				return;
			}
			_Questions[q].setChoiceIsSelected(c);
			if (m == 0) {
				_Questions[q].getChoiceRefMC(c).choice_mc.gotoAndStop(2);
			} else {
				_Questions[q].getChoiceRefMC(c).choice_mc.gotoAndStop(1);
			}
			updateButtons();
		}
		
		override protected function resetChoice(q:int, c:int):void {
			if (_Questions[q].getChoiceType(c) == Choice.HEADER) return;
			
			if (_Questions[q].retainCAsOnReset) {
				//trace(_Questions[q].getChoiceCorrect(c) +" vs "+ _Questions[q].getChoiceIsSelected(c));
				if(_Questions[q].getChoiceIsCorrect(c) && _Questions[q].getChoiceIsSelected(c)) return;
			}
			_Questions[q].setChoiceNotSelected(c);
			_Questions[q].getChoiceRefMC(c).choice_mc.gotoAndStop(1);
		}
		
		override protected function resetChoiceHard(q:int, c:int):void {
			if (_Questions[q].getChoiceType(c) == Choice.HEADER) return;
			
			_Questions[q].setChoiceNotSelected(c);
			_Questions[q].getChoiceRefMC(c).choice_mc.gotoAndStop(1);
		}
		
		override protected function onChoiceOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quad.easeOut } );
		}
		
		override protected function onChoiceOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quad.easeOut } );
		}
		
		override protected function onChoiceClick(e:Event):void {
			var q:int = ChoiceItem(e.target.parent).questionIdx;
			var c:int = ChoiceItem(e.target.parent).choiceIdx;
			var m:int = e.target.name == "choice_mc" ? 0 : 1;
			setChoice2(q, c, m);
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		protected function killAllChoiceAnimations():void {
			var len:int = _Questions[_CurrentQuestion].numChoices;
			for (var i:int = 0; i < len; i++) {
				TweenLite.killTweensOf(_Questions[_CurrentQuestion].getChoiceRefMC(i));
			}
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			killAllChoiceAnimations();
			// destroy interaction specific content
			submit_btn.removeEventListener(MouseEvent.CLICK, onSubmitClick);
			disableAllQuestions();
			stopAllQuestions();

			super.destroy();
		}
		
	}
}