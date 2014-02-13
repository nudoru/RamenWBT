/*
TODO

	[ ] finalize() function - call http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/accessibility/Accessibility.html#updateProperties()
//http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/events/FocusEvent.html
*/
package ramen.common {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.accessibility.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import com.senocular.ui.*;
	
	public class AccessibilityManager extends EventDispatcher{
		
		static private var _Instance	:AccessibilityManager;
		
		private var _Initd				:Boolean;
		
		private var _Enabled			:Boolean;
		
		private var _Items				:Array;
		
		private var _CurrentTarget		:Sprite;
		
		private var _TabIdxCntrActivity	:int;
		private var _TabIdxCntrMedia	:int;
		private var _TabIdxCntrFramework:int;
		
		private var _Vmouse				:VirtualMouse;
		
		private var TABIDX_ACTIVITY		:int = 1;
		private var TABIDX_MEDIA		:int = 20;
		private var TABIDX_FRAMEWORK	:int = 30;

		public function get initd():Boolean { return _Initd; }
		public function set initd(value:Boolean):void { _Initd = value; }
		
		public function get enabled():Boolean { 
			//trace("get acc en: " + _Enabled);
			if (!_Enabled) return false;
			return true;
			//return Capabilities.hasAccessibility;
		}
		
		public function AccessibilityManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():AccessibilityManager {
			if (AccessibilityManager._Instance == null) {
				AccessibilityManager._Instance = new AccessibilityManager(new SingletonEnforcer());
			}
			return AccessibilityManager._Instance;
		}
	
		public function initialize(s:Sprite, en:Boolean):void {
			if (initd) return;
			initd = true;
			
			_Enabled = en;
			if (!_Enabled) return;
			
			_Items = new Array();
			_TabIdxCntrActivity = TABIDX_ACTIVITY;
			_TabIdxCntrMedia = TABIDX_MEDIA;
			_TabIdxCntrFramework = TABIDX_FRAMEWORK;
			trace("stage: " + s);
			_Vmouse = new VirtualMouse(s.stage);
		}
		
		public function addActivityItem(o:Sprite, n:String, sct:String = "", d:String = ""):void {
			trace("$$$ access, add act item: " + n);
			addItem(AccessibilityItemType.ACTIVITY, o, _TabIdxCntrActivity++, n, sct, d);
		}
		
		public function addMediaItem(o:Sprite, n:String, sct:String = "", d:String = ""):void {
			addItem(AccessibilityItemType.MEDIA, o, _TabIdxCntrMedia++, n, sct, d);
		}
		
		public function addFrameworkItem(o:Sprite, n:String, sct:String = "", d:String = ""):void {
			addItem(AccessibilityItemType.FRAMEWORK, o, _TabIdxCntrFramework++, n, sct, d);
		}
		
		private function addItem(t:String, o:Sprite, i:int, n:String, sct:String, d:String):void {
			if (!enabled) return;
			_Items.push(new AccessibilityItem(t, o, i, n, sct, d));
			o.addEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
		}
		
		public function removeItemBySprite(o:Sprite):void {
			if (!enabled) return;
			for (var i:int = 0; i < _Items.length; i++) {
				if (_Items[i].object == o) {
					trace("$$$ access, add act item: " + _Items[i].name);
					_Items[i].destroy();
					try {
						_Items[i].object.removeEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
					} catch(e:*) {}
					_Items.splice(i, 1);
				}
			}
		}
		
		public function makeItemNonAccessible(o:Sprite):void {
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.silent = true;
			o.accessibilityProperties = accessProps;
			o.tabIndex = -1;
			o.tabEnabled = false;
		}
		
		private function removeAllItemsOfType(t:String):void {
			if (!enabled) return;
			for (var i:int = 0; i < _Items.length; i++) {
				if (_Items[i].type == t) {
					_Items[i].destroy();
					try {
						_Items[i].object.removeEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
					} catch(e:*) {}
					_Items.splice(i, 1);
				}
			}
		}
		
		public function removeAllNonFrameworkItems():void {
			removeAllItemsOfType(AccessibilityItemType.ACTIVITY);
			removeAllItemsOfType(AccessibilityItemType.MEDIA);
			_TabIdxCntrActivity = TABIDX_ACTIVITY;
			_TabIdxCntrMedia = TABIDX_MEDIA;
			clearFocus();
		}
		
		private function onObjectFocus(e:FocusEvent):void {
			trace("foc: " + e.currentTarget);
			_CurrentTarget = Sprite(e.currentTarget);
		}
		
		public function clearFocus():void {
			_CurrentTarget = null;
		}
		
		public function getCurrentFocusObject():Sprite {
			return _CurrentTarget;
		}
		
		public function anyFocusedObject():Boolean {
			if (_CurrentTarget == null) return false;
			return true;
		}
		
		public function activateCurrentTarget():void {
			if (!enabled) return;
			if (!_CurrentTarget) return;
			var lcoord:Point = new Point(1, 1);
			var gcoord:Point = _CurrentTarget.localToGlobal(lcoord);
			trace("v mouse at: " + gcoord.x +", "+gcoord.y);
			_Vmouse.x = gcoord.x + 1;
			_Vmouse.y = gcoord.y +	1;
			_Vmouse.click();
			trace("activate current");
		}
		
	}
}

class SingletonEnforcer {}