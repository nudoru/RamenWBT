/*
 * Matt Perkins, last updated 11.06.09
 */

package {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
	import flash.media.SoundTransform;
    import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import ramen.common.*;
	import ramen.page.*;
	
	public class POAudioPlayerUI extends Sprite {
		
		private var DEBUG				:Boolean = false;
		
		private var _Transcript			:String = "";
		private var _Height				:int = 30;
		private var _Width				:int = 275;
		private var _BarWidth			:int = 90;
		private var _Background			:Boolean = true;
		
		private var _AudioFileURL		:String;
		private var _PlayMode			:String;
		private var _AudioStatus		:int = -1;
		private var _Audio				:Sound;
		private var _AudioChannel		:SoundChannel;
		private var _AudioPosTimer		:Timer;
		private var _AudioPausedPosition:int = 0;
		private var _AudioVolume		:Number = 1;
		//private var _LastAudioVolume	:Number = 1;
		
		private var STATUS				:int;
		
		public static const STOPPED		:int = 0;
		public static const PLAYING		:int = 1;
		public static const PAUSED		:int = 2;
		
		private static const NOT_INIT	:int = 0;
		private static const INIT		:int = 1;
		
		public static const AUDIO_LOADED		:String = "audio_loaded";
		public static const AUDIO_PLAY			:String = "audio_play";
		public static const AUDIO_PAUSE			:String = "audio_pause";
		public static const AUDIO_STOP			:String = "audio_stop";
		public static const AUDIO_PLAY_COMPLETE	:String = "audio_play_complete";
		public static const AUDIO_MUTE			:String = "audio_mute";
		public static const AUDIO_UNMUTE		:String = "audio_unmute";
		public static const LOAD_ERROR			:String = "load_error";

		public function get audioFileURL():String { return _AudioFileURL }
		public function set audioFileURL(f:String):void { _AudioFileURL = f }
		
		public function get currentAudioPosition():Number {
			var c:Number = _AudioChannel.position;
			var t:Number = _Audio.length;
			return c / t;
		}
		
		public function get volume():Number {
			//return _AudioChannel.soundTransform.volume;
			return _AudioVolume;
		}
		
		public function get status():int { return STATUS }
		
		public function set loaded(b:Boolean):void {
			if (b && STATUS != INIT) {
				dispatchEvent(new Event(AUDIO_LOADED));
				STATUS = INIT;
			}
			preload_mc.bar_mc.scaleX = 1;
		}
		
		public function POAudioPlayerUI():void {
			STATUS = NOT_INIT;
			progressbar_mc.bar_mc.visible = false;
			if(DEBUG) initialize();
		}
		
		public function initialize(f:String="", pm:String = "", t:String="", w:int=250, b:Boolean=true):void {
			_AudioFileURL = f;
			_PlayMode = pm;
			_Transcript = t;
			_Width = w;
			_Background = b;
			if (f.length) load();
			
			if(DEBUG) test();
			
			if (_Width < 30) _Width = 30;
			
			configureWidth();
			
			if (!_Background) bg_mc.visible = false;
		}
		
		private function test():void {
			trace("RUNNING TEST");
			_Width = 620;
			_PlayMode = "auto";
			audioFileURL = "test.mp3";
			load();
		}
		
		private function configureWidth():void {
			var border:int = 3;
			bg_mc.scaleX = _Width * .01;
			playpause_btn.x = border;
			stop_btn.x = playpause_btn.x + playpause_btn.width + border;
			transcript_btn.x = _Width - border - transcript_btn.width;
			mute_btn.x = transcript_btn.x - border - mute_btn.width;
			position_txt.x = mute_btn.x - (border * 2) - position_txt.width;
			
			progressbar_mc.x = preload_mc.x = stop_btn.x + stop_btn.width + (border*2);
			_BarWidth = position_txt.x - preload_mc.x -(border*2);
			progressbar_mc.scaleX = preload_mc.scaleX = _BarWidth * .01;
			
			if (_Width < 180) {
				progressbar_mc.visible = preload_mc.visible = false;
				position_txt.x = ((stop_btn.x - (playpause_btn.x + playpause_btn.width)) / 2) - (position_txt.width / 2) + playpause_btn.x + playpause_btn.width;
			}
			if (_Width < 140) {
				position_txt.visible = false;
			}
			if (_Width < 85) {
				stop_btn.visible = false;
			}
			if (_Width < 59) {
				mute_btn.visible = false;
			}
		}
		
		// p = auto play on load true/flase
		public function load():void {
			//trace("audio load");
			var request:URLRequest = new URLRequest(audioFileURL);
			_Audio = new Sound();
			_Audio.addEventListener(Event.COMPLETE, completeHandler);
			_Audio.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_Audio.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_Audio.load(request);
			
			resetUIToInitialState();
		}
		
		private function setupButtons():void {
			playpause_btn.buttonMode = true;
			playpause_btn.mouseChildren = false;
			playpause_btn.addEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			playpause_btn.addEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			playpause_btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			playpause_btn.addEventListener(MouseEvent.MOUSE_UP, onPlayPauseClick);
			
			stop_btn.buttonMode = true;
			stop_btn.mouseChildren = false;
			stop_btn.addEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			stop_btn.addEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			stop_btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			stop_btn.addEventListener(MouseEvent.MOUSE_UP, onStopClick);
			
			mute_btn.buttonMode = true;
			mute_btn.mouseChildren = false;
			mute_btn.addEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			mute_btn.addEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			mute_btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			mute_btn.addEventListener(MouseEvent.MOUSE_UP, onMuteClick);
			if(Settings.getInstance().audioVolume == 0) {
				mute_btn.icon_mc.gotoAndStop(5);
			} else {
				mute_btn.icon_mc.gotoAndStop(4);
			}
			
			if(_Transcript.length > 0) {
				transcript_btn.buttonMode = true;
				transcript_btn.mouseChildren = false;
				transcript_btn.addEventListener(MouseEvent.ROLL_OVER, onButtonOver);
				transcript_btn.addEventListener(MouseEvent.ROLL_OUT, onButtonOut);
				transcript_btn.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
				transcript_btn.addEventListener(MouseEvent.MOUSE_UP, onTranscriptClick);
			} else {
				transcript_btn.alpha = .5;
			}
			
			progressbar_mc.addEventListener(MouseEvent.MOUSE_UP, onProgressClick);
			progressbar_mc.buttonMode = true;
		}
		
		private function resetUIToInitialState():void {
			playpause_btn.icon_mc.gotoAndStop(1);
			//mute_btn.icon_mc.gotoAndStop(4);
			//progressbar_mc.bar_mc.scaleX = 0;
			TweenLite.to(progressbar_mc.bar_mc, 1, { scaleX:0 } );
			position_txt.text = "";
		}
		
		private function completeHandler(e:Event):void {
			preload_mc.visible = false;
			loaded = true;
			setupButtons();
			if (DEBUG) playAudio();
        }

        private function ioErrorHandler(e:Event):void {
            trace("AudioPlayer error: " + e);
			dispatchEvent(new Event(LOAD_ERROR));
        }

        private function progressHandler(e:ProgressEvent):void {
			//trace("progressHandler: " + e);
			preload_mc.bar_mc.scaleX = e.bytesLoaded / e.bytesTotal;
        }

		private function onButtonOver(e:Event) {
			//e.target.arrows_mc.alpha = .1;
			e.target.button_mc.gotoAndStop("over");
		}

		private function onButtonOut(e:Event) {
			//e.target.arrows_mc.alpha = .25;
			e.target.button_mc.gotoAndStop("up");
		}

		private function onButtonDown(e:Event) {
			e.target.button_mc.gotoAndStop("down");
		}

		private function onPlayPauseClick(e:Event) {
			togglePlayPause();
		}
		
		private function onStopClick(e:Event) {
			stopAudio();
		}
		
		private function onMuteClick(e:Event) {
			toggleMute();
		}
		
		private function onTranscriptClick(e:Event) {
			if(_Transcript.length) showTranscript("Audio Transcript", _Transcript);
		}
		
		public function togglePlayPause():void {
			if (_AudioStatus == PLAYING) pauseAudio();
			else playAudio();
		}
		
		public function playAudio():void {
			//trace("play");
			_AudioChannel = _Audio.play(_AudioPausedPosition);
			_AudioChannel.addEventListener(Event.SOUND_COMPLETE, onAudioComplete);
			setVolumeLevel();
			if (!_AudioPosTimer) {
				_AudioPosTimer = new Timer(50);
				_AudioPosTimer.addEventListener(TimerEvent.TIMER, doAudioPosUpdate);
			}
			_AudioPosTimer.start();
			_AudioStatus = PLAYING;
			playpause_btn.icon_mc.gotoAndStop(2);
			//mute_btn.visible = true;
			dispatchEvent(new Event(AUDIO_PLAY));
		}
		
		private function doAudioPosUpdate(e:TimerEvent):void {
            //trace("positionTimerHandler: " + currentAudioPosition);// _AudioChannel.position.toFixed(2));
			progressbar_mc.bar_mc.visible = true;
			progressbar_mc.bar_mc.scaleX = currentAudioPosition;
			//TweenLite.to(progressbar_mc.bar_mc, .5, { scaleX:currentAudioPosition } );
			position_txt.text =  formatTimeMMSS(_AudioChannel.position) + "/" + formatTimeMMSS(_Audio.length);
        }
		
		private function killPosTweens():void {
			TweenLite.killTweensOf(progressbar_mc.bar_mc);
		}
		
		private function onAudioComplete(e:Event):void {
			// give it the appearance of being at 100% even though it may only be at 97%
			progressbar_mc.bar_mc.scaleX = 1;
			//TweenLite.to(progressbar_mc.bar_mc, .25, { scaleX:1 } );
			position_txt.text =  formatTimeMMSS(_Audio.length) + "/" + formatTimeMMSS(_Audio.length);
            _AudioStatus = STOPPED;
			_AudioChannel.stop();
			_AudioPosTimer.stop();
			_AudioPausedPosition = 0;
			playpause_btn.icon_mc.gotoAndStop(1);
			dispatchEvent(new Event(AUDIO_PLAY_COMPLETE));
        }
		
		public function pauseAudio():void {
			//trace("pause");
			_AudioStatus = PAUSED;
			_AudioChannel.stop();
			_AudioPosTimer.stop();
			_AudioPausedPosition = _AudioChannel.position;
			playpause_btn.icon_mc.gotoAndStop(1);
			dispatchEvent(new Event(AUDIO_PAUSE));
		}
		
		public function stopAudio():void {
			//trace("stop");
			_AudioStatus = STOPPED;
			_AudioChannel.stop();
			_AudioPosTimer.stop();
			_AudioPausedPosition = 0;
			resetUIToInitialState();
			dispatchEvent(new Event(AUDIO_STOP));
		}
		
		private function onProgressClick(e:Event):void {
			var x:Number = e.target.mouseX;
			var r:Number = _Audio.length/100;
			pauseAudio();
			_AudioPausedPosition = r * x;
			playAudio();
			//killPosTweens();
			//progressbar_mc.bar_mc.scaleX = x*.01;
		}
		
		public function toggleMute():void {
			if (_AudioVolume == 0) unmute();
			else mute();
		}
		
		public function mute():void {
			setVolumeLevel(0);
			mute_btn.icon_mc.gotoAndStop(5);
			dispatchEvent(new Event(AUDIO_MUTE));
			Settings.getInstance().audioVolume = 0;
		}
		
		public function unmute():void {
			setVolumeLevel(1);
			mute_btn.icon_mc.gotoAndStop(4);
			dispatchEvent(new Event(AUDIO_UNMUTE));
			Settings.getInstance().audioVolume = 1;
		}
		
		public function setVolumeLevel(v:Number=-1):void {
			if (v != -1) _AudioVolume = v;
			var transform:SoundTransform = _AudioChannel.soundTransform;
            transform.volume = _AudioVolume;
            _AudioChannel.soundTransform = transform;
		}
		
		public function destroy():void {
			killPosTweens();
			try {
				_AudioChannel.stop();
			} catch (e:*) { } 
			try {
				_AudioPosTimer.stop();
			} catch (e:*) { } 
			try {
				_AudioChannel.removeEventListener(Event.SOUND_COMPLETE, onAudioComplete);
			} catch (e:*) { } 
			try {
				_AudioPosTimer.removeEventListener(TimerEvent.TIMER, doAudioPosUpdate);
			} catch (e:*) { } 
			_Audio.removeEventListener(Event.COMPLETE, completeHandler);
			_Audio.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_Audio.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			playpause_btn.removeEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			playpause_btn.removeEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			playpause_btn.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			playpause_btn.removeEventListener(MouseEvent.MOUSE_UP, onPlayPauseClick);
			stop_btn.removeEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			stop_btn.removeEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			stop_btn.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			stop_btn.removeEventListener(MouseEvent.MOUSE_UP, onStopClick);
			mute_btn.removeEventListener(MouseEvent.ROLL_OVER, onButtonOver);
			mute_btn.removeEventListener(MouseEvent.ROLL_OUT, onButtonOut);
			mute_btn.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			mute_btn.removeEventListener(MouseEvent.MOUSE_UP, onMuteClick);
			_AudioChannel = null;
			try {
				_Audio.close();
			} catch (e:Error) {
				//
			}
			_Audio = null;
			if(_AudioPosTimer) _AudioPosTimer.stop();
			_AudioPosTimer = null;
		}
		
		private function formatTimeMMSS(ms:Number):String {
			var msr:Number = Math.round(ms / 1000);
			var minutes:int;
			var sMinutes:String;
			var sSeconds:String;
			if(msr > 59) {
				minutes = Math.floor(msr / 60);
				sMinutes = String(minutes);
				sSeconds = String(msr % 60);
			} else {
				sMinutes = "0";
				sSeconds = String(msr);
			}
			if(msr < 10) {
				sSeconds = sSeconds;
			}
			sMinutes = formatNum(sMinutes);
			sSeconds = formatNum(sSeconds);
			return sMinutes + ":" + sSeconds;
		}
		
		private function formatNum(num:*):String {
			if (num <= 9) {
				num = "0"+num;
			} else {
				num = String(num);
			}
			return num;
		}
		
		private function showTranscript(t:String, m:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.SIMPLE, t, m, "", mdl, pst)));
		}
		
		private function createPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			//popup += "<hpos>"+ObjectStatus.CENTER+"</hpos>";
			//popup += "<vpos>" + ObjectStatus.MIDDLE + "</vpos>";
			popup += "<hpos>"+ObjectStatus.PAGE_RIGHT+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_BOTTOM+"</vpos>";
			//popup += "<buttons>";
			//popup += "<button event='close'>Close</button>";
			//popup += "</buttons>";
			//popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
	}
	
}