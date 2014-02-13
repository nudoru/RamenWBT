//TODO custom time keeper events

package com.nudoru.utils {

	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.EventDispatcher;

	public class TimeKeeper extends EventDispatcher {
		
		private var _ID					:String;
		
		private var _TheTimer			:Timer;
		
		private var _ExpirationTime		:Number;
		
		private var _Interval			:int;
		
		public static const START		:String = "start";
		public static const STOP		:String = "stop";
		public static const TIMEUP		:String = "time_up";
		public static const	TICK		:String = "tick";
		
		public function get elapsedTime():Number { 
			return (_TheTimer.currentCount * _Interval) / 1000;
		}
		public function get elapsedTimeRnd():Number { 
			return Math.round((_TheTimer.currentCount * _Interval) / 1000);
		}
		public function get expirationTime():Number { return _ExpirationTime; }
		public function get loop():int {
			if (!expirationTime) return 0;
			return (1000 / _Interval) * expirationTime;
		}
		public function get isRunning():Boolean { return _TheTimer.running; }
		
		public function get id():String { return _ID; }
		
		public function TimeKeeper(id:String, e:Number=0, i:int = 250) {
			_ID = id;
			_ExpirationTime = e;
			_Interval = i;
			_TheTimer = new Timer(_Interval, loop);
		}
		
		public function start():void {
			_TheTimer.stop();
			_TheTimer.reset();
			_TheTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerExpire);
			_TheTimer.addEventListener(TimerEvent.TIMER, onTimer);
			_TheTimer.start();
			dispatchEvent(new Event(TimeKeeper.START));
		}
		
		public function stop():void {
			_TheTimer.stop();
			_TheTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerExpire);
			_TheTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			dispatchEvent(new Event(TimeKeeper.STOP));
		}
		
		public function restart():void {
			_TheTimer.stop();
			_TheTimer.reset();
			_TheTimer.start();
		}
		
		public function destroy():void {
			stop();
			_TheTimer = null;
		}
		
		public function elapsedTimeFormattedMMSS():String {
			var minutes:int;
			var sMinutes:String;
			var sSeconds:String;
			if(elapsedTimeRnd > 59) {
				minutes = Math.floor(elapsedTimeRnd / 60);
				sMinutes = String(minutes);
				sSeconds = String(elapsedTimeRnd % 60);
			} else {
				sMinutes = "0";
				sSeconds = String(elapsedTimeRnd);
			}
			if(elapsedTime < 10) {
				sSeconds = sSeconds;
			}
			sMinutes = formatNum(sMinutes);
			sSeconds = formatNum(sSeconds);
			return sMinutes + ":" + sSeconds;
		}
		
		public function elapsedTimeFormattedHHMMSS():String {
			var l_seconds:*;
			var l_minutes:*;
			var l_hours:*;
			if (elapsedTimeRnd <= 9) {
				l_seconds = "0" + String(elapsedTimeRnd);
				l_minutes = "00";
				l_hours = "00";
			} else {
				l_seconds = String(elapsedTimeRnd);
				l_minutes = "00";
				l_hours = "00";
			}
			if (l_seconds > 59) {
				l_minutes = int(l_seconds / 60);
				l_minutes = formatNum(l_minutes);
				l_seconds = l_seconds - (l_minutes * 60);
				l_seconds = formatNum(l_seconds);
				l_hours = "00"
			}
			if (l_minutes > 59) {
				l_hours = int(l_minutes / 60);
				l_hours = formatNum(l_hours);
				l_minutes = l_minutes - (l_hours * 60);
				l_minutes = formatNum(l_minutes);
			}
			return l_hours + ":" + l_minutes + ":" + l_seconds;
		}
		
		private function formatNum(num:*):String {
			if (num <= 9) {
				num = "0"+num;
			} else {
				num = String(num);
			}
			return num;
		}
		
		private function onTimer(e:TimerEvent):void {
			//trace(id +" - "+elapsedTimeFormattedMMSS());
			dispatchEvent(new Event(TimeKeeper.TICK));
		}
		
		private function onTimerExpire(e:TimerEvent):void {
			//trace(id +" - "+"timer expired!");
			stop();
			dispatchEvent(new Event(TimeKeeper.TIMEUP));
		}
		
	}
	
}