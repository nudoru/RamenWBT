package com.nudoru.utils {
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.filters.DropShadowFilter;
	import com.dreaminginflash.ColorUtils;

	public class RoundGradBox extends Sprite {
		
		private var _LightColor		:int;
		private var _DarkColor		:int;
		private var _OutlineColor	:int;
		private var _Radius			:int;
		
		public function RoundGradBox(tgt:Sprite, x:int, y:int, w:int, h:int, sdw:Boolean=false, rad:int=5, colorObj:Object=undefined):void {
			if (colorObj.bc) {
				_DarkColor = colorObj.bc;
				var hls:Object = ColorUtils.RGBtoHLS(_DarkColor);
				var darkL:Number  = Math.max(hls.l - 0.2,0);
				var lightL:Number  = Math.min(hls.l + 0.3,1);
				_OutlineColor = ColorUtils.HLStoRGB(hls.h,darkL,hls.s);
				_LightColor = ColorUtils.HLStoRGB(hls.h,lightL,hls.s);
			} else {
				_LightColor = colorObj.lc ? colorObj.lc : 0xEEEEEE;
				_DarkColor = colorObj.dc ? colorObj.dc : 0xEAEAEA;
				_OutlineColor = colorObj.oc ? colorObj.oc : 0x999999;
			}
			if (colorObj.expand == true) {
				var f:int = rad / 2;
				x -= f;
				y -= f;
				w += f * 2;
				h += f * 2;
			}
			_Radius = rad
			renderBox(tgt, x, y, w, h, sdw, _LightColor, _DarkColor, _OutlineColor);
		}
		
		private function renderBox(tgt:Sprite, x:int, y:int, w:int, h:int, sdw:Boolean, lc:int, dc:int, oc:int):Sprite {
			
			var tBox:Sprite = new Sprite();
			tBox.x = x;
			tBox.y = y;
			
			var box:Sprite= new Sprite();
			var colors:Array = [dc, lc];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(w,h,45);
			box.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			box.graphics.drawRoundRect(0,0,w,h,_Radius);
			box.graphics.endFill();
			
			var whiteline:Sprite = new Sprite();
			whiteline.graphics.lineStyle(0,lc,1,true);
			whiteline.graphics.drawRoundRect(1,1,w-2,h-2,_Radius);
			
			var darkline:Sprite = new Sprite();
			darkline.graphics.lineStyle(0,oc,1,true);
			darkline.graphics.drawRoundRect(0,0,w,h,_Radius);
			
			if(sdw) {
				var dropShadow:DropShadowFilter = new DropShadowFilter(3,45,0x000000,.3,7,7,1,2);
				var filtersArray:Array = new Array(dropShadow);
				box.filters = filtersArray;
			}

			tBox.addChild(box);
			tBox.addChild(whiteline);
			tBox.addChild(darkline);
			
			tgt.addChild(tBox);
			return tBox;
		}
		
	}
	
}