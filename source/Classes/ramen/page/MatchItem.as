package ramen.page {

	import flash.display.MovieClip;
	
	public class MatchItem extends MovieClip {
		
		public var id				:String;
		public var questionIdx		:int;
		public var choiceIdx		:int;
		public var matchIdx			:int;
		public var displayIdx		:int;
		
		public var origionalXPos	:int;
		public var origionalYPos	:int;
		public var origionalAlpha	:Number;
		public var origionalScale	:Number;
		public var origionalXScale	:Number;
		public var origionalYScale	:Number;
		
		public var targetXPos		:int;
		public var targetYPos		:int;
		public var targetAlpha		:Number;
		public var targetScale		:Number;
		public var targetXScale		:Number;
		public var targetYScale		:Number;
		
		public function MatchItem():void {
			//
		}
		
		public function setOrigionalProps():void {
			origionalXPos = this.x;
			origionalYPos = this.y;
			origionalAlpha = this.alpha;
			origionalScale = this.scaleX;
			origionalXScale = this.scaleX;
			origionalYScale = this.scaleY;
		}
	}
}