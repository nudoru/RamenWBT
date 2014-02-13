/*
 * Simple Item Class
 * Used to represent dynamic list items and provide storage for commonly used data
 */

package ramen.page {

	import flash.display.MovieClip;
	import flash.text.TextField;
	import ramen.sheet.Sheet;
	
	public class SimpleListItem extends MovieClip {
		
		public var id				:String;
		public var listIdx			:int;
		public var itemIdx			:int;
		
		public var titleStr			:String;
		public var textStr			:String;
		
		public var extraData		:Object;
		
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
		
		public var selected			:Boolean = false;
		
		public var sheet			:Sheet;
		
		public function SimpleListItem():void {
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