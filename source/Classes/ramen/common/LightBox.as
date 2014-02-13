/*
Based on Lightbox 2 - http://www.huddletogether.com/projects/lightbox2/
11.22.07
*/

package ramen.common {
	
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
	import flash.events.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class LightBox extends Sprite {
		
		private var _TargetSprite	:Sprite;
		private var _FileName		:String;
		private var _Caption		:String;
		private var _Width			:int;
		private var _Height			:int;
		private var _Border			:int;
		
		private var _Container		:Sprite;
		private var _Image			:Sprite;
		private var _ImageLoader	:ImageLoader;
		private var _CloseMessage	:Sprite;
		private var _Background		:Sprite;
		
		public static const UNLOADED:String = "unloaded";
		
		private static var _Index	:int;
		
		public function LightBox(f:String, tgt:Sprite, c:String, initObj:Object):void {
			_Index++;
			
			_TargetSprite = tgt;
			_FileName = f;
			_Caption = c;
			_Width = initObj.width;
			_Height = initObj.height;
			_Border = initObj.border;
			
			_Container = new Sprite();
			_Container.name = "LightBox"+_Index+"_mc";
			_Image = new Sprite();
			_Background = new Sprite();
			
			var colors:Array = [0x333333, 0x000000];
			var alphas:Array = [.8, .8];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(100,100,45);
			_Background.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			_Background.graphics.drawRect(0,0,100,100);
			_Background.graphics.endFill();
			
			_Container.addChild(_Background);
			
			_ImageLoader = new ImageLoader(_FileName,_Image,{caption:_Caption,x:0,y:0,width:_Width,height:_Height,border:_Border,shadow:true,reflection:false});
			_Container.addChild(_Image);
			createCloseMessage()
			_Container.addChild(_CloseMessage);
			_TargetSprite.addChild(_Container);
			
			onWindowResize(null);
			
			_TargetSprite.stage.addEventListener(Event.RESIZE, onWindowResize);
			_Container.buttonMode = true;
			_Container.mouseChildren = false;
			_Container.addEventListener(MouseEvent.CLICK, onBGClick)
			_Container.alpha = 0;
			
			if(!_Border) {
				var filter:BitmapFilter = new GlowFilter(0x000000,.7,20,20,1,BitmapFilterQuality.MEDIUM);
				var myFilters:Array = new Array();
				myFilters.push(filter);
				_ImageLoader.imageloader.filters = myFilters;
			}
			
			TweenLite.to(_Container, .5, {alpha:1, ease:Quadratic.easeOut});
		}
		
		private function createCloseMessage():void {
			_CloseMessage = new Sprite();
			var label:TextField = new TextField();
            label.autoSize = TextFieldAutoSize.LEFT;
            label.selectable = false;
			label.embedFonts = true;
			label.antiAliasType = AntiAliasType.ADVANCED;
            var format:TextFormat = new TextFormat();
            format.font = "Calibri";
            format.color = 0xffffff;
            format.size = 10;

            label.defaultTextFormat = format;
            _CloseMessage.addChild(label);
			label.text = "Click anywhere to return";
			
			_CloseMessage.x = 20;
			_CloseMessage.y = 5;
			_CloseMessage.alpha = .5;
			var filter:BitmapFilter = new GlowFilter(0x000000,.7,5,5,2,BitmapFilterQuality.MEDIUM);
            var myFilters:Array = new Array();
            myFilters.push(filter);
            _CloseMessage.filters = myFilters;
		}
		
		private function onBGClick(event:MouseEvent):void {
			_Container.removeEventListener(MouseEvent.CLICK, onBGClick);
			TweenLite.to(_Container, .25, {alpha:0, ease:Quadratic.easeOut, onComplete:destroy});
		}
		
		private function destroy():void {
			_ImageLoader.destroy();
			_TargetSprite.stage.removeEventListener(Event.RESIZE, onWindowResize);
			_Container.removeEventListener(MouseEvent.CLICK, onBGClick);
			_Container.removeChild(_Background);
			_Container.removeChild(_CloseMessage);
			_Container.removeChild(_Image);
			dispatchEvent(new Event(LightBox.UNLOADED));
		}
		
		private function onWindowResize(event:Event):void {
			_Background.scaleX = _TargetSprite.stage.stageWidth * .01;
			_Background.scaleY = _TargetSprite.stage.stageHeight * .01;
			_CloseMessage.x = Math.floor((_TargetSprite.stage.stageWidth >> 1)-(_CloseMessage.width >> 1));
			_Image.x = Math.floor((_TargetSprite.stage.stageWidth >> 1)-(_Image.width >> 1));
			_Image.y = Math.floor((_TargetSprite.stage.stageHeight >> 1)-(_Image.height >> 1));
		}
		
	}
	
}