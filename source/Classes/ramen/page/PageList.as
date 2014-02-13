package ramen.page {

	import com.nudoru.utils.RoundGradBox;
	import ramen.common.*;

	import flash.display.*;
	import flash.events.*;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.RandomLatin;
	import com.nudoru.utils.TimeKeeper;
	
	public class PageList extends Sprite {	
		protected var _XMLData				:XML;
		
		protected var _Items				:Array;
		
		protected var _State				:int;
		protected var _Status				:int;
		protected var _RefMovieClip			:MovieClip;
		
		protected var _LatencyTimer			:TimeKeeper;
		
		public static const LETTER_LIST			:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
		// const
		public static const STATE_INIT			:int = 0;
		public static const STATE_READY			:int = 1;
		public static const STATE_NOT_SELECTED	:int = 2;
		public static const STATE_SELECTED		:int = 3;
		public static const STATE_CORRECT		:int = 4;
		public static const STATE_WRONG			:int = 5;
		public static const STATE_NEUTRAL		:int = 6;
		// events
		public static const STAGE_CHANGE		:String = "stage_change";
		
		private var _DLog					:Debugger;
		
		private static var _Index			:int;
		
		// getters/setters
		public function get state():int { return _State }
		public function set state(s:int) {
			if (_State == s) return;
			trace("question state to: " + s);
			_State = s;
			dispatchEvent(new Event(STAGE_CHANGE));
		}
		// get question info from the XML
		public function get id():String { return _XMLData.@id }
		public function get type():String { return _XMLData.@type }
		public function get subtype():String { return _XMLData.@subtype }
		public function get numItems():int { return _Items.length }
		public function get listX():int { return int(String(_XMLData.settings.position).split(",")[0]) }
		public function get listY():int { return int(String(_XMLData.settings.position).split(",")[1]) }
		public function get listWidth():int { return int(String(_XMLData.settings.size).split(",")[0]) }
		public function get listHeight():int { return int(String(_XMLData.settings.size).split(",")[1]) }
		
		public function get instruction():String { return _XMLData.instruction }
		public function get feedbackLabel():String { return _XMLData.feedbacklabel }
		public function get autoSizeParts():Boolean { 
			if ( _XMLData.settings.autosizeparts == "true" ||  _XMLData.settings.autosizeparts == "yes") return true;
			return false
		}
		public function get itemColumnLabel():String { return _XMLData.itemcolumnlabel }
		public function get dataColumnLabel():String { return _XMLData.datacolumnlabel }

		public function get itemColumnX():int { return int(String(_XMLData.settings.itemposition).split(",")[0]) }
		public function get itemColumnY():int { return int(String(_XMLData.settings.itemposition).split(",")[1]) }
		public function get itemColumnSpacingX():int { return int(String(_XMLData.settings.itemspacing).split(",")[0]) }
		public function get itemColumnSpacingY():int { return int(String(_XMLData.settings.itemspacing).split(",")[1]) }
		public function get itemColumnWidth():int { return int(String(_XMLData.settings.itemsize).split(",")[0]) }
		public function get itemColumnHeight():int { return int(String(_XMLData.settings.itemsize).split(",")[1]) }
		
		public function get dataColumnX():int { return int(String(_XMLData.settings.dataposition).split(",")[0]) }
		public function get dataColumnY():int { return int(String(_XMLData.settings.dataposition).split(",")[1]) }
		public function get dataColumnSpacingX():int { return int(String(_XMLData.settings.dataspacing).split(",")[0]) }
		public function get dataColumnSpacingY():int { return int(String(_XMLData.settings.dataspacing).split(",")[1]) }
		public function get dataColumnWidth():int { return int(String(_XMLData.settings.datasize).split(",")[0]) }
		public function get dataColumnHeight():int { return int(String(_XMLData.settings.datasize).split(",")[1]) }
		
		public function get refMC():MovieClip { return _RefMovieClip }
		public function set refMC(m:MovieClip):void { _RefMovieClip = m }
		
		public function PageList(x:XML):void {
			_Index++;
			_DLog = Debugger.getInstance();
			_Items = new Array();
			_XMLData = x;
			_Status = ObjectStatus.NOT_INIT;
			//_LatencyTimer = new TimeKeeper("latency_" + id + "_timer");
			parseCommonData();
		}

		public function start():void {
			trace("$$$ list START");
			//_Running = true;
			//_LatencyTimer.start();
		}
		
		public function stop():void {
			//if (!_Running) return;
			trace("$$$ list STOP");
			//_Running = false;
			//_LatencyTimer.stop();
		}
		
		public function getItemID(i:int):String { return _Items[i].id }
		public function getItemStatus(i:int):String { return _Items[i].status }
		public function getItemType(i:int):String { return _Items[i].type }
		public function setItemContainer(i:int, c:*):void { _Items[i].container = c }
		public function getItemContainer(i:int):* { return _Items[i].container }
		public function getItemX(i:int):int { return _Items[i].itemX }
		public function getItemY(i:int):int { return _Items[i].itemY }
		public function getItemWidth(i:int):int { return _Items[i].itemWidth }
		public function getItemHeight(i:int):int { return _Items[i].itemHeight }
		public function getItemTitle(i:int):String { return _Items[i].title }
		public function getItemText(i:int):String { return _Items[i].text }
		public function getItemSummary(i:int):String { return _Items[i].summary }
		public function getItemThumbnail(i:int):String { return _Items[i].thumbnail }
		public function getItemSheetXML(i:int):XMLList { return _Items[i].sheetXML }
		public function getItemMediaURL(i:int):String { return _Items[i].mediaURL }
		public function getItemMediaStartFrame(i:int):int { return _Items[i].mediaStartFrame }
		public function getItemMediaPlayMode(i:int):String { return _Items[i].mediaPlayMode }
		public function getItemLink(i:int):String { return _Items[i].link }
		public function getItemStyle(i:int):String { return _Items[i].style }
		public function getItemRefMC(i:int):MovieClip { return _Items[i].refMC }
		public function setItemRefMC(i:int, m:MovieClip):void { _Items[i].refMC = m }
		public function getItemDataRefMC(i:int):MovieClip { return _Items[i].refDataMC }
		public function setItemDataRefMC(i:int, m:MovieClip):void { _Items[i].refDataMC = m }
		public function getItemFrontURL(i:int):String { return _Items[i].frontURL; }
		public function getItemBackURL(i:int):String { return _Items[i].backURL; }
		public function getItemImageURL(i:int):String { return _Items[i].imageURL; }
		public function getItemImageX(i:int):int { return _Items[i].imageX; }
		public function getItemImageY(i:int):int { return _Items[i].imageY; }
		public function getItemImageWidth(i:int):int { return _Items[i].imageWidth; }
		public function getItemImageHeight(i:int):int { return _Items[i].imageHeight; }
		
		//TODO check list status against other completed items
		//TODO broadcast event
		public function setItemCompleted(i:int):void { _Items[i].status = ObjectStatus.COMPLETED }
		
		public function isItemCompleted(i:int):Boolean { return _Items[i].isCompleted }
		
		// <list id="list1" type="" x="" y="" width="" height="">
		private function parseCommonData():void {
			parseItems();
		}
		
		protected function parseItems():void {
			var len:int = _XMLData.item.length();
			for(var i:int=0; i<len; i++) {
				_Items.push(new PageListItem(XMLList(_XMLData.item[i])));
			}
		}
		
		/*protected function createContainers(target:Sprite):void {
			_Container = new Sprite();
			_Container.name = "pagelist"+_Index+"_mc";
			_Container.x = _X;
			_Container.y = _Y;
			target.addChild(_Container);
		}*/

		protected function render():void {
			_Status = ObjectStatus.INIT;
			//createContainers(_TargetSprite);
		}
		
		public function renderPageObjects(i:int, t:Sprite, p:PageRenderer):void {
			_Items[i].renderPageObjects(t,p);
		}
		
		public function destroyPageObjects(i:int):void {
			_Items[i].destroyPageObjects();
		}
		
		protected function isBool(s:String):Boolean {
			if(s.toLowerCase().indexOf("t") == 0) return true;
			return false;
		}
		
		// this is a template, subclasses must override
		public function destroy():void {
			destroyItems()
		}

		// this is a template, subclasses must override
		protected function destroyItems():void {
			var len:int = _Items.length;
			for(var i:int=0; i<len; i++) {
				_Items[i].destroy();
			}
		}

	}
}