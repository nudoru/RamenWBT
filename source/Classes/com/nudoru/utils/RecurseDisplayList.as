package com.nudoru.utils {

	import com.nudoru.lms.LMSConnector;
	import flash.display.*;
	
	public class RecurseDisplayList {
		
		public static function traceFullDisplayList(o:*):void {
			trace(doRecursion(o));
		}
		
		private static function doRecursion(d:*,s:int=0):String {
			var t:String = "";
			t += getSpaces(s)+d.name + ", "+d+"\n";
			var len:int = 0;
			try {
				len = d.numChildren;
			} catch(e:*) {}
			for (var i:int = 0; i < len; i++) {
				t += doRecursion(d.getChildAt(i),(s+1));
			}
			return t;
		}
		
		private static function getSpaces(l:int):String {
			var t:String = "";
			for (var i:int = 0; i < l; i++) {
				t += " ";
			}
			
			return t;
		}
		
	}
	
}