/*
Debug Log class
Last updated 3.31.09
*/

package com.nudoru.utils {
	
	import flash.text.TextField;
	
	public class Debugger {
		
		static private var _Instance	:Debugger;
		
		private var _Initd			:Boolean;
		private var _DebugText		:Array;
		private var _OutputField	:TextField;
		private var _Verbose		:Boolean;
		
		public function Debugger(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():Debugger {
			if (Debugger._Instance == null) {
				Debugger._Instance = new Debugger(new SingletonEnforcer());
			}
			return Debugger._Instance;
		}
		
		public function init():void {
			if(!_DebugText) _DebugText = new Array();
			_Verbose = true;
			_Initd = true;
		}
		
		public function addDebugText(txt:String):void {
			if (!_Initd) init();
			_DebugText.push(txt);
			updateOutputField();
			if(_Verbose) trace("# "+txt);
		}
	
		public function setOutputField(f:TextField):void {
			_OutputField = f;
		}
	
		private function updateOutputField():void {
			
			if(!_OutputField) return;
			_OutputField.text = "";
			var len:int = _DebugText.length-1;
			for(var i:int = len; i>0; i--) {
				_OutputField.appendText(_DebugText[i]+"\n");
			}
		}
	
	}
	
}

class SingletonEnforcer {}