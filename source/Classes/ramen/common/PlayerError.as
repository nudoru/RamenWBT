
package ramen.common {
	
	import flash.events.*;
	
	public class PlayerError extends Event {
		
		public static const WARNING		:String = "warning";
		public static const ERROR		:String = "error";
		public static const FATAL		:String = "fatal";
		
		public var code					:String;
		public var summary				:String;
		public var text					:String;
		
		// text is optional, warnings don't need text
		public function PlayerError(type:String, c:String, s:String, t:String="", bubbles:Boolean = true, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
			code = c;
			summary = s;
			text = t;
		}
		
		public override function clone():Event {
			return new PlayerError(type, code, summary, text, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("PlayerError", "code", "summary", "text", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}