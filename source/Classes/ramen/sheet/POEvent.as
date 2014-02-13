/*
4.2.08
*/

package ramen.sheet {
	
	import flash.events.*;
	
	public class POEvent extends Event {
		
		public static const LOADED		:String = "loaded";
		public static const INITIALIZED	:String = "initialized";
		public static const RENDERED	:String = "rendered";
		public static const COMPLETED	:String = "completed";
		public static const UNLOADED	:String = "unloaded";
		
		public static const PO_ROLLOVER	:String = "rollover";
		public static const PO_ROLLOUT	:String = "rollout";
		public static const PO_CLICK	:String = "click";
		public static const PO_DOWN		:String = "down";
		public static const PO_RELEASE	:String = "release";
		public static const PO_TIMER	:String = "timer";
		
		public static const PO_ANIMATION_START		:String = "animation_start";
		public static const PO_ANIMATION_COMPLETE	:String = "animation_complete";
		public static const PO_TRANSITIONIN_START	:String = "transitionin_start";
		public static const PO_TRANSITIONIN_COMPLETE:String = "transitionin_complete";
		public static const PO_TRANSITIONOUT_START	:String = "transitionout_start";
		public static const PO_TRANSITIONOUT_COMPLETE:String = "transitionout_complete";
		
		public static const PO_START	:String = "pb_start";
		public static const PO_PLAY		:String = "pb_play";
		public static const PO_PAUSE	:String = "pb_pause";
		public static const PO_STOP		:String = "pb_stop";
		public static const PO_FINISH	:String = "pb_finish";
		
		public var targetID				:String;
		
		public function POEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, eID:String=""):void {
			super(type, bubbles, cancelable);
			targetID = eID;
		}
		
		public override function clone():Event {
			return new POEvent(type, bubbles, cancelable, targetID);
		}
		
		public override function toString():String {
			return formatToString("PageEvent", "type", "bubbles", "cancelable", "eventPhase", "targetID");
		}
		
	}
	
}