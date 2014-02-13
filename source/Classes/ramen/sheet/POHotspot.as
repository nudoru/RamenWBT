package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class POHotspot extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _Debug						:Boolean;
		
		public function POHotspot(p:Sheet, t:Sprite, x:XMLList):void {
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
			i.graphics.lineStyle(0,0x990000,.5);
			i.graphics.beginFill(0xff0000,.3);
			i.graphics.drawRect(0,0,_Width,_Height);
			i.graphics.endFill();
			if(_Debug) i.alpha = 1;
				else i.alpha = 0;
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}

		private function parseRectData():void {
			_Debug = isBool(_XMLData.debug);
		}
		
		public override function destroy():void {
			removeListeners()
			removeReflection()
			_ObjContainer.removeChild(_POObject)
			_POObject = null;
		}
		
	}
}