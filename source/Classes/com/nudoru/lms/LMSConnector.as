/*
SCORM Tracking code for Pipwerks SCORM adapter
http://pipwerks.com/journal/2008/04/27/how-to-add-basic-scorm-code-to-a-flash-movie/

Matt Perkins
Last Update 5.15.09

TODO:
	x. track session time, hhHH:MM:SS.ss
		2004 needs specially formatted time
	
*/

	package com.nudoru.lms {
	
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.TimeKeeper;
	import com.nudoru.lms.LMSEvent;
	import com.pipwerks.SCORM;
	
	public class LMSConnector extends EventDispatcher {
		
		private static var _Instance	:LMSConnector
		
		private var _Mode				:String;
		private var _SimulateLMS		:Boolean;
		private var _LessonStatus		:String;
		private var _SuccessStatus		:String;
		private var _LastLocation		:String;
		private var _SuspendData		:String;
		private var _SimLastLocation	:String = "";
		private var _SimSuspendData		:String = "";
		private var _SessionTime		:String;
		private var _Score				:int;
		private var _StudentName		:String;
		private var _StudentID			:String;
		
		private var _LMSConnected		:Boolean;
			/* DoNotTrack allows for the LMS to be connected, but for no data to be sent.
			 This is required if the course has been completed and you do not want to overwrite
			 and of the data that exists on the server. Eg: overwrite a "complete" with "imcomplete"
			 the LMS should enforce this, but it may not. */
		private var _DoNotTrack			:Boolean;
		private var _LastCommand		:String;
		private var _Success			:Boolean;
		
		private var _Scorm				:SCORM
		
		private var _SessionTimer		:TimeKeeper;
		
		private var _CourseExitTimer	:Timer;
		
		private var _DLog				:Debugger;

		public static const SCORM12				:String = "scorm";
		public static const SCORM2004			:String = "scorm2004";
		
		public function get LMSConnected():Boolean { return _LMSConnected; }
		
		public function get studentName():String { return _StudentName; }
		public function get studentID():String { return _StudentID; }
		
		public function get canTrack():Boolean {
			if (!_LMSConnected || _DoNotTrack) return false;
			return true;
		}
		
		public function get score():int { return _Score; }
		public function set score(value:int):void {
			if (!canTrack) return;
			if (value > 100) value = 100;
			if (value < 0) value = 0;
			_Score = value;
			lastCommand = "Set score to: " + _Score;
			if (_Mode == LMSConnector.SCORM2004) success = _Scorm.set("cmi.score.raw", String(_Score));
				else success = _Scorm.set("cmi.core.score.raw", String(_Score));
		}
		
		public function get lastLocation():String { return _LastLocation; }
		public function set lastLocation(value:String):void {
			if (!canTrack) return;
			_LastLocation = value;
			lastCommand = "Set last location to: " + _LastLocation;
			if (_Mode == LMSConnector.SCORM2004) success = _Scorm.set("cmi.location", _LastLocation);
				else success = _Scorm.set("cmi.core.lesson_location", _LastLocation);
		}
		
		public function get suspendData():String { return _SuspendData; }
		public function set suspendData(value:String):void {
			if (!canTrack) return;
			_SuspendData = value;
			lastCommand = "Set susspend data to: " + _SuspendData;
			if (_Mode == LMSConnector.SCORM2004) success = _Scorm.set("cmi.suspend_data", _SuspendData);
				else success = _Scorm.set("cmi.suspend_data", _SuspendData);
		}
		public function get sessionTime():String { return _SessionTime; }
		public function set sessionTime(value:String):void {
			if (!canTrack) return;
			_SessionTime = value;
			lastCommand = "Set sesstion time to: " + _SessionTime;
			if (_Mode == LMSConnector.SCORM2004) success = _Scorm.set("cmi.session_time", _SessionTime);
				else success = _Scorm.set("cmi.core.session_time", _SessionTime);
		}
		public function get lessonStatus():String { return _LessonStatus; }
		public function set lessonStatus(value:String):void {
			if (!canTrack) return;
			_LessonStatus = value;
			lastCommand = "Set lesson status to: " + _LessonStatus;
			if (_Mode == LMSConnector.SCORM2004) success = _Scorm.set("cmi.completion_status", _LessonStatus);
				else success = _Scorm.set("cmi.core.lesson_status", _LessonStatus);
		}
		
		public function get successStatus():String { return _SuccessStatus; }
		public function set successStatus(value:String):void {
			if (!canTrack) return;
			if (_Mode != LMSConnector.SCORM2004) return;
			_SuccessStatus = value;
			lastCommand = "Set success status to: " + _SuccessStatus;
			success = _Scorm.set("cmi.success_status", _SuccessStatus);
		}
		
		public function get success():Boolean { return _Success; }
		public function set success(value:Boolean):void {
			_Success = value;
			if (!_Success) {
				if (!_SimulateLMS) {
					_DLog.addDebugText("   result: FAILED");
					//_DLog.addDebugText("LMS last operation FAILED!");
					dispatchEvent(new LMSEvent(LMSEvent.ERROR));
				}
			} else {
				_DLog.addDebugText("   result: SUCCESSFUL");
				dispatchEvent(new LMSEvent(LMSEvent.SUCCESS));
			}
		}
		
		public function get simLastLocation():String { return _SimLastLocation; }
		public function set simLastLocation(value:String):void { _SimLastLocation = value; }
		
		public function get simSuspendData():String { return _SimSuspendData; }
		public function set simSuspendData(value:String):void { _SimSuspendData = value; }
		
		public function get lastCommand():String { return _LastCommand; }
		public function set lastCommand(value:String):void { 
			_LastCommand = value;
			_DLog.addDebugText("LMS, " + _LastCommand);
		}
		
		public function LMSConnector(singletonEnforcer:SingletonEnforcer):void {
			setDefaultValues();
		}
		
		public static function getInstance():LMSConnector {
			if (LMSConnector._Instance == null) {
				LMSConnector._Instance = new LMSConnector(new SingletonEnforcer());
				//LMSConnector._Instance.setDefaultValues();
			}
			return LMSConnector._Instance;
		}
		
		public function init(m:String, s:Boolean = false):void {
			_Mode = m;
			_SimulateLMS = s;
			
			_Scorm = new SCORM();
			_DLog = Debugger.getInstance();
			_SessionTimer = new TimeKeeper("SCORMSessionTimer");
			_LMSConnected = false;
			_DoNotTrack = true;
		}
		
		private function setDefaultValues():void {
			//trace("LMS setting default values");
			_LastLocation = "";
			_SuspendData = "";
			_SessionTime = "00:00:01";	// 1 second
			_Score = -1;
			_StudentName = "Name,Student";
			_StudentID = "xxx000";
		}
		
		public function initialize():Boolean {
			_DLog.addDebugText("LMS inititalizing ...");
			_LMSConnected = _Scorm.connect();
			if(_LMSConnected){
				_DLog.addDebugText("LMS connect SUCCESS");
				
				if(_Mode == LMSConnector.SCORM2004) {
					_LessonStatus = _Scorm.get("cmi.completion_status");
					_LastLocation = _Scorm.get("cmi.location");
					_SuspendData = _Scorm.get("cmi.suspend_data");
					_StudentName = _Scorm.get("cmi.learner_name");
					_StudentID = _Scorm.get("cmi.learner_id");
				} else {
					_LessonStatus = _Scorm.get("cmi.core.lesson_status");
					_LastLocation = _Scorm.get("cmi.core.lesson_location");
					_SuspendData = _Scorm.get("cmi.suspend_data");
					_StudentName = _Scorm.get("cmi.core.student_name");
					_StudentID = _Scorm.get("cmi.core.student_id");
				}
				
				outputLaunchData();
				if(lessonStatus == SCOStatus.COMPLETE || lessonStatus == SCOStatus.PASS || lessonStatus == SCOStatus.FAIL){
					_DLog.addDebugText("LMS course already completed, disconnecting");
					//disconnect()
					_DoNotTrack = true;
				} else {
					_DLog.addDebugText("LMS setting incomplete");
					_DoNotTrack = false;
					setIncomplete();
					_SessionTimer.start();
				}
			} else if (!_LMSConnected && _SimulateLMS) {
				_DLog.addDebugText("SIMULATING LMS connect SUCCESS");
				
				_LessonStatus = "i";
				_LastLocation = simLastLocation;
				_SuspendData = _SimSuspendData;
				_StudentName = "Simulated, Simulated";
				_StudentID = "sSimID";
				
				outputLaunchData();
				
				_DLog.addDebugText("LMS setting incomplete");
				_DoNotTrack = false;
				setIncomplete();
				_SessionTimer.start();
				_LMSConnected = true;
			} else {
				dispatchEvent(new LMSEvent(LMSEvent.CANNOT_CONNECT));
			}
			dispatchEvent(new LMSEvent(LMSEvent.INITIALIZED));
			return _LMSConnected;
		}
		
		private function outputLaunchData():void {
			var t:String = "~~~~~~~~~~\n";
			t += "LMS stu name is: '" + studentName + "'\n";
			t += "LMS stu id is: '" + studentID + "'\n";
			t += "LMS lstatus is: '" + lessonStatus + "'\n";
			t += "LMS last loc is: '" + lastLocation + "'\n";
			t += "LMS susp data is: '" + suspendData + "'\n";
			t += "~~~~~~~~~~"
			_DLog.addDebugText(t);
		}
		
		public function setIncomplete(f:Boolean = false):void {
			if (f) {
				sessionTime = getSessionTime();
				_SessionTimer.stop();
			}
			lessonStatus = SCOStatus.INCOMPLETE;
		}
		
		public function setComplete():void {
			sessionTime = getSessionTime();
			_SessionTimer.stop();
			lessonStatus = SCOStatus.COMPLETE;
			successStatus = SCOStatus.SUCCESSSTATUS_PASSED;
		}
		
		public function setPass():void {
			sessionTime = getSessionTime();
			_SessionTimer.stop();
			lessonStatus = SCOStatus.PASS;
			successStatus = SCOStatus.SUCCESSSTATUS_PASSED;
		}
		
		public function setFail():void {
			sessionTime = getSessionTime();
			_SessionTimer.stop();
			lessonStatus = SCOStatus.FAIL;
			successStatus = SCOStatus.SUCCESSSTATUS_FAILED;
		}
		
		public function commit():void {
			if (!canTrack) return;
			_Scorm.save();
		}
		
		// on Saba, this closes the window, must be called at the end
		public function disconnect():void {
			if (!_LMSConnected) return;
			_DLog.addDebugText("LMS, disconnecting");
			_Scorm.disconnect();
		}
		
		public function exitCourse():void {
			_SessionTimer.stop();
			_DLog.addDebugText("LMS, exiting after: " + getSessionTime());
			
			// add a timer so that any communication can finish
            _CourseExitTimer = new Timer(1000,1);
			_CourseExitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, closeWindow);
			_CourseExitTimer.start();
			
			disconnect();
		}
		
		
		public function getSessionTime():String {
			var stime:String = "";
			if (_Mode == LMSConnector.SCORM2004) {
				// type timeinterval (second, 10,2)
				var t:Array =  _SessionTimer.elapsedTimeFormattedHHMMSS().split(":");
				stime = SCORMDataTypes.toTimeIntervalSecond10(t[0],t[1],t[2]);
			} else {
				// scorm 1.2, HHHH:MM:SS.SS
				stime = "00" + _SessionTimer.elapsedTimeFormattedHHMMSS()+".0";
			}
			return stime;
		}
		
		private function closeWindow(e:Event):void {
			_DLog.addDebugText("LMS, attempting to close the window ...");
			try{
				ExternalInterface.call("closeWindow");
			} catch (e:*) {
				dispatchEvent(new LMSEvent(LMSEvent.CANNOT_CLOSE_WINDOW));
			}
		}
		
	}
}

class SingletonEnforcer {}