/*

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
	
	public class MultipleLikert extends QuestionTemplate {

		public function MultipleLikert():void {
			super();
			
			headerrow_mc.visible = false;
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		override protected function configureButtons():void {
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
			if (_Questions[_CurrentQuestion].allChoicesSelected()) enableSubmit();
				else disableSubmit();
		}
		
		override protected function onSubmitClick(e:Event):void {
			if(submit_btn.enabled) judgeAll();
		}
		
		override protected function showCorrectAnswers(q:int):void {
			if (!_Questions[q].showAnswers) return;
			var len:int = _Questions[q].numChoices;
			for (var i:int = 0; i < len; i++) {
				var mc:ChoiceItem = _Questions[q].getChoiceRefMC(i);
				var isC:Boolean = _Questions[q].getChoiceIsCorrect(i);
				if (isC) {
					mc.check_mc.visible = true;
					TweenLite.to(mc.check_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
				} else {
					//mc.x_mc.visible = true;
					//TweenLite.to(mc.x_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
					mc.slider_mc.setToPosition(_Questions[q].getCorrectSelectionIdxForChoice(i));
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			headerrow_mc.visible = true;
			
			headerrow_mc.x = _PageRenderer.getPageCenteredX(700);
			headerrow_mc.y = _PageRenderer.bodyTFBottomY + 10;
			headerrow_mc.alpha = .5;
			
			var x:int = headerrow_mc.x;
			var y:int = headerrow_mc.y;
			var ySpc:int = 10;
			
			var sData:Array = _Questions[_CurrentQuestion].selectionData;
			
			var len:int = _Questions[_CurrentQuestion].numChoices;
			
			var mArry:Array = _Questions[_CurrentQuestion].getChoiceIndexesArray();
			if (_Questions[_CurrentQuestion].randomizeChoices) mArry = _Questions[_CurrentQuestion].getRandomizedChoiceIndexesArray();
			
			for (var i:int = 0; i < len; i++) {
				var c:ChoiceItem = new ChoiceItem();
				_Questions[_CurrentQuestion].setChoiceCurrentSetMatch(mArry[i], -1);
				c.questionIdx = _CurrentQuestion;
				c.choiceIdx = mArry[i];
				c.check_mc.visible = false;
				c.check_mc.alpha = 0;
				c.x_mc.visible = false;
				c.x_mc.alpha = 0;
				
				c.x = x;
				c.y = y;
				
				c.text_txt.autoSize = TextFieldAutoSize.LEFT;
				c.text_txt.wordWrap = true;
				c.text_txt.multiline = true;
				c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(mArry[i]);
				_PageRenderer.changeTextFieldSize(c.text_txt);

				c.slider_mc.initialize(String(mArry[i]), sData);
				c.slider_mc.addEventListener(LikertSlider.CHANGE, onSliderChange);
				c.slider_mc.enable = false;
				
				var lineHeight:int = c.text_txt.height + ySpc;
				if (lineHeight < (c.slider_mc.height + ySpc)) {
					lineHeight = (c.slider_mc.height + ySpc);
					c.text_txt.y = int((lineHeight/2)-(c.text_txt.height/2));
				} else {
					trace((lineHeight / 2) + " " + (c.slider_mc.height / 2) + " = " + int((lineHeight / 2) - (c.slider_mc.height / 2)));
					c.slider_mc.y = int((lineHeight/2)-(c.slider_mc.height/2))+10;
				}
				
				c.bg_mc.scaleY = lineHeight * .01;
				c.choicebg_mc.scaleY = lineHeight * .01;

				c.check_mc.y = c.x_mc.y = int((lineHeight/2)-(c.check_mc.height/2));;
				
				c.line_mc.y = lineHeight;
				
				if (i == len - 1) c.line_mc.visible = false;
				if (i % 2) {
					c.bg_mc.alpha *= .25
					c.choicebg_mc.alpha *= .25
				}
				
				_PageRenderer.interactionLayer.addChild(c);
				_Questions[_CurrentQuestion].setChoiceRefMC(mArry[i], c);
				
				if (_Animate) {
					c.alpha = 0;
					TweenLite.to(c, 1, { alpha:1, delay:(i*.2), ease:Quadratic.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, mArry[i]] } );
				} else {
					enableChoice(_CurrentQuestion, mArry[i]);
				}
				
				y += lineHeight+1;
			}
			
			headerrow_mc.bg_mc.scaleY = (y-headerrow_mc.y+1) * .01;

			submit_btn.x = headerrow_mc.x+240;
			submit_btn.y = y+10;
		}
		
		protected function onSliderChange(e:Event):void {
			//trace(e.target.id + " = " + _Questions[_CurrentQuestion].selectionData[e.target.currentPosition].data);
			var q:int = 0;
			var c:int = int(e.target.id);
			var m:int = e.target.currentPosition;
			setChoice2(q, c, m);
		}
		
		override protected function enableChoice(q:int, c:int):void {
			var mc:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			mc.check_mc.visible = false;
			mc.check_mc.alpha = 0;
			mc.x_mc.visible = false;
			mc.x_mc.alpha = 0;
			mc.slider_mc.enable = true;
			setChoice2(q, c, mc.slider_mc.currentPosition);
			//AccessibilityManager.getInstance().addActivityItem(mc, "Question Choice "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableChoice(q:int, c:int):void {
			var mc:ChoiceItem = _Questions[q].getChoiceRefMC(c);
			mc.slider_mc.enable = false;
			//AccessibilityManager.getInstance().removeItemBySprite(mc);
		}

		override protected function setChoice(q:int, c:int):void {
			//
		}
		
		protected function setChoice2(q:int, c:int, m:int):void {
			_Questions[q].setChoiceCurrentSetMatch(c, m);
			_Questions[q].setChoiceIsSelected(c);
			updateButtons();
		}
		
		/*override protected function resetChoice(q:int, c:int):void {
			if (_Questions[q].retainCAsOnReset) {
				//trace(_Questions[q].getChoiceCorrect(c) +" vs "+ _Questions[q].getChoiceIsSelected(c));
				if(_Questions[q].getChoiceIsCorrect(c) && _Questions[q].getChoiceIsSelected(c)) return;
			}
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].setChoiceNotSelected(c);
			//
		}
		
		override protected function resetChoiceHard(q:int, c:int):void {
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].setChoiceNotSelected(c);
			//
		}*/
		
		/*override protected function onChoiceOver(e:Event):void {
			//TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceOut(e:Event):void {
			//TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceClick(e:Event):void {
			var q:int = ChoiceItem(e.target.parent).questionIdx;
			var c:int = ChoiceItem(e.target.parent).choiceIdx;
			var m:int = e.target.name == "choice1_mc" ? 0 : 1;
			setChoice(q, c);
		}*/

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