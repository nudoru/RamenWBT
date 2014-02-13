/*
Simple Sorting question template

*/

package {
	
	import com.adobe.errors.IllegalStateError;
	import com.nudoru.lms.InteractionObject;
	import flash.geom.Rectangle;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class SortingText extends QuestionTemplate {

		protected var Matches			:Array;
		
		public function SortingText():void {
			super();
			
			submit_btn.visible = false;
			reset_btn.visible = false;
			// renderInteraction() is called in the super
			// calls renderChoices() and configureButtons() then the interaction begins
		}

		// called when the feedback window is closed
		override protected function retryFromFeedback():void {
			enableInteraction(_Questions[_CurrentQuestion].resetOnWA);
			// if the retainCAsOnReset flag is set, choices may still be selected after a reset
			updateButtons();
			// if retaining CAs need to clean up since items may have been removed
			cleanUpMatchColumns();
		}
	
		//----------------------------------------------------------------------------------------------------------------------------------
		// on init state set
		
		override protected function resetQuestionToLastAnsweredIntrObj(qidx:int=0):void {
			var iObj:InteractionObject = _Questions[qidx].getInteractionObject();
			if (!iObj) {
				trace("$$$ error, prev state interaction object not returned");
				return;
			}
			//1[.]b[,]2[.]a[,]3[.]d[,]4[.]c
			var lrsp:Array = iObj.learnerResponse.split("[,]");
			//var lrsp:Array = String("1[.]a[,]2[.]a[,]3[.]b[,]4[.]a").split("[,]");
			for (var i:int = 0; i < lrsp.length; i++) {
				//trace("setting: " + lrsp[i]);
				var mat:Array = lrsp[i].split("[.]");
				_Questions[qidx].getChoiceRefMC(mat[0] - 1).setToOrigionalProps();
				setChoiceToMatch(qidx, mat[0]-1, _Questions[qidx].getLetterIndex(mat[1]), false);
				enableAllChoices(qidx, false);
				updateButtons();
			}
		}
		
		override protected function setToCorrectAnswer(qidx:int = 0):void {
			var len:int = _Questions[qidx].numChoices;
			for (var i:int = 0; i < len; i++) {
				_Questions[qidx].getChoiceRefMC(i).setToOrigionalProps()
				setChoiceToCorrectMatch(qidx, i, false);
				enableAllChoices(qidx, false);
				updateButtons();
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		override protected function configureButtons():void {
			//submit_btn.x = _PageRenderer.pageCenterX - (submit_btn.width/2);
			//submit_btn.y = _PageRenderer.pageBottom - submit_btn.height - (_PageRenderer.pageBorderBottom*2);
			submit_btn.visible = true;
			reset_btn.visible = true;
			submit_btn.addEventListener(MouseEvent.CLICK, onSubmitClick);
			reset_btn.addEventListener(MouseEvent.CLICK, onResetClick);
			disableSubmit();
			disableReset();
			
			//resetQuestionToLastAnsweredIntrObj();
		}
	
		override protected function updateButtons():void {
			if (!areThereAnyMatches(_CurrentQuestion)) disableReset();
				else enableReset();
			if (areAllMatched(_CurrentQuestion)) enableSubmit();
				else disableSubmit();
		}
		
		override protected function enableSubmit():void {
			submit_btn.enabled = true;
			TweenLite.to(submit_btn, .5, { alpha:1, ease:Quadratic.easeOut } );
			//AccessibilityManager.getInstance().addActivityItem(submit_btn, "Submit activity");
		}
		
		override protected function disableSubmit():void {
			submit_btn.enabled = false;
			TweenLite.to(submit_btn, .5, { alpha:.5, ease:Quadratic.easeOut } );
			//AccessibilityManager.getInstance().removeItemBySprite(submit_btn);
		}
		
		override protected function onSubmitClick(e:Event):void {
			if(submit_btn.enabled) judgeAll();
		}
		
		protected function enableReset():void {
			reset_btn.enabled = true;
			TweenLite.to(reset_btn, .5, { alpha:1, ease:Quadratic.easeOut } );
			//AccessibilityManager.getInstance().addActivityItem(reset_btn, "Reset activity");
		}
		
		protected function disableReset():void {
			reset_btn.enabled = false;
			TweenLite.to(reset_btn, .5, { alpha:.5, ease:Quadratic.easeOut } );
			//AccessibilityManager.getInstance().removeItemBySprite(reset_btn);
		}
		
		protected function onResetClick(e:Event):void {
			if (reset_btn.enabled) { 
				resetAllChoices(_CurrentQuestion, true);
				cleanUpMatchColumns();
			}
		}
		
		// called from judge function in super
		override protected function showCorrectAnswers(q:int):void {
			if (!_Questions[q].showAnswers) return;
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				var mc:MovieClip = _Questions[q].getChoiceRefMC(i);
				var isC:Boolean = _Questions[q].isChoiceOnMatch(i);
				if (isC) {
					// correct
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
				} else if (!isC) {
					// not correct
					mc.x_mc.visible = true;
					TweenLite.to(mc.x_mc, .5, { alpha:1, ease:Quadratic.easeIn } );
					setChoiceToCorrectMatch(q, i)
				}
			}
		}
		
		protected function setChoiceToCorrectMatch(q:int, c:int, a:Boolean = true):void {
			trace("set choice to correct match");
			var ci:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			var mi:MatchItem = _Questions[q].getMatchRefMC(c);
			if (!mi) return;
			_Questions[q].setChoiceCurrentSetMatch(c, mi.choiceIdx);
			_Questions[q].removeItemFromAllMatches(c);
			_Questions[q].addItemToMatch(mi.choiceIdx, c);
			cleanUpMatchColumns(a);
			//updateButtons();
		}

		protected function setChoiceToMatch(q:int, c:int, m:int, a:Boolean = true):void {
			//trace("set choice "+c+" to match "+m);
			var ci:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			var mi:MatchItem = _Questions[q].getMatchRefMC(m);
			if (!mi) return;
			//trace("set choice "+c+" to match ["+m+"]"+mi.choiceIdx);
			_Questions[q].setChoiceCurrentSetMatch(c, m);
			_Questions[q].removeItemFromAllMatches(c);
			_Questions[q].addItemToMatch(m, c);
			cleanUpMatchColumns(a);
			//updateButtons();
		}
		
		override protected function disableInteraction(fade:Boolean = true):void {
			if (debugMode && !standaloneMode) return;
			disableSubmit();
			disableReset();
			disableAllQuestions();
			if(fade) TweenLite.to(_PageRenderer.interactionLayer, 5, { alpha:.5, ease:Quadratic.easeIn } );
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			
			var choiceColX:int = _Questions[_CurrentQuestion].choiceColumnX;
			var choiceColY:int = _Questions[_CurrentQuestion].choiceColumnY;
			var choiceColWidth:int = _Questions[_CurrentQuestion].choiceColumnWidth;
			var choiceColYSpc:int = _Questions[_CurrentQuestion].choiceColumnHeight;
			
			var matchColX:int = _Questions[_CurrentQuestion].matchColumnX;
			var matchColY:int = _Questions[_CurrentQuestion].matchColumnY;
			var matchColWidth:int = _Questions[_CurrentQuestion].matchColumnWidth;
			var matchColHeight:int = _Questions[_CurrentQuestion].matchColumnHeight;
			var matchColXSpc:int = _Questions[_CurrentQuestion].matchColumnSpacingX;
			
			var tCols:int = _Questions[_CurrentQuestion].numMatches + 1;
			
			if (!choiceColX) choiceColX = _PageRenderer.getPageDivColumnLocations(tCols)[0]+10;
			if (!choiceColY) choiceColY = _PageRenderer.bodyTFBottomY + 30;
			if (!choiceColWidth) choiceColWidth = _PageRenderer.getPageColumnWidthDiv(tCols)-30;
			if (!choiceColYSpc) choiceColYSpc = 5;

			if (!matchColX) matchColX = _PageRenderer.getPageDivColumnLocations(tCols)[1];
			if (!matchColY) matchColY = _PageRenderer.bodyTFBottomY + 40;
			if (!matchColWidth) matchColWidth = _PageRenderer.getPageColumnWidthDiv(tCols);
			if (!matchColHeight) {
				matchColHeight = submit_btn.y - matchColY - 10;
				if(Settings.getInstance().zoomFactor > 0) {
					// only if zoomed: allow 60px height per choice item - enough for each to fit under once choice optimally
					var dh:int = _Questions[_CurrentQuestion].numChoices * 60;
					if (matchColHeight < dh) matchColHeight = dh;
				}
			}
			if (!matchColXSpc) matchColXSpc = _PageRenderer.pageColumnGutter;
			
			var cY:int = choiceColY;
			var mX:int = matchColX;
			
			Matches = new Array();
			
			// render matches
			for (var k:int = 0; k < _Questions[_CurrentQuestion].numMatches; k++) {
				var m:MatchItem = new MatchItem();
				m.questionIdx = _CurrentQuestion;
				m.choiceIdx = k;
				m.matchIdx = k;
				m.displayIdx = k;
				
				m.x = mX;
				m.y = matchColY;
				
				m.text_txt.width = matchColWidth;
				m.text_txt.autoSize = TextFieldAutoSize.LEFT;
				m.text_txt.wordWrap = true;
				m.text_txt.multiline = true;
				m.text_txt.text = _Questions[_CurrentQuestion].getMatchText(k);
				
				_PageRenderer.changeTextFieldSize(m.text_txt);

				m.text_txt.y = int(m.text_txt.height) * -1;
				m.bg_mc.scaleX = matchColWidth * .01;
				m.bg_mc.scaleY = matchColHeight * .01;
				
				_PageRenderer.interactionLayer.addChild(m);
				
				_Questions[_CurrentQuestion].setMatchMCRef(k, m);

				Matches.push(m);
				
				mX += matchColXSpc + matchColWidth;
			}

			var cArry:Array = _Questions[_CurrentQuestion].getChoiceIndexesArray();
			if (_Questions[_CurrentQuestion].randomizeChoices) cArry = _Questions[_CurrentQuestion].getRandomizedChoiceIndexesArray();
			
			// render choices
			for (var i:int = 0; i < cArry.length; i++) {
				var c:ChoiceItem = new ChoiceItem();
				_Questions[_CurrentQuestion].setChoiceCurrentSetMatch(i, -1);
				c.questionIdx = _CurrentQuestion;
				c.choiceIdx = cArry[i];
				c.matchIdx = _Questions[_CurrentQuestion].getMatchIndexForChoice(cArry[i]);
				c.displayIdx = cArry[i];
				
				c.x = choiceColX;
				c.y = cY;
				c.setOrigionalProps();
				
				c.hi_mc.alpha = 0;
				c.text_txt.width = choiceColWidth-10;
				c.text_txt.autoSize = TextFieldAutoSize.LEFT;
				c.text_txt.wordWrap = true;
				c.text_txt.multiline = true;
				c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(cArry[i]);
				c.text_txt.width = c.text_txt.textWidth + 10;
				
				_PageRenderer.changeTextFieldSize(c.text_txt);
				
				if (_Questions[_CurrentQuestion].autoSizeParts) {
					var tw:int = c.text_txt.textWidth + 20;
					c.bg_mc.scaleX = tw * .01;
					c.hi_mc.scaleX = (4 + tw) * .01;
				} else {
					c.bg_mc.scaleX = (choiceColWidth) * .01;
					c.hi_mc.scaleX = (choiceColWidth+4) * .01;
				}
				
				c.bg_mc.scaleY = (10+c.text_txt.height) * .01;
				c.hi_mc.scaleY = (14+c.text_txt.height) * .01;

				c.check_mc.visible = c.x_mc.visible = false;
				c.check_mc.alpha = c.x_mc.alpha = 0;
				c.check_mc.x = (c.bg_mc.scaleX*100) - 16;
				c.check_mc.x = (c.bg_mc.scaleX*100) + c.bg_mc.x - 16;
				c.x_mc.x = (c.bg_mc.scaleX*100) + c.bg_mc.x - 13;
				c.check_mc.y = c.x_mc.y = (c.bg_mc.scaleY*100) + c.bg_mc.y -14;
				
				_PageRenderer.interactionLayer.addChild(c);
				_Questions[_CurrentQuestion].setChoiceRefMC(cArry[i], c);
				_Questions[_CurrentQuestion].setMatchRefMC(cArry[i], _Questions[_CurrentQuestion].getMatchMCRefForChoice(cArry[i]));
				
				if (_Animate) {
					c.alpha = 0;
					c.y -= 50;
					TweenLite.to(c, 1, { alpha:1, y:cY, delay:(i*.5), ease:Quadratic.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, cArry[i]] } );
				} else {
					enableChoice(_CurrentQuestion, cArry[i]);
				}
				
				cY += choiceColYSpc + (c.bg_mc.scaleY*100);
			}
			
			if (_PageRenderer.interactionLayerHeight > submit_btn.y) {
				submit_btn.y = reset_btn.y = _PageRenderer.interactionLayerHeight + 20;
			}
			
		}
		
		override protected function enableChoice(q:int, c:int):void {
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.check_mc.visible = false;
			mc.check_mc.alpha = 0;
			mc.x_mc.visible = false;
			mc.x_mc.alpha = 0;
			mc.buttonMode = true;
			mc.mouseChildren = false;
			mc.addEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.addEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.addEventListener(MouseEvent.MOUSE_DOWN, onChoiceDown);
			mc.addEventListener(MouseEvent.MOUSE_UP, onChoiceUp);
			//AccessibilityManager.getInstance().addActivityItem(mc, "Question Choice "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableChoice(q:int, c:int):void {
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.buttonMode = false;
			mc.removeEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.removeEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.removeEventListener(MouseEvent.MOUSE_DOWN, onChoiceDown);
			mc.removeEventListener(MouseEvent.MOUSE_UP, onChoiceUp);
			//AccessibilityManager.getInstance().removeItemBySprite(mc);
		}

		override protected function setChoice(q:int, c:int):void {
			if (c > (_Questions[q].numChoices - 1) || c < 0) return;			
			if (_Questions[q].subtype == RamenInteractionType.MC_MULTI_SELECT) {
				if (_Questions[q].getChoiceIsSelected(c)) {
					_Questions[q].setChoiceNotSelected(c);
					_Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("multi_normal");
				} else {
					_Questions[q].setChoiceIsSelected(c);
					_Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("multi_selected");
				}
			} else {
				resetAllChoices(q);
				_Questions[q].setChoiceIsSelected(c);
				_Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("selected");
			}
			if (_Questions[q].anyChoicesSelected()) enableSubmit();
				else disableSubmit();
		}

		override protected function onChoiceOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		protected function onChoiceDown(e:Event):void {
			TweenLite.killTweensOf(e.target);
			_PageRenderer.interactionLayer.setChildIndex(e.target as DisplayObject, _PageRenderer.interactionLayer.numChildren-1);
			e.target.startDrag(false, new Rectangle(0,0,(_PageRenderer.pageWidth-e.target.bg_mc.width),(_PageRenderer.actualPageHeight-e.target.bg_mc.height)));
			TweenLite.to(e.target.hi_mc, .25, { alpha:.5, ease:Quadratic.easeOut } );
		}
		
		protected function onChoiceUp(e:Event):void {
			var q:int = ChoiceItem(e.target).questionIdx;
			var c:int = ChoiceItem(e.target).choiceIdx;
			e.target.stopDrag();
			TweenLite.to(e.target.hi_mc, .5, { alpha:.25, ease:Quadratic.easeOut } );
			checkChoiceDrop(q, c);
		}

		protected function checkChoiceDrop(q:int, c:int):void {
			if (!_Questions[q].getMatchUnderChoiceRefMC(c)) resetChoice(q, c);
			var isCorrect:Boolean = _Questions[q].isChoiceOnMatch(c);
			if (isCorrect || _Questions[q].allowIncorrectMatches) {
				setChoiceToCurrentMatch(q, c);
			} else {
				resetChoice(q, c);
			}
		}

		override protected function resetChoice(q:int, c:int):void {
			if (_Questions[q].retainCAsOnReset && _Questions[q].isChoiceOnMatch(c)) return;
			
			var ci:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].removeItemFromAllMatches(c);
			TweenLite.to(ci, .75, { x:ci.origionalXPos, y:ci.origionalYPos, ease:Elastic.easeOut } );
			updateButtons();
		}
		
		override protected function resetChoiceHard(q:int, c:int):void {
			var ci:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].removeItemFromAllMatches(c);
			TweenLite.to(ci, .75, { x:ci.origionalXPos, y:ci.origionalYPos, ease:Elastic.easeOut } );
			updateButtons();
		}
		
		protected function setChoiceToCurrentMatch(q:int, c:int):void {
			var ci:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			var mi:MatchItem = _Questions[q].getMatchUnderChoiceRefMC(c);
			if (!mi) return;
			_Questions[q].setChoiceCurrentSetMatch(c, mi.choiceIdx);
			_Questions[q].removeItemFromAllMatches(c);
			_Questions[q].addItemToMatch(mi.choiceIdx, c);
			cleanUpMatchColumns();
			updateButtons();
		}
		
		protected function cleanUpMatchColumns(a:Boolean = true):void {
			for (var i:int = 0; i < Matches.length; i++) {
				arrangeItemsOnMatch(i,a);
			}
		}
		
		protected function arrangeItemsOnMatch(m:int, a:Boolean = true):void {
			var q:int = _CurrentQuestion;
			var mi:MatchItem = Matches[m];
			var items:Array = _Questions[q].getMatchItems(m);
			var ySpc:int = 5;
			var y:int = mi.y + 10;
			for (var i:int = 0; i < items.length; i++) {
				var ci:ChoiceItem = _Questions[q].getChoiceRefMC(items[i]);
				var x:int = mi.x + (mi.bg_mc.width / 2) - (ci.bg_mc.width / 2) + 5;
				TweenLite.killTweensOf(ci);
				if (a) {
					TweenLite.to(ci, .5, { x:x, y:y, ease:Quadratic.easeOut } );
				} else {
					ci.x = x;
					ci.y = y;
				}
				y += ySpc + ci.bg_mc.height;
			}
			//TweenLite.to(mi.number_mc, .25, { y:y - mi.y, ease:Quadratic.easeOut } );
		}
		
		protected function removeChoicesOnMatch(q:int, mi:MatchItem):void {
			for (var i:int = 0; i < _Questions[q].numChoices; i++) {
				if (_Questions[q].doesChoiceHitMatch(i, mi)) resetChoice(q, i);
			}
		}

		protected function areThereAnyMatches(q:int):Boolean {
			var cntr:int = 0;
			for (var i:int = 0; i < _Questions[q].numChoices; i++) {
				if (_Questions[q].getChoiceCurrentSetMatch(i) != -1) cntr++;
			}
			return (cntr > 0);
		}
		
		protected function areAllMatched(q:int):Boolean {
			for (var i:int = 0; i < _Questions[q].numChoices; i++) {
				if (_Questions[q].getChoiceCurrentSetMatch(i) == -1) return false;
			}
			return true
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		protected function killAllChoiceAnimations():void {
			var len:int = _Questions[_CurrentQuestion].numChoices;
			for (var i:int = 0; i < len; i++) {
				TweenLite.killTweensOf(_Questions[_CurrentQuestion].getChoiceRefMC(i));
			}
		}
		
		protected function killMatchesArray():void {
			for (var i:int = 0; i < Matches.length; i++) {
				Matches[i] = null;
			}
			Matches = new Array();
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			killAllChoiceAnimations();
			killMatchesArray();
			// destroy interaction specific content
			submit_btn.removeEventListener(MouseEvent.CLICK, onSubmitClick);
			reset_btn.removeEventListener(MouseEvent.CLICK, onResetClick);
			disableAllQuestions();
			stopAllQuestions();

			super.destroy();
		}
		
	}
}