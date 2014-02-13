
package ramen.common {
	
	import flash.events.*;
	
	public class AccessibilityFocusEvent extends Event {
		
		public static const FOCUS_IN	:String = "focus_in";
		public static const FOCUS_OUT	:String = "focus_out";
		
		public var targetitem			:AccessibilityItem;
		
		public function AccessibilityFocusEvent(type:String, t:AccessibilityItem, bubbles:Boolean=true, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			targetitem = t;
		}
		
		public override function clone():Event {
			return new AccessibilityFocusEvent(type, targetitem, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("AccessibilityFocusEvent", "targetitem", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}