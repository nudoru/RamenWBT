/*
List template
*/

package ramen.page {
	
	import flash.accessibility.AccessibilityImplementation;
	import flash.geom.Point;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class ListTemplate extends Template {
		
		// vars
		protected var _State					:int;
		protected var _Lists					:Array;
		protected var _CurrentList				:int;
		protected var _CurrentItem				:int;
		protected var _Animate					:Boolean = true;

		protected var _CurrentSheet				:Sheet;
		
		// conts
		public static const LETTER_LIST			:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "l", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
		public static const STATE_INIT			:int = 0;
		public static const STATE_READY			:int = 1;
		public static const STATE_CORRECT		:int = 2;
		public static const STATE_WRONG			:int = 3;
		public static const STATE_NEUTRAL		:int = 4;
		public static const STATE_DISABLED		:int = 5;
		
		// events
		public static const STAGE_CHANGE		:String = "stage_change";
		public static const MARK_COMPLETE		:String = "mark_complete";

		
		// getters/setters
		public function get state():int { return _State }
		public function set state(s:int) {
			if (_State == s) return;
			_State = s;
			dispatchEvent(new Event(STAGE_CHANGE));
		}
		
		public function get numLists():int { return _Lists.length }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// init
		
		// constructor
		public function ListTemplate():void {
			// initialized the template and will trigger renderPageCustomContent()
			super();
		}
		
		// all template specific stuff goes here
		override protected function renderInteraction():void {
			state = STATE_INIT;

			_CurrentList = 0;
			
			// get the XML from the pages' <customcontent> block
			parseLists(_PageRenderer.interactionXML);			
			renderItems();
		}
		
		protected function parseLists(x:XMLList) {
			_Lists = new Array();
			var len:int = x.list.length();
			for (var i:int = 0; i < len; i++) {
				_Lists.push(new PageList(x.list[i]));
			}
		}
		
		override protected function startInteraction():void {
			//trace("start interaction");
			state = STATE_READY;
			_Lists[_CurrentList].start();
			//dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		// must be overridden by subclasses
		protected function renderItems():void { }
		
		// must be overridden by subclasses
		protected function enableItem(l:int, c:int):void { }
		
		protected function enableAllItems(l:int, r:Boolean=true):void {
			if(r) resetAllItems(l);
			var len:int = _Lists[l].numItems;
			for (var i:int = 0; i < len; i++) {
				enableItem(l, i);
			}
		}
		
		// must be overridden by subclasses
		protected function disableItem(l:int, c:int):void { }
		
		protected function disableAllItems(l:int):void {
			var len:int = _Lists[l].numItems;
			for (var i:int = 0; i < len; i++) {
				disableItem(l, i);
			}
		}
		
		// must be overridden by subclasses
		
		// could be passed mouse events from buttons
		protected function prevItem(e:*=null):void { }
		protected function nextItem(e:*=null):void { }
		
		protected function setItem(l:int, c:int):void { }
		
		protected function loadCurrentItemSheet(t:Sprite):void {
			if (_CurrentSheet) unloadCurrentItemSheet();
			var cisheetXML:XMLList = _Lists[_CurrentList].getItemSheetXML(_CurrentItem);
			if (cisheetXML) {
				_CurrentSheet = new Sheet();
				_CurrentSheet.initialize(cisheetXML, t);
				_CurrentSheet.addEventListener(Sheet.RENDERED, onSheetRendered);
				_CurrentSheet.checkSheetLoaded();
			}
		}
		
		protected function onSheetRendered(e:Event):void {
			_CurrentSheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
			_CurrentSheet.start();
		}
		
		protected function unloadCurrentItemSheet():void {
			if (_CurrentSheet) {
				_CurrentSheet.stop();
				_CurrentSheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
				_CurrentSheet.destroy();
				_CurrentSheet = null;
			}
		}
		
		protected function removeLastItem():void { }
		
		protected function resetItem(l:int, c:int):void { }
		
		protected function resetAllItems(l:int):void {
			var len:int = _Lists[l].numItems;
			for (var i:int = 0; i < len; i++) {
				resetItem(l, i)
			}
		}
		
		// must be overridden by subclasses
		protected function onItemOver(e:Event):void { }
		
		// must be overridden by subclasses
		protected function onItemOut(e:Event):void { }
		
		// must be overridden by subclasses
		protected function onItemClick(e:Event):void { }
		
		protected function disableInteraction(fade:Boolean = true):void {
			if (debugMode && !standaloneMode) return;
			disableAllLists();
			if(fade) TweenLite.to(_PageRenderer.interactionLayer, 5, { alpha:.75, ease:Quadratic.easeIn } );
		}
		
		protected function enableInteraction(f:Boolean=true):void {
			enableAllLists(f);
			if(_PageRenderer.interactionLayer.alpha < 1) TweenLite.to(_PageRenderer.interactionLayer, .5, { alpha:1, ease:Quadratic.easeOut } );
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI buttons
		
		// must be overridden by subclasses
		protected function configureButtons():void { }
		
		// must be overridden by subclasses
		protected function updateButtons():void {}

		//----------------------------------------------------------------------------------------------------------------------------------
		// util
		
		protected function enableAllLists(f:Boolean=true):void {
			var len:int = _Lists.length;
			for (var i:int = 0; i < len; i++) {
				enableAllItems(i, f);
			}
		}
		
		protected function disableAllLists():void {
			var len:int = _Lists.length;
			for (var i:int = 0; i < len; i++) {
				disableAllItems(i);
			}
		}
		
		protected function stopAllLists():void {
			var len:int = _Lists.length;
			for (var i:int = 0; i < len; i++) {
				_Lists[i].stop();
			}
		}
		
		// for DND types
		protected function getLocalizedMousePoint():Point {
			var mp:Point = new Point(this.stage.mouseX, this.stage.mouseY);
			var lp:Point = _PageRenderer.interactionLayer.globalToLocal(mp);
			//trace("global: " + mp.x + ", " + mp.y);
			//trace("   local: " + lp.x + ", " + lp.y+", dif: "+(mp.x-lp.x)+","+(mp.y-lp.y));
			return mp;
		}
		
		protected function showInstructions():void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createInstructionsPopUpXML(PopUpType.SIMPLE, "Instructions", _Lists[_CurrentList].instruction, "", false, false)));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// from player
		
		protected function createPopUp(type:String,t:String, m:String, mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(type, t, m, "", mdl, pmdl, pst)));
		}
		
		protected function message(t:String, m:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.SIMPLE, t, m, "", mdl, pst)));
		}

		protected function createPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_BOTTOM+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		protected function createCentPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_HIGH_MIDDLE+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		protected function createInstructionsPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='intr_instructions' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_RIGHT+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_TOP+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
		override public function handlePopUpEvent(e:PopUpEvent):void {
			trace("template from PM, type: " + e.type + ", from: " + e.data + " to: " + e.callingobj + " about: " + e.buttondata);
		}
		
		override public function handleKeyPress(k:int, isAlt:Boolean = false, isCtrl:Boolean = false, isShift:Boolean = false, l:int=0):void {
			//trace("template from PM, keycode: " + k + " alt: " + isAlt + " ctrl: " + isCtrl + " shift: " + isShift + " location: " + l);
			// A-z
			if(k >= KeyDict.ALPHA_START && k <= KeyDict.ALPHA_END) {
				var pressed:int = k-KeyDict.ALPHA_START;
				setItem(_CurrentList, pressed);
			}
			// control + enter
			//if (k == KeyDict.ENTER && isCtrl) onSubmitClick(undefined);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			// destroy interaction specific content in subclasses
			unloadCurrentItemSheet();
			super.destroy();
		}
		
	}
}