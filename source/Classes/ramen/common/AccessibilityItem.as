package ramen.common {
	
	import flash.accessibility.*;
	import flash.system.Capabilities;
	import flash.display.InteractiveObject;
	
	//http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/accessibility/AccessibilityProperties.html
	//http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/display/InteractiveObject.html#tabIndex
	public class AccessibilityItem {
		
		private var _Type				:String;
		private var _Object				:InteractiveObject;
		private var _TabIndex			:int;
		private var _Description		:String;
		private var _Name				:String;
		private var _Shortcut			:String;
		
		private var _ForceSimple		:Boolean = true;
		private var _NoAutoLabeling		:Boolean = false;
		private var _Silent				:Boolean = false;
		
		public function get type():String { return _Type; }
		public function get object():InteractiveObject { return _Object; }
		public function get name():String { return _Name; }
		
		// the manager should handle this
		public function get enabled():Boolean { return Capabilities.hasAccessibility;  }
		
		public function AccessibilityItem(t:String, o:InteractiveObject, i:int, n:String, sct:String = "", d:String = ""):void {
			//if (!enabled) return;
			_Type = t;
			_Object = o;
			_TabIndex = i;
			_Name = n;
			_Shortcut = sct;
			_Description = d;
			initialize();
		}
		
		private function initialize():void {
			//if (!enabled) return;
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.description = _Description;
			accessProps.forceSimple = _ForceSimple;
			accessProps.name = _Name;
			accessProps.noAutoLabeling = _NoAutoLabeling;
			accessProps.shortcut = _Shortcut;
			accessProps.silent = _Silent;
			_Object.accessibilityProperties = accessProps;
			
			if (_TabIndex) {
				_Object.tabEnabled = true;
				_Object.tabIndex = _TabIndex;
			} else {
				_Object.tabIndex = -1;
				_Object.tabEnabled = false;
			}
			
			//trace("## new item: "+accessProps.name+", "+_Object.tabIndex);
			
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		
		public function destroy():void {
			//if (!enabled) return;
			try {
				//trace("## del item: " + _Object.tabIndex);
				_Object.accessibilityProperties = null;
				_Object.tabEnabled = false;
				_Object.tabIndex = -1;
				_Object = null;
			} catch(e:*) {}
		}
		
		
		
	}
	
}