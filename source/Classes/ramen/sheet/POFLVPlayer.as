package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	public class POFLVPlayer extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _FLVPlayer					:FLVPlayerPO;
		
		private var _FileName					:String;
		private var _PlayMode					:String;
		private var _BorderStyle				:String;
		private var _BorderWidth				:int = 0;
		private var _Shadow						:Boolean = true;
		
		public function POFLVPlayer(p:Sheet, t:Sprite, x:XMLList):void {
			super(p,t,x);
			parseGraphicData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			showPlayer();
			drawBoxes();
			applyDisplayProperties();
		}

		private function showPlayer():void {
			_FLVPlayer = new FLVPlayerPO();
			_ObjContainer.addChild(_FLVPlayer);
			if(_BorderStyle == "none") _FLVPlayer.bg_mc.visible = false;
			_FLVPlayer.playVideo(_FileName);
			_POObject = _FLVPlayer;
			loaded = true;
		}
		
		private function parseGraphicData():void {
			_FileName = _XMLData.url;
			_PlayMode = _XMLData.url.@playmode;
			_BorderStyle = _XMLData.borderstyle;
			_BorderWidth = int(_XMLData.borderwidth);
			_Shadow = isBool(_XMLData.shadow);
		}
		
		
		public override function destroy():void {
			_FLVPlayer.destroy()
			removeListeners()
			removeReflection()
			_ObjContainer.removeChild(_POObject)
			_POObject = null;
		}
		
	}
}