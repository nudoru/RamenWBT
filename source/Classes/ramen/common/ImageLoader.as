/*
Image loader
3.13.08
*/

package ramen.common {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.display.Graphics;
	import flash.display.BlendMode;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.net.URLRequest;
	import flash.events.*;
	import com.nudoru.utils.GradBox;
	import com.nudoru.utils.RoundGradBox;
	import com.pixelfumes.reflect.*;
	
	public class ImageLoader extends Sprite {
		
		private var _FileName		:String;
		private var _TargetSprite	:Sprite;
		private var _Caption		:String;
		private var _X				:int;
		private var _Y				:int;
		private var _Width			:int;
		private var _Height			:int;
		private var _Border			:int;
		private var _BorderStyle	:String;
		private var _BLightColor	:int;
		private var _BDarkColor		:int;
		private var _BOutlineColor	:int;
		private var _ShowShadow		:Boolean;
		private var _ShowReflection	:Boolean;
		
		private var _Container		:MovieClip;
		private var _LoadingBar		:Sprite;
		private var _CaptionText	:Sprite;
		private var _ImgLoader		:Loader;
		private var _ImgMask		:Sprite;
		private var _Reflection		:Reflect;
		private var _BData			:BitmapData;
		
		private static var _Index	:int;
		
		public static const LOADED	:String = "loaded";
		public static const UNLOADED:String = "unloaded";
		
		public static const ERR_GEN_MESSAGE	:String = "Error loading";
		
		public function get imageloader():Loader { return _ImgLoader }
		
		public function get content():DisplayObject { return _ImgLoader.content as DisplayObject }
		
		public function get isBitmapImage():Boolean {
			var fn:String = _FileName.toLowerCase();
			if(fn.indexOf(".jpg") > 1 || fn.indexOf(".png") > 1 ||fn.indexOf(".gif") > 1) return true;
			return false;
		}
		
		public function get bitmap():Bitmap {
			//if (!isBitmapImage) return undefined;
			var b:Bitmap;
			if (isBitmapImage) {
				b = Bitmap(_ImgLoader.content);
			} else {
				if (_BData) _BData.dispose();
				_BData = new BitmapData(_Width+(_Border*2), _Height+(_Border*2));
				_BData.draw(_ImgLoader.content);
				b = new Bitmap(_BData, "auto", true);
			}
			return b;
		}
		
		public function ImageLoader(n:String, t:Sprite, initObj:Object):void {
			_Index++
			
			_FileName = n;
			_TargetSprite = t;
			_Caption = initObj.caption;
			_X = initObj.x;
			_Y = initObj.y;
			_Width = initObj.width;
			_Height = initObj.height;
			_Border = initObj.border;
			_BorderStyle = initObj.borderstyle;
			_BLightColor = initObj.blc;
			_BDarkColor = initObj.bdc;
			_BOutlineColor = initObj.boc;
			_ShowShadow = Boolean(initObj.shadow);
			_ShowReflection = Boolean(initObj.reflection);
			
			_Container = new MovieClip();
			_Container.name = "ImageLoader"+_Index+"_mc";
			_Container.x = _X;
			_Container.y = _Y;
			
			createLoadingBar();
			_LoadingBar.x = Math.floor((_Width/2)-(54/2)) + _Border;
			_LoadingBar.y = Math.floor((_Height/2)-(6/2)) + _Border;
			
			_ImgLoader = new Loader();
			_ImgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			_ImgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onImageProgress);
			_ImgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
			
			_ImgMask = new Sprite();
			createMaskRect(_ImgMask, _Width+1, _Height+1)
			
			if(_Caption) createCaption()
			
			var border:Sprite = new Sprite();
			border.x = 0;
			border.y = 0;
			
			if(_Border > 0) {
				_ImgLoader.x = _Border;
				_ImgLoader.y = _Border;
				var bdrHeight:int = _Height+(_Border*2)
				if(_Caption) {
					_CaptionText.x = _Border;
					_CaptionText.y += _Border;
					bdrHeight += (_CaptionText.getChildByName("caption_txt") as TextField).textHeight + 5;
				}
				var b:*
				if (_BorderStyle == "rounded") {
					b = new RoundGradBox(border, 0, 0, _Width + (_Border * 2), bdrHeight, _ShowShadow, 20, { lc:_BLightColor, dc:_BDarkColor, oc:_BOutlineColor } );
				} else {
					b = new GradBox(border, 0, 0, _Width + (_Border * 2), bdrHeight, _ShowShadow, { lc:_BLightColor, dc:_BDarkColor, oc:_BOutlineColor } );
				}
			} else {
				// create a transparent rectangle to give the sprite a size while the image loads
				border.graphics.beginFill(0xff0000,0);
				border.graphics.drawRect(0,0,_Width,_Height);
				border.graphics.endFill();
			}
			
			_ImgMask.x = _ImgLoader.x;
			_ImgMask.y = _ImgLoader.y;
			
			_Container.addChild(border);
			
			_ImgLoader.load(new URLRequest(_FileName));
			_Container.addChild(_ImgLoader);
			_Container.addChild(_ImgMask);
			_Container.addChild(_LoadingBar);
			if (_Caption) _Container.addChild(_CaptionText)
			
			_ImgLoader.mask = _ImgMask;
			
			_TargetSprite.addChild(_Container);
		}
		
		/* f is the frame # to advance to
		 * p true, play, false, stop
		 * t target instance mc on the timeline of the swf, can be nested. data to the left of the "@" is not used
		 * 		syntax: poid@mcid.mcid.etc...
		 */
		public function imageAdvanceToFrame(f:*, p:Boolean, t:String = ""):void {
			if (_FileName.toLowerCase().indexOf(".swf") < 0) return;
			var tgt:String = "";
			if (t) tgt = t.indexOf("@") > 1 ? t.split("@")[1] : t;
			if (!tgt) {
				if(!p) MovieClip(_ImgLoader.content).gotoAndStop(f);
					else MovieClip(_ImgLoader.content).gotoAndPlay(f);
			} else {
				var ref:MovieClip = MovieClip(_ImgLoader.content)
				var tgtpath:Array = tgt.split(".");
				for (var i:int = 0; i < tgtpath.length; i++) {
					ref = ref[tgtpath[i]];
				}
				if(ref) {
					if(!p) ref.gotoAndStop(f);
						else ref.gotoAndPlay(f);
				} else {
					trace("imageAdvanceToFrame, can't find target: " + t);
				}
			}
		}
		
		private function createLoadingBar():void{
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
			_LoadingBar.blendMode = BlendMode.MULTIPLY;
			_LoadingBar.alpha = .5
			_LoadingBar.getChildByName("bar_mc").scaleX = .1
		}
		
		private function createCaption():void {
			_CaptionText = new Sprite();
			var label:TextField = new TextField();
			label.name = "caption_txt";
			label.width = _Width
			label.autoSize = TextFieldAutoSize.LEFT;
			label.wordWrap = true;
			label.multiline = true;
            label.selectable = false;
			label.embedFonts = true;
			label.antiAliasType = AntiAliasType.ADVANCED;
            var format:TextFormat = new TextFormat();
            format.font = "Calibri";
            format.color = 0x111111;
            format.size = 12;

            label.defaultTextFormat = format;
            _CaptionText.addChild(label);
			label.htmlText = _Caption;
			label.cacheAsBitmap = true;
			_CaptionText.x = 0;
			_CaptionText.y = _Height + 5;
		}
		
		// need to move this into a utility class
		private function createText(text:String,w:int,s:int=12,c:int=0x000000):Sprite {
			var textSprite:Sprite = new Sprite();
			var label:TextField = new TextField();
			label.name = "text_txt";
			label.width = w
			label.autoSize = TextFieldAutoSize.LEFT;
			label.wordWrap = true;
			label.multiline = true;
            label.selectable = false;
			label.embedFonts = true;
			label.antiAliasType = AntiAliasType.ADVANCED;
            var format:TextFormat = new TextFormat();
            format.font = "Calibri";
            format.color = c;
            format.size = s;

            label.defaultTextFormat = format;
            textSprite.addChild(label);
			label.htmlText = text;
			label.cacheAsBitmap = true;
			return textSprite
		}
		
		private function createMaskRect(t:Sprite, w:int, h:int):void {
			var s:Shape = new Shape();
			s.graphics.beginFill(0xff0000);
            s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
			t.addChild(s);
        }
		
		private function onImageError(event:Event):void {
			//trace("ImageLoader Error: " + event);
			_Container.removeChild(_LoadingBar);
			_Container.addChild(createText(ERR_GEN_MESSAGE+": '"+_FileName+"'",_Width,10,0xcc0000));
			dispatchEvent(new Event(ImageLoader.LOADED));
			removeListeners();
		}
		
		private function onImageProgress(event:ProgressEvent):void {
			//trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
			_LoadingBar.getChildByName("bar_mc").scaleX = (event.bytesLoaded/event.bytesTotal);
		}
		
		private function onImageComplete(event:Event):void {
			//trace("completeHandler: " + event);
			if(_ShowReflection) {
				_Reflection = new Reflect({mc:_Container, alpha:35, ratio:100, distance:0, updateTime:-1, reflectionDropoff:0});
				//r.setBounds(_Width+50,_Height+50);
			}
			_Container.removeChild(_LoadingBar);
			if(isBitmapImage) {
				event.target.content.smoothing = true;
			}
			dispatchEvent(new Event(ImageLoader.LOADED));
			removeListeners();
		}
		
		private function removeListeners():void {
			_ImgLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageError);
			_ImgLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onImageProgress);
			_ImgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageComplete);
		}
		
		public function destroy():void {
			if (isBitmapImage) bitmap.bitmapData.dispose();
			if (_BData) _BData.dispose();
			removeListeners();
			try {
				_ImgLoader.close()
			} catch (e:*) { }
			_ImgLoader.unload();
			_ImgLoader = null;
			_Container.removeChildAt(0);
			if(_CaptionText) _Container.removeChild(_CaptionText);
			if(_Reflection) _Reflection.destroy();
			_Reflection = null;
			dispatchEvent(new Event(ImageLoader.UNLOADED));
		}
	}
	
}