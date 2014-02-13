/*
Origional by Scott Morgan
http://www.scottgmorgan.com/blog/index.php/2007/06/18/runtime-font-embedding-in-as3-there-is-no-need-to-embed-the-entire-fontset-anymore/

var fl:FontLoader = new FontLoader("fonts.swf",["Verdana","Calibri"]);
fl.addEventListener(FontLoader.LOADED,drawText);

*/

package ramen.player {     

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.text.Font;
	import com.nudoru.utils.Debugger;
	
	import ramen.common.PlayerError;
	
     public class FontLoader extends Sprite {
		 
		 public var _FontFile			:String;
		 public var _FontList			:Array;
		 
		 private var _Preloader			:Sprite;
		 
		 public static const IO_ERROR	:String = "io_error";
		 public static const LOADED		:String = "loaded";
		 
		 private var _DLog				:Debugger;
		 
          public function FontLoader(f:String, l:Array) {
			  _DLog = Debugger.getInstance();
			  _FontFile = f;
			  _FontList = l;
               loadFont(_FontFile);
          }

		  public function setPreloader(p:Sprite):void {
			_Preloader = p;
			Object(_Preloader).bar_mc.mask_mc.scaleX = 0;
		}
		  
          private function loadFont(url:String):void {
               var loader:Loader = new Loader();
			   loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
               loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			   loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
               loader.load(new URLRequest(url));
          }

		private function onIOError(event:Event):void {
			dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "Cannot load the font data file '"+_FontFile+"'"));
		}
		  
          private function onProgress(event:ProgressEvent):void {
			//trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			Object(_Preloader).bar_mc.mask_mc.scaleX = (event.bytesLoaded/event.bytesTotal)*2;
          }
		  
          private function onLoaded(event:Event):void {
			  for (var i:int; i < _FontList.length; i++) {
				  var font:Class;
				  try {
					  font = event.target.applicationDomain.getDefinition(_FontList[i]) as Class;
				  }catch (e:*) {
					  dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "The font '" + _FontList[i] + "' was not found in the font data file."));
					  return;
				  }
				
				//trace("Font loaded: "+font);
				_DLog.addDebugText("Font, loaded: "+font);
				Font.registerFont(font);
			  }
			  _Preloader = null;
			  dispatchEvent(new Event(FontLoader.LOADED));
          }

     }
}