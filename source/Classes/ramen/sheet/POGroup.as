package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class POGroup extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _Children					:Array;
		
		public function POGroup(p:Sheet, t:Sprite, x:XMLList):void {
			super(p,t,x);
			_Children = new Array();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		//TODO loaded should come from children
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			parseGroupData();
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
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}

		private function parseGroupData():void {
			parseChildren()
		}
		
		public function parseChildren():void {
			var len:int = _XMLData.children.object.length();
			for(var i:int = 0; i<len; i++) {
				var o:IPageObject = POFactory.createPO(_XMLData.children.object[i].@type, _SheetRef, _ObjContainer, XMLList(_XMLData.children.object[i]));
				if (o) _Children.push(o);
			}
		}
		
		public override function destroy():void {
			//trace("destroy group");
			removeListeners();
			removeReflection();
			destroyChildren();
			//_ObjContainer.removeChild(_POObject)
			//_POObject = null;
		}
		
		public function destroyChildren():void {
			var len:int = _Children.length;
			for (var i:int = 0; i < len; i++) {
				_Children[i].destroy();
			}
		}
		
	}
}