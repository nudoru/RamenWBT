// Slider Component
// Matt Perkins, 1-15-10


package ramen.page {
	import fl.motion.Motion;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Rectangle;

	// for animations
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	public class LikertSlider extends MovieClip {
		
		private var _ID					:String;
		
		private var _Enabled			:Boolean = false;
		private var _Data				:Array;
		private var _DataPoints			:int;
		private var _DataPointsStep		:Number;
		private var _DataPointSprite	:Array = new Array();
		private var _ValidPositions		:Array = new Array();
		private var _CurrentPosition	:int;
		
		public static const	INITIALIZE	:String = "initialized";
		public static const ENABLED		:String = "enabled";
		public static const DISABLED	:String = "disabled";
		public static const CHANGE		:String = "change";
		
		public function get id():String { return _ID; }
		
		public function get enable():Boolean { return _Enabled; }
		public function set enable(value:Boolean):void {
			if (_Enabled == value) return;
			_Enabled = value;

			if (_Enabled) {
				enableThumb();
				TweenLite.to(this.sliderBar_mc, .25, { alpha:1 } );
				for (var i:int = 0; i < _DataPointSprite.length; i++) {
					TweenLite.to(_DataPointSprite[i], .25, { alpha:1 } );
				}
			} else {
				disableThumb();
				TweenLite.to(this.sliderBar_mc, .5, { alpha:.25 } );
				for (var k:int = 0; k < _DataPointSprite.length; k++) {
					if(k != _CurrentPosition) TweenLite.to(_DataPointSprite[k], .5, { alpha:.25 } );
				}
			}
		}
		
		public function get currentPosition():int { return _CurrentPosition; }
		public function set currentPosition(value:int) {
			if (_CurrentPosition == value) return;
			_CurrentPosition = value;
			dispatchEvent(new Event(LikertSlider.CHANGE));
		}
		public function get currentLikertPositionString():String { return _Data[_CurrentPosition].data; }
		
		public function LikertSlider():void {
			//this.alpha = 0;
			enable = false;
			this.thumb_mc.gotoAndStop("up");
		}
		
		public function initialize(id:String, data:Array):void {
			_ID = id;
			_Data = data;
			_DataPoints = data.length;
			_DataPointsStep = sliderBar_mc.width / (_DataPoints - 1);
			_CurrentPosition = getDefaultPosition();
			calculateValidPositions();
			displayPoints();
			enable = true;
			snapThumbToCurrentPosition(false);
			dispatchEvent(new Event(LikertSlider.INITIALIZE));
		}
		
		public function getDefaultPosition():int {
			for (var i:int = 0; i < _Data.length; i++) {
				if (_Data[i].selected == true) return i;
			}
			return (_DataPoints - 1) / 2;
		}
		
		private function calculateValidPositions():void {
			_ValidPositions = new Array();
			for (var i:int = 0; i < _DataPoints; i++) {
				_ValidPositions.push(i * _DataPointsStep);
			}
		}
		
		private function displayPoints():void {
			// create the points
			for (var i:int = 0; i < _ValidPositions.length; i++) {
				var p:sliderPoint = new sliderPoint();
				p.x = _ValidPositions[i];
				p.y = 9;
				p.label_txt.autoSize = TextFieldAutoSize.CENTER;
				p.label_txt.wordWrap = false;
				p.label_txt.multiline = false;
				p.label_txt.text = _Data[i].label;
				p.hit_mc.alpha = 0;
				addChild(p);
				_DataPointSprite.push(p);
			}
		}
		
		private function activatePoints():void {
			for (var a:int = 0; a < _DataPointSprite.length; a++) {
				_DataPointSprite[a].hit_mc.id_txt.text = a;
				_DataPointSprite[a].hit_mc.scaleX = (_DataPointSprite[a].label_txt.textWidth+3) * .01;
				_DataPointSprite[a].hit_mc.scaleY = (_DataPointSprite[a].label_txt.height + 7) * .01;
				_DataPointSprite[a].hit_mc.buttonMode = true;
				_DataPointSprite[a].hit_mc.mouseChildren = false;
				_DataPointSprite[a].hit_mc.addEventListener(MouseEvent.CLICK, onPointClick);
			}
		}
		
		private function deactivatePoints():void {
			for (var a:int = 0; a < _DataPointSprite.length; a++) {
				_DataPointSprite[a].hit_mc.buttonMode = false;
				_DataPointSprite[a].hit_mc.removeEventListener(MouseEvent.CLICK, onPointClick);
			}
		}
		
		private function onPointClick(e:Event):void {
			setToPosition(int(e.target.id_txt.text));
		}
		
		public function setToPosition(p:int):void {
			currentPosition = p;
			snapThumbToCurrentPosition();
			if (!enable) {
				for (var i:int = 0; i < _DataPointSprite.length; i++) {
					if (i != _CurrentPosition) TweenLite.to(_DataPointSprite[i], .5, { alpha:.25 } );
						else TweenLite.to(_DataPointSprite[i], .5, { alpha:1 } );
				}
			}
		}
		
		private function snapThumbToCurrentPosition(a:Boolean = true):void {
			TweenLite.killTweensOf(this.thumb_mc);
			if(a) TweenLite.to(this.thumb_mc, 1, {x:_ValidPositions[_CurrentPosition], ease:Quad.easeInOut } );
			 else this.thumb_mc.x = _ValidPositions[_CurrentPosition];
			setThumbLabel(_DataPointSprite[_CurrentPosition].label_txt.text);
		}
		
		private function setThumbLabel(t:String):void {
			//this.thumb_mc.label_txt.text = t;
		}
		
		private function enableThumb():void {
			//trace("enable");
			this.thumb_mc.buttonMode = true;
			this.thumb_mc.mouseChildren = false;
			this.thumb_mc.addEventListener(MouseEvent.MOUSE_OVER, sliderOver);
			this.thumb_mc.addEventListener(MouseEvent.MOUSE_OUT, sliderOut);
			this.thumb_mc.addEventListener(MouseEvent.MOUSE_DOWN, startDragThumb);
			//this.thumb_mc.addEventListener(MouseEvent.MOUSE_UP, stopDragThumb); // listen for mouse up on the stage not the thumb
			activatePoints()
			dispatchEvent(new Event(LikertSlider.ENABLED));
		}
		
		private function disableThumb():void {
			//trace("disable");
			this.thumb_mc.buttonMode = false;
			this.thumb_mc.removeEventListener(MouseEvent.MOUSE_OVER, sliderOver);
			this.thumb_mc.removeEventListener(MouseEvent.MOUSE_OUT, sliderOut);
			this.thumb_mc.removeEventListener(MouseEvent.MOUSE_DOWN, startDragThumb);
			//this.thumb_mc.removeEventListener(MouseEvent.MOUSE_UP, stopDragThumb);
			deactivatePoints()
			dispatchEvent(new Event(LikertSlider.DISABLED));
		}

		private function sliderOver(e:Event):void {
			this.thumb_mc.gotoAndStop("over");
		}
		
		private function sliderOut(e:Event):void {
			this.thumb_mc.gotoAndStop("up");
			//stopDragThumb();
		}
		
		private function startDragThumb(e:Event):void {
			this.thumb_mc.startDrag(false, new Rectangle(0, 0, sliderBar_mc.width, 0));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragThumb);
		}
		
		private function stopDragThumb(e:Event = undefined):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragThumb);
			this.thumb_mc.stopDrag();
			snapThumpToNearestStep();
		}
		
		private function snapThumpToNearestStep():void {
			var x:int = this.thumb_mc.x;
			var mp:int = _DataPointsStep/2
			for (var i:int = 0; i < _ValidPositions.length; i++) {
				if (x - mp < _ValidPositions[i] && x + mp > _ValidPositions[i]) {
					currentPosition = i;
					snapThumbToCurrentPosition();
					return;
				}
			}
		}

		
	}
	
}