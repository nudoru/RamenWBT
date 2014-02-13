package com.nudoru.utils {
	
	import flash.events.*;
	import flash.net.*;
	
	public class SimpleXMLLoader extends EventDispatcher {
		
		private var _XMLFile		:String;
		private var _XMLData		:XML;
		private var _XMLLoader		:URLLoader;
		
		public function get XMLData():XML { return _XMLData }
		public function get XMLFile():String { return _XMLFile }
		
		public static const LOADED	:String = "loaded";
		public static const IO_ERROR:String = "io_error";
		public static const PARSE_ERROR:String = "parse_error";
		
		public function SimpleXMLLoader():void {
			
		}
		
		public function load(d:String):void {
			_XMLFile = d;
			loadXML();
		}
		
		private function loadXML():void {
			trace("load: "+_XMLFile);
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_XMLLoader.load(new URLRequest(_XMLFile))
		}
		
		private function onIOError(event:Event):void {
			trace("XML io error");
			dispatchEvent(new Event(SimpleXMLLoader.IO_ERROR));
		}
		
		private function onXMLLoaded(event:Event):void {
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			// catches malformed XML
			try {
				_XMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				dispatchEvent(new Event(SimpleXMLLoader.PARSE_ERROR));
				return;
			}
			dispatchEvent(new Event(SimpleXMLLoader.LOADED));
		}
		
	}
	
}