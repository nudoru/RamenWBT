/*
Image distortion code from http://www.rubenswieringa.com/blog/distortimage
*/

package ramen.sheet {
	
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.Point;
	
	import org.flashsandy.display.DistortImage;
	
	public class POGraphic extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _ImgLoader					:ImageLoader;
		
		private var _ImageName					:String;
		private var _StartFrame					:int;
		private var _PlayMode					:String;
		private var _Caption					:String;
		private var _BorderStyle				:String;
		private var _BorderWidth				:int = 0;
		private var _Shadow						:Boolean = true;
		private var _Reflect					:Boolean = false;
		private var _CornerPoints				:Array;
		private var _BMShape					:Shape;
		private var _BMDistortion				:DistortImage;
		
		private var _AutoContent				:AutoContent = new AutoContent();
		
		public function get isSWF():Boolean { 
			if(_ImageName.toLowerCase().indexOf(".swf") > 0) return true;
			return false;
		}
		
		public function POGraphic(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
			_CornerPoints = new Array();
			parseGraphicData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createGraphic();
			drawBoxes();
			applyDisplayProperties();
		}
		
		public function gotoFrameAndStop(f:*, t:String = ""):void {
			if (t.indexOf("@") > 1) t = t.split("@")[1];
				else t = undefined;
			try {
				if(isSWF) _ImgLoader.imageAdvanceToFrame(f,false,t)
			} catch(e:*) {}
		}
		
		public function gotoFrameAndPlay(f:*, t:String = ""):void {
			if (t.indexOf("@") > 1) t = t.split("@")[1];
				else t = undefined;
			try {
				if(isSWF) _ImgLoader.imageAdvanceToFrame(f,true,t)
			} catch(e:*) {}
		}
		
		private function createGraphic():void {
			var i:Sprite = new Sprite();
			_ImgLoader = new ImageLoader(_ImageName, i, {x:0,
														 y:0,
														 caption:_Caption,
														 width:_Width,
														 height:_Height,
														 border:_BorderWidth,
														 borderstyle:_BorderStyle,
														 shadow:_Shadow,
														 reflect:_Reflect } );
			_ImgLoader.addEventListener(ImageLoader.LOADED,onGraphicLoaded);
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}
		
		private function onGraphicLoaded(e:Event):void {
			loaded = true;
			applyDistortion();
		}
		
		private function applyDistortion():void {
			if (!_CornerPoints.length) return;
			_POObject.visible = false;
			_BMShape = new Shape();
			_ObjContainer.addChild(_BMShape);
			_BMDistortion = new DistortImage(_Width, _Height, 3, 3)
			_BMDistortion.setTransform(_BMShape.graphics, 
										_ImgLoader.bitmap.bitmapData, 
										_CornerPoints[0], 
										_CornerPoints[2], 
										_CornerPoints[3], 
										_CornerPoints[1]);
		}
		
		// override from super, need additional code to begin playing the SWF if desired
		override public function beginAnimations():void {
			// dupelicate from super
			if(_TransitionInEff.length) {
				if (_TransitionInMode == "play") playTransitionIn();
			}
			// custom code
			if(_ImageName.toLowerCase().indexOf(".swf") < 0) return;
			var fr:int = 0;
			var pl:Boolean = true;
			if(_StartFrame > 0) fr = _StartFrame
			if(!_PlayMode || _PlayMode == "stop" || _PlayMode == "none") pl = false;
			_ImgLoader.imageAdvanceToFrame(fr, pl);
		}
		
		private function parseGraphicData():void {
			_ImageName = _XMLData.url;
			_StartFrame = int(_XMLData.url.@startframe);
			_PlayMode = _XMLData.url.@playmode;
			_Caption = _AutoContent.applyContentFunction(_XMLData.caption);
			_BorderStyle = _XMLData.borderstyle;
			_BorderWidth = int(_XMLData.borderwidth);
			_Shadow = isBool(_XMLData.shadow);
			_Reflect = isBool(_XMLData.reflect);
			if (_XMLData.bmdistort) _CornerPoints = getCornerPointsFromStr(_XMLData.bmdistort);
		}
		
		private function getCornerPointsFromStr(s:String):Array {
			var a:Array = new Array();
			var data:Array = s.split(";");
			if (data.length != 4) {
				//trace("getCornerPointsFromStr - requires 4 points!");
				return a;
			}
			for (var i:int = 0; i < data.length; i++) {
				a.push(new Point(data[i].split(",")[0], data[i].split(",")[1]));
			}
			return a
		}
		
		private function getDisplayObjectCenter (child:DisplayObject, x:Number=0, y:Number=0):Point {
			var c:Point = new Point();
			c.x = int(child.x + child.width/2) + x;
			c.y = int(child.y + child.height/2) + y;
			return c;
		}
		
		public override function destroy():void {
			_ImgLoader.destroy();
			removeListeners();
			removeReflection();
			_ObjContainer.removeChild(_POObject);
			_POObject = null;
		}
		
	}
}