
package ramen.common {
	
	import flash.events.*;
	
	public class PopUpCreationEvent extends Event {

		// these correspond to ButtonType classes 
		public static const OPEN	:String = "open";

		public var callingobj		:*;
		public var xmldata			:XML;
		public var objdata			:Object;
		public var popuptype		:String;
		
		public function PopUpCreationEvent(type:String, t:*=undefined, x:XML=undefined, p:String="", d:Object=undefined, bubbles:Boolean=true, cancelable:Boolean=false):void {
			super(type, bubbles, cancelable);
			callingobj = t;
			xmldata = x;
			objdata = d;
			popuptype = p;
		}
		
		public override function clone():Event {
			return new PopUpCreationEvent(type, callingobj, xmldata, popuptype, objdata, bubbles, cancelable);
		}
		
		public override function toString():String {
			return formatToString("PopUpCreationEvent", "type", "callingobj", "xmldata", "popuptype", "objdata", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}