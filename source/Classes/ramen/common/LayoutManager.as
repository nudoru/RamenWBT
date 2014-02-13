package ramen.common {
	
	public class LayoutManager extends EventDispatcher{
		
		static private var _Instance	:LayoutManager;
		
		private var _XMLLoader			:URLLoader;
		private var _XMLData			:XML;
		
		public static const LOADED	:String = "loaded";
		public static const IO_ERROR:String = "io_error";
		public static const PARSE_ERROR:String = "parse_error";
		
		public function LayoutManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():LayoutManager {
			if (LayoutManager._Instance == null) {
				LayoutManager._Instance = new LayoutManager(new SingletonEnforcer());
			}
			return LayoutManager._Instance;
		}
		
		public function init(f:String):void {
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_XMLLoader.load(new URLRequest(f))
		}
		
		private function loadXML():void {
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_XMLLoader.load(new URLRequest(_XMLFile))
		}
		
		private function onIOError(event:Event):void {
			dispatchEvent(new Event(LayoutManager.IO_ERROR));
		}
		
		private function onXMLLoaded(event:Event):void {
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			// catches malformed XML
			try {
				_XMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				dispatchEvent(new Event(LayoutManager.PARSE_ERROR));
				return;
			}
			parse();
		}
		
		private function parse():void {
			dispatchEvent(new Event(LayoutManager.LOADED));
		}
		
	}
	
}

class SingletonEnforcer {}