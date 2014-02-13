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
	import fl.motion.easing.*;
	
	public class BinaryColumn extends QuestionTemplate {

		public function BinaryColumn():void {
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
				var mc:MovieClip = _Questions[q].getChoiceRefMC(i);
				var isC:Boolean = _Questions[q].getChoiceIsCorrect(i);
				var smatch:int = _Questions[q].getChoiceCurrentSetMatch(i);
				//trace(isC +" " + smatch);
				if (isC && smatch == 0) {
					mc.check1_mc.visible = true;
					TweenLite.to(mc.check1_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
				} else if (isC && smatch == 1) {
					mc.check2_mc.visible = true;
					TweenLite.to(mc.check2_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
				}
				if (!isC && smatch == 0) {
					mc.x1_mc.visible = true;
					TweenLite.to(mc.x1_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
					mc.check2_mc.visible = true;
					TweenLite.to(mc.check2_mc, 1, { alpha:1, ease:Quadratic.easeOut } );
				} else if (!isC && smatch == 1) {
					mc.x2_mc.visible = true;
					TweenLite.to(mc.x2_mc, .5, { alpha:1, ease:Quadratic.easeOut } );
					mc.check1_mc.visible = true;
					TweenLite.to(mc.check1_mc, 1, { alpha:1, ease:Quadratic.easeOut } );
				} 
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			headerrow_mc.visible = true;
			
			headerrow_mc.x = _PageRenderer.getPageCenteredX(700);
			headerrow_mc.y = _PageRenderer.bodyTFBottomY + 30;
			headerrow_mc.label1_txt.text = _Questions[_CurrentQuestion].getMatchText(0);
			headerrow_mc.label2_txt.text = _Questions[_CurrentQuestion].getMatchText(1);
			headerrow_mc.label3_txt.text = _Questions[_CurrentQuestion].choiceColumnLabel;
			
			var x:int = headerrow_mc.x;
			var y:int = headerrow_mc.y+30;
			var ySpc:int = 10;
			
			var len:int = _Questions[_CurrentQuestion].numChoices;
			
			for (var i:int = 0; i < len; i++) {
				var c:ChoiceItem = new ChoiceItem();
				_Questions[_CurrentQuestion].setChoiceCurrentSetMatch(i, -1);
				c.questionIdx = _CurrentQuestion;
				c.choiceIdx = i;
				c.check1_mc.visible = false;
				c.check1_mc.alpha = 0;
				c.x1_mc.visible = false;
				c.x1_mc.alpha = 0;
				c.check2_mc.visible = false;
				c.check2_mc.alpha = 0;
				c.x2_mc.visible = false;
				c.x2_mc.alpha = 0;
				
				c.x = x;
				c.y = y;
				
				c.text_txt.autoSize = TextFieldAutoSize.LEFT;
				c.text_txt.wordWrap = true;
				c.text_txt.multiline = true;
				c.text_txt.htmlText = _Questions[_CurrentQuestion].getChoiceText(i);
				_PageRenderer.changeTextFieldSize(c.text_txt);
			
				c.bg_mc.scaleY = (c.text_txt.height + ySpc) * .01
				c.choicebg_mc.scaleY = (c.text_txt.height + ySpc) * .01
				
				c.choice1_mc.y = c.choice2_mc.y = ((c.text_txt.height + ySpc) / 2) - (c.choice1_mc.height / 2)+2;
				
				c.check1_mc.x = c.choice1_mc.x - 18;
				c.check2_mc.x = c.choice2_mc.x - 18;
				c.x1_mc.x = c.choice1_mc.x - 17;
				c.x2_mc.x = c.choice2_mc.x - 17;
				c.check1_mc.y = c.check2_mc.y = c.x1_mc.y = c.x2_mc.y = c.choice1_mc.y + 2
				
				c.line_mc.y = (c.text_txt.height + ySpc)
				if (i == len - 1) c.line_mc.visible = false;
				if (i % 2) {
					c.bg_mc.alpha *= .5
					c.choicebg_mc.alpha *= .5
				}
				
				_PageRenderer.interactionLayer.addChild(c);
				_Questions[_CurrentQuestion].setChoiceRefMC(i, c);
				
				if (_Animate) {
					c.alpha = 0;
					TweenLite.to(c, 1, { alpha:1, delay:(i*.2), ease:Quadratic.easeOut, onComplete:enableChoice, onCompleteParams:[_CurrentQuestion, i] } );
				} else {
					enableChoice(_CurrentQuestion, i);
				}
				
				y += (c.text_txt.height + ySpc)+1;
			}
			
			headerrow_mc.bg_mc.scaleY = (y-headerrow_mc.y+2) * .01;

			submit_btn.x = headerrow_mc.x+500;
			submit_btn.y = y+30;
		}
		
		override protected function enableChoice(q:int, c:int):void {
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.check1_mc.visible = false;
			mc.check1_mc.alpha = 0;
			mc.x1_mc.visible = false;
			mc.x1_mc.alpha = 0;
			mc.check2_mc.visible = false;
			mc.check2_mc.alpha = 0;
			mc.x2_mc.visible = false;
			mc.x2_mc.alpha = 0;
			mc.choice1_mc.buttonMode = true;
			mc.choice1_mc.mouseChildren = false;
			mc.choice2_mc.buttonMode = true;
			mc.choice2_mc.mouseChildren = false;
			mc.choice1_mc.addEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice1_mc.addEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice1_mc.addEventListener(MouseEvent.CLICK, onChoiceClick);
			mc.choice2_mc.addEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice2_mc.addEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice2_mc.addEventListener(MouseEvent.CLICK, onChoiceClick);
			//AccessibilityManager.getInstance().addActivityItem(mc, "Question Choice "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableChoice(q:int, c:int):void {
			var mc:MovieClip = _Questions[q].getChoiceRefMC(c);
			mc.choice1_mc.buttonMode = false;
			mc.choice2_mc.buttonMode = false;
			mc.choice1_mc.removeEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice1_mc.removeEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice1_mc.removeEventListener(MouseEvent.CLICK, onChoiceClick);
			mc.choice2_mc.removeEventListener(MouseEvent.ROLL_OVER, onChoiceOver);
			mc.choice2_mc.removeEventListener(MouseEvent.ROLL_OUT, onChoiceOut);
			mc.choice2_mc.removeEventListener(MouseEvent.CLICK, onChoiceClick);
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
			_Questions[q].setChoiceCurrentSetMatch(c, m);
			_Questions[q].setChoiceIsSelected(c);
			if (m == 0) {
				_Questions[q].getChoiceRefMC(c).choice1_mc.gotoAndStop(2);
				_Questions[q].getChoiceRefMC(c).choice2_mc.gotoAndStop(1);
			} else {
				_Questions[q].getChoiceRefMC(c).choice1_mc.gotoAndStop(1);
				_Questions[q].getChoiceRefMC(c).choice2_mc.gotoAndStop(2);
			}
			updateButtons();
		}
		
		override protected function resetChoice(q:int, c:int):void {
			if (_Questions[q].retainCAsOnReset) {
				//trace(_Questions[q].getChoiceCorrect(c) +" vs "+ _Questions[q].getChoiceIsSelected(c));
				if(_Questions[q].getChoiceIsCorrect(c) && _Questions[q].getChoiceIsSelected(c)) return;
			}
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].setChoiceNotSelected(c);
			_Questions[q].getChoiceRefMC(c).choice1_mc.gotoAndStop(1);
			_Questions[q].getChoiceRefMC(c).choice2_mc.gotoAndStop(1);
		}
		
		override protected function resetChoiceHard(q:int, c:int):void {
			_Questions[q].setChoiceCurrentSetMatch(c, -1);
			_Questions[q].setChoiceNotSelected(c);
			_Questions[q].getChoiceRefMC(c).choice1_mc.gotoAndStop(1);
			_Questions[q].getChoiceRefMC(c).choice2_mc.gotoAndStop(1);
		}
		
		override protected function onChoiceOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onChoiceClick(e:Event):void {
			var q:int = ChoiceItem(e.target.parent).questionIdx;
			var c:int = ChoiceItem(e.target.parent).choiceIdx;
			var m:int = e.target.name == "choice1_mc" ? 0 : 1;
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