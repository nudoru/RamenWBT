package ramen.page {
	
	import ramen.common.*;
	import ramen.page.*;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import com.nudoru.utils.Debugger;
	
	public class Template extends MovieClip implements ITemplate {
		
		protected var DEBUG				:Boolean = false;
		protected var INITD				:Boolean = false;
		
		private var _Started			:Boolean = false;
		
		protected var _PageRenderer		:PageRenderer;
		protected var _DLog				:Debugger;
		
		private var _XMLSrcDocument		:String;
		private var _TemplateName		:String = "";
		
		private var _PageEntryStatus	:int;
		private var _IsPageScored		:Boolean;
		
		public function get debugMode():Boolean { return DEBUG; }
		public function set debugMode(d:Boolean) { DEBUG = d; }
		public function get standaloneMode():Boolean { return _PageRenderer.standalone; }
		
		public function get pageEntryStats():int { return _PageEntryStatus; }
		public function get isPageScored():Boolean { return _IsPageScored; }
		
		public function Template():void {
			_DLog = Debugger.getInstance();
			
			try {
				// if this works, then we're not running from the player
				//if(this.loaderInfo.url.indexOf("/templates/")>1) DEBUG = true;
				if (this.loaderInfo.url.length) DEBUG = true;
			} catch(e:*) {
				// we got an error, so we're running from the player
				// this isn't on the DisplayList of the player yet, so we get the error
			}
			
			if (DEBUG) {
				trace("PAGE IN DEBUG MODE!!!");
				initialize("",undefined);
			}
			
			dispatchEvent(new PageEvent(PageEvent.LOADED, true, false, "", ""));
		}
		
		// used to mesaure height to add scroll bar or not
		public function measure():Object {
			return { width:this.width, height:this.height };
		}
		
		// called by the player - passes XML file name from the site.xml file
		// es is the status of the page
		public function initialize(xd:String, initObj:Object):void {
			if (INITD) return;
			INITD = true;
			if(DEBUG) {
				// gets the name of the SWF file. if in DEBUG, will load the SWF_FILE_NAME.xml file as content
				var p:Array = this.loaderInfo.url.split("/");
				var f:String = p[p.length-1].split(".")[0];
				_TemplateName = f;
			}
			
			_XMLSrcDocument = !DEBUG ? xd : _TemplateName+".xml";
			
			if(initObj) {
				_PageEntryStatus = initObj.status;
				_IsPageScored = initObj.scored;
			}
			
			//_DLog.addDebugText("template entry status: " + _PageEntryStatus);
			
			_PageRenderer = new PageRenderer(this);
			_PageRenderer.addEventListener(PageRenderer.RENDERED, onPageRendererRendered);
			_PageRenderer.initialize(_XMLSrcDocument);
			
			addChild(_PageRenderer);
			
			dispatchEvent(new PageEvent(PageEvent.INITIALIZED, true, false, "", ""));
		}
		
		protected function onPageRendererRendered(e:Event):void {
			_PageRenderer.removeEventListener(PageRenderer.RENDERED, onPageRendererRendered);
			start();
		}
		
		public function start():void {
			_PageRenderer.renderPageContent();
			renderInteraction();
			_PageRenderer.start();
			startInteraction();
			
			_Started = true;
			
			dispatchEvent(new PageEvent(PageEvent.RENDERED));
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "page_loaded"));
			
			//dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
			//_DLog.addDebugText("Template started");
			
			trace("standalone: " + standaloneMode);
		}

		// this funtion should be overridden by subclasses
		protected function renderInteraction():void {
			//
		}
		
		// this funtion should be overridden by subclasses
		protected function startInteraction():void {
			//
		}
		
		public function hasPageBeenPreviouslyCompleted():Boolean {
			if (pageEntryStats == ObjectStatus.PASSED || pageEntryStats == ObjectStatus.COMPLETED || pageEntryStats == ObjectStatus.FAILED) return true;
			return false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// misc
		
		public static function rnd(min:Number, max:Number):Number {
			return min + Math.floor(Math.random() * (max + 1 - min))
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// handle player events
		
		// called from the Player
		public function handlePopUpEvent(e:PopUpEvent):void {
			trace("template from PM, type: " + e.type + ", from: "+e.data+" to: " + e.callingobj+" about: "+e.buttondata);
		}
		
		public function handleKeyPress(k:int, isAlt:Boolean = false, isCtrl:Boolean = false, isShift:Boolean = false, l:int=0):void {
			trace("template from PM, keycode: " + k + " alt: " + isAlt + " ctrl: " + isCtrl + " shift: " + isShift + " location: " + l);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// navigation
		
		protected function restartPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.REFRESH_CURRENT_PAGE, true, false, "", ""));
		}
		
		protected function jumpToPage(n:String,i:String = ""):void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.PAGE_MENU_SELECTION, true, false, n, i));
		}
	
		protected function gotoNextPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_NEXT_PAGE, true, false, "", ""));
		}
		
		protected function gotoPrevPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_PREVIOUS_PAGE, true, false, "", ""));
		}
		
		/*
		//----------------------------------------------------------------------------------------------------------------------------------
		// popups
		
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
			popup += "<vpos>"+ObjectStatus.PAGE_LOW_MIDDLE+"</vpos>";
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
		*/
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// misc
		
		// called by the player on page changes
		public function destroy():void {
			if(_Started) {
				_PageRenderer.stop();
			} else {
				_PageRenderer.removeEventListener(PageRenderer.RENDERED, onPageRendererRendered);
			}
			_PageRenderer.destroy();
			removeChild(_PageRenderer)
			_PageRenderer = null;
			dispatchEvent(new PageEvent(PageEvent.UNLOADED, true, false, "", ""));
		}
	}
}