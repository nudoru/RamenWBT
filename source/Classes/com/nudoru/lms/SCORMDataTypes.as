// SCORM 2004 datatypes, 

package com.nudoru.lms {

	public class SCORMDataTypes {
		
		public function SCORMDataTypes():void {}
		
		/*localized_string_type
		A localized characterstring is a characterstring that has an indicator of the language of the characterstring. There are certain data model elements where the language information is important. SCORM applies a reserved delimiter for representing the language of the characterstring: {lang=<language_type>}.
		The format of the characterstring is required to have the following syntax:
		“{lang=<language_type>}<actual characterstring>”
		*/
		public static function toLocalizedString(s:String,c:String = "en"):String {
			return "{lang=" + c + "}" + s;
		}
		
		/*time (second, 10, 0)
		The time (second,10,0) data type represents a point in time. This data type shall have a 
		required precision of 1 second and an optional precision of 0.01 seconds [1]. Implementations 
		should be aware of this required precision versus the optional precision, for it may impact 
		implementation decisions. For example, if an application is expecting the optional precision, 
		it may not be supported. The SCORM dot-notation binding defines a particular format for a 
		characterstring to represent a point in time. The format of the characterstring shall be as 
		follows:

		YYYY[-MM[-DD[Thh[:mm[:ss[.s[TZD]]]]]]]
		*/
		public static function getTimeSecond10():String {
			var t:String = "";
			var now = new Date();
			t += now.getFullYear()+"-";
			t += addZero((now.getMonth() + 1))+"-";
			t += addZero(now.getDate());
			t += "T";
			t += addZero(now.getHours())+":";
			t += addZero(now.getMinutes())+":";
			t += addZero(now.getSeconds());
			return t;
		}
		
		/*timeinterval (second, 10,2)
		The timeinterval (second, 10, 2) denotes that the value for the data model element timeinterval represents elapsed time with a precision of 0.01
		seconds[1]. The SCORM dot-notation binding defines a particular format for a characterstring to represent a timeinterval.
		The format of the characterstring shall be as follows:
		P[yY][mM][dD][T[hH][nM][s[.s]S]] where:
		• y: The number of years (integer, >= 0, not restricted)
		• m: The number of months (integer, >=0, not restricted)
		• d: The number of days (integer, >=0, not restricted)
		• h: The number of hours (integer, >=0, not restricted)
		• n: The number of minutes (integer, >=0, not restricted)
		• s: The number of seconds or fraction of seconds (real or integer, >=0, not restricted). If fractions of a second are used, SCORM further restricts the string to a maximum of 2 digits (e.g., 34.45 – valid, 34.45454545 – not valid).
		• The character literals designators P, Y, M, D, T, H, M and S shall appear if the corresponding non-zero value is present.
		• Zero-padding of the values shall be supported. Zero-padding does not change the integer value of the number being represented by a set of characters. For example, PT05H is equivalent to PT5H and PT000005H.
		Example:
		• P1Y3M2DT3H indicates a period of time of 1 year, 3 months, 2 days and 3 hours
		• PT3H5M indicates a period of time of 3 hours and 5 minutes*/
		public static function toTimeIntervalSecond10(h:int,m:int,s:int):String {
			var t:String = "PT"+h+"H"+m+"M"+s+"S";
			return t;
		}
		
		/*real (10,7)
		The real(10,7) data type denotes a real number with a precision of seven significant digits.
		*/
		public static function toReal10(t:Number):String {
			return String(t.toFixed(7));
		}
		
		private static function addZero(n:int):String {
			if (n < 10) return "0" + String(n);
			return String(n);
		}
	}
	
}