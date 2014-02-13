package com.nudoru.utils {

	public class GUID {
		
		public static function getGUID():String {
			var t:String = "{"+String(rnd(10000000,99999999))
			var now = new Date();
			t += "-" + now.getFullYear();
			t += (now.getMonth() + 1);
			t += now.getDate();
			t += "-" + String(rnd(10000000, 99999999));
			t += "-" + now.getHours();
			t += now.getMinutes();
			t += "-" + now.getSeconds();
			t += now.getMilliseconds();
			t += "}"
			return t
		}
		
		public static function rnd(min:Number, max:Number):Number {
			return min + Math.floor(Math.random() * (max + 1 - min))
		}
		
	}
	
}