package ramen.sheet {

	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.*;
	import flash.geom.Point;
	
	public class POInteractiveSWF extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _ImgLoader					:ImageLoader;
		
		private var _ImageName					:String;
		private var _StartFrame					:int;
		private var _PlayMode					:String;
		private var _BorderStyle				:String;
		private var _BorderWidth				:int = 0;
		private var _Shadow						:Boolean = true;
		private var _Reflect					:Boolean = false;
		
		private var _ObjectXML					:XMLList;
		
		public function get isSWF():Boolean { 
			if(_ImageName.toLowerCase().indexOf(".swf") > 0) return true;
			return false;
		}
		
		public function POInteractiveSWF(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
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
		
		public function gotoFrameAndStop(f:int, t:String = ""):void {
			if (t.indexOf("@") > 1) t = t.split("@")[1];
				else t = undefined;
			try {
				if(isSWF) _ImgLoader.imageAdvanceToFrame(f,false,t)
			} catch(e:*) {}
		}
		
		public function gotoFrameAndPlay(f:int, t:String = ""):void {
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
		}
		
		private function initializeObject():void {
			Object(_ImgLoader.content).initialize(_ObjectXML);
		}
		
		override public function command(c:String):void{
			Object(_ImgLoader.content).command(c);
		}
		
		// override from super, need additional code to begin playing the SWF if desired
		override public function beginAnimations():void {
			// dupelicate from super
			if(_TransitionInEff.length) {
				if (_TransitionInMode == "play") playTransitionIn();
			}
			// custom code
			if (_ImageName.toLowerCase().indexOf(".swf") < 0) return;
			
			initializeObject();
			
			var fr:int = 0;
			var pl:Boolean = true;
			if(_StartFrame > 0) fr = _StartFrame
			if(!_PlayMode || _PlayMode == "stop" || _PlayMode == "none") pl = false;
			_ImgLoader.imageAdvanceToFrame(fr, pl)
		}
		
		private function parseGraphicData():void {
			_ImageName = _XMLData.url;
			_StartFrame = int(_XMLData.url.@startframe);
			_PlayMode = _XMLData.url.@playmode;
			_BorderStyle = _XMLData.borderstyle;
			_BorderWidth = int(_XMLData.borderwidth);
			_Shadow = isBool(_XMLData.shadow);
			_Reflect = isBool(_XMLData.reflect);
			_ObjectXML = _XMLData.objectdata;
		}
		
		public override function destroy():void {
			try {
				Object(_ImgLoader.content).destroy();
			} catch (e:*) {
				//
			}
			_ImgLoader.destroy();
			removeListeners();
			removeReflection();
			_ObjContainer.removeChild(_POObject);
			_POObject = null;
		}
		
	}
}