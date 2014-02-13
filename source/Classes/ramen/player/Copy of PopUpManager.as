/*
Manages PopUps
*/

package ramen.player {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.events.*;
	import ramen.player.AbstractView;
	
	import ramen.common.*;
	
	import com.nudoru.utils.GUID;
	
	import com.greensock.TweenLite;
	import com.greensock.TweenFilterLite;
	import fl.motion.easing.*;
	
	public class  PopUpManager extends Sprite {
		
		static private var _Instance		:PopUpManager;
		
		private var _SiteView				:AbstractView;
		private var _PopUpLayer				:Sprite;
		
		private var _PopUpTarget			:Sprite;
		private var _ModalBG				:Sprite;
		private var _PageModalBG			:Sprite;
		
		private var _PopUpList				:Array;
		private var _CurrentPopUp			:int;
		
		private var _TransparentDrag		:Boolean = true;
		private var _AnimateOpen			:Boolean = true;
		private var _AnimateClose			:Boolean = true;

		private var _Settings				:Settings;
		private var _AutoContent			:AutoContent = new AutoContent();
		
		public static const DEFAULT_WIDTH	:int = 300;
		public static const DEFAULT_BORDER	:int = 10;
		public static const DEFAULT_BTN_WIDTH:int = 100;
		
		public static const STOP_AT_BORDERS	:Boolean = false;
		
		// events
		public static const POPUPEVENT		:String = "popupevent";
		public static const MODAL_ON		:String = "modal_on";
		public static const MODAL_OFF		:String = "modal_off";
		public static const POPUP_OPENED	:String = "popup_opened";
		public static const POPUP_CLOSED	:String = "popup_closed";
		public static const ALL_POPUPS_CLOSED:String = "all_popups_closed";
		
		// getter/setter
		public function get modalShowing():Boolean { 
			if (_ModalBG.visible) return true;
			if (_PageModalBG.visible) return true;
			return false;
		}
		
		public function PopUpManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():PopUpManager {
			if (PopUpManager._Instance == null) {
				PopUpManager._Instance = new PopUpManager(new SingletonEnforcer());
			}
			return PopUpManager._Instance;
		}
		
		public function initialize(v:AbstractView):void {
			_Settings = Settings.getInstance();
			
			_SiteView = v;
			_PopUpTarget = _SiteView.popUpContainer;
			_PopUpTarget.stage.addEventListener(Event.RESIZE, onBrowserWindowResize);
			
			createModalBG();
			
			_PopUpLayer = new Sprite();
			_PopUpLayer.name = "PopUpManager_PULAYER";
			_PopUpTarget.addChild(_PopUpLayer);
			
			_PopUpList = new Array();
			
			// this needs to match the list in PopUpEvent.as
			addEventListener(PopUpEvent.BUTTON_CLICK, onPopUpEvent);
			addEventListener(PopUpEvent.OK, onPopUpEvent);
			addEventListener(PopUpEvent.CANCEL, onPopUpEvent);
			addEventListener(PopUpEvent.CLOSE, onPopUpEvent);
			addEventListener(PopUpEvent.EXIT_MODULE, onPopUpEvent);
			addEventListener(PopUpEvent.YES, onPopUpEvent);
			addEventListener(PopUpEvent.NO, onPopUpEvent);
			addEventListener(PopUpEvent.DATA, onPopUpEvent);
			addEventListener(PopUpEvent.START_DRAG, onPopUpEvent);
			addEventListener(PopUpEvent.STOP_DRAG, onPopUpEvent);
			
			_CurrentPopUp = -1;
		}

		//TODO - needs to assign default values if the object does't contain them
		private function createPopUpDataObjectFromEventObj(o:Object):PopUpDataObject {
			trace("popup data from object");
			var d = new PopUpDataObject();
			d.objdata = o;
			d.xmldata = undefined;
			d.modal = o.modal;
			d.title = _AutoContent.applyContentFunction(o.title);
			d.content = _AutoContent.applyContentFunction(o.content);
			d.buttons = o.buttons ? o.buttons.split(",") : ["OK"];
			d.icon = o.icon;
			d.draggable = true;
			d.usermoved = false;
			d.hposition = o.hposition ? o.hposition : ObjectStatus.CENTER;
			d.vposition = o.vposition ? o.vposition : ObjectStatus.MIDDLE;
			d.width = o.width;
			d.height = o.height;
			return d;
		}
		
		private function createPopUpDataObjectFromEventXML(x:XML):PopUpDataObject {
			var d:PopUpDataObject = new PopUpDataObject(x);
			return d;
		}
		
		private function onPopUpEvent(e:PopUpEvent) {
			//trace("popupevent: " + e.type + " from " + e.windowguid);
			switch (e.type) {
				case PopUpEvent.START_DRAG:
					raisePopUpToTop(getPopUpSpriteFromGUID(e.windowguid));
					handleWindowStartDraging(getPopUpObjectFromGUID(e.windowguid));
					break;
				case PopUpEvent.STOP_DRAG:
					handleWindowStopDraging(getPopUpObjectFromGUID(e.windowguid));
					break;
				case PopUpEvent.BUTTON_CLICK:
					handleButtonClick(getPopUpObjectFromGUID(e.windowguid),e.data);
					break;
				case PopUpEvent.CLOSE:
					closePopUp(getPopUpIndexFromGUID(e.windowguid),"closed")
					break;
				case PopUpEvent.EXIT_MODULE:
					// leave the popup here, but remove the buttons
					removeButtons(_PopUpList[getPopUpIndexFromGUID(e.windowguid)]);
					break;
				default:
					//trace("unsupported type: " + e.type);
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Unsupported pop up type: '" + e.type+"'"));
			}
		}
		
		//gets the popup index with GUID
		private function getPopUpIndexFromGUID(g:String):int {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].guid == g) return i;
			}
			return -1;
		}
		
		//gets the popup index from the window sprite
		private function getPopUpIndexFromWindow(w:*):int {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].window == w) return i;
			}
			return -1;
		}
		
		//gets the popupdataobject with GUID
		private function getPopUpObjectFromGUID(g:String):PopUpDataObject {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].guid == g) return PopUpDataObject(_PopUpList[i]);
			}
			return undefined;
		}
		
		//gets the window sprite with GUID
		private function getPopUpSpriteFromGUID(g:String):Sprite {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].guid == g) return _PopUpList[i].window;
			}
			return undefined;
		}
		
		// puts the window on top
		private function raisePopUpToTop(w:Sprite):void {
			if (!w) return;
			_PopUpLayer.setChildIndex(w, _PopUpLayer.numChildren-1);
		}
		
		private function handleWindowStartDraging(p:PopUpDataObject):void {
			if (!p) return;
			p.usermoved = true;
			if(_TransparentDrag) p.window.alpha = .75;
			_CurrentPopUp = getPopUpIndexFromGUID(p.guid);
		}
		
		private function handleWindowStopDraging(p:PopUpDataObject):void {
			if (!p) return;
			if(_TransparentDrag) p.window.alpha = 1;
		}
		
		private function handleButtonClick(p:PopUpDataObject, d:String):void {
			if (!p) return;
			//trace("click of " + d + " from " + p.guid);
			// 2nd parm passes the data from the button that was pressed
			var btnEvt:String = getButtonEventFromName(p, d);
			switch(btnEvt) {
				case "exit_module":
					dispatchEvent(new PopUpEvent(PopUpEvent.EXIT_MODULE, true, false, p.guid, p.id, p.callingobj,d));
					break;
				default:
					closePopUp(getPopUpIndexFromGUID(p.guid), getButtonDataFromName(p, d));
					break;
			}
			
		}
		
		private function getButtonEventFromName(p:PopUpDataObject, b:String):String {
			for (var i:int = 0; i < p.buttons.length; i++) {
				if (p.buttons[i].label == b) return p.buttons[i].event;
			}
			return "";
		}
		
		private function getButtonDataFromName(p:PopUpDataObject, b:String):String {
			for (var i:int = 0; i < p.buttons.length; i++) {
				if (p.buttons[i].label == b) return p.buttons[i].data;
			}
			return "";
		}
		
		// d, is optional data passed to ramen from the button in the XML file
		// should be passed when this is called from a button
		private function closePopUp(i:int,d:String="autoclose"):Boolean {
			if (i < 0) return false;
			//trace("close window: " + i);
			removeDrag(_PopUpList[i])
			removeButtons(_PopUpList[i]);
			_PopUpList[i].destroy();
			if (_AnimateClose) {
				TweenLite.to(_PopUpList[i].window, .25, 
											{delay:0, 
											ease: Quadratic.easeOut,
											y:(_PopUpList[i].window.y)+25,
											alpha:0,
											onComplete:removePopUpSprite,
											onCompleteParams:[_PopUpList[i].window]
											});
			} else {
				_PopUpLayer.removeChild(_PopUpList[i].window);
			}
			var oldWin:Array = _PopUpList.splice(i, 1);
			if (!anyModalPopUps()) hideModalBG();
			// goes back to Ramen controller. should route this even to the obj that opened the window
			dispatchEvent(new PopUpEvent(PopUpEvent.CLOSE, true, false, oldWin[0].guid, oldWin[0].id, oldWin[0].callingobj,d));
			return true;
		}
		
		private function removePopUpSprite(s:Sprite) {
			_PopUpLayer.removeChild(s);
		}
		
		public function closeTopPopUp():Boolean {
			if (_CurrentPopUp < 0 || _PopUpList.length == 0) return false;
			var err:Boolean = closePopUp(_CurrentPopUp);
			if(err) {
				// closed the current top one, get the new current top one from the window object
				setCurrentPopUp();
			}
			return err;
		}
		
		private function setCurrentPopUp():void {
			if (_PopUpLayer.numChildren) _CurrentPopUp = getPopUpIndexFromWindow(_PopUpLayer.getChildAt(_PopUpLayer.numChildren - 1));
				else _CurrentPopUp = -1;
		}
		
		// if f==true, persistant popups will be closed also
		// makes a list of the non persistant popup guids and then uses that list to close
		public function closeAllPopUps(f:Boolean = false):void {
			var list:Array = new Array();
			for (var i:int = 0; i < _PopUpList.length; i++) {
				//trace("is pst: " + _PopUpList[i].persistant);
				if(!_PopUpList[i].persistant) {
					//closePopUp(i);
					list.push(_PopUpList[i].guid);
				} else {
					// persistant and flag
					if(f) closePopUp(i);
				}
			}
			for (var k:int = 0; k < list.length; k++) {
				closePopUp(getPopUpIndexFromGUID(list[k]));
			}
			dispatchEvent(new Event(PopUpManager.ALL_POPUPS_CLOSED));
		}
		
		private function createModalBG():void {
			_ModalBG = new Sprite();
			_ModalBG.name = "PopUpManager_MODALBG";

			_PageModalBG = new Sprite();
			_PageModalBG.name = "PopUpManager_PAGEMODALBG";
			
			var bg:Sprite = _SiteView.getSharedResource("ModalBackground") as Sprite;
			_ModalBG.addChild(bg);
			_ModalBG.scaleX = _PopUpTarget.stage.stageWidth * .01;
			_ModalBG.scaleY = _PopUpTarget.stage.stageHeight * .01;
			
			var pbg:Sprite = _SiteView.getSharedResource("PageModalBackground") as Sprite;
			_PageModalBG.addChild(pbg);
			
			_PopUpTarget.addChild(_PageModalBG);
			_PopUpTarget.addChild(_ModalBG);
			
			_ModalBG.buttonMode = true;
			_ModalBG.useHandCursor = false;
			_ModalBG.mouseChildren = false;
			_ModalBG.addEventListener(MouseEvent.CLICK, onModalBGClick);
			
			_PageModalBG.buttonMode = true;
			_PageModalBG.useHandCursor = false;
			_PageModalBG.mouseChildren = false;
			_PageModalBG.addEventListener(MouseEvent.CLICK, onModalBGClick);
			
			hideModalBG();
		}
		
		public function showModalBG():void {
			if (modalShowing) return;
			_ModalBG.visible = true;
			_SiteView.blurMainUI();
			dispatchEvent(new Event(PopUpManager.MODAL_ON));
		}
		
		public function showPageModalBG():void {
			if (modalShowing) return;
			_PageModalBG.visible = true;
			_PageModalBG.x = _SiteView.currentPageXtoGlobal;
			_PageModalBG.y = _SiteView.currentPageYtoGlobal;
			_PageModalBG.scaleX = _SiteView.currentPageWidth * .01;
			_PageModalBG.scaleY = _SiteView.currentPageHeight * .01;
			dispatchEvent(new Event(PopUpManager.MODAL_ON));
		}
		
		public function hideModalBG():void {
			if (!modalShowing) return;
			var which:int = 0;
			if (_PageModalBG.visible) which = 1;
			_ModalBG.visible = false;
			_PageModalBG.visible = false;
			if(which == 0) _SiteView.removeAllFiltersOnMainUI();
			dispatchEvent(new Event(PopUpManager.MODAL_OFF));
		}
		
		private function onModalBGClick(event:MouseEvent):void {
			//trace("click on modal bg");
		}

		public function anyModalPopUps():Boolean {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].modal) return true;
			}
			return false;
		}
		
		private function anyOtherModalPopUps(w:int):Boolean {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				//trace(i + " modal? " + _PopUpList[i].modal);
				if (i != w && _PopUpList[i].modal) return true;
			}
			return false;
		}
		
		public function anyPageModalPopUps():Boolean {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].pagemodal) return true;
			}
			return false;
		}
		
		private function anyOtherPageModalPopUps(w:int):Boolean {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				//trace(i + " pagemodal? " + _PopUpList[i].pagemodal);
				if (i != w && _PopUpList[i].pagemodal) return true;
			}
			return false;
		}
		
		// d should either be XML or object
		public function createPopUp(d:*):Boolean {
			var pd:PopUpDataObject;
			// get the data for it
			if (d is PopUpCreationEvent) {
				// was from an event - repsonse to user action or other 
				//trace("making popup from event");
				if (d.xmldata) {
					pd = createPopUpDataObjectFromEventXML(XML(d.xmldata));
				} else { 
					pd = createPopUpDataObjectFromEventObj(d.objdata);
					pd.popuptype = d.popuptype;
				}
				pd.callingobj = d.callingobj;
			} else if (d is PopUpDataObject) {
				//trace("Making popup from data object");
				pd = d;
			} else {
				trace("can't make popup from this data");
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Bad pop up data"));
				return false;
			}
			
			if (popupWithIDExists(pd.id)) {
				trace("popup with same id exists: " + pd.id);
				//dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "A pop up with same id exists: '" + pd.id+"'"));
				return false;
			}
			
			// determine the type and show it
			switch (pd.popuptype) {
				case PopUpType.SIMPLE:
					pd.window = createSimplePopUp(pd);
					break;
				case PopUpType.ICON:
					pd.window = createIconPopUp(pd);
					break;
				case PopUpType.ERROR:
					pd.window = createErrorPopUp(pd);
					break;
				case PopUpType.EXIT_PROMPT:
					pd.window = createExitPromptPopUp(pd);
					break;
				case PopUpType.FB_CORRECT:
				case PopUpType.FB_INCORRECT:
				case PopUpType.FB_NEUTRAL:
					pd.window = createFeedbackPopUp(pd);
					break;
				case PopUpType.LIGHTBOX:
					pd.window = createLightboxPopUp(pd);
					break;
				case PopUpType.CUSTOM:
					pd.window = createCustomPopUp(pd);
					pd.initializeSheet();
					break;
				case PopUpType.TEXT_SCOLLING:
					pd.window = createTextScrollingPopUp(pd);
					break;
				default:
					//trace("can't create popup, unknown type: " + pd.popuptype);
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Can't create pop up, unknown type: '" + pd.popuptype+"'"));
					return false;
			}
			
			if (!pd.window) {
				//trace("no window returned!");
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Tried to create pop up, but no window was returned."));
				return false;
			}
			
			pd.window.name = pd.guid;
			
			switch (pd.popuptype) {
				case PopUpType.SIMPLE:
				case PopUpType.ICON:
				case PopUpType.ERROR:
				case PopUpType.FB_CORRECT:
				case PopUpType.FB_INCORRECT:
				case PopUpType.FB_NEUTRAL:
				case PopUpType.CUSTOM:
				case PopUpType.TEXT_SCOLLING:
					setupButtons(pd);
					updatePosition(pd);
					setupDrag(pd);
					break;
				case PopUpType.LIGHTBOX:
				case PopUpType.EXIT_PROMPT:
					setupButtons(pd);
					updatePosition(pd);
					break;
			}
			
			_CurrentPopUp = _PopUpList.length;
			_PopUpList.push(pd);
			
			_PopUpLayer.addChild(Sprite(pd.window));
			
			if (_AnimateOpen) {
				pd.window.alpha = 0;
				var oy:int = pd.window.y;
				pd.window.y -= 25
				TweenLite.to(pd.window, .5, 
											{delay:.25, 
											ease: Quadratic.easeOut,
											y:oy,
											alpha:1
											})
			}
			
			if (pd.modal) showModalBG();
			if (pd.pagemodal) showPageModalBG();
			
			dispatchEvent(new Event(PopUpManager.POPUP_OPENED));
			return true;
		}

		//gets the popup index with GUID
		private function popupWithIDExists(id:String):Boolean {
			for (var i:int = 0; i < _PopUpList.length; i++) {
				if (_PopUpList[i].id == id) return true;
			}
			return false;
		}
		
		public function createSimplePopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpSimple";
			if (d.title.length > 0) popupLinkage += "_title";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createSimplePopUp - couldn't find type");
				return undefined;
			}
			setupSize(window,d.popuptype,(d.buttons.length > 0));
			return window;
		}
		
		public function createIconPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpIcon";
			if (d.title.length > 0) popupLinkage += "_title";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createIconPopUp - couldn't find type");
				return undefined;
			}
			window.icon_mc.y = int(window.body_txt.y); 
			window.icon_mc.gotoAndStop(d.icon);
			setupSize(window,d.popuptype,(d.buttons.length > 0));
			return window;
		}
		
		public function createFeedbackPopUp(d:PopUpDataObject):* {
			var popupLinkage:String;
			switch (d.popuptype) {
				case PopUpType.FB_CORRECT:
					popupLinkage = "PopUpFeedbackCorrect"
					break;
				case PopUpType.FB_INCORRECT:
					popupLinkage = "PopUpFeedbackIncorrect"
					break;
				default:
					popupLinkage = "PopUpFeedbackNeutral"
				
			}
			//if (d.title.length > 0) popupLinkage += "_title";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createFeedbackPopUp - couldn't find type");
				return undefined;
			}
			//window.icon_mc.y = int(window.body_txt.y); 
			//window.icon_mc.gotoAndStop(d.icon);
			setupSize(window,d.popuptype,(d.buttons.length > 0));
			return window;
		}
		
		public function createErrorPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpError";
			if (d.title.length < 1) d.title = "Error";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createErrorPopUp - couldn't find type");
				return undefined;
			}
			setupSize(window,d.popuptype,(d.buttons.length > 0));
			return window;
		}
		
		public function createExitPromptPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpExitPrompt";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createExitPromptPopUp - couldn't find type");
				return undefined;
			}
			setupSize(window,d.popuptype,(d.buttons.length > 0));
			return window;
		}
		
		public function createLightboxPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpLightbox";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was unsuccessful
			if (!window) {
				trace("createErrorPopUp - couldn't find type");
				return undefined;
			}
			var th:int = 0;
			if (d.content) {
				window.body_txt.x = d.border;
				window.body_txt.y = d.height + d.border + DEFAULT_BORDER;
				window.body_txt.width = d.width;
				setWindowText(window, d);
				th = window.body_txt.height+DEFAULT_BORDER;
			} else {
				window.body_txt.visible = false;
				//window.bg_mc.visible = false;
			}
			window.x_btn.x = (d.width + (d.border * 2)) + DEFAULT_BORDER;// - window.x_btn.width;
			window.x_btn.y = 0;
			if (d.border < 0) window.bg_mc.visible = false;
			window.bg_mc.scaleX = (d.width + (d.border * 2)) * .01;
			window.bg_mc.scaleY = (d.height + (d.border * 2) + th) * .01;
			d.loadURLImage(window as Sprite);
			return window;
		}
		
		public function createCustomPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpSimple";
			if (d.title.length > 0) popupLinkage += "_title";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d);
			} else {
				trace("createSimplePopUp - couldn't find type");
				return undefined;
			}
			setupSize(window, d.popuptype, (d.buttons.length > 0));
			if (d.width) {
				var w:int = d.width * .01;
				var xbtndist:int = window.bg_mc.width - window.x_btn.x;
				window.draghandle_mc.scaleX = w;
				window.titlebar_mc.scaleX = w;
				window.bg_mc.scaleX = w;
				window.x_btn.x = d.width - xbtndist;
				try {
					window.titlebar_mc.scaleX = w;
					window.buttonbg_mc.scaleX = w;
					window.button_0_btn.x = (d.width/2) - (window.button_0_btn.width/2);
				} catch(e:*) {}
			}
			if (d.height) {
				window.bg_mc.scaleY = d.height * .01;
				try {
					window.buttonbg_mc.y = d.height - window.buttonbg_mc.height;
				}catch(e:*) {}
			}
			return window;
		}
		
		public function createTextScrollingPopUp(d:PopUpDataObject):* {
			var popupLinkage:String = "PopUpSimpleTS_title";
			var window:Object = _SiteView.getSharedResource(popupLinkage);
			// test to see if it was successful
			if (window) {
				setWindowText(window, d, false);
			} else {
				trace("createTextScrollingPopUp - couldn't find type");
				return undefined;
			}
			setupSize(window, d.popuptype, (d.buttons.length > 0));
			return window;
		}
		
		private function setWindowText(w:Object, d:PopUpDataObject, rsz:Boolean=true):void {
			if (d.title.length > 0) {
				var bdr:int = w.title_txt.y;
				w.title_txt.autoSize = TextFieldAutoSize.LEFT;
				w.title_txt.wordWrap = true;
				w.title_txt.multiline = true;
				w.title_txt.htmlText = d.title;
				w.title_txt.mouseWheelEnabled = false;
				changeTextFieldSize(w.title_txt);
				// title bar bg is optional
				var titleareaH:Number = ((bdr * 2) + int(w.title_txt.height)) * .01;
				try {
					w.titlebar_mc.scaleY = titleareaH;
				} catch(e:*) {}
				w.draghandle_mc.scaleY = titleareaH;
				w.body_txt.y = int(w.title_txt.y + w.title_txt.height + 10);
			}
			if(rsz) {
				w.body_txt.autoSize = TextFieldAutoSize.LEFT;
				w.body_txt.wordWrap = true;
				w.body_txt.multiline = true;
			}
			w.body_txt.styleSheet = _Settings.css;
			w.body_txt.htmlText = d.content;
			w.body_txt.mouseWheelEnabled = false;
			changeTextFieldSize(w.body_txt);
		}
		
		private function setupSize(w:Object, t:String, b:Boolean):void {
			var hasTitle:Boolean = false;
			var buttonAreaHight:int = 40;
			if (w.title_txt) {
				hasTitle = true;
				// resize title area
			}
			var textBottom:int = w.body_txt.y + DEFAULT_BORDER + w.body_txt.height;
			if (t == PopUpType.ICON || t == PopUpType.FB_CORRECT ||t == PopUpType.FB_INCORRECT ||t == PopUpType.FB_NEUTRAL) {
				try {
					var iconBottom:int = w.icon_mc.y + w.icon_mc.height + DEFAULT_BORDER;
					if (textBottom < iconBottom) textBottom = iconBottom;
				} catch(e:*) {}
			}
			w.bg_mc.scaleY = (textBottom + buttonAreaHight) * .01;
			if (!b) {
				w.bg_mc.scaleY = textBottom * .01;
			}
			// buttonbg is optional
			try {
				w.buttonbg_mc.y = textBottom;
			} catch(e:*) {}
		}
		
		private function setupButtons(d:PopUpDataObject):void {
			var textBottom:int = d.window.body_txt.y + DEFAULT_BORDER + d.window.body_txt.height;
			switch (d.popuptype) {
				case PopUpType.SIMPLE:
				case PopUpType.ICON:
				case PopUpType.ERROR:
				case PopUpType.FB_CORRECT:
				case PopUpType.FB_INCORRECT:
				case PopUpType.FB_NEUTRAL:
				case PopUpType.EXIT_PROMPT:
				case PopUpType.LIGHTBOX:
				case PopUpType.CUSTOM:
				case PopUpType.TEXT_SCOLLING:
					// for somereason, the button MC plays dispite the stop(); script, this will force it to stop
					try {
						d.window.x_btn.stop();
						d.window.x_btn.buttonMode = true;
						d.window.x_btn.mouseChildren = false;
						d.window.x_btn.addEventListener(MouseEvent.MOUSE_OVER, popUpButtonOver);
						d.window.x_btn.addEventListener(MouseEvent.MOUSE_OUT, popUpButtonOut);
						d.window.x_btn.addEventListener(MouseEvent.MOUSE_DOWN, popUpButtonDown);
						d.window.x_btn.addEventListener(MouseEvent.CLICK, popUpXButtonUp);
						AccessibilityManager.getInstance().addActivityItem(Sprite(d.window.x_btn),"Pop up close button","","");
					} catch(e:*) {}
					if (d.buttons.length) {
						for (var i:int = 0; i < d.buttons.length; i++) {
							var button:MovieClip = d.window["button_"+i+"_btn"];
							// for somereason, the button MC plays dispite the stop(); script, this will force it to stop
							button.stop();
							if (d.popuptype == PopUpType.ICON) {
								var iconBottom:int = d.window.icon_mc.y + d.window.icon_mc.height + DEFAULT_BORDER;
								if (textBottom < iconBottom) textBottom = iconBottom;
							} else if (d.popuptype == PopUpType.CUSTOM) {
								textBottom = d.window.bg_mc.height - 40;
							}
							button.y = textBottom + (DEFAULT_BORDER/2);
							configureButton(button, d.buttons[i]); 
						}
					} else {
						// should have atleast 1 default button?
						try {
							d.window.button_0_btn.visible = false;
							d.window.buttonbg_mc.visible = false;
						} catch(e:*) {}
					}
					
					break;
				default:
					//trace("can't create popup buttons, unknown type: " + d.popuptype);
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Can't create buttons, unknown pop up type: '" + d.popuptype+"'"));
			}
		}

		private function configureButton(button:MovieClip, btnData:Object):void {
			button.label_txt.text = btnData.label;
			button.buttonMode = true;
			button.mouseChildren = false;
			button.addEventListener(MouseEvent.MOUSE_OVER, popUpButtonOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, popUpButtonOut);
			button.addEventListener(MouseEvent.MOUSE_DOWN, popUpButtonDown);
			button.addEventListener(MouseEvent.CLICK, popUpButtonUp);
			AccessibilityManager.getInstance().addActivityItem(Sprite(button),btnData.label+" button","","");
		}
		
		private function popUpButtonOver(e:Event):void {
			e.target.gotoAndStop("over");
		}
		
		private function popUpButtonOut(e:Event):void {
			e.target.gotoAndStop("up");
		}
		
		private function popUpButtonDown(e:Event):void {
			e.target.gotoAndStop("down");
		}
		
		private function popUpButtonUp(e:Event):void {
			e.target.gotoAndStop("up");
			// send the name of the button as data
			dispatchEvent(new PopUpEvent(PopUpEvent.BUTTON_CLICK, true, false, e.target.parent.name, e.target.label_txt.text));
		}
		
		private function popUpXButtonUp(e:Event):void {
			e.target.gotoAndStop("up");
			dispatchEvent(new PopUpEvent(PopUpEvent.CLOSE, true, false, e.target.parent.name, "x"));
		}
		
		private function removeButtons(d:PopUpDataObject):void {
			switch (d.popuptype) {
				case PopUpType.SIMPLE:
				case PopUpType.ICON:
				case PopUpType.ERROR:
				case PopUpType.EXIT_PROMPT:
				case PopUpType.LIGHTBOX:
				case PopUpType.CUSTOM:
				case PopUpType.TEXT_SCOLLING:
					try {
						d.window.x_btn.removeEventListener(MouseEvent.MOUSE_OVER, popUpButtonOver);
						d.window.x_btn.removeEventListener(MouseEvent.MOUSE_OUT, popUpButtonOut);
						d.window.x_btn.removeEventListener(MouseEvent.MOUSE_DOWN, popUpButtonDown);
						d.window.x_btn.removeEventListener(MouseEvent.CLICK, popUpXButtonUp);
					} catch(e:*) {}
					if (d.buttons.length) {
						for (var i:int = 0; i < d.buttons.length; i++) {
							var button:MovieClip = d.window["button_" + i + "_btn"];
							button.buttonMode = false;
							button.removeEventListener(MouseEvent.MOUSE_OVER, popUpButtonOver);
							button.removeEventListener(MouseEvent.MOUSE_OUT, popUpButtonOut);
							button.removeEventListener(MouseEvent.MOUSE_DOWN, popUpButtonDown);
							button.removeEventListener(MouseEvent.CLICK, popUpButtonUp);
						}
					}
					break;
				default:
					//trace("can't remove popup buttons, unknown type: " + d.popuptype);
			}
		}
		
		//TODO, suppot other locations
		private function updatePosition(d:PopUpDataObject):void {
			if (d.usermoved) return;
			var midX:int;
			var popHW:int;
			var midY:int;
			var popHH:int;
			var qrtY:int;
			var posX:int = 0;
			var posY:int = 0;
			if(d.hposition.indexOf("page") != 0) {
				switch (d.hposition) {
					case ObjectStatus.LEFT:
						posX = 0;
						break;
					case ObjectStatus.RIGHT:
						posX = _PopUpTarget.stage.stageWidth - d.window.bg_mc.width;
						break;
					default:
						// default to center
						midX = _PopUpTarget.stage.stageWidth >> 1;
						popHW = (d.window.bg_mc.width) >> 1;
						posX = midX - popHW;
				}
			} else {
				switch (d.hposition) {
					case ObjectStatus.PAGE_LEFT:
						posX = _SiteView.currentPageXtoGlobal;
						trace(posX);
						break;
					case ObjectStatus.PAGE_RIGHT:
						posX = _SiteView.currentPageXtoGlobal+_SiteView.currentPageWidth - d.window.bg_mc.width;
						break;
					default:
						// default to center
						midX = _SiteView.currentPageWidth >> 1;
						popHW = (d.window.bg_mc.width) >> 1;
						posX = _SiteView.currentPageXtoGlobal+midX - popHW;
				}
			}
			if(d.vposition.indexOf("page") != 0) {
				switch (d.vposition) {
					case ObjectStatus.TOP:
						posY = 0;
						break;
					case ObjectStatus.HIGH_MIDDLE:
						midY = _PopUpTarget.stage.stageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						qrtY = _PopUpTarget.stage.stageHeight / 8;
						posY = midY - popHH - qrtY;
						break;
					case ObjectStatus.LOW_MIDDLE:
						midY = _PopUpTarget.stage.stageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						qrtY = _PopUpTarget.stage.stageHeight / 8;
						posY = midY - popHH + qrtY;
						break;
					case ObjectStatus.BOTTOM:
						posY = _PopUpTarget.stage.stageHeight - d.window.bg_mc.height;
						break;
					default:
						// default to middle
						midY = _PopUpTarget.stage.stageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						posY = midY - popHH;
				}
			} else {
				switch (d.vposition) {
					case ObjectStatus.PAGE_TOP:
						posY = _SiteView.currentPageYtoGlobal;
						break;
					case ObjectStatus.PAGE_HIGH_MIDDLE:
						midY = _SiteView.currentPageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						qrtY = _SiteView.currentPageHeight / 8;
						posY = _SiteView.currentPageYtoGlobal +midY - popHH - qrtY;
						break;
					case ObjectStatus.PAGE_LOW_MIDDLE:
						midY = _SiteView.currentPageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						qrtY = _SiteView.currentPageHeight / 8;
						posY = _SiteView.currentPageYtoGlobal +midY - popHH + qrtY;
						break;
					case ObjectStatus.PAGE_BOTTOM:
						posY = _SiteView.currentPageYtoGlobal +_SiteView.currentPageHeight - d.window.bg_mc.height;
						break;
					default:
						// default to middle
						midY =_SiteView.currentPageHeight >> 1;
						popHH = (d.window.bg_mc.height) >> 1;
						posY = _SiteView.currentPageYtoGlobal+midY - popHH;
				}

			}
			posX = posX < 0 ? 0 : posX;
			posY = posY < 0 ? 0 : posY;
			d.window.x = posX;
			d.window.y = posY;
			
			if (_PageModalBG.visible == true) {
				_PageModalBG.x = _SiteView.currentPageXtoGlobal;
				_PageModalBG.y = _SiteView.currentPageYtoGlobal;
				_PageModalBG.scaleX = _SiteView.currentPageWidth * .01;
				_PageModalBG.scaleY = _SiteView.currentPageHeight * .01;
			}
		}
		
		private function setupDrag(d:PopUpDataObject):void {
			d.window.draghandle_mc.alpha = 0;
			if (!d.draggable) return;
			d.window.draghandle_mc.buttonMode = true;
			d.window.draghandle_mc.addEventListener(MouseEvent.MOUSE_DOWN, onDragHandleClick);
			d.window.draghandle_mc.addEventListener(MouseEvent.MOUSE_UP, onDragHandleRelease);
			//d.window.draghandle_mc.addEventListener(MouseEvent.ROLL_OUT, onDragHandleRelease);

		}
		
		private function removeDrag(d:PopUpDataObject):void {
			if (!d.draggable) return;
			d.window.draghandle_mc.buttonMode = false;
			d.window.draghandle_mc.removeEventListener(MouseEvent.MOUSE_DOWN, onDragHandleClick);
			d.window.draghandle_mc.removeEventListener(MouseEvent.MOUSE_UP, onDragHandleRelease);
			//d.window.draghandle_mc.removeEventListener(MouseEvent.ROLL_OUT, onDragHandleRelease);
		}
		
		private function onDragHandleClick(e:Event):void {
			var maxx = _PopUpTarget.stage.stageWidth - e.target.parent.bg_mc.width;
			var maxy = _PopUpTarget.stage.stageHeight - e.target.parent.bg_mc.height;
			if (STOP_AT_BORDERS) e.target.parent.startDrag(false, new Rectangle(0, 0, maxx, maxy));
				else e.target.parent.startDrag(false);
			dispatchEvent(new PopUpEvent(PopUpEvent.START_DRAG,true,false,e.target.parent.name));
		}
		
		private function onDragHandleRelease(e:Event):void {
			e.target.parent.stopDrag();
			dispatchEvent(new PopUpEvent(PopUpEvent.STOP_DRAG,true,false,e.target.parent.name));
		}
		
		private function onBrowserWindowResize(event:Event):void {
			_ModalBG.scaleX = _PopUpTarget.stage.stageWidth * .01;
			_ModalBG.scaleY = _PopUpTarget.stage.stageHeight * .01;
			
			for (var i:int = 0; i < _PopUpList.length; i++) {
				updatePosition(_PopUpList[i]);
			}
		}
		
		private function changeTextFieldSize(f:TextField):void {
			if (f.styleSheet) return;
			var tf:TextFormat = f.getTextFormat();
			tf.size += _Settings.zoomFactor;
			f.setTextFormat(tf);
		}
		
	}
	
}

class SingletonEnforcer {}