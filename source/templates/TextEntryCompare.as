/*
Text Entry Compare

[ ] need suppport for fill-in interaction type
[ ] on resume from prev answer, show previous answer
[ ] dynamic sizes
[ ] font size increase support in area headers
*/

package {
	
	import com.nudoru.lms.InteractionObject;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class TextEntryCompare extends QuestionTemplate {

		public function TextEntryCompare():void {
			super();
			textareas_mc.visible = false;
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
		
		override protected function judgeAll():void {
			showCorrectAnswers(0)
			
			disableInteraction(false);
			_Questions[_CurrentQuestion].state = Question.STATE_CORRECT;
			_Questions[_CurrentQuestion].stop();
			showCorrectAnswers(_CurrentQuestion);
			dispatchEvent(new Event(MARK_CORRECT));
			dispatchEvent(new PageStatusEvent(PageStatusEvent.PASSED));
		}
		
		override protected function showCorrectAnswers(q:int):void {
			textareas_mc.correct_ta.enabled = true;
			textareas_mc.correct_ta.text = _Questions[_CurrentQuestion].ca;
			TweenLite.to(textareas_mc.choicebg_mc, 1, { x:350, alpha:1, ease:Back.easeInOut } );
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderChoices():void {
			textareas_mc.visible = true;
			textareas_mc.x = _PageRenderer.getPageCenteredX(700);
			textareas_mc.y = _PageRenderer.bodyTFBottomY + 20;
			textareas_mc.choicelabel_txt.htmlText = _Questions[_CurrentQuestion].getChoiceLabel(0);
			textareas_mc.feedbacklabel_txt.htmlText = _Questions[_CurrentQuestion].feedbackLabel;
			
			_PageRenderer.changeTextFieldSize(textareas_mc.choicelabel_txt);
			_PageRenderer.changeTextFieldSize(textareas_mc.feedbacklabel_txt);
			
			submit_btn.x = _PageRenderer.pageCenterX - (submit_btn.width/2);
			submit_btn.y = textareas_mc.y + textareas_mc.height + 20;
			
			textareas_mc.correct_ta.verticalScrollPolicy = ScrollPolicy.OFF;
			textareas_mc.correct_ta.horizontalScrollPolicy = ScrollPolicy.OFF;
			textareas_mc.choice_ta.verticalScrollPolicy = ScrollPolicy.OFF;
			textareas_mc.choice_ta.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			textareas_mc.correct_ta.enabled = false;
			textareas_mc.correct_ta.editable = false;
			textareas_mc.choice_ta.text = _Questions[_CurrentQuestion].getChoiceText(0);
			textareas_mc.choice_ta.addEventListener(Event.CHANGE, onTextEntry);
		}
		
		protected function onTextEntry(e:Event):void {
			var len:int = textareas_mc.choice_ta.text.length;
			if (textareas_mc.choice_ta.text == _Questions[_CurrentQuestion].getChoiceText(0)) {
				disableSubmit();
				return;
			}
			if (len > 0) enableSubmit();
				else disableSubmit();
		}
		
		
		override protected function enableChoice(q:int, c:int):void {
			textareas_mc.choice_ta.editable = true;
			textareas_mc.choice_ta.addEventListener(Event.CHANGE, onTextEntry);
		}
		
		override protected function disableChoice(q:int, c:int):void {
			textareas_mc.choice_ta.editable = false;
			textareas_mc.choice_ta.removeEventListener(Event.CHANGE, onTextEntry);
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy

		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			// destroy interaction specific content
			textareas_mc.choice_ta.removeEventListener(Event.CHANGE, onTextEntry);
			
			submit_btn.removeEventListener(MouseEvent.CLICK, onSubmitClick);
			disableAllQuestions();
			stopAllQuestions();

			super.destroy();
		}
		
	}
}