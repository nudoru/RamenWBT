/*

*/

package ramen.common {
	
	import flash.events.*;
	
	public class PageEvent extends Event {
		
		public static const LOADED	:String = "loaded";
		public static const INITIALIZED	:String = "initialized";
		public static const RENDERED	:String = "rendered";
		public static const COMPLETED	:String = "completed";
		public static const UNLOADED	:String = "unloaded";
		
		public var eventName					:String;
		public var eventData					:String;
		
		public function PageEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, eName:String=" ", eData:String=" "):void {
			super(type, bubbles, cancelable);
			eventName = eName;
			eventData = eData;
		}
		
		public override function clone():Event {
			return new PageEvent(type, bubbles, cancelable, eventName, eventData);
		}
		
		public override function toString():String {
			return formatToString("PageEvent", "type", "bubbles", "cancelable", "eventPhase", "eventName", "eventData");
		}
		
	}
	
}