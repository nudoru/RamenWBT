/*
Base class for a site
last updated: 2.16.09

Tweener docs: http://hosted.zeh.com.br/tweener/docs/en-us/

Info on the queue loader: http://blog.hydrotik.com/category/queueloader/
*/

package ramen.player {
	
	import ramen.common.*;
	import ramen.player.*;
	
	import flash.display.*;
	import flash.text.StyleSheet;
	import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import com.hydrotik.utils.QueueLoader;
	import com.hydrotik.utils.QueueLoaderEvent;
	import com.nudoru.utils.BMUtils;
	import com.nudoru.utils.Debugger;
	
	import fl.events.ScrollEvent;
	import fl.controls.*;
	
	public class AbstractView extends Sprite implements ISiteView{

		protected var _ViewContainter		:Sprite;
		protected var _SiteModel			:SiteModel;
		protected var _CurrentPageLoader	:PageLoader;
		protected var _UIContainer			:Sprite;
		protected var _PopUpContrainer		:Sprite;
		protected var _Background			:Sprite;
		protected var _MainBackgroundLayer	:Sprite;
		protected var _MainUICont			:Sprite;
		protected var _MainUIBG				:Sprite;
		protected var _FocusLayer			:Sprite;
		protected var _PageArea				:Sprite;
		protected var _PageAreaMask			:Sprite;
		protected var _PageAreaScrollbar	:UIScrollBar;
		protected var _Navigation			:Sprite;
		protected var _Overlay				:Sprite;
		protected var _MainMenuCont			:Sprite;		// unused
		protected var _PageScrollBarCont	:Sprite;		// scroll bar uses this
		protected var _StyleSheet			:StyleSheet;
		protected var _PageLoadingBar		:Sprite;
		
		protected var _LastPageBMImage		:Bitmap;
		protected var _LastPageImage		:Sprite;
		
		protected var _SharedResLoader		:Loader;
		
		protected var _ConfigSiteWidth		:int;
		protected var _ConfigSiteHeight		:int;
		protected var _ConfigHAlign			:String;
		protected var _ConfigVAlign			:String;
		protected var _ConfigHSnap			:int;
		protected var _ConfigVSnap			:int;
		
		protected var _CropPageArea			:Boolean;
		protected var _ScrollPageArea		:Boolean;
		
		protected var _Preloader			:Sprite;
		
		private var _DLog					:Debugger;
		
		private var _ThemeQueueLoader		:QueueLoader = new QueueLoader();
		
		public static const LOADED		:String = "loaded";
		
		public function set dataModel(d:SiteModel):void {
			_SiteModel = d;
			_SiteModel.addEventListener(SiteModel.PAGE_CHANGE, onPageChange);
		}
		
		public function get pageAreaSprite():Sprite { return _PageArea }
		public function get popUpContainer():Sprite { return _PopUpContrainer }
		
		public function get css():StyleSheet { return _StyleSheet }
		
		public function get currentPageXtoGlobal():int { return _MainUICont.x + _SiteModel.configDefaultPageX; }
		public function get currentPageYtoGlobal():int { return _MainUICont.y + _SiteModel.configDefaultPageY; }
		public function get currentPageWidth():int { return _SiteModel.configDefaultPageWidth; }
		public function get currentPageHeight():int { return _SiteModel.configDefaultPageHeight; }
		
		public function AbstractView(cntr:Sprite,d:SiteModel):void {
			_DLog = Debugger.getInstance();
			
			_ViewContainter = cntr;
			dataModel = d;
				
				// copy these values from the model since local var access is faster than accessing it from another class
			_ConfigSiteWidth = _SiteModel.configSiteWidth;
			_ConfigSiteHeight = _SiteModel.configSiteHeight;
			_ConfigHAlign = _SiteModel.configSiteHAlign;
			_ConfigVAlign = _SiteModel.configSiteVAlign;
			_ConfigHSnap = _SiteModel.configHSnap;
			_ConfigVSnap = _SiteModel.configVSnap;
			_CropPageArea = _SiteModel.configCropPageArea;
			_ScrollPageArea = _SiteModel.configScrollPageArea;
		}
		
		public function render():void {
			_MainBackgroundLayer = Sprite(Sprite(_ViewContainter.stage.getChildAt(0)).getChildByName("backgroundlayer"));
			createSiteContainers();
			loadThemeFiles();
		}
		
		public function setPreloader(p:Sprite):void {
			_Preloader = p;
			Object(_Preloader).bar_mc.mask_mc.scaleX = 0;
		}
		
		public function blurViewContainer():void {
			var filter:BitmapFilter = new BlurFilter(10, 10, BitmapFilterQuality.LOW);
            var myFilters:Array = new Array();
            myFilters.push(filter);
            _ViewContainter.filters = myFilters;
		}
		
		public function removeAllFiltersOnViewContainer():void {
			_ViewContainter.filters = null;
		}
		
		public function blurMainUI():void {
			var filter:BitmapFilter = new BlurFilter(10, 10, BitmapFilterQuality.LOW);
            var myFilters:Array = new Array();
            myFilters.push(filter);
            _MainUICont.filters = myFilters;

		}
		
		public function removeAllFiltersOnMainUI():void {
			 _MainUICont.filters = null;
		}
		
		public function getSharedResource(n:String):Object {
			var objC:Class = Class(_SharedResLoader.content.loaderInfo.applicationDomain.getDefinition(n));
			var obj:Object = Object(new objC());
			return obj;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Update UI on Model changes
		
		public function onPageChange(e:Event):void {
			updateUI();
		}
		
		public function updateUI():void {
			//_DLog.addDebugText("View, VIEW UPDATE UI");
			updateResourcesOnPageChange();
		}
		
		public function handleNavigationUIEvent(e:NavigationUIEvent):void {
			try {
				if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).onNavigationUIEvent(e);
			} catch(e:*) {
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "AbstractView Error: can't pass NavigationUIEvent to navigation SWF."));
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI Navigation
		
		private function onMainNavClick(e:Event):void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.MAIN_MENU_SELECTION, true, false, e.target.label_txt.text, e.target.label_txt.text));
		}

		private function onPageNavClick(e:Event):void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.PAGE_MENU_SELECTION, true, false, e.target.label_txt.text, e.target.label_txt.text));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Setup the site
		
		private function createSiteContainers():void {
			_UIContainer = new Sprite();
			_PopUpContrainer = new Sprite();
			
			_Background = new Sprite();
			_MainUICont = new Sprite();
			_MainUIBG = new Sprite();
			_PageArea = new Sprite();
			_PageAreaMask = new Sprite();
			_PageScrollBarCont = new Sprite();
			_MainMenuCont = new Sprite();
			_Navigation = new Sprite();
			_Overlay = new Sprite();

			_MainUICont.addChild(_MainUIBG);
			_MainUICont.addChild(_PageArea);
			_MainUICont.addChild(_PageAreaMask);
			_MainUICont.addChild(_PageScrollBarCont);
			_MainUICont.addChild(_MainMenuCont);
			_MainUICont.addChild(_Navigation);
			_MainUICont.addChild(_Overlay);
			
			//_UIContainer.addChild(_Background);
			_MainBackgroundLayer.addChild(_Background);
			_UIContainer.addChild(_MainUICont);
			_UIContainer.visible = false;		// hide it until everything is loaded
			
			_ViewContainter.addChild(_UIContainer);
			_ViewContainter.addChild(_PopUpContrainer);
			
			/*if (_CropPageArea) {
				_PageAreaMask.graphics.beginFill(0xff0000, 1);
				//_PageAreaMask.graphics.drawRoundRect(_SiteModel.configDefaultPageX, _SiteModel.configDefaultPageY, _SiteModel.configDefaultPageWidth, _SiteModel.configDefaultPageHeight, 10);
				_PageAreaMask.graphics.drawRect(_SiteModel.configDefaultPageX, _SiteModel.configDefaultPageY, _SiteModel.configDefaultPageWidth, _SiteModel.configDefaultPageHeight);
				_PageAreaMask.graphics.endFill();
				_PageArea.mask = _PageAreaMask;
			}*/
		}
		
		public function setPageMask():void {
			if (_PageArea.mask) return;
			trace("Setting Mask");
			_PageAreaMask.graphics.beginFill(0xff0000, 1);
			_PageAreaMask.graphics.drawRect(_SiteModel.configDefaultPageX, _SiteModel.configDefaultPageY, _SiteModel.configDefaultPageWidth, _SiteModel.configDefaultPageHeight);
			_PageAreaMask.graphics.endFill();
			_PageArea.mask = _PageAreaMask;
		}
		
		public function clearPageMask():void {
			trace("Clearing Mask");
			removePageScrollBar();
			_PageArea.y = 0;
			_PageAreaMask.graphics.clear();
			_PageArea.mask = null;
		}
		
		private function finalizeSiteContainers():void {
			_SharedResLoader = Loader(Sprite(_Background.getChildByName("sharedres")).getChildAt(0));
			initializeResources();
			adjustUI(false);
			_UIContainer.visible = true;
			_ViewContainter.stage.addEventListener(Event.RESIZE, onWindowResize);
			_ThemeQueueLoader = null;
			_Preloader = null;
			dispatchEvent(new Event(CenteredView.LOADED));
		}
		
		
		// TODO, find a better way than this string of casts!
		private function initializeResources():void {
			try {
				if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).initialize(_SiteModel.getCourseDataPacket());
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on Navigation");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on Navigation"));
			}
			try {
				if(_SiteModel.configInterfaceBGFile && _SiteModel.configInterfaceBGFile.indexOf(".swf") > 0) Object(Loader(Sprite(_MainUIBG.getChildByName("uibg")).getChildAt(0)).content).initialize();
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on MainUIBG");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on MainUIBG"));
			}
			try {
				if(_SiteModel.configOverlayFile && _SiteModel.configOverlayFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Overlay.getChildByName("overlay")).getChildAt(0)).content).initialize();
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on Overlay");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on Overlay"));
			}
			try {
				if(_SiteModel.configBackgroundFile && _SiteModel.configBackgroundFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Background.getChildByName("background")).getChildAt(0)).content).initialize();
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on Background");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on Background"));
			}
			try {
				if(_SiteModel.configAudioBGFile) Object(Loader(Sprite(_Background.getChildByName("bgaudio")).getChildAt(0)).content).initialize();
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on AudioBGFile");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on AudioBGFile"));
			}
			try {
				if(_SiteModel.configAudioSFXFile) Object(Loader(Sprite(_Background.getChildByName("sfxaudio")).getChildAt(0)).content).initialize(_SiteModel.configSndBGEnabled);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't run initialize() on AudioSFXFile");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't run initialize() on AudioSFXFile"));
			}
			//don't need to init the shared resources, if(_SiteModel.configSharedResFile) Object(Loader(Sprite(_Background.getChildByName("sharedres")).getChildAt(0)).content).initialize();
		}
		
		protected final function updateResourcesOnPageChange():void {
			// send the UI bg the page ID
			try {
				if(_SiteModel.configInterfaceBGFile && _SiteModel.configInterfaceBGFile.indexOf(".swf") > 0) Object(Loader(Sprite(_MainUIBG.getChildByName("uibg")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update MainUIBG on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update MainUIBG on page change"));
			}
			// send the navigation the page ID, parent page ID, current node data, is prev, is next
			try {
				//if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID, _SiteModel.currentPageParentID, _SiteModel.getStructureDataUnderCurrentNode(), _SiteModel.isLinearPreviousPage(), _SiteModel.isLinearNextPage());
				if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).updateOnPageChange(_SiteModel.getCurrentPageInfoObject());
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update Navigation on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update Navigation on page change"));
			}
			try {
				if(_SiteModel.configBackgroundFile && _SiteModel.configBackgroundFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Background.getChildByName("background")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update BackgroundFile on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update BackgroundFile on page change"));
			}
			try {
				if(_SiteModel.configOverlayFile && _SiteModel.configOverlayFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Overlay.getChildByName("overlay")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update OverlayFile on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update OverlayFile on page change"));
			}
			try {
				if(_SiteModel.configAudioBGFile && _SiteModel.configAudioBGFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Background.getChildByName("bgaudio")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update AudioBGFile on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update AudioBGFile on page change"));
			}
			try {
				if(_SiteModel.configAudioSFXFile && _SiteModel.configAudioSFXFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Background.getChildByName("sfxaudio")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID);
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update AudioSFXFile on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update AudioSFXFile on page change"));
			}
		}
		
		public function updateResourcesOnStatusChange():void {
			// send the navigation the page ID, parent page ID, current node data, is prev, is next
			try {
				//if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).updateOnPageChange(_SiteModel.currentPageID, _SiteModel.currentPageParentID, _SiteModel.getStructureDataUnderCurrentNode(), _SiteModel.isLinearPreviousPage(), _SiteModel.isLinearNextPage());
				if(_SiteModel.configNavigationFile && _SiteModel.configNavigationFile.indexOf(".swf") > 0) Object(Loader(Sprite(_Navigation.getChildByName("navigation")).getChildAt(0)).content).updateOnPageChange(_SiteModel.getCurrentPageInfoObject());
			} catch(e:*) {
				//_DLog.addDebugText("!!! AbstractView Error: couldn't update Navigation on page change");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "AbstractView Error: couldn't update Navigation on status change"));
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Page Loading
		
		public function showPageLoadingBar():void {
			if(_PageLoadingBar) removePageLoadingBar()
			_PageLoadingBar = new Sprite();
			_PageLoadingBar.name = "loadingbar_mc";
			
			var lb:Class = Class(_SharedResLoader.content.loaderInfo.applicationDomain.getDefinition("PageLoading"));
			var bar:Object = Object(new lb());

			bar.bar_mc.mask_mc.scaleX = 0;
			_PageLoadingBar.x = Math.floor((_SiteModel.currentPageWidth/2)-((bar.sizer_mc.width)/2))+_SiteModel.currentPageX;
			_PageLoadingBar.y = Math.floor((_SiteModel.currentPageHeight/2)-((bar.sizer_mc.height)/2))+_SiteModel.currentPageY;
			_PageLoadingBar.addChild(Sprite(bar));
			_PageArea.addChild(_PageLoadingBar);
		}
		
		public function updatePageLoadingProgress(p:Number):void {
			try {
				Object(_PageLoadingBar.getChildAt(0)).bar_mc.mask_mc.scaleX = p * 2;
			} catch(e:*) {}
		}
		
		public function removePageLoadingBar(a:Boolean = false):void {
			try {
				if(!a) {
					_PageArea.removeChild(_PageLoadingBar);
					_PageLoadingBar = undefined;
				} else {
					TweenLite.to(_PageLoadingBar,.5,{alpha:0, onComplete:removePageLoadingBar});
				}
			} catch(e:*) { }
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Page transitions
		
		public function fadeInCurrentPage(s:Sprite, dur:Number):void {
			s.alpha = 0;
			TweenLite.to(s, dur, { alpha:1, ease:Quadratic.easeOut } );
			if(_LastPageImage) TweenLite.to(_LastPageImage, dur, {alpha:0, ease:Quadratic.easeOut, onComplete:deleteImageOfLastPage});
		}
		
		public function slideInCurrentPage(s:Sprite, dir:int):void {
			var opX:int = _SiteModel.configDefaultPageWidth * -1;
			var npX:int = _SiteModel.configDefaultPageWidth;
			if (dir == PageTransition.DIR_BACK) {
				opX = _SiteModel.configDefaultPageWidth;
				npX = _SiteModel.configDefaultPageWidth*-1;
			} else if (dir == PageTransition.DIR_NONE) {
				fadeInCurrentPage(s, PageTransition.DUR_QUICK);
				return;
			}
			s.alpha = 0;
			s.x = npX;
			TweenLite.to(s, PageTransition.DUR_MEDIUM, { alpha:1, x:_SiteModel.configDefaultPageX, ease:Quadratic.easeOut } );
			if(_LastPageImage) TweenLite.to(_LastPageImage, PageTransition.DUR_MEDIUM, {alpha:0, x:opX, ease:Quadratic.easeOut, onComplete:deleteImageOfLastPage});
		}
		
		public function squeezeInCurrentPage(s:Sprite, dir:int):void {
			var opX:int = _SiteModel.configDefaultPageX; //0;// _SiteModel.configDefaultPageWidth * -1;
			var npX:int = _SiteModel.configDefaultPageX+_SiteModel.configDefaultPageWidth;
			if (dir == PageTransition.DIR_BACK) {
				opX = _SiteModel.configDefaultPageWidth;
				npX = _SiteModel.configDefaultPageX; // _SiteModel.configDefaultPageWidth * -1;
			} else if (dir == PageTransition.DIR_NONE) {
				fadeInCurrentPage(s, PageTransition.DUR_QUICK);
				return;
			}
			s.scaleX = 0;
			s.x = npX;
			TweenLite.to(s, PageTransition.DUR_MEDIUM, { scaleX:1, x:_SiteModel.configDefaultPageX, ease:Quadratic.easeOut } );
			if(_LastPageImage) TweenLite.to(_LastPageImage, PageTransition.DUR_MEDIUM, {x:opX, scaleX:0, ease:Quadratic.easeOut, onComplete:deleteImageOfLastPage});
		}
		
		public function createImageOfLastPage(s:Sprite):void {
			deleteImageOfLastPage();
			_LastPageBMImage = BMUtils.getBitmapCopy(s, 0, 0, _SiteModel.currentPageWidth, _SiteModel.currentPageHeight);
			if(_LastPageBMImage) {
				_LastPageImage = new Sprite();
				_LastPageImage.x = _SiteModel.currentPageX;
				_LastPageImage.y = _SiteModel.currentPageY;
				_LastPageImage.addChild(_LastPageBMImage);
				pageAreaSprite.addChild(_LastPageImage);
			}
		}
		
		public function fadeImageOfLastPage():void {
			TweenLite.to(_LastPageBMImage, 2, { alpha:.5, ease:Quadratic.easeOut } );
		}
		
		protected function deleteImageOfLastPage():void {
			if (_LastPageBMImage) {
				_LastPageBMImage.bitmapData.dispose();
				_LastPageBMImage = undefined;
			}
			if (_LastPageImage) {
				pageAreaSprite.removeChild(_LastPageImage);
				_LastPageImage = undefined;
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Page scrolling
		
		// param is wild since the arg will be the type of template displayed
		// TODO template interface, and datatype to it
		public function configurePageScrolling(p:ITemplate):Boolean {
			_PageArea.y = 0;
			if (_CropPageArea && _ScrollPageArea) {
				setPageMask();
				//trace("passed: " + p);
				//trace("page height: " + p.measure().height);
				if (p.measure().height > _SiteModel.configDefaultPageHeight) {
					removePageScrollBar();
					var diff:int = p.measure().height - _SiteModel.configDefaultPageHeight;
					_PageAreaScrollbar = new UIScrollBar();
					_PageAreaScrollbar.addEventListener(ScrollEvent.SCROLL, onPageScroll);
					_PageAreaScrollbar.height = _SiteModel.configDefaultPageHeight;
					_PageAreaScrollbar.x = _SiteModel.configDefaultPageX + _SiteModel.configDefaultPageWidth + 2;
					_PageAreaScrollbar.y = _SiteModel.configDefaultPageY;
					_PageAreaScrollbar.setScrollProperties(_SiteModel.configDefaultPageHeight, 0, diff, int(diff/4));
					_PageScrollBarCont.addChild(_PageAreaScrollbar);
				
					//trace("sb fm: " + _PageAreaScrollbar.focusManager);
					// fixes tab focus on dynamically created page items
					_PageAreaScrollbar.focusManager.deactivate();
					
					
					/*_PageScrollBarCont.tabChildren = true;
					_PageArea.tabChildren = true;
					_PageAreaMask.tabChildren = true;
					
					AccessibilityManager.getInstance().addActivityItem(_PageAreaScrollbar, "Page scrollbar");*/
					
					return true;
				} else {
					removePageScrollBar();
					return false;
				}
			}
			return false;
		}

		private function onPageScroll(e:ScrollEvent):void {
			_PageArea.y = e.position * -1;
		}
		
		private function removePageScrollBar():void {
			if (_PageAreaScrollbar) {
				_PageAreaScrollbar.removeEventListener(ScrollEvent.SCROLL, onPageScroll);
				_PageScrollBarCont.removeChild(_PageAreaScrollbar);
				_PageAreaScrollbar = undefined;
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Audio
		
		public function playSoundEffect(e:String):void {
			try {
				Object(Loader(Sprite(_Background.getChildByName("sfxaudio")).getChildAt(0)).content).playSoundEffect(e);
			} catch(e:*) {}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI Adjust
		
		// this function must be overridden by any subclass!
		public function adjustUI(a:Boolean):void {
			_DLog.addDebugText("AbstractView, adjust ui");
		}
		
		private function onWindowResize(event:Event):void {
			adjustUI(false);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI loading
		
		private function loadThemeFiles():void {
			var uiBG:Sprite = new Sprite();
			uiBG.name = "uibg";
			var ovrImage:Sprite = new Sprite();
			ovrImage.name = "overlay";
			var navigation:Sprite = new Sprite();
			navigation.name = "navigation";
			var bgImage:Sprite = new Sprite();
			bgImage.name = "background";
			var bgAudio:Sprite = new Sprite();
			bgAudio.name = "bgaudio";
			var sfxAudio:Sprite = new Sprite();
			sfxAudio.name = "sfxaudio";
			var sharedRes:Sprite = new Sprite();
			sharedRes.name = "sharedres";
			bgAudio.x = -1000;
			bgAudio.y = -1000;
			sfxAudio.x = -1000;
			sfxAudio.y = -1000;
			sharedRes.x = -1000;
			sharedRes.y = -1000;
			if(_SiteModel.configInterfaceBGFile) {
				_MainUIBG.addChild(uiBG);
				_ThemeQueueLoader.addItem(_SiteModel.configInterfaceBGFile, uiBG, {title:"UIBGImage"});
			}
			if(_SiteModel.configNavigationFile) {
				_Navigation.addChild(navigation);
				_ThemeQueueLoader.addItem(_SiteModel.configNavigationFile, navigation, {title:"UINavigation"});
			}
			if(_SiteModel.configOverlayFile) {
				_Overlay.addChild(ovrImage);
				_ThemeQueueLoader.addItem(_SiteModel.configOverlayFile, ovrImage, {title:"UIOverlayImage"});
			}
			if(_SiteModel.configBackgroundFile) {
				_Background.addChild(bgImage);
				_ThemeQueueLoader.addItem(_SiteModel.configBackgroundFile, bgImage, {title:"BGImage"});
			}
			if(_SiteModel.configAudioBGFile) {
				_Background.addChild(bgAudio);
				_ThemeQueueLoader.addItem(_SiteModel.configAudioBGFile, bgAudio, {title:"BGAudio"});
			}
			if(_SiteModel.configAudioSFXFile) {
				_Background.addChild(sfxAudio);
				_ThemeQueueLoader.addItem(_SiteModel.configAudioSFXFile, sfxAudio, {title:"SFXAudio"});
			}
			if(_SiteModel.configSharedResFile) {
				_Background.addChild(sharedRes);
				_ThemeQueueLoader.addItem(_SiteModel.configSharedResFile, sharedRes, {title:"SharedRes"});
			}
			// not using CSS yet
			if(_SiteModel.configCSSFile) {
				_ThemeQueueLoader.addItem(_SiteModel.configCSSFile, uiBG, {title:"CSSFile"});
			}
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.QUEUE_START, onQueueStart, false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.ITEM_START, onItemStart, false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.ITEM_PROGRESS, onItemProgress, false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.ITEM_INIT, onItemInit,false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError,false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress, false, 0, true);
			_ThemeQueueLoader.addEventListener(QueueLoaderEvent.QUEUE_INIT, onQueueInit,false, 0, true);
			_ThemeQueueLoader.execute();
		}
		
		//Theme queue Listener functions
		private function onQueueStart(event:QueueLoaderEvent):void {
			_DLog.addDebugText("AbstractView, loading theme files >> "+event.type);
		}
		
		private function onItemStart(event:QueueLoaderEvent):void {
			//trace("\t>> "+event.type, "item title: "+event.title);
		}
		
		private function onItemProgress(event:QueueLoaderEvent):void {
			//trace("\t>> "+event.type+": "+[" percentage: "+event.percentage]);
		}
		
		private function onQueueProgress(event:QueueLoaderEvent):void {
			//trace("\t>> "+event.type+": "+[" queuepercentage: "+event.queuepercentage]);
			Object(_Preloader).bar_mc.mask_mc.scaleX = event.queuepercentage * 2;
		}
		
		private function onItemInit(event:QueueLoaderEvent):void {
			_DLog.addDebugText("Theme file loaded: " + event.title); //+ " event:" + event.type+" - "+["target: "+event.targ, "w: "+event.width, "h: "+event.height]);
			if (event.title == "CSSFile") {
				parseCSSFile(event.file);
			}
		}
		
		private function onItemError(event:QueueLoaderEvent):void {
			//_DLog.addDebugText("AbstractView, ERROR loading theme file >> "+event.message);
			dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "AbstractView Error: coundn't load theme file.<br><br>"+event.message));
		}
		
		private function onQueueInit(event:QueueLoaderEvent):void {
			_DLog.addDebugText("AbstractView, theme files done >> "+event.type);
			finalizeSiteContainers();
		}
		
		private function parseCSSFile(t:String):void {
			_StyleSheet = new StyleSheet();
			_StyleSheet.parseCSS(t);
			_DLog.addDebugText("Loaded CSS: "+_StyleSheet.styleNames);
		}
		
	}
}