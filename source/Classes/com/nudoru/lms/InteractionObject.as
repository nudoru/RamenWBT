//SCORM 2004 interaction data model, RTE-4-49

package com.nudoru.lms {

	public class InteractionObject {
		
		private var _Prompt					:String;		// this isn't part of the DM but may be useful
		private var _ID						:String;
		private var _Type					:String;
		private var _Objectives				:Array;		// not fully supported
		private var _TimeStamp				:String;
		private var _CorrectResponses		:Array;
		private var _Weighting				:int;
		private var _LearnerResponse		:String;
		private var _Result					:String;
		private var _Latency				:String;
		private var _Description			:String;
		
		public function get prompt():String { return _Prompt; }
		public function set prompt(value:String):void {_Prompt = value;}
		public function get id():String { return _ID; }
		public function set id(value:String):void {_ID = value;}
		public function get type():String { return _Type; }
		public function set type(value:String):void {_Type = value;}
		public function get objectives():Array { return _Objectives; }
		public function set objectives(value:Array):void {_Objectives = value;}
		public function get timeStamp():String { return _TimeStamp; }
		public function set timeStamp(value:String):void {_TimeStamp = value;}	
		public function get correctResponses():Array { return _CorrectResponses; }
		public function set correctResponses(value:Array):void {_CorrectResponses = value;}
		public function get weighting():int { return _Weighting; }
		public function set weighting(value:int):void {_Weighting = value;}
		public function get learnerResponse():String { return _LearnerResponse; }
		public function set learnerResponse(value:String):void {_LearnerResponse = value;}
		public function get result():String { return _Result; }
		public function set result(value:String):void {_Result = value;}
		public function get latency():String { return _Latency; }
		public function set latency(value:String):void {_Latency = value;}
		public function get description():String { return _Description; }
		public function set description(value:String):void {_Description = value;}
		
		public function InteractionObject():void {
			_Objectives = new Array();
			_CorrectResponses = new Array();
			setTimeStamp();
		}

		// see RTE 4.2.9.1, pp RTE-4-68
		public function addCorrectRepsonse(p:String):void {
			var o:Object = new Object();
			o.pattern = p;
			_CorrectResponses.push(p);
		}
		
		// time(second,10,0) format, rte-4-16
		// ex: 2009-03-23T16:34:22
		public function setTimeStamp():void {
			timeStamp = SCORMDataTypes.getTimeSecond10();
		}
		
		public function traceProps():void {
			var t:String = "$$$ InteractionObject\n";
			t += "      type: "+type+"\n";
			t += "      id: "+id+"\n";
			//t += "      timestamp: "+timeStamp+"\n";
			t += "      result: "+result+"\n";
			//t += "      weighting: "+weighting+"\n";
			t += "      latency: "+latency+"\n";
			t += "      prompt: "+prompt+"\n";
			t += "      correct resp: "+correctResponses+"\n";
			t += "      learner resp: "+learnerResponse+"\n";
			//t += "      objectives: "+objectives+"\n";
			//t += "      desc.: "+description;
			trace(t);
		}
	}
	
}