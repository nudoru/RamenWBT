/*
 * Mangages object to sheet communications
 */

package ramen.sheet {
	
	import flash.events.EventDispatcher;
	
	public class SheetManager extends EventDispatcher{
		
		static private var _Instance	:SheetManager;
		
		private var _Initd				:Boolean;
		
		private var _Sheets				:Array;
		
		public function get initd():Boolean { return _Initd; }
		public function set initd(value:Boolean):void { _Initd = value; }
		
		public function SheetManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():SheetManager {
			if (SheetManager._Instance == null) {
				SheetManager._Instance = new SheetManager(new SingletonEnforcer());
			}
			return SheetManager._Instance;
		}
		
		public function registerSheet(id:String, s:Sheet):void {
			if (!_Sheets) _Sheets = new Array();
			var o:Object = new Object();
			o.id = id;
			o.sheet = s;
			_Sheets.push(o);
		}
		
		public function unregisterSheet(id:String):void {
			for (var i:int = 0; i < _Sheets.length; i++) {
				if (_Sheets[i].id == id) {
					_Sheets.splice(i, 1);
					return;
				}
			}
			trace("Sheet '"+id+"' not found!");
		}
		
	}
}

class SingletonEnforcer {}