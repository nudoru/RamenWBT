/*
Page loader
2.14.09
*/

package ramen.player {
	
	import flash.display.DisplayObject;
	import ramen.common.*;
	import ramen.player.*;
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Graphics;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.net.URLRequest;
	import flash.events.*;
	import com.nudoru.utils.Debugger;
	
	public class PageLoader extends Sprite {
		
		private var _Complete		:Boolean = false;
		private var _PageSWFFileName:String;
		private var _PageXMLFileName:String;
		private var _PageEntryObject:Object;
		private var _TargetSprite	:Sprite;
		private var _X				:int;
		private var _Y				:int;
		private var _Width			:int;
		private var _Height			:int;
		
		private var _Container		:MovieClip;
		private var _LoadingBar		:Sprite;
		private var _SWFLoader		:Loader;
		
		private var _Settings		:Settings;
		
		private var _PageLoadingProgress:Number = 0;
		
		private static var _Index	:int;
		
		private var _DLog			:Debugger;
		
		public static const LOADED	:String = "loaded";
		public static const PROGRESS:String = "progress";
		public static const ERROR	:String = "error";
		public static const UNLOADED:String = "unloaded";
		
		//public function get pageloader():Loader { return _SWFLoader }
		
		public function get container():MovieClip { return _Container }
		
		public function get pageLoadingProgress():Number { return _PageLoadingProgress }
		
		public function get page():DisplayObject { return _SWFLoader.content }
		
		public function PageLoader(t:Sprite, swf:String,  xml:String, peo:Object, initObj:Object):void {
			_Index++
			_DLog = Debugger.getInstance();
			_Settings = Settings.getInstance();
			
			_TargetSprite = t;
			_PageSWFFileName = swf;
			_PageXMLFileName = xml;
			_PageEntryObject = peo;

			_X = initObj.x;
			_Y = initObj.y;
			_Width = initObj.width;
			_Height = initObj.height;
			
			_Container = new MovieClip();
			_Container.name = "pagecontainer";
			_Container.x = _X;
			_Container.y = _Y;
			
			_SWFLoader = new Loader();
			_SWFLoader.name = "pageloader";
			_SWFLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onSWFError);
			_SWFLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onSWFProgress);
			_SWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSWFComplete);
			
			_SWFLoader.load(new URLRequest(_PageSWFFileName));
			_Container.addChild(_SWFLoader);
			_TargetSprite.addChild(_Container);
		}
		
		private function onSWFError(event:Event):void {
			removeListeners();
			// this even triggers the player to clean up
			dispatchEvent(new Event(PageLoader.ERROR));
		}
		
		private function onSWFProgress(event:ProgressEvent):void {
			_PageLoadingProgress = event.bytesLoaded/event.bytesTotal;
			dispatchEvent(new Event(PageLoader.PROGRESS));
		}
		
		private function onSWFComplete(event:Event):void {
			try {
				// or to access it later Object(_SWFLoader.content).initialize();
				event.target.content.initialize(_PageXMLFileName, _PageEntryObject);
			} catch(e:*) {
				//_DLog.addDebugText("!!! PageLoader Error: couldn't run initialize()");
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Could not run initialze on the page template"));
			}
			removeListeners();
			_Complete = true;
			dispatchEvent(new Event(PageLoader.LOADED));
		}
		
		private function removeListeners():void {
			_SWFLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onSWFError);
			_SWFLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onSWFProgress);
			_SWFLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSWFComplete);
		}
		
		public function destroy():void {
			if (!_SWFLoader) return;
			if (!_Complete) removeListeners();
			//trace("destroy on: " + _PageSWFFileName);
			try {
				//trace("pageloader destroy "+Object(_SWFLoader.content)+", "+_SWFLoader.contentLoaderInfo.bytesTotal);
				Object(_SWFLoader.content).destroy();
			} catch(e:*) {
				_DLog.addDebugText("!!! PageLoader Error: couldn't run destroy: " + String(e));
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Could not run destroy on the page template"));
			}
			try {
				_SWFLoader.close()
			} catch (e:*) {
				// will fail if not in progress of loading
				//_DLog.addDebugText("!!! PageLoader Error: couldn't close loader: "+String(e));
			}
			_SWFLoader.unload();
			_Container.removeChild(_SWFLoader);
			_TargetSprite.removeChild(_Container);
			_SWFLoader = null;
			_Container = null;
			
			dispatchEvent(new Event(PageLoader.UNLOADED));
		}
	}
	
}