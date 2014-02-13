// http://drawlogic.com/2008/01/10/howto-sharedobjects-for-local-storage-as3/

package ramen.player {
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.ByteArray;
	
	public class LSOManager extends EventDispatcher {
		
		static private var _Instance	:LSOManager;
		
		private var _Initd				:Boolean;
		private var _Delimeter			:String = "%%";
		
		public function get initd():Boolean { return _Initd; }
		public function set initd(value:Boolean):void { _Initd = value; }
		
		public function LSOManager(singletonEnforcer:SingletonEnforcer) {
				initialize();
		}
		
		public static function getInstance():LSOManager {
			if (LSOManager._Instance == null) {
				LSOManager._Instance = new LSOManager(new SingletonEnforcer());
			}
			return LSOManager._Instance;
		}
	
		public function initialize():void {
			initd = true;
		}
		
		public function saveData(id:String, d:String):Boolean {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				trace("CAN'T GET/save LSO: '" + id + "'");
				return false;
			}
			so.data.thedata = compressData(d);
			
			var flstat:String;
			
			try {
				flstat = so.flush();
			} catch (e:*) {
				trace("CAN'T WRITE LSO: '" + id + "'");
				return false;
			}
			if (flstat == SharedObjectFlushStatus.PENDING) {
				// need more space
				trace("CAN'T WRITE LSO, status pending");
				return false;
			}
			return true;
		}
		
		public function clearData(id:String):Boolean {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				trace("CAN'T GET/clear LSO: '" + id + "'");
				return false;
			}
			so.clear();
			trace("$$$ LSO cleared: " + id);
			return true;
		}
		
		public function getData(id:String):String {
			var so:SharedObject;
			
			try {
				so = SharedObject.getLocal(id);
			} catch (e:*) {
				trace("CAN'T GET/get LSO: '" + id + "'");
				return undefined;
			}
			trace("$$$ data ret: '"+so.data.thedata+"'");
			return decompressData(so.data.thedata);
		}
		
		//http://www.flexdeveloper.eu/forums/actionscript-3-0/compress-and-uncompress-strings-using-bytearray/
		private function compressData(d:String):ByteArray {
			var b:ByteArray = new ByteArray();
			b.writeUTFBytes(d);
			b.compress();
			return b;
		}
		
		private function decompressData(d:ByteArray):String {
			if (!d) return "";
			var b:ByteArray = d;
			try {
				b.uncompress();
			} catch (e:*) {
				trace("$$$ error decompressing LSO data");
				return "";
			}
			return b.toString();
		}
		
	}
}

class SingletonEnforcer {}