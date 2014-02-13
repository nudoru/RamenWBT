package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import com.nudoru.utils.RoundGradBox;
	
	public class POGradRoundRect extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _Color						:int;
		private var _BaseColor					:int;
		private var _Radius						:int;
		private var _LineColor					:int;
		private var _LightColor					:int;
		private var _DarkColor					:int;
		private var _Shadow						:Boolean = true;
		
		public function POGradRoundRect(p:Sheet, t:Sprite, x:XMLList):void {
			super(p,t,x);
			parseRectData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createRect();
			drawBoxes();
			applyDisplayProperties();
			loaded = true;
		}

		private function createRect():void {
			var i:Sprite = new Sprite();
			if(_Color) {
				var a:RoundGradBox = new RoundGradBox(i, 0, 0, _Width, _Height, _Shadow, _Radius, {oc:_Color, lc:_Color, dc:_Color});
			} else if (_BaseColor) {
				var b:RoundGradBox = new RoundGradBox(i, 0, 0, _Width, _Height, _Shadow, _Radius, {bc:_BaseColor});
			} else {
				var c:RoundGradBox = new RoundGradBox(i, 0, 0, _Width, _Height, _Shadow, _Radius, {oc:_LineColor, lc:_LightColor, dc:_DarkColor});
			}
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}

		private function parseRectData():void {
			_Color = int(_XMLData.color);
			_BaseColor = int(_XMLData.basecolor);
			_Radius = int(_XMLData.radius);
			_LineColor = int(_XMLData.linecolor);
			_LightColor = int(_XMLData.lightcolor);
			_DarkColor = int(_XMLData.darkcolor);
			_Shadow = isBool(_XMLData.shadow);
		}
		
		public override function destroy():void {
			removeListeners()
			removeReflection()
			_ObjContainer.removeChild(_POObject)
			_POObject = null;
		}
		
	}
}