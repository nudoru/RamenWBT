/*
Ramen Player 

Matt Perkins
*/

package ramen.player {

	import com.nudoru.utils.RecurseDisplayList;
	import ramen.common.*;
	import ramen.player.*;
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import com.nudoru.utils.Debugger;
	import com.nudoru.lms.*;
	
	import flash.net.LocalConnection;		// this is only imported for the GC hack
	import flash.system.System;				// this is only imported for the GC hack

	
	public class Player extends Sprite {
		private static const VERSION	:String = ".8.3, 09.11.05";
		
		private var _DefaultSiteDataFile:String = "xml/site.xml";
		
		private var _RunStage			:int = -1;
		
		private var _SiteModel			:SiteModel;
		private var _SiteView			:AbstractView;
		private var _LSOMgr				:LSOManager;
		private var _LogicMgr			:LogicManager;
		private var _AssessmentMgr		:AssessmentManager;
		private var _AccessabilityMgr	:AccessibilityManager;
		
		private var _FontLoader			:FontLoader;
		
		private var _CustomContextMnu	:ContextMenu;
		private var _AboutShowing		:Boolean;
		private var _BackgroundLayer	:Sprite;
		private var _ContentLayer		:Sprite;
		private var _MessageLayer		:Sprite;
		private var _ErrorLayer			:Sprite;
		private var _FocusLayer			:Sprite;
		
		private var _CurrentPageLoader	:PageLoader;
		private var _PopUpManager		:PopUpManager;
		
		private var _Preloader			:Preloader;
		private var _SiteLoadingBG		:LoadingBG;
		private var _DebugOutput		:DebugWindow;
		private var _MemoryGraph		:Sprite;
		private var _MousePosDebug		:MousePosition;
		
		private var _LMSConnector		:LMSConnector;
		private var _PageHistory		:Array;
		
		private var _DLog				:Debugger;
		
		private var _GlobalSettings		:Settings;
		
		private var _LockLinearNavOnPageChange:Boolean;
		private var _NavDirection		:int;		// used for some page transition, -1 back, 1 = other
		
		private var _PageNavNextEN		:Boolean;
		private var _PageNavBackEN		:Boolean;
		private var _PageNavRefreshEN	:Boolean;
	
		private var _CheatMode			:Boolean;
		
		private var _InitialMemUsg		:int;
		private var _MemoryLog			:Array = new Array();
		
		// conts for run stages
		public static const UNINIT		:int = -1;
		public static const INIT		:int = 0;
		public static const MODEL_LOADED:int = 1;
		public static const FONTS_LOADED:int = 2;
		public static const VIEW_LOADED	:int = 3;
		public static const STARTING	:int = 4;
		public static const RUNNING		:int = 5;
		public static const INIT_LMS	:int = 6;
		public static const TRACKING	:int = 7;
		public static const SHUTDOWN	:int = 99;
		
		// events
		public static const CHEAT_MODE_ON	:String = "cheat_mode_on";
		public static const CHEAT_MODE_OFF	:String = "cheat_mode_off";
		public static const NEXT_DISABLE	:String = "next_disable";
		public static const NEXT_ENABLE		:String = "next_enable";
		
		public function get cheatMode():Boolean {
			if (!_SiteModel.configCheatKeyEnabled) return false;
			return _CheatMode;
		}
		
		public function set cheatMode(m:Boolean):void {
			if (!_SiteModel.configCheatKeyEnabled) _CheatMode = false;
			_CheatMode = m;
		}
		
		public function Player():void {
			initialize();
		}
		
		// 1 - init and start loading the site config file
		public function initialize():void {
			_RunStage = Player.INIT;
			
			addEventListener(PlayerError.WARNING, onPlayerWarning);
			addEventListener(PlayerError.ERROR, onPlayerError);
			addEventListener(PlayerError.FATAL, onPlayerFatal);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_DLog = Debugger.getInstance();
			_DLog.init();

			createLayers();
			showPreloader();
			setPreloaderText("1 of 3 loading xml");
			
			_SiteModel = SiteModel.getInstance();
			_SiteModel.init();
			_SiteModel.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_SiteModel.addEventListener(PlayerError.ERROR, onPlayerError);
			_SiteModel.addEventListener(PlayerError.FATAL, onPlayerFatal);
			_SiteModel.addEventListener(SiteModel.LOADED, onSiteModelLoaded);
			_SiteModel.load(_DefaultSiteDataFile)
			
			customizeContextMenu();
			
			_AboutShowing = false;
			_NavDirection = 1;
			_PageNavNextEN = true;
			_PageNavBackEN = true;
			_PageNavRefreshEN = true;
			_PageHistory = new Array();
			_CheatMode = false;
			_LockLinearNavOnPageChange = true;
		}
		
		// 2 - load the fonts
		private function onSiteModelLoaded(event:Event):void {
			_RunStage = Player.MODEL_LOADED;
			_DLog.addDebugText("! MODEL LOADED");
			
			_AccessabilityMgr = AccessibilityManager.getInstance();
			_AccessabilityMgr.initialize(this, _SiteModel.configUseAccessibility);
			
			setPreloaderText("2 of 3 loading fonts");
			var _FontLoader:FontLoader = new FontLoader(_SiteModel.configFontFile, _SiteModel.configFontList);
			_FontLoader.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_FontLoader.addEventListener(PlayerError.ERROR, onPlayerError);
			_FontLoader.addEventListener(PlayerError.FATAL, onPlayerFatal);
			_FontLoader.addEventListener(FontLoader.LOADED,onFontsLoaded);
			_FontLoader.setPreloader(_Preloader);
			
		}
		
		// 3 - load the view
		private function onFontsLoaded(event:Event):void {
			_RunStage = Player.FONTS_LOADED;
			_DLog.addDebugText("! FONTS LOADED");
				// pass the view a reference to the main time time line and the model
			setPreloaderText("3 of 3 loading resources");
			_SiteView = SiteViewFactory.createView("",_ContentLayer, _SiteModel);
			//_SiteView = new CenteredView(_ContentLayer, _SiteModel);
			_SiteView.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_SiteView.addEventListener(PlayerError.ERROR, onPlayerError);
			_SiteView.addEventListener(PlayerError.FATAL, onPlayerFatal);
			_SiteView.addEventListener(AbstractView.LOADED, onSiteViewLoaded);
			_SiteView.setPreloader(_Preloader);
			_SiteView.render();
		}

		// 4
		private function onSiteViewLoaded(event:Event):void {
			_RunStage = Player.VIEW_LOADED;
			
			// cannot create the debug output until here because the proper display order is only set in the View
			createDebugOutput(false);
			
			_DLog.addDebugText("! VIEW LOADED");
			
			//stage.addEventListener(Event.ENTER_FRAME, onFrameDelay);
			startSite();
		}
		
		private function onFrameDelay(e:Event):void {
			trace("PLAYER FRAME!");
			stage.removeEventListener(Event.ENTER_FRAME, onFrameDelay);
			startSite();
		}
		
		// 5 - start the site
		private function startSite():void {
			_RunStage = Player.STARTING;
			
			setPreloaderText("starting ...");
			
			_DLog.addDebugText("! START SITE");
			
			_GlobalSettings = Settings.getInstance();
			_GlobalSettings.setDataFromModel(_SiteModel);
			_GlobalSettings.css = _SiteView.css;
			_GlobalSettings.addEventListener(Settings.AUDIO_STATUS_CHANGE, onGlobalVolumeChange);
			_GlobalSettings.addEventListener(Settings.ZOOM_FACTOR_CHANGE, onGlobalZoomFactorChange);
			
			_LogicMgr = LogicManager.getInstance();
			_LogicMgr.initialize();
			// add it to the stage for events
			addChild(_LogicMgr);
			
			_AssessmentMgr = AssessmentManager.getInstance();
			_AssessmentMgr.initialize();
			
			_PopUpManager = PopUpManager.getInstance();
			_PopUpManager.initialize(_SiteView);

			_LSOMgr = LSOManager.getInstance();
			
			_MousePosDebug = new MousePosition(_MessageLayer,_SiteView.pageAreaSprite, _SiteModel.currentPageX, _SiteModel.currentPageY);

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			
			_SiteModel.addEventListener(SiteModel.PAGE_CHANGE, onPageChange);
			_SiteModel.addEventListener(SiteModel.ALL_SCORED_PAGES_COMPLETED, onAllScoredPagesCompleted);
			
			//_SiteView.addEventListener(NavChangeEvent.MAIN_MENU_SELECTION, onMainMenuSelection);
			//_SiteView.addEventListener(NavChangeEvent.PAGE_MENU_SELECTION, onPageMenuSelection);
			_SiteView.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_SiteView.addEventListener(PlayerError.ERROR, onPlayerError);
			
			addEventListener(NavChangeEvent.MAIN_MENU_SELECTION, onMainMenuSelection);
			addEventListener(NavChangeEvent.PAGE_MENU_SELECTION, onPageMenuSelection); //onPageNavEvent
			
			// traps page navigation requests from pages and resources
			addEventListener(NavChangeEvent.PAGE_JUMP_SELECTION, onPageNavEvent);
			addEventListener(NavChangeEvent.GOTO_NEXT_PAGE, onPageNavNext);
			addEventListener(NavChangeEvent.GOTO_PREVIOUS_PAGE, onPageNavPrev);
			addEventListener(NavChangeEvent.REFRESH_CURRENT_PAGE, onPageRefresh);
			addEventListener(NavChangeEvent.SHOW_EXIT_PROMPT, onShowExitPrompt);
			// misc events
			addEventListener(InterfaceEvent.UI, onInterfaceUIEvent);
			addEventListener(InterfaceEvent.PAGE, onInterfacePageEvent);
			addEventListener(InterfaceEvent.CUSTOM, onInterfaceCustomEvent);
			// text size change
			addEventListener(TextZoomEvent.ZOOM, onTextZoomEvent);
			// nav swf customizations, passed from pages to the nav controls
			addEventListener(NavigationUIEvent.BTN_DISABLE, onNavigationUIEvent);
			addEventListener(NavigationUIEvent.BTN_ENABLE, onNavigationUIEvent);
			addEventListener(NavigationUIEvent.BTN_TOGGLE, onNavigationUIEvent);
			addEventListener(NavigationUIEvent.BTN_SHOW, onNavigationUIEvent);
			addEventListener(NavigationUIEvent.BTN_HIDE, onNavigationUIEvent);
			// page swapping
			addEventListener(PageLoader.LOADED,onPageLoaded);
			addEventListener(PageLoader.UNLOADED, onPageUnloaded);
			addEventListener(PageEvent.RENDERED, onPageRendered);
			// page status
			addEventListener(PageStatusEvent.INCOMPLETE, onPageStatus);
			addEventListener(PageStatusEvent.COMPLETED, onPageStatus);
			addEventListener(PageStatusEvent.PASSED, onPageStatus);
			addEventListener(PageStatusEvent.FAILED, onPageStatus);
			// popup events
			addEventListener(PopUpCreationEvent.OPEN, onPopUpOpen);
			_PopUpManager.addEventListener(PopUpEvent.EVENT, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.OK, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.CLOSE, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.YES, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.NO, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.EXIT_MODULE, onPopUpEvent);
			_PopUpManager.addEventListener(PopUpEvent.DATA, onPopUpEvent);
			_PopUpManager.addEventListener(PlayerError.WARNING, onPlayerWarning);
			
			_InitialMemUsg = System.totalMemory;
			
			_RunStage = Player.RUNNING;
			
			lockLinearNav();
			
			if (_SiteModel.configLMSEnabled) {
				initLMS();
			} else {
				removePreloader();
				if (_SiteModel.configUseLSO) {
					initWithLSO();
					return;
				}
				if (_SiteModel.configSWFAddressEnabled) SWFAddress.addEventListener(SWFAddressEvent.CHANGE, handleSWFAddress);
			}

			//traceCourseStructure();
		}
		
		private function initLMS():void {
			setPreloaderText("connecting to LMS ...");
			_RunStage = Player.INIT_LMS;
			_LMSConnector = LMSConnector.getInstance();
			_LMSConnector.init(_SiteModel.LMSMode.toLowerCase(), _SiteModel.simulateLMSEnabled);
			_LMSConnector.addEventListener(LMSEvent.INITIALIZED, onLMSInitialize);
			_LMSConnector.addEventListener(LMSEvent.CANNOT_CONNECT, onLMSCannotConnect);
			_LMSConnector.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_LMSConnector.addEventListener(PlayerError.ERROR, onPlayerError);
			_LMSConnector.addEventListener(PlayerError.FATAL, onPlayerFatal);
			
			// trap this no matter what
			addEventListener(LMSEvent.EXIT, onLMSExit);
			
			// debug data
			_LMSConnector.simLastLocation = "";
			_LMSConnector.simSuspendData = "";
			
			_LMSConnector.initialize();
		}
		
		private function onLMSInitialize(e:LMSEvent):void {
			_DLog.addDebugText("! LMS init'd");
			_LMSConnector.removeEventListener(LMSEvent.INITIALIZED, onLMSInitialize);
			_LMSConnector.addEventListener(LMSEvent.SUCCESS, onLMSSuccess);
			_LMSConnector.addEventListener(LMSEvent.CANNOT_CLOSE_WINDOW, onLMSCannotCloseWindow);
			_LMSConnector.addEventListener(LMSEvent.ERROR, onLMSGeneralError);
			// objects in the display list can force these LMS behaviors/commands for manual control
			addEventListener(LMSEvent.COMMIT, onLMSCommit);
			addEventListener(LMSEvent.SET_SCORE, onLMSSetScore);
			addEventListener(LMSEvent.SET_STATUS, onLMSSetStatus);
			addEventListener(LMSEvent.SET_INCOMPLETE, onLMSSetIncomplete);
			addEventListener(LMSEvent.SET_COMPLETE, onLMSSetComplete);
			addEventListener(LMSEvent.SET_PASS, onLMSSetPass);
			addEventListener(LMSEvent.SET_FAIL, onLMSSetFail);
			addEventListener(LMSEvent.SET_LASTLOCATION, onLMSSetLastLocation);
			addEventListener(LMSEvent.SET_SUSPENDDATA, onLMSSetSuspendData);
			// set the last location when the page finishes changing
			_SiteModel.addEventListener(SiteModel.PAGE_CHANGE, onLMSMonitorPageChange);
			
			_GlobalSettings.setLMSStudentData(_LMSConnector.studentID, _LMSConnector.studentName);
			
			_SiteModel.parseSuspendData(_LMSConnector.suspendData);
			
			_RunStage = Player.TRACKING;

			removePreloader();
			gotoLastLocation(_LMSConnector.lastLocation);
		}
		
		private function onLMSCannotConnect(e:LMSEvent):void {
			_LMSConnector.removeEventListener(LMSEvent.INITIALIZED, onLMSInitialize);
			_LMSConnector.removeEventListener(LMSEvent.CANNOT_CONNECT, onLMSCannotConnect);
			_LMSConnector.removeEventListener(PlayerError.WARNING, onPlayerWarning);
			_LMSConnector.removeEventListener(PlayerError.ERROR, onPlayerError);
			_LMSConnector.removeEventListener(PlayerError.FATAL, onPlayerFatal);
			
			_RunStage = Player.RUNNING;

			if (_SiteModel.configUseLSO) {
				removePreloader();
				initWithLSO();
				return;
			}
			
			removePreloader();
			_SiteModel.setCurrentPageModule(_SiteModel.getFirstPage());
			//_SiteModel.refreshCurrentPage();
			
			// classify this error as a warning so that it will fail if connection not intended, ex: reuse from CDROM or static site
			dispatchEvent(new PlayerError(PlayerError.WARNING, "10000", "Could not initialize connection to the LMS"));
			// because the warning above will trip cause the navigation not to unlock - modal popup showing
			dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_ENABLE, NavigationUIEvent.NEXT_BTN));
		}
		
		private function onLMSSuccess(e:LMSEvent):void {
			//
		}
		
		private function onLMSGeneralError(e:LMSEvent):void {
			dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "An error occured when sending information to the LMS:<br><br>"+_LMSConnector.lastCommand+"<br><br>Your results may not have been successfully saved."));
		}
		
		// this should help prevent the feeling of the course "freezing" on exit
		private function onLMSCannotCloseWindow(e:LMSEvent):void {
			dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Cound not automatically close the browser window.<br><br>Please close the window, your results were successfully saved."));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// LOCALLY SHARED OBJECT
		
		private function initWithLSO():void {
			if (!_SiteModel.configUseLSO) return;
			trace("$$$ loading data from LSO");
			var err:Boolean;
			var data:String = _LSOMgr.getData(_SiteModel.metaID + "_suspendata");
			
			if (data) {
				err = _SiteModel.parseSuspendData(data);
			}
			
			_SiteModel.addEventListener(SiteModel.PAGE_CHANGE, onLSOMonitorPageChange);
			
			gotoLastLocation(_SiteModel.sdLastLocation);
			
			//if (_SiteModel.configSWFAddressEnabled) SWFAddress.addEventListener(SWFAddressEvent.CHANGE, handleSWFAddress);
		}
		
		private function onLSOMonitorPageChange(e:Event):void {
			saveSDToLSO();
		}
		
		private function saveSDToLSO():void {
			if (!_SiteModel.configUseLSO) return;
			trace("$$$ saving data to LSO");
			_LSOMgr.saveData(_SiteModel.metaID+"_suspendata",_SiteModel.getSuspendData());
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// TRACKING LMS
		
		// the last location string is based on a SWFAddress style string
		private function gotoLastLocation(l:String):void {
			if (!l || l == "null" || l == "undefined" || l.length < 1) {
				trace("there is no last location");
				_SiteModel.setCurrentPageModule(_SiteModel.getFirstPage());
				//_SiteModel.refreshCurrentPage();
				return;
			}
			if (l != _SiteModel.currentSWFAddressLocation) {
				trace("last location isn't at the SWFAddress");
				_SiteModel.gotoSWFAddressLocation(l);
			}
		}
		
		public function traceCourseStructure():void {
			_DLog.addDebugText(_SiteModel.traceCourseStructure());
		}
		
		private function onLMSInitialized(e:LMSEvent):void {
			//nothing
		}
		private function onLMSCommit(e:LMSEvent):void {
			_LMSConnector.commit()
		}
		private function onLMSSetScore(e:LMSEvent):void {
			_LMSConnector.score = int(e.ldata);
		}
		private function onLMSSetStatus(e:LMSEvent):void {
			_LMSConnector.lessonStatus = e.ldata;
		}
		
		// TODO should look for manual completion status for these?
		private function onLMSSetIncomplete(e:LMSEvent):void {
			_LMSConnector.setIncomplete();
		}
		private function onLMSSetComplete(e:LMSEvent):void {
			_LMSConnector.setComplete()
		}
		private function onLMSSetPass(e:LMSEvent):void {
			_LMSConnector.setPass();
		}
		private function onLMSSetFail(e:LMSEvent):void {
			_LMSConnector.setFail();
		}
		
		private function onLMSMonitorPageChange(e:Event):void {
			_LMSConnector.lastLocation = _SiteModel.currentSWFAddressLocation;
			if (_PageHistory.length && (_PageHistory.length % 3) == 0) {
				_DLog.addDebugText("Saving SD");
				_LMSConnector.suspendData = _SiteModel.getSuspendData();
			}
			if (_PageHistory.length && (_PageHistory.length % 5) == 0) {
				_DLog.addDebugText("Commiting");
				_LMSConnector.commit();
			}
		}
		private function onLMSSetLastLocation(e:LMSEvent):void {
			_LMSConnector.lastLocation = e.ldata;
		}
		private function onLMSSetSuspendData(e:LMSEvent):void {
			_LMSConnector.suspendData = e.ldata;
		}
		private function onLMSExit(e:LMSEvent):void {
			_RunStage = Player.SHUTDOWN;
			_PopUpManager.closeAllPopUps(true);
			_PopUpManager.showModalBG();
			showPreloader(true);
			setPreloaderText("Exiting, please wait ...");
			setPreloaderBarPct(100);
			if (_SiteModel.LMSMode.toLowerCase() == "scorm" || _SiteModel.LMSMode.toLowerCase() == "scorm2004") {
				_LMSConnector.suspendData = _SiteModel.getSuspendData();
				// TODO add criteria for scoring, now it doesn't matter
				if (_SiteModel.isComplete()) _LMSConnector.setComplete();
					else _LMSConnector.setIncomplete(true);
				_LMSConnector.exitCourse();
				return;
			}
			
			// other or undefined mode
			//dispatchEvent(new PlayerError(PlayerError.WARNING, "10000", "Unknown LMS mode '"+_SiteModel.LMSMode.toLowerCase()+"'.<br><br>Results not saved."));
			
			if (ExternalInterface.available) {
				try{
					ExternalInterface.call("closeWindow");
				} catch (e:*) {
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Please close the course window."));
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// PAGE STATUS
		
		private function onPageStatus(e:PageStatusEvent):void {
			var type:String = e.type;
			//_DLog.addDebugText("Page status change: " + type);
			// data should represent the score
			var data:int = int(e.eventData);
			if (type == PageStatusEvent.INCOMPLETE) {
				_SiteModel.setCurrentPageIncomplete();
			} else if (type == PageStatusEvent.COMPLETED) {
				_SiteModel.setCurrentPageComplete();
			} else if (type == PageStatusEvent.PASSED) {
				_SiteModel.setCurrentPagePassed();
			} else if (type == PageStatusEvent.FAILED) {
				_SiteModel.setCurrentPageFailed();
			} else {
				_DLog.addDebugText("invalid page status "+e);
			}
			_SiteView.updateResourcesOnStatusChange();
			unlockLinearNav();
			
			//trace("$$ %: " + _SiteModel.getPassingPct());
			
		}
		
		public function getCurrentPageStatus():Number {
			return _SiteModel.currentPageStatus;
		}
		
		public function setCurrentPageComplete():void {
			if(_SiteModel.currentPageCompleted) return;
			_SiteModel.setCurrentPageComplete();
		}
		
		public function getPercentCompletedCourse():Number {
			return _SiteModel.getPercentCompletedCourse();
		}
		
		private function onAllScoredPagesCompleted(e:Event):void {
			trace("all scored pages are completed");
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// POPUP EVENTS
		
		// TODO need to route these events back to the calling objects
		private function onPopUpEvent(e:PopUpEvent):void {
			//trace("from PM, type: " + e.type + ", from: "+e.data+" to: " + e.callingobj+" about: "+e.buttondata);
			if (e.type == PopUpEvent.CLOSE) {
				if (e.buttondata == "autoclose") {
					//trace("closed by page change");
				} else if (e.buttondata.indexOf("player_") == 0) {
					handlePlayerCommandString(e.buttondata.split("_")[1]);
				} else if (e.buttondata.length > 0) {
					//trace("sending it to the page: " + e.buttondata);
					try {
						Object(_CurrentPageLoader.page).handlePopUpEvent(e);
					} catch(e:*) { }
				}
			} else if (e.type == PopUpEvent.EXIT_MODULE) {
				onLMSExit(null);
			} else {
				trace("nothing to do with type: " + e.type);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// POPUP WINDOWS
		
		private function onPopUpOpen(e:PopUpCreationEvent):void {
			_PopUpManager.createPopUp(e);
		}
		
		//PopUpCreationEvent(type:String, t:*=undefined, x:XML=undefined, p:String="", d:Object=undefined, bubbles:Boolean=true, cancelable:Boolean=false)
		
		private function createPopUp(type:String,t:String, m:String, mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(type, t, m, "", mdl, pmdl, pst)));
		}
		
		private function message(t:String, m:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.SIMPLE, t, m, "", mdl, pst)));
		}

		private function messageIcon(t:String, m:String, icn:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.ICON, t, m, icn, mdl, pst)));
		}
		
		private function messageError(t:String, m:String):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.ERROR, t, m, "", true, false)));
		}
		
		private function createPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			//popup += "<hpos>"+ObjectStatus.CENTER+"</hpos>";
			//popup += "<vpos>" + ObjectStatus.MIDDLE + "</vpos>";
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
		
		private function createLightbox(url:String,w:int,h:int,brdr:int=0, t:String=""):void {
			var popup:String = "<popup id='lightboximage' draggable='false'>";
			popup += "<type modal='true' persistant='false'>" + PopUpType.LIGHTBOX + "</type>";
			popup += "<content><![CDATA["+t+"]]></content>";
			popup += "<hpos>"+ObjectStatus.CENTER+"</hpos>";
			popup += "<vpos>" + ObjectStatus.MIDDLE + "</vpos>";
			popup += "<size>"+w+","+h+"</size>";
			popup += "<url>"+url+"</url>";
			popup += "<border>"+brdr+"</border>";
			popup += "</popup>";
			var data:XML = new XML(popup);
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, data));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// MISC
		
		// TODO reevaluate these? are the used correctly?
		private function createLayers():void {
			_BackgroundLayer = new Sprite();
			_BackgroundLayer.name = "backgroundlayer";
			_ContentLayer = new Sprite();
			_ContentLayer.name = "contentlayer";
			_MessageLayer = new Sprite();
			_MessageLayer.name = "messagelayer";
			_ErrorLayer = new Sprite();
			_ErrorLayer.name = "errorlayer";
			_FocusLayer = new Sprite();
			_FocusLayer.name = "focuslayer";
			
			addChild(_BackgroundLayer);
			addChild(_ContentLayer);
			addChild(_MessageLayer);
			addChild(_ErrorLayer);
			addChild(_FocusLayer);
		}
		
		public function getMessageLayer():Sprite {
			return _MessageLayer;
		}
		
		public function getErrorLayer():Sprite {
			return _ErrorLayer;
		}
		
		public function getContentLayer():Sprite {
			return _ContentLayer;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Respond to UI events
		
		private function onPageLoaded(e:Event):void {
			//trace("PAGE LOADED");
		}
		
		private function onPageRendered(e:Event):void {
			dispatchEvent(new InterfaceEvent(InterfaceEvent.UI, true, false, this, "page_loaded"));
			
			_PageHistory.push(_SiteModel.currentPageID);
			
			performMemoryCheck();
			// show or hide scroll bar, pass a ref to the current page template
			if(_SiteModel.currentSiteNodePg.scrolling) _SiteView.configurePageScrolling(ITemplate(_CurrentPageLoader.page));
			//trace("PAGE RENDERED");
			unlockLinearNav();
			_SiteModel.startCurrentPageNode();
			//trace("Status: "+_SiteModel.getCourseStatusStr());
			//trace("SD: "+_SiteModel.getSuspendData());
		}
		
		private function onPageUnloaded(e:Event):void {
			dispatchEvent(new InterfaceEvent(InterfaceEvent.UI, true, false, this, "page_unloaded"));
			//trace("PAGE UNLOADED");
			lockLinearNav();
		}
		
		private function onInterfaceUIEvent(e:InterfaceEvent):void {
			handleRamenEvent("ui",e);
		}
		
		private function onInterfacePageEvent(e:InterfaceEvent):void {
			handleRamenEvent("page",e);
		}
		
		private function onInterfaceCustomEvent(e:InterfaceEvent):void {
			handleRamenEvent("custom",e);
		}
		
		private function onNavigationUIEvent(e:NavigationUIEvent):void {
			// disable/enable these nav functions
			if (e.type == NavigationUIEvent.BTN_DISABLE) {
				switch (e.data){
					case NavigationUIEvent.NEXT_BTN:
						_PageNavNextEN = false;
						break;
					case NavigationUIEvent.BACK_BTN:
						_PageNavBackEN = false;
						break;
					case NavigationUIEvent.REPLAY_BTN:
						_PageNavRefreshEN = false;
						break;
					default:
						break;
				}
			} else if (e.type == NavigationUIEvent.BTN_ENABLE) {
				switch (e.data){
					case NavigationUIEvent.NEXT_BTN:
						_PageNavNextEN = true;
						break;
					case NavigationUIEvent.BACK_BTN:
						_PageNavBackEN = true;
						break;
					case NavigationUIEvent.REPLAY_BTN:
						_PageNavRefreshEN = true;
						break;
					default:
						break;
				}
			}
			// pass it to the view to pass to the nav.swf file
			_SiteView.handleNavigationUIEvent(e);
		}
		
		//TODO other events:
		//	lightbox event
		//	message box event
		//	error messages
		//	???
		private function handleRamenEvent(t:String, e:InterfaceEvent):void {
			if(_SiteModel.configSndFXEnabled) _SiteView.playSoundEffect(e.data);
		}
		
		private function handlePlayerCommandString(c:String):Boolean {
			trace("## Performing player command: " + c);
			if (c == PlayerCommands.NEXT_PAGE) {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_NEXT_PAGE));
			} else if (c == PlayerCommands.PREV_PAGE) {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_PREVIOUS_PAGE));
			} else if (c == PlayerCommands.REFRESH_PAGE) {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.REFRESH_CURRENT_PAGE));
			} else if (c.indexOf(PlayerCommands.JUMP_TO) == 1) {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.PAGE_MENU_SELECTION, true, false, c.split("%")[1], c.split("%")[1]));
			} else if (c == PlayerCommands.SETPAGE_INCOMPLETE) {
				dispatchEvent(new PageStatusEvent(PageStatusEvent.INCOMPLETE));
			} else if (c == PlayerCommands.SETPAGE_COMPLETED) {
				dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
			} else if (c == PlayerCommands.SETPAGE_PASSED) {
				dispatchEvent(new PageStatusEvent(PageStatusEvent.PASSED));
			} else if (c == PlayerCommands.SETPAGE_FAILED) {
				dispatchEvent(new PageStatusEvent(PageStatusEvent.FAILED));
			} else if (c == PlayerCommands.EXIT_MODULE) {
				dispatchEvent(new LMSEvent(LMSEvent.EXIT));
			} else if (c == PlayerCommands.ZOOM_IN) {
				dispatchEvent(new TextZoomEvent(TextZoomEvent.ZOOM, "++"));
			} else if (c == PlayerCommands.ZOOM_OUT) {
				dispatchEvent(new TextZoomEvent(TextZoomEvent.ZOOM, "--"));
			} else {
				trace("unrecognized command: " + c);
			}
			return false;
		}
		
		private function onGlobalVolumeChange(e:Event):void {
			_DLog.addDebugText("Global audio volume is now: " + _GlobalSettings.audioVolume);
		}
		
		private function onGlobalZoomFactorChange(e:Event):void {
			_DLog.addDebugText("Global zoom factor is now: " + _GlobalSettings.zoomFactor);
			if(_SiteModel.currentSiteNodePg.refreshOnTextSzCh) handlePlayerCommandString(PlayerCommands.REFRESH_PAGE);
		}
		
		private function onTextZoomEvent(e:TextZoomEvent):void {
			switch(e.data) {
				case "++":
					_GlobalSettings.increaseZoomFactor();
					break;
				case "--":
					_GlobalSettings.decreaseZoomFactor();
					break;
				default:
					_GlobalSettings.setZoomFactor(parseInt(e.data));
					break;
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Respond to navigation events
		
		private function isNavGlobalLocked():Boolean {
			if (cheatMode) return false;
			if (_PopUpManager.anyModalPopUps()) return true;
			return false;
		}
		
		private function isNavNextLocked():Boolean {
			//trace("1");
			if (cheatMode) return false;
			//trace("2");
			if (isNavGlobalLocked()) return true;
			//trace("3");
			if (!isNextPage()) return true;
			//trace("4");
			if (!_PageNavNextEN) return true;
			//trace("5");
			if (_SiteModel.interactionForceAnswer) {
				if (_SiteModel.currentPageScored && !_SiteModel.currentPageCompleted) {
					trace("this page is scored and not completed");
					return true;
				}
			}
			//trace("6");
			return false;
		}
		
		private function isNavPrevLocked():Boolean {
			if (cheatMode) return false;
			if (isNavGlobalLocked()) return true;
			if (!isPreviousPage()) return true;
			if (!_PageNavBackEN) return true;
			return false;
		}
		
		private function lockLinearNav():void {
			if (!_LockLinearNavOnPageChange) return;
			//trace("LOCK LINEAR NAV");
			_PageNavNextEN = false;
			_PageNavBackEN = false;
			_PageNavRefreshEN = false;
			dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_DISABLE, NavigationUIEvent.BACK_BTN));
			dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_DISABLE, NavigationUIEvent.NEXT_BTN));
			
		}
		
		private function unlockLinearNav():void {
			if (!_LockLinearNavOnPageChange) return;
			//trace("UNLOCK LINEAR NAV");
			_PageNavNextEN = true;
			_PageNavBackEN = true;
			_PageNavRefreshEN = true;
			if(!isNavPrevLocked()) dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_ENABLE, NavigationUIEvent.BACK_BTN));
			if(!isNavNextLocked()) dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_ENABLE, NavigationUIEvent.NEXT_BTN));
			
		}
		
		private function onMainMenuSelection(e:NavChangeEvent):void {
			trace("Main menu - selected: "+e.selectionName);
			if (isNavGlobalLocked()) return;
			var err:Boolean = _SiteModel.gotoNodeID(e.selectionID, NavChangeEvent.MAIN_MENU_SELECTION);
			if (err) {
				_NavDirection = PageTransition.DIR_NEXT;
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.UI, true, false, this, InterfaceEvent.MAIN_MENU_SELECTION));
			}
		}
		
		private function onPageMenuSelection(e:NavChangeEvent):void {
			trace("Page menu - selected: "+e.selectionName);
			if (isNavGlobalLocked()) return;
			var err:Boolean = _SiteModel.gotoNodeID(e.selectionID, NavChangeEvent.PAGE_MENU_SELECTION);
			if(err) {
				_NavDirection = PageTransition.DIR_NEXT;
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.UI, true, false, this, InterfaceEvent.PAGE_MENU_SELECTION));
			}
		}

		private function onPageNavEvent(e:NavChangeEvent):void {
			trace("Page nav event: "+e.selectionName);
			if (isNavGlobalLocked()) return;
			var err:Boolean = _SiteModel.gotoNodeID(e.selectionID, NavChangeEvent.PAGE_JUMP_SELECTION);
			if(err) {
				_NavDirection = PageTransition.DIR_NEXT;
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, InterfaceEvent.PAGE_NAVIGATION_EVENT));
			}
		}
		
		private function onPageNavNext(e:NavChangeEvent):void {
			if (isNavNextLocked()) return;
			var err:Boolean = _SiteModel.gotoNextPage();
			if (err) {
				_NavDirection = PageTransition.DIR_NEXT;
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, InterfaceEvent.PAGE_NAVIGATION_EVENT));
			} else {
				trace("onPageNavNext: there is no next page!")
			}
		}
		
		private function onPageNavPrev(e:NavChangeEvent):void {
			if (isNavPrevLocked()) return;
			var err:Boolean = _SiteModel.gotoPreviousPage();
			if (err) {
				_NavDirection = PageTransition.DIR_BACK;
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, InterfaceEvent.PAGE_NAVIGATION_EVENT));
			} else {
				trace("onPageNavPrev: there is no prev page!")
			}
		}
		
		private function onPageRefresh(e:NavChangeEvent):void {
			if (!_PageNavRefreshEN) return;
			_SiteModel.refreshCurrentPage();
			_NavDirection = PageTransition.DIR_NONE;
			//updateSWFAddressLocation();
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, InterfaceEvent.PAGE_NAVIGATION_EVENT));
		}
		
		private function onShowExitPrompt(e:NavChangeEvent):void {
			var exitMessage:String = _SiteModel.exitPromptNonComplete;
			if (_SiteModel.isComplete()) exitMessage = _SiteModel.exitPromptComplete;
			var popup:String = "<popup id='exitPrompt' draggable='false'>";
			popup += "<type modal='true' persistant='false'>" + PopUpType.EXIT_PROMPT + "</type>";
			popup += "<content><![CDATA["+exitMessage+"]]></content>";
			popup += "<hpos>"+ObjectStatus.CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.HIGH_MIDDLE+"</vpos>";
			popup += "<buttons>";
			popup += "<button event='exit_module'>Yes</button>";
			popup += "<button event='close'>No</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			var data:XML = new XML(popup);
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, data));
		}
		
		 //TODO, use delimeter
		public function getCurrentPagePathStr(d:String):String {
			return _SiteModel.currentPagePathStr;
		}
		
		public function gotoPageID(s:String):Boolean {
			if(!s || s=="null" || s=="undefined") return false;
			var success:Boolean = _SiteModel.gotoNodeID(s);
			if(success) {
				updateSWFAddressLocation();
				dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "page_navigation_event"));
				return true;
			} else {
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "There is no node with the id '"+s+"'"));
			}
			return false;
		}
		
		public function isPreviousPage():Boolean {
			return _SiteModel.isLinearPreviousPage();
		}
		
		public function isNextPage():Boolean {
			return _SiteModel.isLinearNextPage();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Page Changing
		
		public function onPageChange(e:Event):void {
			//trace("     page change");
			unloadCurrentPage();
			_SiteModel.updateSiteNodeStructure();
			showCurrentPage();
			_PageNavNextEN = true;
			_PageNavBackEN = true;
			_PageNavRefreshEN = true;
		}
		
		public function showCurrentPage():void {
			_SiteView.pageAreaSprite.addEventListener(PageEvent.RENDERED, onPageXMLComplete);
			
			_CurrentPageLoader = new PageLoader(_SiteView.pageAreaSprite, _SiteModel.currentPageSWF, _SiteModel.currentPageXML, _SiteModel.getPageEntryObject(), {x:_SiteModel.currentPageX, y:_SiteModel.currentPageY, width:_SiteModel.currentPageWidth, height:_SiteModel.currentPageHeight});
			_CurrentPageLoader.addEventListener(PageLoader.PROGRESS, onPageLoadingProgress);
			_CurrentPageLoader.addEventListener(PageLoader.LOADED, onPageLoadingComplete);
			_CurrentPageLoader.addEventListener(PageLoader.ERROR, onPageLoadingError);
			_CurrentPageLoader.addEventListener(PlayerError.WARNING, onPlayerWarning);
			_CurrentPageLoader.addEventListener(PlayerError.ERROR, onPlayerError);
			_CurrentPageLoader.addEventListener(PlayerError.FATAL, onPlayerFatal);
			_SiteView.showPageLoadingBar();
			
			updateDebugDisplay();
		}
		
		public function unloadCurrentPage():void {
			if (_SiteModel.validPageTransition && _CurrentPageLoader) {
				//trace("     creating image");
				_SiteView.createImageOfLastPage(_CurrentPageLoader.container);
				_SiteView.fadeImageOfLastPage();
			}
			
			if (_CurrentPageLoader) {
				//trace("     unloading ...");
				_PopUpManager.closeAllPopUps();
				_AccessabilityMgr.clearFocus();
				_AccessabilityMgr.removeAllNonFrameworkItems();
				_CurrentPageLoader.destroy();
				removePageLoadingEvents();
				_CurrentPageLoader = null;
			}
		}
		
		private function onPageXMLComplete(event:Event):void {
			_SiteView.removePageLoadingBar(true);
			_SiteView.pageAreaSprite.removeEventListener(PageEvent.RENDERED, onPageXMLComplete);
		}
		
		public function onPageLoadingProgress(e:Event):void {
			_SiteView.updatePageLoadingProgress(_CurrentPageLoader.pageLoadingProgress);
		}
		
		public function onPageLoadingComplete(e:Event):void {
			removePageLoadingEvents();
			//trace("valid: " + _SiteModel.validPageTransition);
			//trace("mode: " + _SiteModel.configPageTransition);
			//trace("dir: " + _NavDirection);
			if (_SiteModel.validPageTransition && _CurrentPageLoader) {
				//_SiteView.fadeInCurrentPage(_CurrentPageLoader.container);
				switch(_SiteModel.configPageTransition) {
					case PageTransition.SLIDE:
						_SiteView.slideInCurrentPage(_CurrentPageLoader.container, _NavDirection);
						break;
					case PageTransition.SQUEEZE:
						_SiteView.squeezeInCurrentPage(_CurrentPageLoader.container, _NavDirection);
						break;
					case PageTransition.XFADE_SLOW:
						_SiteView.fadeInCurrentPage(_CurrentPageLoader.container, PageTransition.DUR_SLOW);
						break;
					default:
						// default to xfade quick
						_SiteView.fadeInCurrentPage(_CurrentPageLoader.container, PageTransition.DUR_QUICK);
						break;
				}
			}
			dispatchEvent(new Event(PageLoader.LOADED));
		}
		
		public function onPageLoadingError(e:Event):void {
			removePageLoadingEvents();
			_SiteView.removePageLoadingBar();
			_SiteView.pageAreaSprite.removeEventListener(PageEvent.RENDERED, onPageXMLComplete);
			dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Cannot load page template file '"+_SiteModel.currentPageSWF+"'"));
		}
		
		public function removePageLoadingEvents():void {
			_CurrentPageLoader.removeEventListener(PageLoader.PROGRESS, onPageLoadingProgress);
			_CurrentPageLoader.removeEventListener(PageLoader.LOADED, onPageLoadingComplete);
			_CurrentPageLoader.removeEventListener(PageLoader.ERROR, onPageLoadingError);
			_CurrentPageLoader.removeEventListener(PlayerError.WARNING, onPlayerWarning);
			_CurrentPageLoader.removeEventListener(PlayerError.ERROR, onPlayerError);
			_CurrentPageLoader.removeEventListener(PlayerError.FATAL, onPlayerFatal);
		}
		
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// SWFAddress
		
		private function updateSWFAddressLocation():void {
			if (!_SiteModel.configSWFAddressEnabled) return;
			//trace(_SiteModel.currentSWFAddressLocation);
			SWFAddress.setValue(_SiteModel.currentSWFAddressLocation);
		}
		
		private function handleSWFAddress(e:SWFAddressEvent):void {
			if (!_SiteModel.configSWFAddressEnabled) return;
			if(e.value != _SiteModel.currentSWFAddressLocation) {
				// if we're not already on this page then go there
				_SiteModel.gotoSWFAddressLocation(e.value);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Keypress debug stuff
		
		private function onKeyPress(e:KeyboardEvent):void {
			var keyCode:int = e.keyCode;
			var isCtrl:Boolean = e.ctrlKey;
			var isShift:Boolean = e.shiftKey;
			var isAlt:Boolean = e.altKey;
			var keyLocation:int = e.keyLocation;
			//trace("keyCode " + keyCode);
			// trap TAB key
			if (keyCode == 9) return;
			// trap enter key
			if (keyCode == 13) _AccessabilityMgr.activateCurrentTarget();
			// trap key for debug window first, CTRL+SHIFT+1
			if(keyCode == 49 && isCtrl && isShift) {
				toggleDebugOutput();
				return;
			}
			// memory hack, CTRL+SHIFT+ALT+M
			if(keyCode == 77 && isCtrl && isShift && isAlt) {
				performGCHack();
				return;
			}
			// cheat, CTRL+SHIFT+ALT+M
			if(keyCode == 192 && isCtrl && isShift && isAlt) {
				if (!_SiteModel.configCheatKeyEnabled) return;
				trace("cheater!");
				if (cheatMode) cheatMode = false;
					else cheatMode = true;
				return;
			}
			if(_SiteModel.configUseKeyCommands) {
				switch (keyCode) {
					case KeyDict.NEXT_PAGE:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.NEXT_PAGE);
						return;
					case KeyDict.PREV_PAGE:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.PREV_PAGE);
						return;
					case KeyDict.MENU_PAGE:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.JUMP_TO + "%menu");
						return;
					case KeyDict.POPUP_CLOSE:
						_PopUpManager.closeTopPopUp();
						return;
					case KeyDict.ZOOM_IN:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.ZOOM_IN);
						return;
					case KeyDict.ZOOM_OUT:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.ZOOM_OUT);
						return;
					case KeyDict.EXIT_MODULE:
						if(!_PopUpManager.anyModalPopUps()) handlePlayerCommandString(PlayerCommands.EXIT_MODULE);
						return;
					default:
						// not trapped, send it to the page
						break;
				}
			} 
			
			try {
				Object(_CurrentPageLoader.page).handleKeyPress(keyCode, isAlt, isCtrl, isShift, keyLocation);
			} catch(e:*) { }
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Debug view
		
		private function createDebugOutput(v:Boolean):void {
			_DebugOutput = new DebugWindow();
			_DebugOutput.x = 2;
			_DebugOutput.y = 2;
			_DebugOutput.alpha = .95;
			_ErrorLayer.addChild(_DebugOutput);
			_MemoryGraph = new Sprite();
			_DebugOutput.addChild(_MemoryGraph);
			_DLog.setOutputField(_DebugOutput.output_txt);
			if(v) showDebugOutput();
				else hideDebugOutput();
				
			_DebugOutput.refresh_btn.addEventListener(MouseEvent.CLICK, onDbgRefreshClick);
			_DebugOutput.close_btn.addEventListener(MouseEvent.CLICK, onDbgCloseClick);
			_DebugOutput.mousepos_btn.addEventListener(MouseEvent.CLICK, onDbgMPosClick);
			_DebugOutput.clearlso_btn.addEventListener(MouseEvent.CLICK, onDbgCLSOClick);
			_DebugOutput.drag_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDbgDragDown);
			_DebugOutput.drag_btn.addEventListener(MouseEvent.MOUSE_UP, onDbgDragUp);
		}
		
		private function toggleDebugOutput():void {
			if(_DebugOutput.visible) hideDebugOutput();
				else showDebugOutput();
		}
		
		private function showDebugOutput():void {
			_DebugOutput.visible = true;
			createMemoryGraph();
		}
		
		private function hideDebugOutput():void {
			_DebugOutput.visible = false;
		}
		
		private function createMemoryGraph():void {
			removeMemoryGraph();
			var w:int = 240;
			var h:int = 100;
			var x:int = 5;
			var y:int = 365;
			var maxL:int = 50;
			var xSpc:int = w / maxL;
			var graph:Sprite = new Sprite();
			_MemoryGraph.addChild(graph);
			
			for (var i:int = 0; i < _MemoryLog.length; i++) {
				var d:memorydot = new memorydot();
				d.x = x;
				d.y = int(y - _MemoryLog[i]);
				x += xSpc;
				graph.addChild(d);
			}
		}
		
		private function removeMemoryGraph():void {
			if(_MemoryGraph.numChildren) _MemoryGraph.removeChildAt(0);
		}
		
		// call when a page is shown
		private function updateDebugDisplay():void {
			_DebugOutput.pageid_txt.text = "PID: " + _SiteModel.currentPageID;
			if (_DebugOutput.visible) createMemoryGraph();
		}
		
		private function onDbgRefreshClick(e:Event):void {
			onPageRefresh(undefined);
		}
		
		private function onDbgMPosClick(e:Event):void {
			toggleMouseDbg();
		}
		
		private function  onDbgCLSOClick(e:Event):void {
			_LSOMgr.clearData(_SiteModel.metaID + "_suspendata");
		}
		
		private function onDbgCloseClick(e:Event):void {
			hideDebugOutput();
		}
		
		private function onDbgDragDown(e:Event):void {
			_DebugOutput.startDrag();
		}
		
		private function onDbgDragUp(e:Event):void {
			_DebugOutput.stopDrag();
		}
		
		private function toggleMouseDbg():void {
			if(_MousePosDebug.status == MousePosition.ON) _MousePosDebug.stop();
				else _MousePosDebug.start();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Preloader
		
		private function showPreloader(f:Boolean = false):void { 
			_SiteLoadingBG = new LoadingBG();
			
			_Preloader = new Preloader();
			_Preloader.bar_mc.mask_mc.scaleX = 0;
			
			this.stage.addEventListener(Event.RESIZE, centerPreloader);
			if(!f) _MessageLayer.addChild(_SiteLoadingBG);
			_MessageLayer.addChild(_Preloader);
			centerPreloader(null);
		}
		
		private function centerPreloader(event:Event):void {
			_SiteLoadingBG.scaleX = this.stage.stageWidth*.01;
			_SiteLoadingBG.scaleY = this.stage.stageHeight*.01;
			_Preloader.x = (this.stage.stageWidth >> 1) - (_Preloader.sizer_mc.width >> 1);
			_Preloader.y = (this.stage.stageHeight >> 1) - (_Preloader.sizer_mc.height >> 1);
		}
		
		private function setPreloaderText(t:String):void {
			_Preloader.status_txt.text = t;
		}
		
		private function setPreloaderBarPct(p:int):void {
			_Preloader.bar_mc.mask_mc.scaleX = p*2 * .01;
		}
		
		private function removePreloader():void {
			this.stage.removeEventListener(Event.RESIZE, centerPreloader);
			TweenLite.to(_SiteLoadingBG, .5, {alpha:0, ease:Quadratic.easeOut});
			TweenLite.to(_Preloader, 1, {alpha:0, ease:Quadratic.easeOut, onComplete:deletePreloader});
		}
		
		private function deletePreloader():void {
			_MessageLayer.removeChild(_SiteLoadingBG);
			_MessageLayer.removeChild(_Preloader);
			_SiteLoadingBG = null;
			_Preloader = null;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Context menu
		
		private function customizeContextMenu():void {
			_CustomContextMnu = new ContextMenu();
			_CustomContextMnu.hideBuiltInItems();
			var item:ContextMenuItem = new ContextMenuItem("Player, "+VERSION);
            _CustomContextMnu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleCntxtMnuSelection);
			this.contextMenu = _CustomContextMnu;
		}
		
		private function handleCntxtMnuSelection(event:ContextMenuEvent):void {
			//trace("handleCntxtMnuSelection: " + event.target);
			showAbout();
		}
		
		private function showAbout():void {
			if (_AboutShowing) return;
			
			var p:Array = this.loaderInfo.url.split("/");
			var f:String = p[p.length-1].split(".")[0];
			var abtName:String = "resources/"+f+"_about.swf";
			
			trace("Showing about: " + abtName);
			
			var l:LightBox = new LightBox(abtName, _MessageLayer ,"",{width:280,height:320});
			l.addEventListener(LightBox.UNLOADED,onAboutRemoved);
			//_SiteView.blurViewContainer();
			_AboutShowing = true;
		}
		
		private function onAboutRemoved(e:Event):void {
			_SiteView.removeAllFiltersOnViewContainer();
			_AboutShowing = false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UTILITY
		
		// hack from http://www.gskinner.com/blog/archives/2006/08/as3_resource_ma_2.html			
		// the GC will perform a full mark/sweep on the second call.
		private function performGCHack():void {
			var a:int = System.totalMemory;
			try {
			   new LocalConnection().connect('foo');
			   new LocalConnection().connect('foo');
			} catch (e:*) { }
			_DLog.addDebugText("GC b:"+a+", a:"+System.totalMemory+", d:"+(a-System.totalMemory));
		}
		
		private function performMemoryCheck():void {
			if (_MemoryLog.length > 50) _MemoryLog = new Array();
			var diff:int = System.totalMemory - _InitialMemUsg;
			var m:Number = (diff / 1024) / 1024;
			//trace("mem dif: " + m+"MB");
			_MemoryLog.push(m);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Error notification
		
		private function onPlayerWarning(e:PlayerError):void {
			_DLog.addDebugText("Warning " + e.code + ", " + e.summary);
			if (_RunStage >= Player.RUNNING && _SiteModel.configShowWarnings) {
				messageError("Warning", e.summary+"<br><br>Code "+e.code+"");
			}
		}
		
		private function onPlayerError(e:PlayerError):void {
			_DLog.addDebugText("ERROR " + e.code + ", " + e.summary +" : " + e.text);
			if (_RunStage >= Player.RUNNING) {
				messageError("An error has occurred", e.summary+"<br><br>Code "+e.code+"");
			} else {
				showFatalErrorBox(e.code, e.summary);
			}
		}
		
		private function onPlayerFatal(e:PlayerError):void {
			_DLog.addDebugText("FATAL " + e.code + ", " + e.summary +" : " + e.text);
			if (_RunStage >= Player.RUNNING) {
				messageError("FATAL ERROR! Cannot continue", e.summary+"<br><br>Code "+e.code+"");
			} else {
				showFatalErrorBox(e.code, e.summary);
			}
		}
		
		private function showFatalErrorBox(c:String, s:String):void {
			var w:FatalErrorBox = new FatalErrorBox();
			w.x = 10;
			w.y = 10;
			getErrorLayer().addChild(w);
			w.text_txt.htmlText = s + "<br><br>Code " + c;
		}
		
	}
}