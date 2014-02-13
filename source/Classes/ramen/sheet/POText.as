package ramen.sheet {
	
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import fl.controls.UIScrollBar;
	
	public class POText extends PageObject implements IPageObject {
		
		private var _POObject					:TextField;
		
		private var _Content					:String;
		private var _Scrolling					:Boolean = false;
		private var _FontName					:String;
		private var _FontAlign					:String;
		private var _FontSize					:int;
		private var _FontColor					:int;
		private var _FontLeading				:int;
		private var _IsBold						:Boolean;
		private var _IsItalic					:Boolean;
		private var _ScrollBar					:UIScrollBar;
		private var _Selectable					:Boolean = false;
		
		private var _AutoContent				:AutoContent = new AutoContent();
		
		public function POText(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
			parseTextData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createText();
			drawBoxes();
			applyDisplayProperties();
			loaded = true;
		}
		
		private function createText():void {
			var field:TextField = new TextField();
			field.name = "text_txt";
			field.width = _Width;
			if(!_Scrolling) {
				field.height = 1;				// this will adjust with autosize, just setting since the default is 100
				if (_FontAlign) field.autoSize = _FontAlign;	// should probably use constants here, but that would require an if block, TextFieldAutoSize.LEFT;
					else field.autoSize = TextFieldAutoSize.LEFT;
			} else {
				field.height = _Height;
				field.autoSize = TextFieldAutoSize.NONE;
			}
			field.wordWrap = true;
			field.multiline = true;
            field.selectable = _Selectable;
			field.embedFonts = true;
			field.antiAliasType = AntiAliasType.ADVANCED;
			
            var format:TextFormat = new TextFormat();
            if(_FontName) format.font = _FontName;
			if(_FontAlign) format.align = _FontAlign;
            if(_FontColor) format.color = _FontColor;
            if(_FontSize) format.size = _FontSize + _Settings.zoomFactor;
			if(_FontLeading) format.leading = _FontLeading;
			if(_IsBold) format.bold = _IsBold;
			if(_IsItalic) format.italic = _IsItalic;

            field.defaultTextFormat = format;
			field.styleSheet = _Settings.css;
			field.htmlText = _Content;
			field.mouseWheelEnabled = false;
			//field.width = field.textWidth + 5;
			//field.cacheAsBitmap = true;
			_POObject = field;
			_ObjContainer.addChild(_POObject);
			
			if(_Scrolling) {
				_ScrollBar = new UIScrollBar();
				_ScrollBar.scrollTarget = field;
				_ScrollBar.setSize(field.width, field.height);
				_ScrollBar.move(field.x+field.width, field.y);
				_ObjContainer.addChild(_ScrollBar);
			}
			
		}
		
		private function changeTextFieldSize(f:TextField):void {
			var tf:TextFormat = f.getTextFormat();
			tf.size += _Settings.zoomFactor;
			f.setTextFormat(tf);
		}
		
		private function parseTextData():void {
			_Content = _AutoContent.applyContentFunction(_XMLData.content);
			_Scrolling = isBool(_XMLData.scrolling);
			_FontName = _XMLData.fontstyle;
			_FontAlign = _XMLData.fontstyle.@align;
			_FontSize = int(_XMLData.fontstyle.@size);
			_FontColor = int(_XMLData.fontstyle.@color);
			_FontLeading = int(_XMLData.fontstyle.@leading);
			_IsBold = isBool(_XMLData.fontstyle.@bold);
			_IsItalic = isBool(_XMLData.fontstyle.@italic);
			_Selectable = isBool(_XMLData.selectable);
		}
		
		public override function destroy():void {
			removeListeners()
			removeReflection()
			_ObjContainer.removeChild(_POObject);
			_POObject = null;
		}
		
	}
}