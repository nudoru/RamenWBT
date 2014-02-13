/*
 * This double as the data holder for both questions and lists
 */

package ramen.page {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import ramen.sheet.Sheet;
	
	public class ChoiceItem extends MovieClip {
		
		public var id				:String;
		public var questionIdx		:int;
		public var listIdx			:int;
		public var choiceIdx		:int;
		public var matchIdx			:int;
		public var itemIdx			:int;
		public var displayIdx		:int;
		
		public var origionalXPos	:int;
		public var origionalYPos	:int;
		public var origionalAlpha	:Number;
		public var origionalScale	:Number;
		public var origionalXScale	:Number;
		public var origionalYScale	:Number;
		public var origionalRotation:Number;
		
		public var targetXPos		:int;
		public var targetYPos		:int;
		public var targetAlpha		:Number;
		public var targetScale		:Number;
		public var targetXScale		:Number;
		public var targetYScale		:Number;
		
		public var effectLayer		:Sprite;
		
		public var selected			:Boolean;
		
		public var sheet			:Sheet;
		
		public function ChoiceItem():void {
			//
		}
		
		public function setOrigionalProps():void {
			origionalXPos = this.x;
			origionalYPos = this.y;
			origionalAlpha = this.alpha;
			origionalScale = this.scaleX;
			origionalXScale = this.scaleX;
			origionalYScale = this.scaleY;
			origionalRotation = this.rotation;
		}
		
		public function setToOrigionalProps():void {
			this.x = origionalXPos;
			this.y = origionalYPos;
			this.alpha = origionalAlpha;
			this.scaleX = origionalXScale;
			this.scaleY = origionalYScale;
			this.rotation = origionalRotation;
		}
	}
}