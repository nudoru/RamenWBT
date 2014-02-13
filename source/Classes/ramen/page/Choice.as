package ramen.page {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Choice extends Sprite {
		
		//vars
		private var _State						:int;
		private var _ChoiceData					:XML;
		private var _CurrentSetMatch			:int;
		private var _RefMovieClip				:MovieClip;
		private var _RefMatchMovieClip			:MovieClip;
		
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
		public static const MARK_SELECT			:String = "mark_select";
		public static const MARK_DESELECT		:String = "mark_deselect";
		public static const MARK_CORRECT		:String = "mark_correct";
		public static const MARK_WRONG			:String = "mark_wrong";
		public static const MARK_NEUTRAL		:String = "mark_neutral";
		
		//types
		public static const HEADER				:String = "header";
		
		// getters/setters
		public function get state():int { return _State }
		public function set state(s:int) {
			if (_State == s) return;
			_State = s;
			dispatchEvent(new Event(STAGE_CHANGE));
		}
		public function get answered():Boolean {
			if (state > STATE_SELECTED) return true;
			return false;
		}
		
		public function get selected():Boolean {
			if (state == STATE_SELECTED) return true;
			return false;
		}
		public function set selected(s:Boolean) {
			if (s && _State == STATE_SELECTED) return;
			if (!s && _State == STATE_NOT_SELECTED) return;
			if (s) {
				state = STATE_SELECTED;
				dispatchEvent(new Event(MARK_SELECT));
			} else {
				state = STATE_NOT_SELECTED;
				dispatchEvent(new Event(MARK_DESELECT));
			}
		}
		public function get isCorrect():Boolean {
			if (selected && correct) return true;
			if (!selected && !correct) return true;
			return false;
		}
		// get choice info from the XML
		public function get id():String { return _ChoiceData.@id }
		public function get type():String { return _ChoiceData.@type }
		public function get subtype():String { return _ChoiceData.@subtype }
		public function get correct():Boolean {
			if (_ChoiceData.@correct == "true" || _ChoiceData.@correct == "yes") return true;
			return false;
		}
		public function get text():String { return _ChoiceData.text }
		public function get label():String { return _ChoiceData.label }
		public function get match():String { return _ChoiceData.match }
		public function get choiceX():int { return int(String(_ChoiceData.settings.position).split(",")[0]) }
		public function get choiceY():int { return int(String(_ChoiceData.settings.position).split(",")[1]) }
		public function get choiceWidth():int { return int(String(_ChoiceData.settings.size).split(",")[0]) }
		public function get choiceHeight():int { return int(String(_ChoiceData.settings.size).split(",")[1]) }
		public function get choiceMatchX():int { return int(String(_ChoiceData.settings.matchposition).split(",")[0]) }
		public function get choiceMatchY():int { return int(String(_ChoiceData.settings.matchposition).split(",")[1]) }
		public function get choiceMatchWidth():int { return int(String(_ChoiceData.settings.matchsize).split(",")[0]) }
		public function get choiceMatchHeight():int { return int(String(_ChoiceData.settings.matchsize).split(",")[1]) }
		public function get caaction():String { return _ChoiceData.settings.caaction }
		public function get waaction():String { return _ChoiceData.settings.waaction }
		public function get numWA():int { return _ChoiceData.wafeedback.length() }
		public function get ca():String { return _ChoiceData.cafeedback }
		public function get wa1():String { return getWAIndex(0) }
		public function get wa2():String { return getWAIndex(1) }
		
		public function get imageURL():String { return _ChoiceData.image.@url; }
		public function get imageX():int { return _ChoiceData.image.@x; }
		public function get imageY():int { return _ChoiceData.image.@y; }
		public function get imageWidth():int { return _ChoiceData.image.@width; }
		public function get imageHeight():int { return _ChoiceData.image.@height; }
		
		public function get currentSetMatch():int { return _CurrentSetMatch }
		public function set currentSetMatch(m:int) { _CurrentSetMatch = m }
		
		public function get refMC():MovieClip { return _RefMovieClip }
		public function set refMC(m:MovieClip):void { _RefMovieClip = m }
		
		public function get refMatchMC():MovieClip { return _RefMatchMovieClip }
		public function set refMatchMC(m:MovieClip):void { _RefMatchMovieClip = m }
		
		// constructor
		public function Choice(x:XML):void {
			_ChoiceData = x;
			//trace("new choice " + x.@id);
		}
		
		public function getWAIndex(i:int):String {
			return _ChoiceData.wafeedback[i];
		}

		public function isOnMatch():Boolean {
			var err:Boolean = false;
			try {
				err = _RefMovieClip.bg_mc.hitTestObject(_RefMatchMovieClip.bg_mc);
			}catch (e:*) { }
			return err;
		}
		
		/*
		public function isOnMatch():Boolean {
			var err:Boolean = false;
			try {
				err = _RefMovieClip.bg_mc.hitTestObject(_RefMatchMovieClip.bg_mc);
			}catch (e:*) { }
			var err2:Boolean = false;
			trace(_RefMovieClip.matchIdx +" is? " + (_RefMovieClip.matchIdx >= 0));
			if (_RefMovieClip.matchIdx >= 0) err2 = (_RefMovieClip.matchIdx == currentSetMatch);
				else err2 = (_RefMovieClip.choiceIdx == currentSetMatch);
			trace(err+", "+_RefMovieClip.name+"("+_RefMovieClip.x+") on "+_RefMatchMovieClip.name+"("+_RefMatchMovieClip.x+") is "+err);
			trace(err2+", "+_RefMovieClip.matchIdx +" should be on match " + currentSetMatch);
			return err && err2;
		} 
		*/
		
		public function isOnMatchPoint(p:Point):Boolean {
			var err:Boolean = false;
			try {
				err = _RefMatchMovieClip.bg_mc.hitTestPoint(p.x, p.y);
			}catch (e:*) { }
			return err;
		}
		
	}
	
}