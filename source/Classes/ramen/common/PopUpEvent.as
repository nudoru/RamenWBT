
package ramen.common {
	
	import flash.events.*;
	
	public class PopUpEvent extends Event {
		
		public static const EVENT		:String = "event";
		
		// these correspond to ButtonType classes 
		public static const OK			:String = "ok";
		public static const CANCEL		:String = "cancel";
		public static const CLOSE		:String = "close";
		public static const EXIT_MODULE	:String = "exit_module";
		public static const YES			:String = "yes";
		public static const NO			:String = "no";
		
		public static const DATA		:String = "data";
		
		public static const BUTTON_CLICK:String = "button_click";
		public static const START_DRAG	:String = "start_drag";
		public static const STOP_DRAG	:String = "stop_drag";
		
		public var windowguid		:String;
		public var data				:String;
		public var callingobj		:*;
		public var buttondata		:String;
		
		public function PopUpEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, t:String="", d:String="", c:*=undefined, bd=""):void {
			super(type, bubbles, cancelable);
			windowguid = t;
			data = d;
			callingobj = c;
			buttondata = bd;
		}
		
		public override function clone():Event {
			return new PopUpEvent(type, bubbles, cancelable, windowguid, data, callingobj,buttondata);
		}
		
		public override function toString():String {
			return formatToString("PopUpEvent", "type", "bubbles", "cancelable", "eventPhase", "windowguid", "data", "callingobj","buttondata");
		}
		
	}
	
}