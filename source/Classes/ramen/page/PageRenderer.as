package ramen.page {
	
	import flash.display.DisplayObject;
	import ramen.common.*;
	import ramen.page.*;
	import ramen.sheet.*;
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	import flash.events.*;
	import flash.net.*;
	import fl.motion.Animator;
	import fl.motion.MotionEvent;
	import com.nudoru.utils.SWFLoader;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.RandomLatin;
	
	public class PageRenderer extends Sprite {
	
		private var _TargetSprite				:Sprite;
		private var _XMLFile					:String;
		private var _XMLData					:XML;
		private var _XMLLoader					:URLLoader;
		
		private var _Standalone					:Boolean;
		private var _Name						:String;
		private var _Type						:String;
		private var _Width						:int;
		private var _Height						:int;
		private var _BorderLeft					:int;
		private var _BorderTop					:int;
		private var _BorderRight				:int;
		private var _BorderBottom				:int;
		
		private var _PageBGLayer				:Sprite;
		private var _SimpleImageObjectLayer		:Sprite;
		private var _SimpleTextObjectLayer		:Sprite;
		private var _InteractionLayer			:Sprite;
		private var _MessageLayer				:Sprite;
		private var _SheetLayer					:Sprite;
		
		private var _Sheet						:Sheet;
		
		private var _SimpleObjects				:Array;
		private var _SheetXML					:XMLList;
		private var _InteractionXML				:XMLList;
		
		private var _PageBGImageURL				:String;
		private var _SWFLoaders					:Array;
		
		private var _AutoContent				:AutoContent = new AutoContent();
		
		private var _Started					:Boolean = false;

		private var _Settings					:Settings;
		private var _DLog						:Debugger;
		
		public static const LOADED				:String = "loaded";
		public static const RENDERED			:String = "rendered";
		
		public function get interactionLayer():Sprite { return _InteractionLayer }
		public function get interactionXML():XMLList { return _InteractionXML }
		public function get messageLayer():Sprite { return _MessageLayer }
		
		public function get targetSprite():Sprite { return _TargetSprite }
		
		public function get standalone():Boolean { return _Standalone }
		
		public function get pageName():String { return _Name }
		public function get pageWidth():int { 
			if (_Settings.pageWidth) return _Settings.pageWidth;
				else return _Width
		}
		public function get pageWidthActual():int { return pageWidth - pageBorderLeft - pageBorderRight; }
		public function get pageHeight():int { 
			if (_Settings.pageHeight) return _Settings.pageHeight;
				else return _Height
		}
		public function get pageLeft():int { return _BorderLeft }
		public function get pageTop():int { return _BorderTop }
		public function get pageRight():int { return pageWidth - _BorderRight }
		public function get pageBottom():int { return pageHeight - _BorderBottom }
		public function get pageCenterX():int {
			var actualW:int = pageWidth - pageBorderLeft - pageBorderRight;
			var cent:int = Math.floor(actualW / 2);
			return cent + pageBorderLeft;
		}
		public function get pageCenterY():int {
			var actualH:int = pageHeight - pageBorderTop - pageBorderBottom;
			var cent:int = Math.floor(actualH / 2);
			return cent + pageBorderTop;
		}
		public function get pageBorderLeft():int { return _BorderLeft }
		public function get pageBorderTop():int { return _BorderTop }
		public function get pageBorderRight():int { return _BorderRight }
		public function get pageBorderBottom():int { return _BorderBottom }
		
		// values for a divided page
		public function get pageColumnGutter():int { return _BorderLeft }
		public function get pageWidthHalf():int {
			return (pageWidth - pageBorderLeft - pageBorderRight) / 2;
		}
		public function get pageColumnWidthHalf():int {
			return pageWidthHalf - pageColumnGutter;
		}
		public function get pageWidthThird():int {
			return (pageWidth - pageBorderLeft - pageBorderRight) / 3;
		}
		public function get pageColumnWidthThree():int {
			return pageWidthThird - (pageColumnGutter * 2);
		}
	
		// values based on the text fields
		public function get titleTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("title_txt"));
			return t.y + t.height;
		}
		/*public function get bodyTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("body_txt"));
			return t.y + t.height;
		}*/
		
		public function get bodyTFBottomY():int {
			var ttl:TextField = TextField(_SimpleTextObjectLayer.getChildByName("title_txt"));
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("body_txt"));
			if (ttl.text.length < 1 && t.text.length < 1) return pageBorderTop;
			if (t.text.length < 1) return t.y;
			return t.y + t.height;
		}
		
		public function get bodyLeftTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("bodyleft_txt"));
			return t.y + t.height;
		}
		public function get bodyRightTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("bodyright_txt"));
			return t.y + t.height;
		}
		
		// special props
		public function get pageAreaHeightUnderText():int {
			return pageHeight - pageBorderBottom - bodyTFBottomY;
		}
		public function get interactionLayerHeight():int {
			var h:int = interactionLayer.height;
			var y:int = h;
			for (var i:int = 0; i < interactionLayer.numChildren; i++) {
				var cc:DisplayObject = interactionLayer.getChildAt(i);
				if (cc.y < y && cc.y!=0) y = cc.y;
			}
			if (y < 0) y = Math.abs(y) * 2;
			return h+y;
		}
		public function get actualPageHeight():int {
			return interactionLayerHeight > pageHeight ? interactionLayerHeight : pageHeight;
		}
		
		public function PageRenderer(t:Sprite):void {
			_Settings = Settings.getInstance();
			_DLog = Debugger.getInstance();
			_TargetSprite = t;
			_SimpleObjects = new Array();
			_SWFLoaders = new Array();
			
			_Sheet = new Sheet();
			// added to the display list for event bubbling
			addChild(_Sheet);
			
			createLayers();
		}
		
		public function initialize(f:String):void {
			_XMLFile = f;
			loadXML();
		}
		
		private function initializeSheet():void {
			//_DLog.addDebugText("PR, init Sheet");
			if (!_SheetXML || !_SheetXML.object.length()) {
				//trace("no sheet XML");
				dispatchEvent(new Event(PageRenderer.RENDERED));
				return;
			}
			//trace(_SheetXML);
			_Sheet.initialize(_SheetXML, _SheetLayer);
			_Sheet.addEventListener(Sheet.RENDERED, onSheetRendered);
			_Sheet.checkSheetLoaded();
		}

		private function onSheetRendered(e:Event):void {
			dispatchEvent(new Event(PageRenderer.RENDERED));
			_Sheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
		}
		
		public function start():void {
			if (_Started) return;
			_Started = true;
			_Sheet.start();
		}
		
		public function stop():void {
			_Started = false;
			_Sheet.stop();
		}
		
		public function fillInteractionLayer():void {
			var bgfill:Sprite = new Sprite();
			bgfill.graphics.beginFill(0xff0000, 0);
			bgfill.graphics.drawRect(0, 0, pageWidth, pageHeight);
			bgfill.graphics.endFill();
			_InteractionLayer.addChild(bgfill);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// MISC
		
		public function changeTextFieldSize(f:TextField):void {
			if (f.styleSheet) return;
			var tf:TextFormat = f.getTextFormat();
			tf.size += _Settings.zoomFactor;
			f.setTextFormat(tf);
		}
		
		private function createLayers():void {
			//_DLog.addDebugText("PageRenderer, creating layers");
			_PageBGLayer = new Sprite();
			_PageBGLayer.name = "pagebglayer";
			_SimpleImageObjectLayer = new Sprite();
			_SimpleImageObjectLayer.name = "simpleimageobjectlayer";
			_SimpleTextObjectLayer = new Sprite();
			_SimpleTextObjectLayer.name = "simpletextobjectlayer";
			_InteractionLayer = new Sprite();
			_InteractionLayer.name = "interactionlayer";
			_SheetLayer = new Sprite();
			_SheetLayer.name = "sheetlayer";
			_MessageLayer = new Sprite();
			_MessageLayer.name = "messagelayer";
			
			
			_TargetSprite.addChild(_PageBGLayer);
			_TargetSprite.addChild(_SimpleImageObjectLayer);
			_TargetSprite.addChild(_SimpleTextObjectLayer);
			_TargetSprite.addChild(_SheetLayer);
			_TargetSprite.addChild(_InteractionLayer);
			_TargetSprite.addChild(_MessageLayer);
			
		}
		
		public function addMCToMessageLayer(mc:*):void {
			_MessageLayer.addChild(mc);
		}
		
		public function getPageCenteredX(w:int):int {
			return pageCenterX - (w / 2);
		}
		
		public function getPageCenteredYUnderText(h:int):int {
			return ((pageAreaHeightUnderText/2) - (h / 2)) + bodyTFBottomY;
		}
		
		public function getPageTwoColumnLocations():Array {
			var a:Array = new Array();
			a.push(pageBorderLeft);
			a.push(pageBorderLeft + pageColumnGutter + pageColumnWidthThree);
			return a;
		}
		
		public function getPageThreeColumnLocations():Array {
			var a:Array = new Array();
			a.push(pageBorderLeft);
			a.push(pageBorderLeft + pageColumnGutter + pageColumnWidthThree);
			a.push(pageBorderLeft + (pageColumnGutter*2) + (pageColumnWidthThree*2));
			return a;
		}
		
		public function getPageWidthDiv(d:int):int {
			return (pageWidth - pageBorderLeft - pageBorderRight) / d;
		}

		public function getPageColumnWidthDiv(d:int):int {
			return getPageWidthDiv(d) - (pageColumnGutter);
		}
		
		public function getPageDivColumnLocations(d:int):Array {
			var a:Array = new Array();
			for (var i:int = 0; i < d; i++) {
				a.push(pageBorderLeft + (pageColumnGutter * i) + (getPageWidthDiv(d) * i));
			}
			return a;
		}
		
		public function interactionItemToTop(itm:*):void {
			interactionLayer.setChildIndex(itm as DisplayObject, interactionLayer.numChildren-1);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// rendering
		
		public function renderPageContent():void {
			if (_PageBGImageURL) showImage(_PageBGLayer, _PageBGImageURL);
			
			if (!_SimpleObjects.length) return;
			//_DLog.addDebugText("PageRenderer,  rendering simple objects");
			adjustSimpleTextAreas();
			for(var i:int = 0; i<_SimpleObjects.length; i++) {
				//_SimpleObjects.push(createSimpleTextObject("text","text",_XMLData.pagecontent.text[i].@target,_XMLData.pagecontent.text[i],null));
				if(_SimpleObjects[i].type == "text") {
					var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName(_SimpleObjects[i].target+"_txt"))
					t.autoSize = TextFieldAutoSize.LEFT;
					t.multiline = true;
					t.wordWrap = true;
					t.selectable = false;
					t.styleSheet = _Settings.css;
					//trace("field sheet: " + _Settings.css.styleNames);
					t.htmlText = _SimpleObjects[i].content;
					changeTextFieldSize(t);
					//t.cacheAsBitmap = true;
				} else if (_SimpleObjects[i].type == "image") {
					showImage(_SimpleImageObjectLayer, _SimpleObjects[i].url,_SimpleObjects[i].x,_SimpleObjects[i].y);
				} else {
					// no other simple objects defined
				}
			}
		}
		
		private function createSimpleTextObject(n:String, t:String, tgt:String, cont:String):Object {
			//trace("new "+t+", " + cont);
			var o:Object = new Object();
			o.name = n;
			o.type = t;
			o.target = tgt;
			o.content = _AutoContent.applyContentFunction(cont);
			return o;
		}

		private function createSimpleImageObject(n:String,t:String,url:String,x:int,y:int):Object {
			//trace("new "+t+", " + url+" @ "+x+","+y);
			var o:Object = new Object();
			o.name = n;
			o.type = t;
			o.url = url;
			o.x = x;
			o.y = y;
			return o;
		}
		
		private function adjustSimpleTextAreas():void {
			var titleTF:TextField = TextField(_TargetSprite.getChildByName("title_txt"))
			var bodyTF:TextField = TextField(_TargetSprite.getChildByName("body_txt"))
			var bodyLeftTF:TextField = TextField(_TargetSprite.getChildByName("bodyleft_txt"))
			var bodyRightTF:TextField = TextField(_TargetSprite.getChildByName("bodyright_txt"))
			
			_SimpleTextObjectLayer.addChild(titleTF);
			_SimpleTextObjectLayer.addChild(bodyTF);
			_SimpleTextObjectLayer.addChild(bodyLeftTF);
			_SimpleTextObjectLayer.addChild(bodyRightTF);
			
			var totW:int = pageWidth - _BorderLeft - _BorderRight;
			var columnW:int = int(totW / 2);
			var rightCX:int = columnW + _BorderLeft;
			var titleH:int = 40;
			titleTF.x = _BorderLeft;
			titleTF.y = _BorderTop;
			titleTF.width = totW;
			titleTF.mouseWheelEnabled = false;
			bodyTF.x = _BorderLeft;
			bodyTF.y = _BorderTop + titleH;
			bodyTF.width = totW;
			bodyTF.mouseWheelEnabled = false;
			bodyLeftTF.x = _BorderLeft;
			bodyLeftTF.y = _BorderTop + titleH;
			bodyLeftTF.width = columnW;
			bodyLeftTF.mouseWheelEnabled = false;
			bodyRightTF.x = rightCX;
			bodyRightTF.y = _BorderTop + titleH;
			bodyRightTF.width = columnW;
			bodyRightTF.mouseWheelEnabled = false;
		}
		
		private function showImage(tgt:Sprite, url:String,x:int=0,y:int=0):void {
			var img:SWFLoader = new SWFLoader(url, tgt, { x:x, y:y } );
			_SWFLoaders.push(img);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// XML loading
		
		private function loadXML():void {
			_DLog.addDebugText("PageRenderer load: "+_XMLFile);
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_XMLLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.load(new URLRequest(_XMLFile))
		}
		
		private function onIOError(event:Event):void {
			dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Cannot load the page XML file '"+_XMLFile+"'"));
		}
		
		private function onXMLLoaded(event:Event):void {
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			try {
				_XMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Cannot parse the page XML file '"+_XMLFile+"'. Invalid XML markup, an element is malformed."));
				return;
			}
			dispatchEvent(new Event(PageRenderer.LOADED));
			parseXML();
			initializeSheet();
		}
		
		public function parseXML():void {
			//_DLog.addDebugText("PageRenderer XML parsing ...");
			parseConfig(_XMLData.config);
			parsePageContent(_XMLData.pagecontent);
			if (_XMLData.sheet.length()) _SheetXML = _XMLData.sheet;
			if (_XMLData.interaction.length()) _InteractionXML = _XMLData.interaction;
			//_DLog.addDebugText("PageRenderer XML PARSED COMPLETE");
		}

		private function parseConfig(d:XMLList):void {
			//_DLog.addDebugText("PageRenderer, config");
			_Name = d.name;
			_Type = d.type;
			_Width = int(String(d.pagesize).split(",")[0]);
			_Height = int(String(d.pagesize).split(",")[1]);
			_BorderLeft = int(String(d.pageborders).split(",")[0]);
			_BorderTop = int(String(d.pageborders).split(",")[1]);
			_BorderRight = int(String(d.pageborders).split(",")[2]);
			_BorderBottom = int(String(d.pageborders).split(",")[3]);
			_PageBGImageURL	 = d.pagebgimage;
			_Standalone = d.standalone == "true" ? true : false;
			// if these are not in the page xml file, then use the default values from the site.xml file
			if (!_Width) _Width = _Settings.pageWidth;
			if (!_Height) _Height = _Settings.pageHeight;
		}
		
		private function parsePageContent(d:XMLList):void {
			//_DLog.addDebugText("PageRenderer, content");
			var list:XMLList = d.children()
			var len:int = list.length();
			for (var i:int = 0; i < len; i++) {
				switch (String(list[i].name())) {
					case "text":
						_SimpleObjects.push(createSimpleTextObject("text_" + i, "text", list[i].@target, list[i]));
						break;
					case "image":
						_SimpleObjects.push(createSimpleImageObject("image_" + i, "image", list[i], list[i].@x, list[i].@y));
						break;
					default:
						trace("simple object type not found: " +list[i].name());
				}
			}
		}
		
		public function destroy():void {
			//trace("page render destroy ..");
			stop();
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			
			_Sheet.destroy();
			
			for (var i:int = 0; i<_SWFLoaders.length; i++) {
				_SWFLoaders[i].destroy();
			}

			_TargetSprite.removeChild(_SimpleTextObjectLayer);
			_TargetSprite.removeChild(_InteractionLayer);
			_TargetSprite.removeChild(_SheetLayer);
			
			_XMLData = null;
			_XMLLoader = null;
			_PageBGLayer = null;
			_SimpleImageObjectLayer = null;
			_SimpleTextObjectLayer = null;
			_InteractionLayer = null;
			_SheetLayer = null;
		}
		
	}
}