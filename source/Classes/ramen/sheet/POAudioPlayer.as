package ramen.sheet {

	import ramen.common.*;
	import ramen.page.*;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.*;
	
	import com.nudoru.utils.TimeKeeper;
	
	public class POAudioPlayer extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _SWFUILoader				:ImageLoader;
		
		private var _PlayerUIFileName			:String;
		private var _FileName					:String;
		private var _PlayMode					:String;
		private var _PlayDelay					:int;
		private var _Transcript					:String;
		private var _Background					:Boolean;
		private var _Timer						:TimeKeeper;
		
		public function POAudioPlayer(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
			
			parseGraphicData();
			render();
		}
		
		public override function getObject():* { return _POObject }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createPlayerUI();
			// not drawing boxes prevents mouse events from being applied to it
			//drawBoxes();
			applyDisplayProperties();
		}
		
		private function createPlayerUI():void {
			var i:Sprite = new Sprite();
			_SWFUILoader = new ImageLoader(_PlayerUIFileName, i, {x:0,
														 y:0,
														 width:_Width,
														 height:_Height,
														 border:0,
														 borderstyle:"",
														 shadow:false,
														 reflect:false } );
			_SWFUILoader.addEventListener(ImageLoader.LOADED,onSWFUILoaded);
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}
		
		private function onSWFUILoaded(e:Event):void {
			initializePlayerUI();
		}
		
		/*
		 * The player ui doc class isn't available to this class, but these are the events
		public static const AUDIO_LOADED		:String = "audio_loaded";
		public static const AUDIO_PLAY			:String = "audio_play";
		public static const AUDIO_PAUSE			:String = "audio_pause";
		public static const AUDIO_STOP			:String = "audio_stop";
		public static const AUDIO_PLAY_COMPLETE	:String = "audio_play_complete";
		public static const LOAD_ERROR			:String = "load_error";
		 */
		
		private function initializePlayerUI():void {
			_SWFUILoader.content.addEventListener("audio_loaded", onMP3Loaded);
			_SWFUILoader.content.addEventListener("audio_play", onMP3Play);
			_SWFUILoader.content.addEventListener("audio_pause", onMP3Pause);
			_SWFUILoader.content.addEventListener("audio_stop", onMP3Stop);
			_SWFUILoader.content.addEventListener("audio_play_complete", onMP3PlayComplete);
			_SWFUILoader.content.addEventListener("audio_mute", onMP3Mute);
			_SWFUILoader.content.addEventListener("audio_unmute", onMP3Unmute);
			Object(_SWFUILoader.content).initialize(_FileName, _PlayMode, _Transcript, _Width, _Background);
		}
		
		private function onMP3Loaded(e:Event):void {
			//trace("mp3 loaded")
			_Timer = new TimeKeeper("poaudioplayertk");
			
			loaded = true;
			
			if (_PlayDelay > 0) {
				
				startTimer();
			} else {
				runPlayMode();
			}
		}
		
		private function startTimer():void {
			_Timer.addEventListener(TimeKeeper.TICK, onTimerTick);
			_Timer.start();
		}
		
		private function stopTimer():void {
			_Timer.removeEventListener(TimeKeeper.TICK, onTimerTick);
			_Timer.stop();
		}
		
		private function onTimerTick(e:Event):void {
			if (_Timer.elapsedTime >= _PlayDelay) {
				stopTimer();
				runPlayMode();
			}
		}

		private function runPlayMode():void {
			if (_PlayMode == "auto") {
				Object(_SWFUILoader.content).playAudio();
				dispatchEvent(new POEvent(POEvent.PO_START, true, false, _ID));
			} else if (_PlayMode == "play") {
				Object(_SWFUILoader.content).playAudio();
				dispatchEvent(new POEvent(POEvent.PO_START, true, false, _ID));
			}
		}
		
		// listen for playing to start, stop the timer in case you started it playing before the predefined time
		private function onMP3Play(e:Event):void {
			//trace("mp3 playing");
			if (!_Settings.audioEnable) Object(_SWFUILoader.content).mute();
			dispatchEvent(new POEvent(POEvent.PO_PLAY, true, false, _ID));
			stopTimer();
		}
		
		private function onMP3Pause(e:Event):void {
			//trace("mp3 paused");
			dispatchEvent(new POEvent(POEvent.PO_PAUSE, true, false, _ID));
		}
		
		private function onMP3Stop(e:Event):void {
			//trace("mp3 stopped");
			dispatchEvent(new POEvent(POEvent.PO_STOP, true, false, _ID));
		}
		
		private function onMP3PlayComplete(e:Event):void {
			//trace("mp3 play completed");
			dispatchEvent(new POEvent(POEvent.PO_FINISH, true, false, _ID));
		}

		private function onMP3Mute(e:Event):void {
			//trace("MUTE");
			_Settings.audioEnable = false;
		}
		
		private function onMP3Unmute(e:Event):void {
			//trace("UNMUTE");
			_Settings.audioEnable = true;
		}
		
		private function parseGraphicData():void {
			_PlayerUIFileName = _XMLData.playerswf;
			_FileName = _XMLData.url;
			_PlayMode = _XMLData.url.@playmode;
			_PlayDelay = _XMLData.url.@playdelay;
			_Transcript = _XMLData.transcript;
			_Background = _XMLData.background.indexOf("true") == 0 ? true : false;
		}
		
		public override function destroy():void {
			Object(_SWFUILoader.content).removeEventListener("audio_loaded", onMP3Loaded);
			Object(_SWFUILoader.content).removeEventListener("audio_play", onMP3Play);
			Object(_SWFUILoader.content).removeEventListener("audio_pause", onMP3Pause);
			Object(_SWFUILoader.content).removeEventListener("audio_stop", onMP3Stop);
			Object(_SWFUILoader.content).removeEventListener("audio_play_complete", onMP3PlayComplete);
			Object(_SWFUILoader.content).removeEventListener("audio_mute", onMP3Mute);
			Object(_SWFUILoader.content).removeEventListener("audio_unmute", onMP3Unmute);
			Object(_SWFUILoader.content).destroy();
			_SWFUILoader.destroy();
			stopTimer();
			removeListeners();
			removeReflection();
			_ObjContainer.removeChild(_POObject);
			_Timer = null;
			_POObject = null;
			_Settings = null;
		}
		
	}
}