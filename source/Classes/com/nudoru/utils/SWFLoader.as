package com.nudoru.utils {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Graphics;
	import flash.net.URLRequest;
	import flash.events.*;
	
	public class SWFLoader extends MovieClip {
		
		private var _FileName		:String;
		private var _TargetSprite	:Sprite;
		private var _X				:int;
		private var _Y				:int;
		private var _Width			:int;
		private var _Height			:int;
		
		private var _Container		:MovieClip;
		private var _LoadingBar		:Sprite;
		private var _ImgLoader		:Loader;
		
		private static var _Index	:int;
		
		public static const LOADED	:String = "loaded";
		public static const UNLOADED:String = "unloaded";
		
		public static const ERR_GEN_MESSAGE	:String = "Error loading";
		
		public function get loader():Loader { return _ImgLoader }
		
		public function get isBitmapImage():Boolean {
			var fn:String = _FileName.toLowerCase();
			if(fn.indexOf(".jpg") > 1 || fn.indexOf(".png") > 1 ||fn.indexOf(".gif") > 1) return true;
			return false;
		}
		
		public function SWFLoader(n:String, t:Sprite, initObj:Object):void {
			_Index++
				
			_FileName = n;
			_TargetSprite = t;
			_X = initObj.x;
			_Y = initObj.y;
			_Width = initObj.width;
			_Height = initObj.height;
			
			_Container = new MovieClip();
			_Container.name = "SWFLoader"+_Index+"_mc";
			_Container.x = _X;
			_Container.y = _Y;
			
			createLoadingBar();
			_LoadingBar.x = Math.floor((_Width/2)-(54/2));
			_LoadingBar.y = Math.floor((_Height/2)-(6/2));
			
			_ImgLoader = new Loader();
			_ImgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			_ImgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onImageProgress);
			_ImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
			
			// create a transparent rectangle to give the sprite a size while the image loads
			var border:Sprite = new Sprite();
			border.x = 0;
			border.y = 0;
			border.graphics.beginFill(0xff0000,0);
			border.graphics.drawRect(0,0,_Width,_Height);
			border.graphics.endFill();
			_Container.addChild(border);
			
			_ImgLoader.load(new URLRequest(_FileName));
			_Container.addChild(_ImgLoader);
			_Container.addChild(_LoadingBar);
			_TargetSprite.addChild(_Container);
		}
		
		public function imageAdvanceToFrame(f:*,p:Boolean=false):void {
			//if(_FileName.toLowerCase().indexOf(".swf") < 0) return;
			if(!p) MovieClip(_ImgLoader.content).gotoAndStop(f);
				else MovieClip(_ImgLoader.content).gotoAndPlay(f);
		}
		
		private function createLoadingBar(){
			_LoadingBar = new Sprite();
			_LoadingBar.name = "loadingbar_mc";
			var bbg:Sprite = new Sprite();
			bbg.name = "barbg_mc";
            bbg.graphics.lineStyle(0, 0x000000, .25);
           	bbg.graphics.drawRect(0, 0, 53, 5);
			
			var bbar:Sprite = new Sprite();
			bbar.name = "bar_mc";
			bbar.x = 2;
			bbar.y = 2;
			bbar.graphics.beginFill(0x000000);
           	bbar.graphics.drawRect(0, 0, 50, 2);
            bbar.graphics.endFill();
			
			_LoadingBar.addChild(bbg);
			_LoadingBar.addChild(bbar);
			_LoadingBar.alpha = .5
			_LoadingBar.getChildByName("bar_mc").scaleX = .1
		}

		private function onImageError(event:Event):void {
			trace("SWFLoader Error: " + event);
			_Container.removeChild(_LoadingBar);
			//_Container.addChild(createText(ERR_GEN_MESSAGE+": '"+_FileName+"'",_Width,10,0xcc0000));
			dispatchEvent(new Event(SWFLoader.LOADED));
			removeListeners();
		}
		
		private function onImageProgress(event:ProgressEvent):void {
			//trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			_LoadingBar.getChildByName("bar_mc").scaleX = (event.bytesLoaded/event.bytesTotal);
		}
		
		private function onImageComplete(event:Event):void {
			//trace("completeHandler: " + event);
			_Container.removeChild(_LoadingBar);
			if(isBitmapImage) {
				event.target.content.smoothing = true;
			}
			dispatchEvent(new Event(SWFLoader.LOADED));
			removeListeners();
		}
		
		private function removeListeners():void {
			_ImgLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageError);
			_ImgLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onImageProgress);
			_ImgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageComplete);
		}
		
		public function destroy():void {
			try {
				_ImgLoader.close()
			} catch(e:*) {}
			_ImgLoader.unload();
			_ImgLoader = null;
			_Container.removeChildAt(0);
			dispatchEvent(new Event(SWFLoader.UNLOADED));
		}
	}
	
}