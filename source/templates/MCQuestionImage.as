/*
Multiple Choice question template

[ ] on resume from prev answer, show previous answer, but don't allow changes. allow submit to see feedback

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
	import fl.motion.easing.*;
	
	public class MCQuestionImage extends QuestionTemplate {

		private var ImageAssets			:Array;
		
		public function MCQuestionImage():void {
			super();
			
			ImageAssets = new Array();
			submit_btn.visible = false;
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		override protected function configureButtons():void {
			submit_btn.visible = true;
			submit_btn.addEventListener(MouseEvent.CLICK, onSubmitClick);
			disableSubmit();
		}
	
		override protected function enableSubmit():void {
			submit_btn.enabled = true;
			TweenLite.to(submit_btn, .5, { alpha:1, ease:Quadratic.easeOut } );
			//AccessibilityManager.getInstance().addActivityItem(submit_btn, "Submit button");
		}
		
		override protected function disableSubmit():void {
			submit_btn.enabled = false;
			TweenLite.to(submit_btn, .5, { alpha:.5, ease:Quadratic.easeOut } );
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
			if (!_Questions[q].showAnswers) return;
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				var mc:MovieClip = _Questions[q].getChoiceRefMC(i);
				var isC:Boolean = _Questions[q].getChoiceCorrect(i);
				var isS:Boolean = _Questions[q].getChoiceIsSelected(i);
				if (isC && isS) {
					// correct and selected
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
				} else if (!isC && isS) {
					// not correct and selected
					mc.x_mc.visible = true;
					TweenLite.to(mc.x_mc, .5, { alpha:1, ease:Quadratic.easeIn } );
				} else if (isC && !isS) {
					// correct AND not selected
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quadratic.easeIn } );
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			var x:int = _Questions[_CurrentQuestion].questionX;
			var y:int = _Questions[_CurrentQuestion].questionY;
			var cWidth:int = _Questions[_CurrentQuestion].questionWidth;
			if (!x) x = _PageRenderer.pageBorderLeft + 50;
			if (!y) y = _PageRenderer.bodyTFBottomY + 30;
			if (!cWidth) cWidth = 500;
			
			var xGutter:int = 10;
			var ySpc:int = 10;
			var len:int = _Questions[_CurrentQuestion].numChoices;
			
			var cArry:Array = _Questions[_CurrentQuestion].getChoiceIndexesArray();
			if (_Questions[_CurrentQuestion].randomizeChoices) cArry = _Questions[_CurrentQuestion].getRandomizedChoiceIndexesArray();
			
			for (var i:int = 0; i < len; i++) {
				var c:ChoiceItem = new ChoiceItem();
				c.questionIdx = _CurrentQuestion;
				c.choiceIdx = cArry[i];
				c.radio_mc.gotoAndStop("normal");
				c.check_mc.visible = false;
				c.check_mc.alpha = 0;
				c.x_mc.visible = false;
				c.x_mc.alpha = 0;
				
				c.x = x;
				c.y = y;
				
				var imgWidth = 0;
				var imgHeight = 0;
				
				if(_Questions[_CurrentQuestion].getChoiceImageURL(cArry[i])) {
					var il:ImageLoader = new ImageLoader(_Questions[_CurrentQuestion].getChoiceImageURL(cArry[i]), c.imageloader_mc, {x:0,y:0,width:_Questions[_CurrentQuestion].getChoiceImageWidth(cArry[i]),height:_Questions[_CurrentQuestion].getChoiceImageHeight(cArry[i])});
					ImageAssets.push(il);
					imgWidth = _Questions[_CurrentQuestion].getChoiceImageWidth(cArry[i]);
					imgHeight = _Questions[_CurrentQuestion].getChoiceImageHeight(cArry[i]);
				} else {
					c.imageloader_mc.visible = false
				}
				
				if (_Questions[_CurrentQuestion].subtype == RamenInteractionType.MC_MULTI_SELECT) c.radio_mc.gotoAndStop("multi_normal");
				c.hi_mc.alpha = 0;
				c.text_txt.width = cWidth;
				c.text_txt.autoSize = TextFieldAutoSize.LEFT;
				c.text_txt.wordWrap = true;
				c.text_txt.multiline = true;
				c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(cArry[i]);
				c.letter_txt.text = "";// LETTER_LIST[i].toUpperCase() + ".";
				_PageRenderer.changeTextFieldSize(c.text_txt);
				
				if (_Questions[_CurrentQuestion].autoSizeParts) c.text_txt.width = c.text_txt.textWidth+5;
				
				//c.hi_mc.scaleX = (c.text_txt.x + c.text_txt.width+5) * .01;
				//c.hi_mc.scaleY = c.text_txt.height * .01;

				if (imgWidth > 0) {
					//c.hi_mc.x += imgWidth + xGutter;
					c.letter_txt.x += imgWidth + xGutter;
					c.radio_mc.x += imgWidth + xGutter;
					c.text_txt.x += imgWidth + xGutter;
				}
				
				if (imgHeight > c.text_txt.height) {
					c.letter_txt.y = (imgHeight / 2) - (c.letter_txt.height / 2);
					c.radio_mc.y = (imgHeight / 2) - (c.radio_mc.height / 2);
					c.text_txt.y = (imgHeight / 2) - (c.text_txt.height / 2);
				}
				
				var cHeight:int = (imgHeight > c.text_txt.height ? imgHeight : c.text_txt.height);
				
				c.hi_mc.scaleX = (c.text_txt.x + c.text_txt.width+5) * .01;
				c.hi_mc.scaleY = (cHeight) * .01;
				
				c.bg_mc.scaleX = (c.text_txt.x + c.text_txt.width+11) * .01;
				c.bg_mc.scaleY = (cHeight + 6) * .01;
				
				_PageRenderer.interactionLayer.addChild(c);
				_Questions[_CurrentQuestion].setChoiceRefMC(cArry[i], c);
				
				if (_Animate) {
					c.alpha = 0;
					//c.y -= 50;
					//TweenLite.to(c, 1, { alpha:1, y:y, delay:(i*.5), ease:Quadratic.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, i] } );
					c.x -= 500;
					TweenLite.to(c, 2, { alpha:1, x:x, delay:(i*.5), ease:Back.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, i] } );
				} else {
					enableChoice(_CurrentQuestion, i);
				}
				
				y += ySpc + cHeight;
			}
			
			submit_btn.x = _PageRenderer.pageCenterX - (submit_btn.width/2);
			submit_btn.y = y+ySpc; // _PageRenderer.pageBottom - submit_btn.height - (_PageRenderer.pageBorderBottom * 2);
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
			mc.addEventListener(MouseEvent.CLICK, onChoiceClick);
			//AccessibilityManager.getInstance().addActivityItem(mc, "Question Choice "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableChoice(q:int, c:int):void {
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.buttonMode = false;
			mc.removeEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.removeEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.removeEventListener(MouseEvent.CLICK, onChoiceClick);
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
				resetAllChoices(q, true); // hard reset
				_Questions[q].setChoiceIsSelected(c);
				_Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("selected");
			}
			updateButtons();
		}
		
		override protected function resetChoice(q:int, c:int):void {
			if (_Questions[q].retainCAsOnReset) {
				//trace(_Questions[q].getChoiceCorrect(c) +" vs "+ _Questions[q].getChoiceIsSelected(c));
				if(_Questions[q].getChoiceCorrect(c) && _Questions[q].getChoiceIsSelected(c)) return;
			}
			_Questions[q].setChoiceNotSelected(c);
			if (_Questions[q].subtype == RamenInteractionType.MC_MULTI_SELECT) _Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("multi_normal");
					else _Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("normal");
		}
		
		override protected function resetChoiceHard(q:int, c:int):void {
			_Questions[q].setChoiceNotSelected(c);
			if (_Questions[q].subtype == RamenInteractionType.MC_MULTI_SELECT) _Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("multi_normal");
					else _Questions[q].getChoiceRefMC(c).radio_mc.gotoAndStop("normal");
		}
		
		override protected function onChoiceOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceClick(e:Event):void {
			var q:int = ChoiceItem(e.target).questionIdx;
			var c:int = ChoiceItem(e.target).choiceIdx;
			setChoice(q, c);
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		protected function killAllChoiceAnimations():void {
			var len:int = _Questions[_CurrentQuestion].numChoices;
			for (var i:int = 0; i < len; i++) {
				TweenLite.killTweensOf(_Questions[_CurrentQuestion].getChoiceRefMC(i));
			}
		}
		
		protected function unloadImages():void {
			for (var i:int = 0; i < ImageAssets.length; i++) {
				ImageAssets[i].destroy();
			}
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			killAllChoiceAnimations();
			unloadImages();
			// destroy interaction specific content
			submit_btn.removeEventListener(MouseEvent.CLICK, onSubmitClick);
			disableAllQuestions();
			stopAllQuestions();

			super.destroy();
		}
		
	}
}