package ramen.sheet {
	
	import flash.events.Event;
	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.nudoru.utils.TimeKeeper;
	
	public class POEventManager extends Sprite {
		
		private var _SheetRef			:Sheet;
		private var _EventTimer			:TimeKeeper;	
		private var _EventList			:Array;
		
		private var _MouseEvents		:Boolean = false;
		private var _TimedEvents		:Boolean = false;
		
		public function get hasMouseEvents():Boolean { return _MouseEvents; }
		public function get hasTimedEvents():Boolean { return _TimedEvents; }
		
		public function POEventManager(p:Sheet) {
			_SheetRef = p;
			_EventTimer = new TimeKeeper("poeventmanagertk");
			_EventList = new Array();
			_TimedEvents = false;
		}
		
		public function start():void {
			if (_TimedEvents) {
				_EventTimer.addEventListener(TimeKeeper.TICK, onTimerTick);
				_EventTimer.start();
			}
		}
		
		public function stop():void {
			if (_TimedEvents) {
				_EventTimer.removeEventListener(TimeKeeper.TICK, onTimerTick);
				_EventTimer.stop();
			}
		}
		
		public function destroy():void {
			stop();
			_EventTimer.destroy();
		}
		
		public function restartTimer():void {
			if (_TimedEvents) {
				_EventTimer.restart();
			}
		}
		
		private function onTimerTick(e:Event):void {
			checkTimedEvents(_EventTimer.elapsedTime);
		}
		
		private function checkTimedEvents(t:Number):void {
			var len:int = _EventList.length;
			for (var i:int = 0; i < len; i++) {
				if (_EventList[i].actionevent == "timer") {
					if (Number(_EventList[i].time) == t) {
						performEvent(POEvent.PO_TIMER, _EventList[i].originatorid, _EventList[i].time);
					}
				}
			}
		}
		
		public function addEventList(e:XMLList, t:*):void {
			var len:int = e.event.length();
			// <event id="imageover" actionevent="rollover" actionresult="" target="" data="" />
			for(var i:int=0; i<len; i++) {
				var o:Object = new Object();
				o.originator = t;
				o.originatorid = t.id;
				o.id = e.event[i].@id;
				o.actionevent = e.event[i].@actionevent;
				o.time = e.event[i].@time;
				o.actionresult = e.event[i].@actionresult;
				o.target = e.event[i].@target;
				o.data = e.event[i].@data;
				o.dataxml =  e.event[i].data;
				o.runcount = 0;
				_EventList.push(o);
				
				if (o.actionevent == "rollover" || o.actionevent == "rollout" || o.actionevent == "over" || o.actionevent == "out" || o.actionevent == "click" || o.actionevent == "release") _MouseEvents = true;
				if (o.actionevent == "timer") _TimedEvents = true;
			}
		}
		
		public function performEvent(e:String, t:String, ti:Number=-1):void {
			//trace("perform: "+e+" on "+t+" @ "+ti);
			var eidx:Array = getEventIndexes(e,t,ti);
			for (var i:int = 0; i < eidx.length; i++) {
				playEvent(eidx[i]);
			}
		}

		
		private function playEvent(idx:int):void {
			var r:String = _EventList[idx].actionresult;
			var t:String = _EventList[idx].target;
			var d:String = _EventList[idx].data;
			_EventList[idx].runcount++;
			var tt:Array = t.split("@");
			if(r == "goto_url") {
				var request:URLRequest = new URLRequest(t);
				if(t.indexOf("mailto:") == 0) {
					navigateToURL(request,"_self");
				} else {
					navigateToURL(request,"_blank");
				}
			} else if(r == "goto_pageid") {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.PAGE_JUMP_SELECTION, true, false, t, t));
			} else if (r == "goto_nextpage") {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_NEXT_PAGE));
			} else if (r == "goto_prevpage") {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_PREVIOUS_PAGE));
			} else if (r == "restart_page") {
				dispatchEvent(new NavChangeEvent(NavChangeEvent.REFRESH_CURRENT_PAGE));
			} else if (r == "gotoandstop") {
				Object(_SheetRef.getPOByID(String(tt[0]))).gotoFrameAndStop(d, t);
			} else if (r == "gotoandplay") {
				Object(_SheetRef.getPOByID(String(tt[0]))).gotoFrameAndPlay(d, t);
			} else if(r == "hide") {
				Object(_SheetRef.getPOByID(t)).hide();
			} else if(r == "show") {
				Object(_SheetRef.getPOByID(t)).show();
			} else if(r == "toggle") {
				Object(_SheetRef.getPOByID(t)).toggleVis();
			} else if(r == "transitionin") {
				Object(_SheetRef.getPOByID(t)).playTransitionIn();
			} else if(r == "transitionout") {
				Object(_SheetRef.getPOByID(t)).playTransitionOut();
			} else if(r == "restarttimer") {
				restartTimer();
			} else if (r == "set_page_status") {
				dispatchEvent(new PageStatusEvent(d));
			} else if(r == "playanimation") {
				//Object(_SheetRef.getPOByID(t)).playAnimationID(d);
				//_SheetRef.playAnimationIDonPO(d,t);
				trace("playanimation disabled");
			} else if (r == "lightbox") {
				var data:Array = d.split("%%");
				var iwidth:Number = int(data[0]);
				var iheight:Number = int(data[1]);
				var iborderw:Number = int(data[2]);
				var iborders:String = String(data[3]);
				var icaption:String = String(data[4]);
				//var l:LightBox = new LightBox(t, _SheetRef.getRamenMessageLayer(), icaption, {width:iwidth,height:iheight,border:iborderw}); 
			} else if (r == "show_popup") {
				dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, _SheetRef, XML(XMLList(_EventList[idx].dataxml).popup)));
			} else if(r == "dispatchcustomevent"){
				dispatchEvent(new InterfaceEvent(InterfaceEvent.CUSTOM, true, false, this, "po_custom&"+t+"_"+d));
			} else if(r=="command") {
				Object(_SheetRef.getPOByID(t)).command(d);
			} else {
				//
			}
		}
		
		// TI - time index when the event is to occur
		private function getEventIndexes(e:String, t:String, ti:Number = -1):Array {
			var a:Array = new Array()
			var len:int = _EventList.length;
			for (var i:int = 0; i < len; i++) {
				if (ti == -1) {
					// an event that isn't timer driven
					if (t == _EventList[i].originatorid && e == _EventList[i].actionevent) a.push(i);
				} else {
					// timer event
					if(t == _EventList[i].originatorid && e == _EventList[i].actionevent && ti == Number(_EventList[i].time)) a.push(i);
				}
			}
			return a;
		}
		
	}
}