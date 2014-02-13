package ramen.page {
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import ramen.common.Settings;
	import ramen.common.AssessmentManager;
	import com.nudoru.lms.InteractionResult;
	import com.nudoru.lms.InteractionObject;
	import com.nudoru.lms.InteractionType;
	import com.nudoru.lms.SCORMDataTypes;
	import com.nudoru.utils.TimeKeeper;
	
	public class Question extends Sprite {
		
		// vars
		private var _State						:int;
		private var _Running					:Boolean; // should this be a state?
		private var _QuestionData				:XML;
		private var _Choices					:Array;
		private var _Matches					:Array;
		private var _CurrentTry					:int;
		private var _RefMovieClip				:MovieClip;
		
		private var _LatencyTimer				:TimeKeeper;
		
		public static const LETTER_LIST			:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
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
		
		// getters/setters
		public function get state():int { return _State }
		public function set state(s:int) {
			if (_State == s) return;
			trace("question state to: " + s);
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
		
		// get question info from the XML
		public function get id():String { return _QuestionData.@id }
		public function get type():String { return _QuestionData.@type }
		public function get subtype():String { return _QuestionData.@subtype }
		public function get prompt():String { return _QuestionData.prompt }
		public function get instruction():String { return _QuestionData.instruction }
		public function get scenarioTitle():String { return _QuestionData.scenario.title; }
		public function get scenarioText():String { return _QuestionData.scenario.text; }
		public function get showScenarioButton():Boolean {  return (_QuestionData.scenario.@button == "true"); }
		public function get feedbackLabel():String { return _QuestionData.feedbacklabel }
		public function get numTries():int { 
			if (_QuestionData.settings.tries) return _QuestionData.settings.tries;
				else return Settings.getInstance().interactionNumberOfTries;
		}
		public function get randomizeChoices():Boolean { 
			if ( _QuestionData.settings.randomizechoices == "true" ||  _QuestionData.settings.randomizechoices == "yes") return true;
			return false
		}
		public function get randomizeMatches():Boolean { 
			if ( _QuestionData.settings.randomizematches == "true" ||  _QuestionData.settings.randomizematches == "yes") return true;
			return false
		}
		public function get allowIncorrectMatches():Boolean { 
			if ( _QuestionData.settings.allowincorrectmatches == "true" ||  _QuestionData.settings.allowincorrectmatches == "yes") return true;
			return false
		}
		public function get resetOnWA():Boolean { 
			if ( _QuestionData.settings.resetonwa == "true" ||  _QuestionData.settings.resetonwa == "yes") return true;
			return false
		}
		 public function get retainCAsOnReset():Boolean { 
			if ( _QuestionData.settings.resetonwa.@retainca == "true" ||  _QuestionData.settings.resetonwa.@retainca == "yes") return true;
			return false
		}
		public function get showAnswers():Boolean { 
			if ( _QuestionData.settings.showanswers == "true" ||  _QuestionData.settings.showanswers == "yes") return true;
			return false
		}
		public function get autoSizeParts():Boolean { 
			if ( _QuestionData.settings.autosizeparts == "true" ||  _QuestionData.settings.autosizeparts == "yes") return true;
			return false
		}
		public function get questionX():int { return int(String(_QuestionData.settings.position).split(",")[0]) }
		public function get questionY():int { return int(String(_QuestionData.settings.position).split(",")[1]) }
		public function get questionWidth():int { return int(String(_QuestionData.settings.size).split(",")[0]) }
		public function get questionHeight():int { return int(String(_QuestionData.settings.size).split(",")[1]) }
		
		public function get choiceColumnLabel():String { return _QuestionData.choicecolumnlabel }
		public function get choiceColumnX():int { return int(String(_QuestionData.settings.choiceposition).split(",")[0]) }
		public function get choiceColumnY():int { return int(String(_QuestionData.settings.choiceposition).split(",")[1]) }
		public function get choiceColumnSpacingX():int { return int(String(_QuestionData.settings.choicespacing).split(",")[0]) }
		public function get choiceColumnSpacingY():int { return int(String(_QuestionData.settings.choicespacing).split(",")[1]) }
		public function get choiceColumnWidth():int { return int(String(_QuestionData.settings.choicesize).split(",")[0]) }
		public function get choiceColumnHeight():int { return int(String(_QuestionData.settings.choicesize).split(",")[1]) }
		
		public function get matchColumnLabel():String { return _QuestionData.matchcolumnlabel }
		public function get matchColumnX():int { return int(String(_QuestionData.settings.matchposition).split(",")[0]) }
		public function get matchColumnY():int { return int(String(_QuestionData.settings.matchposition).split(",")[1]) }
		public function get matchColumnSpacingX():int { return int(String(_QuestionData.settings.matchspacing).split(",")[0]) }
		public function get matchColumnSpacingY():int { return int(String(_QuestionData.settings.matchspacing).split(",")[1]) }
		public function get matchColumnWidth():int { return int(String(_QuestionData.settings.matchsize).split(",")[0]) }
		public function get matchColumnHeight():int { return int(String(_QuestionData.settings.matchsize).split(",")[1]) }
		
		public function get numMatches():int { return _Matches.length; }
		public function get caaction():String { return _QuestionData.settings.caaction }
		public function get waaction():String { return _QuestionData.settings.waaction }
		public function get feedbacktype():String { return _QuestionData.settings.feedbacktype }
		public function get numChoices():int { return _QuestionData.choice.length() }
		public function get numWA():int { return _QuestionData.wafeedback.length() }
		public function get ca():String { return _QuestionData.cafeedback }
		public function get wa1():String { return getWAIndex(0) }
		public function get wa2():String { return getWAIndex(1) }
		
		public function get label1():String { return _QuestionData.label[0]; }
		public function get label2():String { return _QuestionData.label[1]; }
		public function get label3():String { return _QuestionData.label[2]; }
		public function get label4():String { return _QuestionData.label[3]; }
		
		public function get refMC():MovieClip { return _RefMovieClip }
		public function set refMC(m:MovieClip):void { _RefMovieClip = m }
		
		public function get selectionData():Array {
			if (_QuestionData.selection.choice.length() < 1) return [];
			var a:Array = new Array();
			for (var i:int = 0; i < _QuestionData.selection.choice.length(); i++) {
				a.push( { data:_QuestionData.selection.choice[i].@data, label: _QuestionData.selection.choice[i], selected:(_QuestionData.selection.choice[i].@default=="true" ? true:false) } );
			}
			return a;
		}
		
		public function Question(x:XML):void {
			_QuestionData = x;
			//trace("new question " + x.@id);
			state = STATE_NOT_SELECTED;
			parseXML();
			_CurrentTry = 0;
			_LatencyTimer = new TimeKeeper("latency_" + id + "_timer");
			_Running = false;
		}
		
		public function start():void {
			trace("$$$ question START");
			_Running = true;
			_LatencyTimer.start();
		}
		
		public function stop():void {
			if (!_Running) return;
			trace("$$$ question STOP");
			_Running = false;
			_LatencyTimer.stop();
			if(Settings.getInstance().interactionUseIObj && answered) submitQuestionToAssmntMgr();
		}
		
		private function parseXML():void {
			_Choices = new Array();
			_Matches = new Array();
			var clen:int = _QuestionData.choice.length();
			for (var i:int = 0; i < clen; i++) {
				_Choices.push(new Choice(_QuestionData.choice[i]));
			}
			var mlen:int = _QuestionData.match.length();
			for (var k:int = 0; k < mlen; k++) {
				_Matches.push(addNewMatch(_QuestionData.match[k]));
			}
		}
		
		private function addNewMatch(d:XML):Object {
			var m:Object = new Object();
			m.id = d.@id;
			m.text = d;
			m.mcref = undefined;
			m.matches = new Array();
			return m;
		}
		
		public function getWAIndex(i:int):String {
			return _QuestionData.wafeedback[i];
		}
		
		public function nextTry():Boolean {
			if (Settings.getInstance().interactionForceCA) {
				_CurrentTry++;
				return true;
			}
			if (++_CurrentTry < numTries) return true;
			return false;
		}
		
		public function getLetterIndex(l:String):int {
			for (var i:int = 0; i < LETTER_LIST.length; i++) {
				if (LETTER_LIST[i] == l) return i;
			}
			return 0;
		}
		
		public function getChoiceIndexFromMC(m:MovieClip):int {
			for (var i:int = 0; i < numChoices; i++) {
				if (_Choices[i].refMC == m) return i;
			}
			return -1;
		}
	
		// matches
		public function getMatchText(m:int):String { return _Matches[m].text; }
		public function getMatchID(m:int):String { return _Matches[m].id; }
		public function setMatchMCRef(m:int, mc:MovieClip):void { _Matches[m].mcref = mc; }
		public function getMatchMCRef(m:int):MovieClip { return _Matches[m].mcref; }
		public function getMatchMCRefByID(m:String):MovieClip { 
			for (var i:int = 0; i < numMatches; i++) {
				if (m == _Matches[i].id) return _Matches[i].mcref;
			}
			return undefined;
		}
		public function getMatchMCRefForChoice(c:int):MovieClip {
			return getMatchMCRefByID(getChoiceMatch(c));
		}
		public function getMatchIndexByID(m:String):int { 
			for (var i:int = 0; i < numMatches; i++) {
				if (m == _Matches[i].id) return i;
			}
			return undefined;
		}
		public function getMatchIndexForChoice(c:int):int {
			return getMatchIndexByID(getChoiceMatch(c));
		}
		public function addItemToMatch(m:int, i:*):void {
			if (getMatchedItemIndex(m, i) >= 0) return;
			_Matches[m].matches.push(i);
		}
		
		public function getMatchItems(m:int):Array { return _Matches[m].matches; }
		
		public function removeItemFromMatch(m:int, i:*):void {
			var idx:int = getMatchedItemIndex(m, i);
			if (idx < 0) return;
			_Matches[m].matches.splice(idx, 1);
		}
		
		public function removeItemFromAllMatches(itm:*):void {
			for (var i:int = 0; i < _Matches.length; i++) {
				removeItemFromMatch(i, itm);
			}
		}
		
		private function getMatchedItemIndex(m:int, itm:*):int {
			for (var i:int = 0; i < _Matches[m].matches.length; i++) {
				if (itm == _Matches[m].matches[i]) return i;
			}
			return -1;
		}
		
		public function hasScenario():Boolean {
			if (scenarioText.length) return true;
			return false;
		}
		
		public function getDataForSelectionLabel(l:String):String {
			var d:Array = selectionData;
			for (var i:int = 0; i < d.length; i++) {
				if (d[i].label == l) return d.data;
			}
			return "";
		}
		
		public function getSelectionIndexByData(d:String):int {
			var sd:Array = selectionData;
			for (var i:int = 0; i < sd.length; i++) {
				if (sd[i].data == d) return i;
			}
			return -1;
		}
		
		// choice getter/setters
		public function getChoiceID(c:int):String { return _Choices[c].id }
		public function getChoiceType(c:int):String { return _Choices[c].type }
		public function getChoiceSubType(c:int):String { return _Choices[c].subtype }
		
		public function getChoiceText(c:int):String { return _Choices[c].text }
		public function getChoiceLabel(c:int):String { return _Choices[c].label }
		public function getChoiceMatch(c:int):String { return _Choices[c].match }
		public function getChoiceCAAction(c:int):String { return _Choices[c].caaction }
		public function getChoiceWAAction(c:int):String { return _Choices[c].waaction }
		public function getChoiceNumWA(c:int):int { return _Choices[c].numWA }
		public function getChoiceCA(c:int):String { return _Choices[c].ca }
		public function getChoiceWA1(c:int):String { return _Choices[c].wa }
		public function getChoiceWA2(c:int):String { return _Choices[c].wa2 }
		
		public function getChoiceX(c:int):int { return _Choices[c].choiceX }
		public function getChoiceY(c:int):int { return _Choices[c].choiceY }
		public function getChoiceWidth(c:int):int { return _Choices[c].choiceWidth }
		public function getChoiceHeight(c:int):int { return _Choices[c].choiceHeight }
		public function getChoiceMatchX(c:int):int { return _Choices[c].choiceMatchX }
		public function getChoiceMatchY(c:int):int { return _Choices[c].choiceMatchY }
		public function getChoiceMatchWidth(c:int):int { return _Choices[c].choiceMatchWidth }
		public function getChoiceMatchHeight(c:int):int { return _Choices[c].choiceMatchHeight }
		
		public function getChoiceImageURL(c:int):String { return _Choices[c].imageURL; }
		public function getChoiceImageX(c:int):int { return _Choices[c].imageX; }
		public function getChoiceImageY(c:int):int { return _Choices[c].imageY; }
		public function getChoiceImageWidth(c:int):int { return _Choices[c].imageWidth; }
		public function getChoiceImageHeight(c:int):int { return _Choices[c].imageHeight; }
		
		public function getChoiceCurrentSetMatch(c:int):int { return _Choices[c].currentSetMatch }
		public function setChoiceCurrentSetMatch(c:int, m:int) { _Choices[c].currentSetMatch = m }
		public function getChoiceRefMC(c:int):MovieClip { return _Choices[c].refMC }
		public function setChoiceRefMC(c:int, m:MovieClip):void { _Choices[c].refMC = m }
		public function getMatchRefMC(c:int):MovieClip { return _Choices[c].refMatchMC }
		public function setMatchRefMC(c:int, m:MovieClip):void { _Choices[c].refMatchMC = m }
		
		public function getChoiceIsSelected(c:int):Boolean { return _Choices[c].selected }
		public function setChoiceIsSelected(c:int):void { _Choices[c].selected = true }
		public function setChoiceNotSelected(c:int):void { _Choices[c].selected = false }
		public function selectAllChoices():void {
			for (var i:int = 0; i < _Choices.length; i++) {
				_Choices[i].selected = true;
			}
		}
		public function deselectAllChoices():void {
			for (var i:int = 0; i < _Choices.length; i++) {
				_Choices[i].selected = false;
			}
		}
		public function anyChoicesSelected():Boolean {
			for (var i:int = 0; i < _Choices.length; i++) {
				if(_Choices[i].selected) return true;
			}
			return false;
		}
		public function allChoicesSelected():Boolean {
			for (var i:int = 0; i < _Choices.length; i++) {
				if(!_Choices[i].selected) return false;
			}
			return true;
		}
		
		public function getCorrectSelectionIdxForChoice(c:int):int {
			trace("choice " + c +" = " + _Choices[c].match + " which is " + getSelectionIndexByData(_Choices[c].match));
			return getSelectionIndexByData(_Choices[c].match);
		}
		
		public function getChoiceCorrect(c:int):Boolean { return _Choices[c].correct }
		
		// TODO expand this so that it supports all types, currently supports only MC
		public function getChoiceIsCorrect(c:int):Boolean { 
			if (type == InteractionType.CHOICE) {
				if (subtype == RamenInteractionType.MC_COLUMNS) {
					if (getChoiceCurrentSetMatch(c) == getMatchIndexByID(_Choices[c].match)) return true;
					return false;
				}
				return _Choices[c].isCorrect;
			} if (type == RamenInteractionType.SELECTION ) {
				// the match on the choice should match the data of the selection element
				if (getChoiceCurrentSetMatch(c) == getSelectionIndexByData(_Choices[c].match)) return true;
				return false;
			} else {
				trace("getChoiceIsCorrect doesn't support type: " + type);
				return false;
			}
		}

		public function getNumCorrectChoices():int {
			var len:int = numChoices;
			var cntr:int = 0;
			for (var i:int = 0; i < len; i++) {
				if (_Choices[i].correct) cntr++;
			}
			return cntr;
		}
		
		public function getFirstCorrectChoice():int {
			var len:int = numChoices;
			var c:int = -1;
			for (var i:int = 0; i < len; i++) {
				if (_Choices[i].correct) {
					c = i;
					break;
				}
			}
			return c;
		}

		public function getFirstSelectedChoice():int {
			var len:int = numChoices;
			var c:int = -1;
			for (var i:int = 0; i < len; i++) {
				if (_Choices[i].selected) {
					c = i;
					break;
				}
			}
			return c;
		}
		
		// judging
		public function isCorrect():Boolean {
			switch (type) {
				case InteractionType.CHOICE:
					if(subtype == RamenInteractionType.MC_COLUMNS) return isQuestionMCCorrect();
					return isQuestionMCCorrect();
					break;
				case InteractionType.MATCHING:
					return isQuestionMatchingCorrerct();
					break;
				case RamenInteractionType.SELECTION:
					return isQuestionMCCorrect();
					break;
				default:
				trace("Question.isCorrect can't judge question type: " + type);
					return false;
			}
		}
		
		//------------------------------------------------------------------------------------------------------------------
		// mc
		
		private function isQuestionMCCorrect():Boolean {
			var len:int = numChoices;
			for (var i:int = 0; i < len; i++) {
				if (!getChoiceIsCorrect(i)) return false;
			}
			return true;
		}
		
		//------------------------------------------------------------------------------------------------------------------
		// matching
		
		public function isChoiceOnMatch(c:int):Boolean {
			return _Choices[c].isOnMatch();
		}
		
		public function isChoiceOnMatchPoint(c:int, p:Point):Boolean {
			return _Choices[c].isOnMatchPoint(p);
		}
		
		public function getMatchUnderChoiceRefMC(c:int):MatchItem {
			// is it correct?
			if (isChoiceOnMatch(c)) return _Choices[c].refMatchMC;
			// whatever is under it
			for (var i:int = 0; i < _Choices.length; i++) {
				var err:Boolean = false;
				try {
					err = _Choices[c].refMC.bg_mc.hitTestObject(_Choices[i].refMatchMC.bg_mc);
				} catch(e:*) {}
				if (err) return _Choices[i].refMatchMC;
			}
			return null;
		}
		
		public function getMatchUnderPoint(p:Point):MatchItem {
			// whatever is under it
			for (var i:int = 0; i < _Choices.length; i++) {
				var err:Boolean = false;
				try {
					err = _Choices[i].refMatchMC.bg_mc.hitTestPoint(p.x, p.y);
				} catch (e:*) { }
				//trace( _Choices[i].refMatchMC.bg_mc+" by "+p+" is "+err);
				if (err) return _Choices[i].refMatchMC;
			}
			return null;
		}
		
		public function doesChoiceHitMatch(c:int, mi:MovieClip):Boolean {
			var err:Boolean = false;
			try {
				err = _Choices[c].refMC.bg_mc.hitTestObject(mi.bg_mc);
			} catch(e:*) {}
			return err;
		}
		
		private function isQuestionMatchingCorrerct():Boolean {
			var len:int = numChoices;
			for (var i:int = 0; i < len; i++) {
				if (!isChoiceOnMatch(i)) return false;
			}
			return true;
		}
		
		//------------------------------------------------------------------------------------------------------------------
		// feedback
		
		// TODO adapt for other types
		public function getCA():String {
			var retVal:String = ca;
			if (getNumCorrectChoices() == 1) {
				var selC:int = getFirstSelectedChoice();
				if (selC > -1) {
					// does the selected choice have a ca?
					if (_Choices[selC].ca.length) retVal = _Choices[selC].ca;
				}
			}
			return retVal;
		}
		
		// TODO adapt for other types
		public function getWA():String {
			var retVal:String = wa1;
			var waIdx:int = _CurrentTry - 1;	// the current try is 1 higher than we want since it's already been incrimented
			if (waIdx < numWA) retVal = getWAIndex(waIdx);
			if (getNumCorrectChoices() == 1) {
				var selC:int = getFirstSelectedChoice();
				if (selC > -1) {
					// does the selected choice have a wa?
					if (waIdx < _Choices[selC].numWA) retVal = _Choices[selC].getWAIndex(waIdx);
				}
			}
			return retVal;
		}
		
		
		// utility
		public function getChoiceIndexesArray():Array {
			var a:Array = new Array();
			for (var i:int = 0; i < _Choices.length; i++) {
				a.push(i);
			}
			return a;
		}
		
		public function getMatchIndexesArray():Array {
			var a:Array = new Array();
			for (var i:int = 0; i < _Matches.length; i++) {
				a.push(i);
			}
			return a;
		}
		
		// from Juan Pablo Califano <califa010.flashcoders@gmail.com>, Flash Tiger list
		private function randomizeArray(array:Array):void {
			array.sort(function(a:Object,b:Object):Number {
				return Math.round(Math.random()*2) - 1;
			});
		}
		
		// from Steven Sacks <flashdev@stevensacks.net>, Flash Tiger list
		private function randomizeArray2(array:Array):Array {
			var i:int = array.length;
			var n:int = i - 1;
			while (--i)
			{
				var r:int = Math.random() * n;
				var item:Object = array[i];
				array[i] = array[r];
				array[r] = item;
			}
			return array;
		}
		
		public function getRandomizedChoiceIndexesArray():Array {
			return randomizeArray2(getChoiceIndexesArray());
		}
		
		//------------------------------------------------------------------------------------------------------
		// Assessment manager interfacing
		
		// should this functionality be here or in the template?
		public function submitQuestionToAssmntMgr():void {
			AssessmentManager.getInstance().submitQuestion(createInteractionObject());
		}
		
		public function hasQuestionBeenSubmittedToAssmntMgr():Boolean {
			if (!Settings.getInstance().interactionUseIObj) return false;
			return AssessmentManager.getInstance().questionExists(id);
		}
		
		/*
		public function set prompt(value:String):void {_Prompt = value;}
		public function set id(value:String):void {_ID = value;}
		public function set type(value:String):void {_Type = value;}
		public function set objectives(value:Array):void {_Objectives = value;}
		public function set timeStamp(value:String):void {_TimeStamp = value;}	
		public function set correctResponses(value:Array):void {_CorrectResponses = value;}
		public function set weighting(value:int):void {_Weighting = value;}
		public function set learnerResponse(value:String):void {_LearnerResponse = value;}
		public function set result(value:String):void {_Result = value;}
		public function set latency(value:String):void {_Latency = value;}
		public function set description(value:String):void {_Description = value;}
		*/
		
		public function createInteractionObject():InteractionObject {
			var iObj:InteractionObject = new InteractionObject();
			iObj.prompt = prompt;
			iObj.id = id;
			iObj.type = type;
			iObj.objectives = [];
			

			// refer to RTE 4.2.9.1
			var corrResp:Array = new Array;
			// refer to RTE 4.2.9.2
			var lrnrResp:String = "";
			switch(type) {
				case InteractionType.CHOICE:
					corrResp = getCorrectResponsePatternForChoice();
					lrnrResp = getLearnerResponsePatternForChoice();
					break;
				case InteractionType.MATCHING:
					corrResp = getCorrectResponsePatternForMatching();
					lrnrResp = getLearnerResponsePatternForMatching();
					break;
				default:
					trace("$$$ Can't get response patterns for type: " + type);
			}
			iObj.correctResponses = corrResp;
			iObj.learnerResponse = lrnrResp;
			
			if (isCorrect()) iObj.result = InteractionResult.CORRECT;
				else iObj.result = InteractionResult.INCORRECT;

			var t:Array = _LatencyTimer.elapsedTimeFormattedHHMMSS().split(":");
			iObj.latency = SCORMDataTypes.toTimeIntervalSecond10(int(t[0]), int(t[1]), int(t[2]));
			iObj.weighting = 1;
			iObj.description = "";
			
			iObj.traceProps();
			return iObj;
		}
		
		// will only have 1 possible correct pattern	
		// to be standard, must use text of choice not index
		private function getCorrectResponsePatternForChoice():Array {
			var c:Array = new Array();
			var t:String = "";
			for (var i:int = 0; i < _Choices.length; i++) {
				if (_Choices[i].correct) {
					t += String(i);
					if (i < _Choices.length - 2) t += ",";
				}
			}
			c.push(t);
			return c;
		}
		
		// to be standard, must use text of choice not index
		private function getLearnerResponsePatternForChoice():String {
			var t:String = "";
			for (var i:int = 0; i < _Choices.length; i++) {
				if (_Choices[i].selected) {
					t += String(i);
					t += ",";
				}
			}
			//trim the comma
			t = t.substr(0, t.length - 1);
			return t;
		}
		
		// will only have 1 possible correct pattern	
		// to be standard, must use text of choice not index
		private function getCorrectResponsePatternForMatching():Array {
			var c:Array = new Array();
			var t:String = "";
			for (var i:int = 0; i < _Choices.length; i++) {
				if (subtype == RamenInteractionType.DND_SORTING) {
					t += String(i+1)+"[.]"+LETTER_LIST[getMatchIndexForChoice(i)];
				} else {
					t += String(i+1)+"[.]"+LETTER_LIST[i];
				}
				if (i < _Choices.length - 1) t += "[,]";
			}
			c.push(t);
			return c;
		}
		
		// to be standard, must use text of choice not index
		private function getLearnerResponsePatternForMatching():String {
			var t:String = "";
			for (var i:int = 0; i < _Choices.length; i++) {
				if (subtype == RamenInteractionType.DND_SORTING) {
					t += String(i + 1) + "[.]" + LETTER_LIST[_Choices[i].currentSetMatch];
				} else {
					t += String(i + 1) + "[.]" + LETTER_LIST[_Choices[i].currentSetMatch];
				}
				if (i < _Choices.length - 1) t += "[,]";
			}
			return t;
		}
		
		public function getInteractionObject():InteractionObject {
			return AssessmentManager.getInstance().getIntrObjByID(id);
		}
		
		public function resetToIntObjState():void {
			var iObj:InteractionObject = AssessmentManager.getInstance().getIntrObjByID(id);
			trace("ret");
			iObj.traceProps();
		}
		
	}
	
}