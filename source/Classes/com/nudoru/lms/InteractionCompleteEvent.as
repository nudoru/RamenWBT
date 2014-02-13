
package com.nudoru.lms {
	
	import flash.events.*;
	
	public class InteractionCompleteEvent extends Event {
		
		public static const COMPLETE	:String = "interaction_complete";
		
		public var idata					:InteractionObject;
		
		public function InteractionCompleteEvent(type:String, d:InteractionObject, bubbles:Boolean=true, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			idata = d;
		}
		
		public override function clone():Event {
			return new InteractionCompleteEvent(type, idata, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("InteractionCompleteEvent", "type", "idata", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}