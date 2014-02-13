
package ramen.common {
	
	import flash.events.*;
	
	public class InterfaceEvent extends Event {
		
		public static const CUSTOM	:String = "custom";
		public static const PAGE	:String = "page";
		public static const UI		:String = "ui";
		
		public static const MAIN_MENU_SELECTION	:String = "main_menu_selection";
		public static const PAGE_MENU_SELECTION	:String = "page_menu_selection";
		public static const PAGE_NAVIGATION_EVENT	:String = "page_navigatio_event";
		
		public var thetarget		:*;
		public var data				:String;
		
		public function InterfaceEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, t:*=undefined, d:String=""):void {
			super(type, bubbles, cancelable);
			thetarget = t;
			data = d;
		}
		
		public override function clone():Event {
			return new InterfaceEvent(type, bubbles, cancelable, thetarget, data);
		}
		
		public override function toString():String {
			return formatToString("InterfaceEvent", "type", "bubbles", "cancelable", "eventPhase", "thetarget", "data");
		}
		
	}
	
}