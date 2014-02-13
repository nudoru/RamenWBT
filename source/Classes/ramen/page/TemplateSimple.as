package ramen.page {
	
	import ramen.common.ITemplate;
	import ramen.common.InterfaceEvent;
	
	import ramen.page.PageRendererSimple;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	
	public class TemplateSimple extends MovieClip implements ITemplate {
		
		private var DEBUG				:Boolean = false;
		private var INITD				:Boolean = false;
		
		private var _Started			:Boolean = false;
		
		protected var _PageRenderer		:PageRendererSimple;
		
		private var _XMLSrcDocument		:String;
		private var _TemplateName		:String = ""
		
		// PageEvents
		public static const LOADED		:String = "loaded";
		public static const INITIALIZED	:String = "initialized";
		public static const RENDERED	:String = "rendered";
		public static const COMPLETED	:String = "completed";
		public static const UNLOADED	:String = "unloaded";
		
		public function TemplateSimple():void {
			
			try {
				// if this works, then we're not running from the player
				if(this.loaderInfo.url.indexOf("/templates/")>1) DEBUG = true;
			} catch(e:*) {
				// we got an error, so we're running from the player
				// this isn't on the DisplayList of the player yet, so we get the error
			}
			
			if (DEBUG) initialize();
			
			dispatchEvent(new Event(TemplateSimple.LOADED));
		}
		
		// used to mesaure height to add scroll bar or not
		public function measure():Object {
			return { width:this.width, height:this.height };
		}
		
		// called by the player - passes XML file name from the site.xml file
		public function initialize(xd:String = ""):void {
			if (INITD) return;
			INITD = true;
			if(DEBUG) {
				// gets the name of the SWF file. if in DEBUG, will load the SWF_FILE_NAME.xml file as content
				var p:Array = this.loaderInfo.url.split("/");
				var f:String = p[p.length-1].split(".")[0];
				_TemplateName = f;
			}
			
			_XMLSrcDocument = !DEBUG ? xd : _TemplateName+".xml";
			
			_PageRenderer = new PageRendererSimple(this);
			_PageRenderer.addEventListener(PageRendererSimple.RENDERED, onPageRendererRendered);
			_PageRenderer.initialize(_XMLSrcDocument);
			
			addChild(_PageRenderer);
			
			dispatchEvent(new Event(TemplateSimple.INITIALIZED));
		}
		
		protected function onPageRendererRendered(e:Event):void {
			_PageRenderer.removeEventListener(PageRendererSimple.RENDERED, onPageRendererRendered);
			start();
		}
		
		public function start():void {
			_PageRenderer.renderPageContent();
			renderInteraction();
			_PageRenderer.start();
			startInteraction();
			
			_Started = true;
			
			dispatchEvent(new Event(TemplateSimple.RENDERED));
			dispatchEvent(new InterfaceEvent(InterfaceEvent.PAGE, true, false, this, "page_loaded"));
			
			trace("Template started");
		}

		// this funtion should be overridden by subclasses
		protected function renderInteraction():void {
			//
		}
		
		// this funtion should be overridden by subclasses
		protected function startInteraction():void {
			//
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// misc
		
		// called by the player on page changes
		public function destroy():void {
			if(_Started) {
				_PageRenderer.stop();
			} else {
				_PageRenderer.removeEventListener(PageRendererSimple.RENDERED, onPageRendererRendered);
			}
			_PageRenderer.destroy();
			removeChild(_PageRenderer)
			_PageRenderer = null;
			dispatchEvent(new Event(TemplateSimple.UNLOADED));
		}
	}
}