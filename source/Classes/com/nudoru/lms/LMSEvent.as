
package com.nudoru.lms {
	
	import flash.events.*;
	
	public class LMSEvent extends Event {
		
		public static const INITIALIZED		:String = "initialized";
		public static const NOT_INITIALIZED	:String = "not_initialized";
		public static const CANNOT_CONNECT	:String = "cannot_connect";
		public static const CONNECTION_LOST	:String = "connection_lost";
		public static const ERROR			:String = "error";
		public static const SUCCESS			:String = "lms_success";
		public static const CANNOT_CLOSE_WINDOW:String = "cannot_close_window";
		public static const UPDATE			:String = "update";
		
		public static const COMMIT			:String = "commit";
		public static const SET_SCORE		:String	= "set_score";
		public static const SET_STATUS		:String = "set_status";
		public static const SET_INCOMPLETE	:String = "set_incomplete";
		public static const SET_COMPLETE	:String = "set_complete";
		public static const SET_PASS		:String = "set_pass";
		public static const SET_FAIL		:String = "set_fail";
		public static const SET_LASTLOCATION:String = "set_lastlocation";
		public static const SET_SUSPENDDATA	:String = "set_suspenddata";
		public static const EXIT			:String = "exit";
		
		public var ldata				:String;
		
		public function LMSEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, d:String=""):void {
			super(type, bubbles, cancelable);
			ldata = d;
		}
		
		public override function clone():Event {
			return new LMSEvent(type, bubbles, cancelable, ldata);
		}
		
		public override function toString():String {
			return formatToString("LMSEvent", "type", "bubbles", "cancelable", "eventPhase", "ldata");
		}
		
	}
	
}