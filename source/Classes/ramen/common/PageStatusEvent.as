package ramen.common {
	
	import flash.events.*;
	
	public class PageStatusEvent extends Event {
		
		public static const INCOMPLETE	:String = "incomplete";
		public static const COMPLETED	:String = "completed";
		public static const PASSED		:String = "passed";
		public static const FAILED		:String = "failed";

		public var eventData					:String;
		
		public function PageStatusEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, eData:String=""):void {
			super(type, bubbles, cancelable);
			eventData = eData;
		}
		
		public override function clone():Event {
			return new PageEvent(type, bubbles, cancelable, eventData);
		}
		
		public override function toString():String {
			return formatToString("PageStatusEvent", "type", "bubbles", "cancelable", "eventPhase", "eventData");
		}
		
	}
	
}