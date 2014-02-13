package ramen.page {
	
	//import ramen.common.*;
	//import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.*;
	import flash.net.*;
	import com.nudoru.utils.SWFLoader;
	
	public class PageRendererSimple extends Sprite {
	
		private var _TargetSprite				:Sprite;
		private var _XMLFile					:String;
		private var _XMLData					:XML;
		private var _XMLLoader					:URLLoader;
		
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
		
		private var _SimpleObjects				:Array;
		private var _InteractionXML				:XMLList;
		
		private var _PageBGImageURL				:String;
		private var _SWFLoaders					:Array;
		
		private var _Started					:Boolean = false;
		
		public static const LOADED				:String = "loaded";
		public static const RENDERED			:String = "rendered";
		
		public function get interactionLayer():Sprite { return _InteractionLayer }
		public function get interactionXML():XMLList { return _InteractionXML }
		public function get messageLayer():Sprite { return _MessageLayer }
		
		public function get pageName():String { return _Name }
		public function get pageWidth():int { return _Width }
		public function get pageHeight():int { return _Height }
		public function get pageLeft():int { return _BorderLeft }
		public function get pageTop():int { return _BorderTop }
		public function get pageRight():int { return _Width - _BorderRight }
		public function get pageBottom():int { return _Height - _BorderBottom }
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
		
		public function get targetSprite():Sprite { return _TargetSprite }
		
		public function get titleTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("title_txt"));
			return t.y + t.height;
		}
		public function get bodyTFBottomY():int {
			var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName("body_txt"));
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
		
		public function PageRendererSimple(t:Sprite):void {
			_TargetSprite = t;
			_SimpleObjects = new Array();
			_SWFLoaders = new Array();
			
			createLayers();
		}
		
		public function initialize(f:String):void {
			_XMLFile = f;
			loadXML();
		}
	
		public function start():void {
			if (_Started) return;
			_Started = true;
		}
		
		public function stop():void {
			_Started = false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// MISC
		
		private function changeTextFieldSize(f:TextField, z:int):void {
			var tf:TextFormat = f.getTextFormat();
			tf.size += z;
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
			_MessageLayer = new Sprite();
			_MessageLayer.name = "messagelayer";
			
			_TargetSprite.addChild(_PageBGLayer);
			_TargetSprite.addChild(_SimpleImageObjectLayer);
			_TargetSprite.addChild(_SimpleTextObjectLayer);
			_TargetSprite.addChild(_InteractionLayer);
			_TargetSprite.addChild(_MessageLayer);
		}
		
		public function destroy():void {
			stop();
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);

			for (var i:int = 0; _SWFLoaders.length; i++) {
				_SWFLoaders[i].destroy();
			}
			
			_TargetSprite.removeChild(_SimpleTextObjectLayer);
			_TargetSprite.removeChild(_InteractionLayer);
			
			_XMLData = null;
			_XMLLoader = null;
			_PageBGLayer = null;
			_SimpleImageObjectLayer = null;
			_SimpleTextObjectLayer = null;
			_InteractionLayer = null;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// rendering
		
		public function renderPageContent():void {
			if (_PageBGImageURL) showImage(_PageBGLayer, _PageBGImageURL);
			
			if (!_SimpleObjects.length) return;

			adjustSimpleTextAreas();
			for(var i:int = 0; i<_SimpleObjects.length; i++) {
				if(_SimpleObjects[i].type == "text") {
					var t:TextField = TextField(_SimpleTextObjectLayer.getChildByName(_SimpleObjects[i].target+"_txt"))
					t.autoSize = TextFieldAutoSize.LEFT;
					t.multiline = true;
					t.wordWrap = true;
					t.selectable = false;
					t.htmlText = _SimpleObjects[i].content;
					t.cacheAsBitmap = true;
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
			o.content = cont;
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
			
			var totW:int = _Width - _BorderLeft - _BorderRight;
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
			trace("PageRenderer load: "+_XMLFile);
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_XMLLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.load(new URLRequest(_XMLFile))
		}
		
		private function onIOError(event:Event):void {
			//dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Cannot load the page XML file '"+_XMLFile+"'"));
		}
		
		private function onXMLLoaded(event:Event):void {
			_XMLLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			try {
				_XMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				//dispatchEvent(new PlayerError(PlayerError.ERROR, "10000", "Cannot parse the page XML file '"+_XMLFile+"'. Invalid XML markup, an element is malformed."));
				return;
			}
			dispatchEvent(new Event(PageRenderer.LOADED));
			parseXML();
			dispatchEvent(new Event(PageRenderer.RENDERED));
		}
		
		public function parseXML():void {
			parseConfig(_XMLData.config);
			parsePageContent(_XMLData.pagecontent);
			if (_XMLData.interaction.length()) _InteractionXML = _XMLData.interaction;
		}

		private function parseConfig(d:XMLList):void {
			_Name = d.name;
			_Type = d.type;
			_Width = int(String(d.pagesize).split(",")[0]);
			_Height = int(String(d.pagesize).split(",")[1]);
			_BorderLeft = int(String(d.pageborders).split(",")[0]);
			_BorderTop = int(String(d.pageborders).split(",")[1]);
			_BorderRight = int(String(d.pageborders).split(",")[2]);
			_BorderBottom = int(String(d.pageborders).split(",")[3]);
			_PageBGImageURL	 = d.pagebgimage;
		}
		
		private function parsePageContent(d:XMLList):void {
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
		
	}
}