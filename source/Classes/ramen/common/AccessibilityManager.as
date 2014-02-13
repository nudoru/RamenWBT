/*
TODO

	[ ] finalize() function - call http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/accessibility/Accessibility.html#updateProperties()
//http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/events/FocusEvent.html
*/
package ramen.common {
	
	import com.nudoru.utils.RecurseDisplayList;
	import flash.display.InteractiveObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.accessibility.*;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	//import fl.managers.FocusManager;

	import com.senocular.ui.*;
	
	public class AccessibilityManager extends EventDispatcher{
		
		static private var _Instance	:AccessibilityManager;
		
		private var _Initd				:Boolean;
		
		private var _Enabled			:Boolean;
		
		private var _Stage				:Stage;
		
		private var _FocusLayer			:Sprite;
		private var _FocusRect			:Sprite;
		
		private var _Items				:Array;
		
		// the first tab press after the next button gets turned on should hit the next button
		private var _NextEnabledFl		:Boolean;
		private var _TheNextButton		:SimpleButton;
		
		// the first tab press after the next button gets turned on should hit the next button
		private var _CloseEnabledFl		:Boolean;
		private var _TheCloseButton		:*;
		
		private var _CurrentTarget		:InteractiveObject;
		
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
		
		public function get nextEnabledFl():Boolean { return _NextEnabledFl; }
		public function set nextEnabledFl(value:Boolean):void { 
			trace("SET, next force: " + value);
			_NextEnabledFl = value;
		}
		
		public function get theNextButton():SimpleButton { return _TheNextButton; }
		public function set theNextButton(value:SimpleButton):void {
			trace("SET, next button: " + value);
			_TheNextButton = value;
		}
		
		public function get closeEnabledFl():Boolean { return _CloseEnabledFl; }
		public function set closeEnabledFl(value:Boolean):void { 
			trace("SET, close force: " + value);
			_CloseEnabledFl = value;
		}
		
		public function get theCloseButton():* { return _TheCloseButton; }
		public function set theCloseButton(value:*):void {
			trace("SET, close button: " + value);
			_TheCloseButton = value;
		}
		
		public function AccessibilityManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():AccessibilityManager {
			if (AccessibilityManager._Instance == null) {
				AccessibilityManager._Instance = new AccessibilityManager(new SingletonEnforcer());
			}
			return AccessibilityManager._Instance;
		}
	
		public function initialize(s:InteractiveObject, en:Boolean, fl:Sprite = null):void {
			if (initd) return;
			initd = true;
			
			_Stage = s.stage;
			_Stage.stageFocusRect = true;
			
			// focus layer display a little off. doesn't add more value than the standard focus rect
			if (fl && false) {
				//trace("$$$ focus layer defined!");
				_FocusLayer = fl;
				_Stage.stageFocusRect = false;
			}
			
			_Enabled = en;
			if (!_Enabled) return;
			
			_Items = new Array();
			_TabIdxCntrActivity = TABIDX_ACTIVITY;
			_TabIdxCntrMedia = TABIDX_MEDIA;
			_TabIdxCntrFramework = TABIDX_FRAMEWORK;

			_Vmouse = new VirtualMouse(_Stage);
		}
		
		public function addActivityItem(o:InteractiveObject, n:String, sct:String = "", d:String = ""):void {
			//trace("$$$ access, add act item: " + n);
			addItem(AccessibilityItemType.ACTIVITY, o, _TabIdxCntrActivity++, n, sct, d);
		}
		
		public function addMediaItem(o:InteractiveObject, n:String, sct:String = "", d:String = ""):void {
			addItem(AccessibilityItemType.MEDIA, o, _TabIdxCntrMedia++, n, sct, d);
		}
		
		public function addFrameworkItem(o:InteractiveObject, n:String, sct:String = "", d:String = ""):void {
			addItem(AccessibilityItemType.FRAMEWORK, o, _TabIdxCntrFramework++, n, sct, d);
		}
		
		public function addActivityTextItem(o:*, n:String):void {
			o.tabEnabled = true;
			o.tabIndex = _TabIdxCntrActivity++;
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.description = n;
			o.accessibilityProperties = accessProps;
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		
		public function addMediaTextItem(o:*, n:String):void {
			o.tabEnabled = true;
			o.tabIndex = _TabIdxCntrMedia++;
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.description = n;
			o.accessibilityProperties = accessProps;
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		
		public function addFrameworkTextItem(o:*, n:String):void {
			o.tabEnabled = true;
			o.tabIndex = _TabIdxCntrFramework++;
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.description = n;
			o.accessibilityProperties = accessProps;
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		
		private function addItem(t:String, o:InteractiveObject, i:int, n:String, sct:String, d:String):void {
			if (!enabled) return;
			_Items.push(new AccessibilityItem(t, o, i, n, sct, d));
			o.addEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
		}
		
		public function removeItemBySprite(o:InteractiveObject):void {
			if (!enabled) return;
			for (var i:int = 0; i < _Items.length; i++) {
				if (_Items[i].object == o) {
					//trace("$$$ access, remove act item: " + _Items[i].name);
					try {
						_Items[i].object.removeEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
					} catch (e:*) { }
					_Items[i].destroy();
					_Items.splice(i, 1);
				}
			}
		}
		
		public function makeItemNonAccessible(o:InteractiveObject):void {
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
					try {
						_Items[i].object.removeEventListener(FocusEvent.FOCUS_IN, onObjectFocus);
					} catch (e:*) { }
					_Items[i].destroy();
					_Items.splice(i, 1);
				}
			}
		}
		
		public function removeAllNonFrameworkItems():void {
			removeAllItemsOfType(AccessibilityItemType.ACTIVITY);
			removeAllItemsOfType(AccessibilityItemType.MEDIA);
			_TabIdxCntrActivity = TABIDX_ACTIVITY;
			_TabIdxCntrMedia = TABIDX_MEDIA;
		}
		
		private function onObjectFocus(e:FocusEvent):void {
			if (_CurrentTarget) {
				dispatchEvent(new AccessibilityFocusEvent(AccessibilityFocusEvent.FOCUS_OUT, getCurrentFocusItem()));
			}
			var ct:InteractiveObject = e.currentTarget as InteractiveObject;
			if (closeEnabledFl && theCloseButton) {
				trace("$$$ acc focus: focusing close button")
				_Stage.focus = theCloseButton;
				closeEnabledFl = false;
				ct = theCloseButton as InteractiveObject;
			} else if (nextEnabledFl && theNextButton) {
				trace("$$$ acc focus: focusing next")
				_Stage.focus = theNextButton;
				nextEnabledFl = false;
				ct = theNextButton as InteractiveObject;
			}
			_CurrentTarget = InteractiveObject(ct);
			trace("$$$ acc focus: " + getCurrentFocusItem().name + " " + _CurrentTarget);
			//if (_CurrentTarget is fl.controls.UIScrollBar) trace("scroll bar!");
			//RecurseDisplayList.traceFullDisplayList(_CurrentTarget);
			//showFocusRect();
			dispatchEvent(new AccessibilityFocusEvent(AccessibilityFocusEvent.FOCUS_IN, getCurrentFocusItem()));
		}
		
		/*private function showFocusRect():void {
			if (_FocusLayer) {
				clearFocusRect();
				var brdr:int = 1;
				var lcoord:Point = new Point(1, 1);
				var gcoord:Point = _CurrentTarget.localToGlobal(lcoord);
				_FocusRect = new FocusRect();
				_FocusRect.x = gcoord.x - brdr;
				_FocusRect.y = gcoord.y - brdr;
				_FocusRect.scaleX = (_CurrentTarget.width + (brdr*2)) * .01;
				_FocusRect.scaleY = (_CurrentTarget.height + (brdr*2)) * .01;
				_FocusLayer.addChild(_FocusRect);
			}
		}
		
		private function clearFocusRect():void {
			if (_FocusRect) _FocusLayer.removeChild(_FocusRect);
		}*/
		
		public function clearFocus():void {
			//trace("$$$ clearing focus");
			_CurrentTarget = null;
			_Stage.focus = null;
		}
		
		public function getCurrentFocusObject():InteractiveObject {
			return _CurrentTarget;
		}
		
		private function getItemFromObject(d:InteractiveObject):AccessibilityItem {
			for (var i:int = 0; i < _Items.length; i++) {
				if (_Items[i].object == d) {
					return _Items[i] as AccessibilityItem;
				}
			}
			return null;
		}

		public function getCurrentFocusItem():AccessibilityItem {
			return getItemFromObject(_CurrentTarget);
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
			//trace("$$$ v mouse activated at: " + gcoord.x +", "+gcoord.y);
			_Vmouse.x = gcoord.x + 1;
			_Vmouse.y = gcoord.y + 1;
			_Vmouse.click();
			// vmouse class works better - not sure why yet
			//_CurrentTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
	}
}

class SingletonEnforcer {}