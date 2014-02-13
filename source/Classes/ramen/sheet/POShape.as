package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.events.*;

	public class POShape extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _Shape						:String;
		private var _X2							:int;
		private var _Y2							:int;
		private var _Radius						:int;
		private var _LineColor					:int;
		private var _LineAlpha					:Number;
		private var _LineThickness				:int;
		private var _FillColor					:int;
		private var _FillAlpha					:Number;
		
		public function POShape(p:Sheet, t:Sprite, x:XMLList):void {
			super(p,t,x);
			parseShapeData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createShape();
			drawBoxes();
			applyDisplayProperties();
			loaded = true;
		}

		private function createShape():void {
			var i:Sprite = new Sprite();
			var s:Shape = new Shape();
			setLineStyle(s);
			setFillStyle(s);
			switch(_Shape) {
				case "line":
					doDrawLine(s);
					break;
				case "rect":
					doDrawRect(s);
					break;
				case "roundrect":
					doDrawRoundRect(s);
					break;
				case "circle":
					doDrawCircle(s);
					break;
				case "ellipse":
					doDrawEllipse(s);
					break;
				default:
					trace("POShape unrecognized shape: " + _Shape);
			}
			endFillStyle(s);
			i.addChild(s);
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}

		private function setLineStyle(s:Shape):void {
			if (_LineColor == -1) return;
			s.graphics.lineStyle(_LineThickness, _LineColor, _LineAlpha, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);
		}
		
		private function setFillStyle(s:Shape):void {
			if (_FillColor == -1) return;
			s.graphics.beginFill(_FillColor, _FillAlpha);
		}
		
		private function endFillStyle(s:Shape):void {
			if (_FillColor == -1) return;
			s.graphics.endFill();
		}

		private function doDrawLine(s:Shape):void {
            s.graphics.moveTo(0, 0);
			s.graphics.lineTo((_X2 - _X), (_Y2 - _Y));
        }
		
		private function doDrawCircle(s:Shape):void {
            //var halfSize:uint = Math.round(size / 2);
            s.graphics.drawCircle(0,0,_Radius);
        }

		private function doDrawEllipse(s:Shape):void {
            //var halfSize:uint = Math.round(size / 2);
            s.graphics.drawEllipse(0, 0, _Width, _Height);
        }
		
        private function doDrawRoundRect(s:Shape):void {
            s.graphics.drawRoundRect(0, 0, _Width, _Height, _Radius);
        }

        private function doDrawRect(s:Shape):void {
            s.graphics.drawRect(0, 0, _Width, _Height);
        }
		
		private function parseShapeData():void {
			_Shape = _XMLData.shape;
			_Radius = int(_XMLData.radius);
			_X2 = int(String(_XMLData.position).split(",")[2]);
			_Y2 = int(String(_XMLData.position).split(",")[3]);
			if (_XMLData.linecolor.length()) _LineColor = int(_XMLData.linecolor);
				else _LineColor = -1;
			if (_XMLData.linealpha.length()) _LineAlpha = Number(_XMLData.linealpha);
				else _LineAlpha = 1;
			if (_XMLData.linethickness.length()) _LineThickness = int(_XMLData.linethickness);
				else _LineThickness = 0;
			if (_XMLData.fillcolor.length()) _FillColor = int(_XMLData.fillcolor);
				else _FillColor = -1;
			if (_XMLData.fillalpha.length()) _FillAlpha = Number(_XMLData.fillalpha);
				else _FillAlpha = 1;
		}
		
		public override function destroy():void {
			removeListeners()
			removeReflection()
			_ObjContainer.removeChild(_POObject)
			_POObject = null;
		}
		
	}
}