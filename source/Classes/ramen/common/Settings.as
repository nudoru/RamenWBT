/*
Settings for Ramen
Last updated 5.6.09
*/

package ramen.common {
	
	import flash.text.StyleSheet;
	import ramen.player.SiteModel;
	import flash.display.AVM1Movie;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	public class Settings extends EventDispatcher {
		
		static private var _Instance	:Settings;
		
		private var _AudioEnabled		:Boolean;
		private var _AudioVolume		:Number;
		private var _ZoomFactor			:int;
		private var _CaptionsEn			:Boolean;
		
		private var _SiteWidth			:int;
		private var _SiteHeight			:int;
		private var _PageWidth			:int;
		private var _PageHeight			:int;
		private var _ThemeColors		:Array;
		private var _ThemeHiColor		:String;
		private var _ThemeHiStyle		:String;
		
		private var _StyleSheet			:StyleSheet;
		
		private var _AllowScoredReanswer:Boolean;
		private var _IntrNumTries		:int;
		private var _IntrForceAnswer	:Boolean;
		private var _IntrForceCA		:Boolean;
		private var _IntrUseIObj		:Boolean;
		
		private var _LMSStudentID		:String;
		private var _LMSStudentName		:String;
		
		private var _VarList			:Array;
		
		private var _Delimeter			:String = "%%";	// used for data string
		
		// when adjusting the max factor, be sure to adjust an UI elements that use this value - may hardcode instead of getting from here
		public static const ZOOM_FACTOR_MAX	:int = 6;
		public static const ZOOM_FACTOR_MIN	:int = 0;
		
		public static const AUDIO_STATUS_CHANGE	:String = "audio_status_change";
		public static const ZOOM_FACTOR_CHANGE	:String = "zoom_factor_change";
		
		public function set audioEnable(s:Boolean):void {
			if (_AudioEnabled == s) return;
			_AudioEnabled = s;
			dispatchEvent(new Event(AUDIO_STATUS_CHANGE));
		}
		public function get audioEnable():Boolean { return _AudioEnabled }
		
		public function set audioVolume(s:Number):void {
			if (_AudioVolume == s) return;
			_AudioVolume = s;
			dispatchEvent(new Event(AUDIO_STATUS_CHANGE));
		}
		public function get audioVolume():Number { return _AudioVolume }
		
		public function get zoomFactor():int { return _ZoomFactor; }
		public function get zoomFactorMax():int { return ZOOM_FACTOR_MAX; }
		public function get zoomFactorMin():int { return ZOOM_FACTOR_MIN; }
		
		public function get captionsEn():Boolean { return _CaptionsEn; }
		public function set captionsEn(value:Boolean):void { _CaptionsEn = value; }
		
		public function get siteWidth():int { return _SiteWidth }
		public function get siteHeight():int { return _SiteHeight }
		public function get pageWidth():int { return _PageWidth }
		public function get pageHeight():int { return _PageHeight }
		public function get themeColors():Array { 
			if (_ThemeColors) return _ThemeColors 
				else return [];
		}
		public function get themeHiColor():int { 
			if (_ThemeHiColor) return int(_ThemeHiColor);
				else return 0x00ff00;
		}
		public function get themeHiStyle():String {
			if (_ThemeHiStyle) return _ThemeHiStyle;
				else return "rounded:10";
		}
		
		public function get allowScoredReanswer():Boolean { return _AllowScoredReanswer; }
		public function get interactionNumberOfTries():int { return _IntrNumTries; }
		public function get interactionForceCA():Boolean { return _IntrForceCA; }
		public function get intearctionForceAnswer():Boolean { return _IntrForceAnswer; }
		public function get interactionUseIObj():Boolean { return _IntrUseIObj; }
		
		public function get lmsStudentID():String { return _LMSStudentID; }
		public function get lmsStudentName():String { return _LMSStudentName; }
		
		public function get css():StyleSheet { return _StyleSheet; }
		public function set css(value:StyleSheet):void { 
			_StyleSheet = value;
			//trace(_StyleSheet.styleNames);
		}
		
		public function Settings(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():Settings {
			if (Settings._Instance == null) {
				Settings._Instance = new Settings(new SingletonEnforcer());
				Settings._Instance.setDefaultValues();
			}
			return Settings._Instance;
		}
		
		public function setDataFromModel(m:SiteModel) {
			_ThemeColors = new Array();
			_SiteWidth = m.configSiteWidth;
			_SiteWidth = m.configSiteHeight;
			_PageWidth = m.configDefaultPageWidth;
			_PageHeight = m.configDefaultPageHeight;
			_ThemeColors = m.configThemeColors;
			_ThemeHiColor = m.configThemeHiColor;
			_ThemeHiStyle = m.configThemeHiStyle;
			_AllowScoredReanswer = m.allowScoredReanswer;
			_IntrNumTries = m.iteractionNumberOfTries;
			_IntrForceCA = m.iteractionForceCA;
			_IntrForceAnswer = m.interactionForceAnswer;
			_IntrUseIObj = m.interactionUseIObjs;
		}
		
		public function setDefaultValues():void {
			//trace("Settings, setting default values");
			_VarList = new Array();
			audioEnable = true;
			audioVolume = 1;
			_ZoomFactor = 0;
			_CaptionsEn = false;
			
			// default interaction props for template testing
			_AllowScoredReanswer = true;
			_IntrNumTries = 2;
			_IntrForceCA = false;
			_IntrForceAnswer = true;
			_IntrUseIObj = true;
		}
	
		public function setLMSStudentData(id:String, n:String):void {
			_LMSStudentID = id;
			_LMSStudentName = n;
		}
		
		public function setZoomFactor(z:int):void {
			if (z > ZOOM_FACTOR_MAX) {
				trace("setZoomFactor out of bounds, "+z+" max is " + ZOOM_FACTOR_MAX);
				//return false;
				return;
			}
			//trace("setting zoom to: " + z);
			_ZoomFactor = z;
			dispatchEvent(new Event(Settings.ZOOM_FACTOR_CHANGE));
			//return true;
		}
		
		public function increaseZoomFactor():void {
			if (_ZoomFactor >= ZOOM_FACTOR_MAX) {
				trace("zoom factor at max: " + _ZoomFactor);
				//return false;
				return;
			}
			_ZoomFactor++;
			dispatchEvent(new Event(Settings.ZOOM_FACTOR_CHANGE));
			//return true;
		}
		
		public function decreaseZoomFactor():void {
			if (_ZoomFactor <= ZOOM_FACTOR_MIN) {
				trace("zoom factor at min: " + _ZoomFactor);
				return;
			}
			_ZoomFactor--;
			dispatchEvent(new Event(Settings.ZOOM_FACTOR_CHANGE));
		}
		
		public function getPrefsDataString():String {
			var audEn:String = _AudioEnabled ? "1" : "0";
			var audVol:String = String(_AudioVolume);
			var zoomF:String = String(_ZoomFactor);
			var capEn:String = _CaptionsEn ? "1" : "0";
			var d:String = audEn + _Delimeter + audVol + _Delimeter + zoomF + _Delimeter + capEn;
			return d;
		}
		
		public function parsePrefsSavedStateStr(p:String):Boolean {
			if (p) {
				var data:Array = p.split(_Delimeter);
				_AudioEnabled = data[0] == "1" ? true : false;
				_AudioVolume = Number(data[1]);
				_ZoomFactor = int(data[2]);
				_CaptionsEn = data[3] == "1" ? true : false;
				return true;
			}
			return false;
		}
		
		/* MOVED TO LOGIC
		public function addNewVar(n:String, d:String, t:String):void {
			var o:Object = new Object();
			o.name = n;
			o.data = d;
			o.type = t;
			_VarList.push(o);
		}
		
		public function getVarValue(n:String):String {
			for (var i:int = 0; i, _VarList.length; i++) {
				if (_VarList[i].name == n) return _VarList[i].data;
			}
			return "~~~null~~~";
		}*/
		
	}
}

class SingletonEnforcer {}