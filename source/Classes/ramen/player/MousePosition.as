/*
Mouse Positioning helper for dynamic positioning.
Author: Matt Perkins, 4.17.08

Target is the Sprite to draw the UI to
Object is the nested object to base 2ndary coordinate calculations off of
*/

package ramen.player {
	import flash.display.*;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	
	import com.nudoru.utils.Debugger;
	
	public class  MousePosition {
		
		private var _DisplayTarget		:*;
		private var _TargetObject		:*;
		
		private var _OutputLayer		:Sprite;
		private var _OutputMask			:Sprite;
		private var _OutputLineLayer	:Sprite;
		private var _OutputWindow		:MousePositionOutput;
		
		private var _UpdateTimer		:Timer
		
		private var _ClickedDTX			:int = undefined;
		private var _ClickedDTY			:int = undefined;
		private var _ClickedTOX			:int = undefined;
		private var _ClickedTOY			:int = undefined;
		
		private var OFFSX				:int = 20;
		private var OFFSY				:int = 10;
		
		private var POFFSX				:int = 0;
		private var POFFSY				:int = 0;
		
		private var _Status				:int;
		
		private var _DLog				:Debugger;
		
		public static const OFF			:int = 0;
		public static const ON			:int = 1;

		public function get status():int { return _Status }
		
		public function MousePosition(d:*, t:*,pox:int=0, poy:int=0):void {
			_DisplayTarget = d;
			_TargetObject = t;
			POFFSX=pox;
			POFFSY=poy;
			_Status = OFF;
			
			_DLog = Debugger.getInstance();
		}
		
		public function start():void {
			_OutputLayer = new Sprite();
			_OutputLayer.x = 0;
			_OutputLayer.y = 0;
			_DisplayTarget.addChild(_OutputLayer);
			
			_OutputMask = new Sprite();
			_OutputMask.graphics.beginFill(0xff0000, .1);
			_OutputMask.graphics.drawRect(-1000, -1000, 3000, 3000);
			_OutputLayer.addChild(_OutputMask);
			//_OutputLayer.buttonMode = true;
			_OutputLayer.addEventListener(MouseEvent.CLICK, onMaskClick);
			
			_OutputLineLayer = new Sprite();
			_OutputLayer.addChild(_OutputLineLayer);
			
			_OutputWindow = new MousePositionOutput();
			_OutputWindow.alpha = .9;
			_OutputLayer.addChild(_OutputWindow);
			
			_UpdateTimer = new Timer(30, 0);
			_UpdateTimer.addEventListener(TimerEvent.TIMER, updatePosition);
			_UpdateTimer.start();
			
			_Status = ON;
		}
		
		private function updatePosition(e:TimerEvent):void {
			var dtX:int = _DisplayTarget.mouseX;
			var dtY:int = _DisplayTarget.mouseY;
			var toX:int = _TargetObject.mouseX-POFFSX;
			var toY:int = _TargetObject.mouseY-POFFSY;
			var w:int = dtX-_ClickedDTX;
			var h:int = dtY-_ClickedDTY;
			
			_OutputLineLayer.graphics.clear();
			
			if (_ClickedDTX) {
				_OutputLineLayer.graphics.lineStyle(0, 0x009900, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);
				_OutputLineLayer.graphics.beginFill(0x00ff00, .3);
				_OutputLineLayer.graphics.drawRect(_ClickedDTX, _ClickedDTY, w, h);
			}
			
			_OutputLineLayer.graphics.lineStyle(0, 0xff0000, 1, true, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.MITER);
			_OutputLineLayer.graphics.moveTo(-1000, dtY);
			_OutputLineLayer.graphics.lineTo(2000, dtY);
			_OutputLineLayer.graphics.moveTo(dtX, -1000);
			_OutputLineLayer.graphics.lineTo(dtX, 2000);
			
			var t:String = ""; // "ui x,y: " + dtX + ", " + dtY + "\n";
			t += "page x,y: " + toX + ", " + toY+"\n";
			if (_ClickedDTX) t += "w/h: "+w+", " + h;
			_OutputWindow.output_txt.text = t;
			_OutputWindow.x = _DisplayTarget.mouseX + OFFSX;
			_OutputWindow.y = _DisplayTarget.mouseY + OFFSY;
		}
		
		private function onMaskClick(e:MouseEvent):void {
			traceOutput();
			_ClickedDTX = _DisplayTarget.mouseX;
			_ClickedDTY = _DisplayTarget.mouseY;
			_ClickedTOX = _TargetObject.mouseX-POFFSX;
			_ClickedTOY = _TargetObject.mouseY-POFFSY;
			if (e.shiftKey) {
				_ClickedDTX = undefined;
				_ClickedDTY = undefined;
			}
		}
		
		private function traceOutput():void {
			var posx:int = _TargetObject.mouseX - POFFSX;//(_ClickedDTX-_TargetObject.x) - POFFSX;
			var posy:int = _TargetObject.mouseY - POFFSY;// (_ClickedDTY - _TargetObject.y) - POFFSY;
			var width:int = posx -_ClickedTOX;
			var height:int = posy - _ClickedTOY;
			
			var t:String = "<position>" + posx + "," + posy + "</position>\n";

			if (_ClickedDTX) {
				t += "------start box props-\n";
				t += "<position>" + _ClickedTOX + "," + _ClickedTOY + "</position>\n";
				t += "<size>" + width + "," + height + "</size>\n";
				t += "-----end box props-\n";
			}
			_DLog.addDebugText(t);
		}
		
		public function stop():void {
			_UpdateTimer.stop();
			_UpdateTimer.removeEventListener(TimerEvent.TIMER, updatePosition);
			_UpdateTimer = null;
			_OutputLayer.removeEventListener(MouseEvent.CLICK, onMaskClick);
			_DisplayTarget.removeChild(_OutputLayer);
			_OutputLayer = null;
			_ClickedDTX = undefined;
			_ClickedDTY = undefined;
			
			_Status = OFF;
		}
		
	}
	
}