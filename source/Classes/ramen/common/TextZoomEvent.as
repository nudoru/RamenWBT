
package ramen.common {
	
	import flash.events.*;
	
	public class TextZoomEvent extends Event {

		// these correspond to ButtonType classes 
		public static const ZOOM	:String = "zoom";

		public var data		:String;
		
		public function TextZoomEvent(type:String, d:String, bubbles:Boolean=true, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			data = d;
		}
		
		public override function clone():Event {
			return new TextZoomEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("TextZoomEvent", "type", "data", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}