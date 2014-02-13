
package ramen.common {
	
	import flash.events.*;
	
	public class NavigationUIEvent extends Event {
		
		public static const BTN_HIDE		:String = "btn_hide";
		public static const BTN_SHOW		:String = "btn_show";
		public static const BTN_TOGGLE		:String = "btn_toggle";
		public static const BTN_ENABLE		:String = "btn_enable";
		public static const BTN_DISABLE		:String = "btn_disable";
		
		public static const NEXT_BTN		:String = "nav_next_btn";
		public static const BACK_BTN		:String = "nav_back_btn";
		public static const REPLAY_BTN		:String = "nav_replay_btn";
		
		public var data				:String;
		
		public function NavigationUIEvent(type:String, d:String, bubbles:Boolean=true, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			data = d;
		}
		
		public override function clone():Event {
			return new NavigationUIEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("NavigationUIEvent", "data", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}