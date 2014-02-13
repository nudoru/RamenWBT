package ramen.common {
	
	import com.nudoru.lms.InteractionObject;
	import flash.events.EventDispatcher;
	
	public class AssessmentManager extends EventDispatcher{
		
		static private var _Instance	:AssessmentManager;
		
		private var _Initd				:Boolean;
		private var _Delimeter			:String = "^^";
		
		private var _QuestionList		:Array;
		
		public function get initd():Boolean { return _Initd; }
		public function set initd(value:Boolean):void { _Initd = value; }
		
		public function AssessmentManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():AssessmentManager {
			if (AssessmentManager._Instance == null) {
				AssessmentManager._Instance = new AssessmentManager(new SingletonEnforcer());
			}
			return AssessmentManager._Instance;
		}
	
		public function initialize():void {
			trace("$$$ initialize AssessmentManager");
			initd = true;
			_QuestionList = new Array();
		}
		
		public function submitQuestion(q:InteractionObject):void {
			if (!initd) initialize();
			if (questionExists(q.id)) {
				trace("$$$ this question ID exists, removeing");
				removeQuestionId(q.id);
			}
			_QuestionList.push(q);
			trace("$$$ AssmntMgr, added question: " + q.id);
		}
		
		public function retreiveQuestion(id:String):InteractionObject {
			return getIntrObjByID(id);
		}
		
		public function removeQuestionId(id:String):Boolean {
			var idx:int = getIntrObjIndexByID(id);
			if (idx >= 0) {
				_QuestionList.splice(idx, 1);
				return true;
			}
			return false;
		}
		
		public function questionExists(id:String):Boolean {
			if (!initd) return false;
			if (getIntrObjIndexByID(id) < 0) return false;
			return true;
		}
		
		public function getIntrObjByID(id:String):InteractionObject {
			for (var i:int = 0; i < _QuestionList.length; i++) {
				if (_QuestionList[i].id == id) return _QuestionList[i];
			}
			return null;
		}
		
		public function getIntrObjIndexByID(id:String):int {
			for (var i:int = 0; i < _QuestionList.length; i++) {
				if (_QuestionList[i].id == id) return i;
			}
			return -1;
		}
		
		public function parseSavedStateStr(s:String):void {
			if (!initd) initialize();
			if (s == "null") return;
			return;
		}
		
		public function getSavedStateStr():String {
			if (!initd) return "null";
			return "null";
		}
		
	}
}

class SingletonEnforcer {}