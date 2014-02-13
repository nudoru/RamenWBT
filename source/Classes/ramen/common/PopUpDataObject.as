
package ramen.common {
	
	import flash.events.Event;
	import flash.display.Sprite;
	import ramen.common.ObjectStatus;
	import ramen.common.AutoContent;
	import com.nudoru.utils.GUID;
	import com.nudoru.utils.SWFLoader;
	import ramen.sheet.Sheet;
	
	public class PopUpDataObject {

		public var popuptype		:String;
		
		public var callingobj		:*;
		public var objdata			:Object;
		public var xmldata			:XML;
		
		public var id				:String;
		public var guid				:String;
		public var modal			:Boolean;
		public var pagemodal		:Boolean;
		public var title			:String;
		public var content			:String;
		public var url				:String;
		public var border			:int;
		public var icon				:String;
		public var draggable		:Boolean = true;
		public var usermoved		:Boolean = false;
		public var persistant		:Boolean = false;
		public var vposition		:String;
		public var hposition		:String;
		public var width			:int;
		public var height			:int;
		public var buttons			:Array = new Array();
		public var sheetXML			:XMLList;
		public var sheet			:Sheet;
		public var sheetLayer		:Sprite;
		
		public var imageloader		:SWFLoader;
		
		public var window			:*;
		
		private var _AutoContent	:AutoContent = new AutoContent();
		
		public function get hasSheet():Boolean {
			if (sheetXML) return true;
			return false;
		}
		
		public function PopUpDataObject(x:XML = undefined):void {
			if (x) {
				xmldata = x;
				parseXMLData();
			} else {
				createGUID();
			}
		}

		public function toString():String {
			return "[PopUpDataObject id:"+id+" type:"+popuptype+" title:"+title+" ]";
		}
		
		public function createGUID():String{
			guid = GUID.getGUID();
			return guid;
		}
		
		/*
		 <popup id=”id” draggable=”true|false”>
			<type modal=”true|false” persistant=”true|false”>type</type>
			<title>text</title>
			<content></content>
			<icon>icon name</icon>
			<size>width,height</size>
			<hpos>center</hpos>
			<vpos>middle</vpos>
			<buttons>
				<button event=”close”>OK</button>
			</buttons>
			<custom>
				… TBD …
			<custom>
		</popup>
		*/
		
		private function parseXMLData():void {
			id = xmldata.@id;
			guid = createGUID();
			draggable = xmldata.@draggable == "true" ? true : false;
			popuptype = xmldata.type;
			modal = xmldata.type.@modal == "true" ? true : false;
			pagemodal = xmldata.type.@pmodal == "true" ? true : false;
			persistant = xmldata.type.@persistant == "true" ? true : false;
			title = _AutoContent.applyContentFunction(xmldata.title);
			content	= _AutoContent.applyContentFunction(xmldata.content);
			url	= xmldata.url;
			border = int(xmldata.border);
			icon = xmldata.icon;
			width = int(String(xmldata.size).split(",")[0]);
			height = int(String(xmldata.size).split(",")[1]);
			vposition = xmldata.vpos;
			hposition = xmldata.hpos;
			if (xmldata.buttons.button.length()) {
				var len:int = xmldata.buttons.button.length();
				for (var i:int = 0; i < len; i++) {
					buttons.push( { event:xmldata.buttons.button[i].@event, data:xmldata.buttons.button[i].@data, label:xmldata.buttons.button[i] } );
				}
			} else {
				// default to just a close button ??
				//buttons.push( { event:"close", label:"OK" } );
			}
			sheetXML = xmldata.sheet;

			// validation steps
			// can't be both modal and persistant
			if ((modal || pagemodal) && persistant) persistant = false;
			// can't be both site modal and page modal
			if (modal && pagemodal) pagemodal = false;
			if (!border) border = 0;
			if (id.length < 1) id = guid;
		}
		
		public function loadURLImage(t:Sprite):void {
			imageloader = new SWFLoader(url, t, {width:width, height:height, x:border, y:border});
		}
		
		public function initializeSheet():void {
			if (popuptype == PopUpType.CUSTOM && hasSheet) {
				sheetLayer = new Sprite();
				window.addChild(sheetLayer);
				sheetLayer.x = 0;
				sheetLayer.y = window.draghandle_mc.height;
				sheet = new Sheet();
				window.addChild(sheet);
				sheet.initialize(sheetXML, sheetLayer);
				sheet.addEventListener(Sheet.RENDERED, onSheetRendered);
				sheet.checkSheetLoaded();
			}
		}

		private function onSheetRendered(e:Event):void {
			//sheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
			sheet.start();
		}
		
		public function destroy():void {
			if (imageloader) {
				imageloader.destroy();
			}
			if (sheet) {
				sheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
				sheet.destroy();
				window.removeChild(sheetLayer);
				sheetLayer = null;
			}
		}
		
	}
	
}