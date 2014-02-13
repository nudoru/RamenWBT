package ramen.page {
	
	import ramen.common.*;

	import flash.display.*;
	import flash.events.*;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.RandomLatin;
	
	public class PageListItem extends Sprite {

		protected var _XMLData					:XMLList;
		protected var _RefMovieClip				:MovieClip;
		protected var _RefDataMovieClip			:MovieClip;
		protected var _Status					:int;
		
		protected var _AutoContent				:AutoContent = new AutoContent();
		
		private var _DLog						:Debugger;
		
		private static var _Index				:int;
		
		public function get id():String { return _XMLData.@id; }
		public function get type():String { return _XMLData.@type; }
		public function get label():String { return _XMLData.label }
		public function get itemX():int { return int(String(_XMLData.settings.position).split(",")[0]) }
		public function get itemY():int { return int(String(_XMLData.settings.position).split(",")[1]) }
		public function get itemWidth():int { return int(String(_XMLData.settings.size).split(",")[0]) }
		public function get itemHeight():int { return int(String(_XMLData.settings.size).split(",")[1]) }
		
		public function get title():String { return _AutoContent.applyContentFunction(_XMLData.title); }
		public function get text():String { return _AutoContent.applyContentFunction(_XMLData.text); }
		public function get summary():String { return _AutoContent.applyContentFunction(_XMLData.summary); }
		public function get thumbnail():String { return _XMLData.thumbnail; }
		public function get mediaURL():String { return _XMLData.mediaurl; }
		public function get mediaStartFrame():int { return int(_XMLData.mediaurl.@startframe); }
		public function get mediaPlayMode():String { return _XMLData.mediaurl.@playmode; }
		public function get link():String { return _XMLData.link; }
		public function get style():String { return _XMLData.style; }
		public function get sheetXML():XMLList { return _XMLData.sheet; }
		public function get frontURL():String { return _XMLData.front.@url; }
		public function get backURL():String { return _XMLData.back.@url; }
		public function get imageURL():String { return _XMLData.image.@url; }
		public function get imageX():int { return _XMLData.image.@x; }
		public function get imageY():int { return _XMLData.image.@y; }
		public function get imageWidth():int { return _XMLData.image.@width; }
		public function get imageHeight():int { return _XMLData.image.@height; }
		
		public function get refMC():MovieClip { return _RefMovieClip }
		public function set refMC(m:MovieClip):void { _RefMovieClip = m }
		public function get refDataMC():MovieClip { return _RefDataMovieClip }
		public function set refDataMC(m:MovieClip):void { _RefDataMovieClip = m }
		
		public function get status():int { return _Status; }
		
		//TODO dispatch event
		public function set status(value:int):void {
			_Status = value;
		}
		
		public function get isCompleted():Boolean {
			if (status >= ObjectStatus.COMPLETED) return true;
			return false;
		}
		
		public function get isPassed():Boolean {
			if (status == ObjectStatus.COMPLETED || status == ObjectStatus.PASSED) return true;
			return false;
		}
		
		public function get isFailed():Boolean {
			if (status == ObjectStatus.FAILED) return true;
			return false;
		}
		
		public function PageListItem(x:XMLList):void {
			_Index++;
			_DLog = Debugger.getInstance();
			_XMLData = x;
			_Status = ObjectStatus.NOT_INIT;
			parseCommonData();
		}

		private function parseCommonData():void {
			//trace("item "+_ID)
		}

		public function render():void {
			_Status = ObjectStatus.INIT;
			//createContainers(_TargetSprite);
		}
		
		// handled via sheet in the page template
		public function renderPageObjects(t:Sprite, p:PageRenderer):void {
			//PageObject(p:PageRenderer, t:Sprite, x:XMLList)
		}
		
		public function destroyPageObjects():void {
			//
		}
		
		protected function isBool(s:String):Boolean {
			if(s.toLowerCase().indexOf("t") == 0) return true;
			return false;
		}

		// this is a template, subclasses must override
		public function destroy():void {
			//
		}

		protected function drawRect(target:Sprite, w:int, h:int, line:int, fill:int, alpha:Number):void {
			target.graphics.lineStyle(0,line,alpha);
			target.graphics.beginFill(fill,alpha);
			target.graphics.drawRect(0,0,w,h);
			target.graphics.endFill();
		}
	}
}