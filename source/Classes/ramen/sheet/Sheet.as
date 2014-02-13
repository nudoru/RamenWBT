package ramen.sheet {
	
	import com.nudoru.utils.GUID;
	import flash.display.DisplayObject;
	import ramen.common.*;
	import ramen.page.*;
	import ramen.sheet.*;
	
	import flash.display.Sprite;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.*;
	import flash.net.*;
	import fl.motion.Animator;
	import fl.motion.MotionEvent;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.RandomLatin;
	
	public class Sheet extends Sprite {
		
		private var _Started					:Boolean;
		private var _Initialized				:Boolean;
		
		private var _id							:String;
		
		private var _XMLData					:XMLList;
		private var _TargetSprite				:Sprite;
		private var _EventManager				:POEventManager;
		
		private var _PageObjects				:Array;
		private var _AnimationSeqs				:Array;
		
		private var _DLog						:Debugger;
		
		public static const RENDERED			:String = "rendered";
		public static const PARSING_ERROR		:String = "parsing_error";

		public function get id():String { return _id; };
		
		public function get HasPOMouseEvents():Boolean { return _EventManager.hasMouseEvents }
		public function get HasPOTimerEvents():Boolean { return _EventManager.hasTimedEvents }

		public function Sheet():void {
			_DLog = Debugger.getInstance();
			_Initialized = false;
		}
		
		public function initialize(x:XMLList, t:Sprite):void {
			_Initialized = true;
			_XMLData = x;
			_id = _XMLData.@id;
			if (!_id) _id = GUID.getGUID();
			_TargetSprite = t;
			_EventManager = new POEventManager(this);
			// added to the display list for event bubbling
			addChild(_EventManager);
			_PageObjects = new Array();
			_AnimationSeqs = new Array();

			parseSheetXML(_XMLData);
			
			SheetManager.getInstance().registerSheet(id, this);
			//parseAnimationSeq(_XMLData.animationsequences);
		}
		
		public function start():void {
			if (_Started || !_Initialized) return;
			_Started = true;
			_EventManager.start();
			beginPOAnimations();
		}
		
		public function stop():void {
			if (!_Initialized) return;
			_Started = false;
			_EventManager.stop();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// PO Loaded

		private function onPOLoaded(e:Event):void {
			checkPOsLoaded()
		}
		
		public function checkSheetLoaded():void {
			checkPOsLoaded();
		}
		
		private function checkPOsLoaded():void {
			var c:int = 0;
			var len = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				if (_PageObjects[i].loaded) c++;
			}
			if (c == len || !len) {
				clearPOLoadedEvents();
				dispatchEvent(new Event(Sheet.RENDERED));
			}
		}
		
		private function clearPOLoadedEvents():void {
			var len = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				_PageObjects[i].removeEventListener(PageObject.LOADED, onPOLoaded);
			}
		}
		
		public function beginPOAnimations():void {
			var len = _PageObjects.length;
			if (!len) return;
			for (var i:int = 0; i < len; i++) {
				//trace("begin: " + _PageObjects[i]);
				_PageObjects[i].beginAnimations();
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// for event lists
		
		public function addEventList(e:XMLList, t:*):void {
			//_DLog.addDebugText("Sheet, reg events: "+t.id);
			_EventManager.addEventList(e, t);
			// TODO - sould be more descrimimating about what it adds?
			// for mouse events
			t.addEventListener(POEvent.PO_ROLLOVER, onPORollOver);
			t.addEventListener(POEvent.PO_ROLLOUT, onPORollOut);
			t.addEventListener(POEvent.PO_CLICK, onPOClick);
			t.addEventListener(POEvent.PO_RELEASE, onPORelease);
			// for playback events
			t.addEventListener(POEvent.PO_START, onPOPBStart);
			t.addEventListener(POEvent.PO_PLAY, onPOPBPlay);
			t.addEventListener(POEvent.PO_PAUSE, onPOPBPause);
			t.addEventListener(POEvent.PO_STOP, onPOPBStop);
			t.addEventListener(POEvent.PO_FINISH, onPOPBFinish);
		}
		
		private function onPORollOver(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_ROLLOVER, e.targetID);
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "po_rollover_event"));
		}
		private function onPORollOut(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_ROLLOUT, e.targetID);
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "po_rollout_event"));
		}
		private function onPOClick(e:POEvent):void {
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "po_click_event"));
			_EventManager.performEvent(POEvent.PO_CLICK, e.targetID);
		}
		private function onPORelease(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_RELEASE, e.targetID);
		}
		private function onPOPBStart(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_START, e.targetID);
		}
		private function onPOPBPlay(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_PLAY, e.targetID);
		}
		private function onPOPBPause(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_PAUSE, e.targetID);
		}
		private function onPOPBStop(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_STOP, e.targetID);
		}
		private function onPOPBFinish(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_FINISH, e.targetID);
		}
		
		// should only be called by POEventManager
		public function getPOByID(id:String):* {
			var len:int = _PageObjects.length;
			for(var i:int=0; i<len; i++) {
				if(_PageObjects[i].id == id) return _PageObjects[i];
			}
			_DLog.addDebugText("Sheet, PO ID not found: "+id);
			return undefined;
		}
		
		public function getPOSpriteByID(id:String):Sprite {
			return getPOByID(id).container;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// animation sequence
		
		public function playAnimationIDonPO(aid:String, poid:String):void {
			trace("play animation " + aid + " on " + poid);
			var po:Sprite = getPOSpriteByID(poid);
			var a:XML = getAnimationSeqMotionByID(aid).children()[0];
			if (!po || !a) return;
			createAnimationbyID(aid, a, po, true);
		}
		
		private function createAnimationbyID(aid:String, axml:XML, d:Sprite, p:Boolean):void {
			var aidx:int = getAnimationSeqIdxByID(aid);
			if (aidx < 0 || !d) return;
			_AnimationSeqs[aidx].animator = new Animator(axml, d);
			if(p) _AnimationSeqs[aidx].animator.play()
		}
		
		public function getAnimationSeqMotionByID(id:String):XML {
			var aidx:int = getAnimationSeqIdxByID(id);
			if (aidx < 0) return undefined;
			return XML(_AnimationSeqs[aidx].xml);
		}
		
		private function getAnimationSeqIdxByID(id:String):int {
			var len:int = _AnimationSeqs.length;
			for (var i:int = 0; i < len; i++) {
				if(_AnimationSeqs[i].id == id) return i;
			}
			_DLog.addDebugText("PageRenderer, Animation Seq not found: "+id);
			return -1;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// parsing
		
		private function parseSheetXML(d:XMLList):void {
			//_DLog.addDebugText("Sheet, parsing XML ...");
			var len:int = d.object.length();
			for(var i:int = 0; i<len; i++) {
				var o:IPageObject = POFactory.createPO(d.object[i].@type, this, _TargetSprite, XMLList(d.object[i]));
				if (o) {
					_PageObjects.push(o);
					_PageObjects[_PageObjects.length - 1].addEventListener(PageObject.LOADED, onPOLoaded);
				}
			}
			validatePOIDs();
			// checks to see if all POs are loaded
			checkPOsLoaded();
		}
		
		// just a dev helper function - checks for duplicate IDs
		private function validatePOIDs():void {
			var dupeCntr:int = 0;
			for (var i:int = 0; i < _PageObjects.length; i++) {
				var cID = _PageObjects[i].id;
				dupeCntr = 0;
				for (var k:int = 0; k < _PageObjects.length; k++) {
					if (cID == _PageObjects[k].id) {
						if (++dupeCntr > 1) {
							dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", dupeCntr+" page objects have the same ID on this page: '" + cID+"'<br><br>This will cause unexpected behavior with events on these objects."));
						}
					}
				}
			}
		}
		
		private function parseAnimationSeq(d:XMLList):void {
			//_DLog.addDebugText("PageRenderer, animation sequences");
			var len:int = _XMLData.animationsequences.animation.length();
			for(var i:int = 0; i<len; i++) {
				var o:Object = new Object();
				o.id = _XMLData.animationsequences.animation[i].@id;
				o.xml = _XMLData.animationsequences.animation[i];
				_AnimationSeqs.push(o);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// other
		
		public function destroy():void {
			//trace("destroy sheet ...");
			if (!_Initialized) return;
			
			SheetManager.getInstance().unregisterSheet(id);
			
			if(_Started) stop();
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				//trace("destroying object:" + _PageObjects[i]);
				if(_PageObjects[i].hasEvents) {
					_PageObjects[i].removeEventListener(POEvent.PO_ROLLOVER, onPORollOver);
					_PageObjects[i].removeEventListener(POEvent.PO_ROLLOUT, onPORollOut);
					_PageObjects[i].removeEventListener(POEvent.PO_CLICK, onPOClick);
					_PageObjects[i].removeEventListener(POEvent.PO_RELEASE, onPORelease);
					_PageObjects[i].removeEventListener(POEvent.PO_START, onPOPBStart);
					_PageObjects[i].removeEventListener(POEvent.PO_PLAY, onPOPBPlay);
					_PageObjects[i].removeEventListener(POEvent.PO_PAUSE, onPOPBPause);
					_PageObjects[i].removeEventListener(POEvent.PO_STOP, onPOPBStop);
					_PageObjects[i].removeEventListener(POEvent.PO_FINISH, onPOPBFinish);
				}
				_PageObjects[i].removeEventListener(PageObject.LOADED, onPOLoaded);
				_PageObjects[i].destroy();
				_PageObjects[i].cleanUp();
			}
			_PageObjects = new Array();
			
			removeChild(_EventManager);
			_EventManager.destroy();
			
			_XMLData = null;
			_EventManager = null;
		}
		
	}
	
}