package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.*;

	public class POEM extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		
		public function POEM(p:Sheet, t:Sprite, x:XMLList):void {
			super(p,t,x);
			parseEMData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			_POObject = new Sprite();
			_ObjContainer.addChild(_POObject);
			loaded = true;
		}

		private function parseEMData():void {
			//
		}
		
		public override function destroy():void {
			removeListeners()
			_ObjContainer.removeChild(_POObject)
			_POObject = null;
		}
		
	}
}