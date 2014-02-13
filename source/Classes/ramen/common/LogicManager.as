package ramen.common {
	
	import ramen.common.*;
	import ramen.player.*;
	import com.nudoru.lms.LMSConnector;
	
	import flash.display.Sprite;
	
	public class LogicManager extends Sprite {
		
		static private var _Instance	:LogicManager;
		
		private var _Initd				:Boolean;
		private var _History			:Array;
		private var _Variables			:Array;
		private var _Delimeter			:String = "^^";
		
		// conditionals
		private var IS_EQUAL			:String = "equal";
		private var IS_NOT_EQUAL		:String = "not_equal";
		private var IS_GREATER			:String = "greater";
		private var IS_LESS				:String = "less";
		private var IS_GREATER_OR_EQUAL	:String = "greater_or_equal";
		private var IS_LESS_OR_EQUAL	:String = "less_or_equal";
		
		// types
		private var TYP_STRING			:String = "typ_string";
		private var TYP_BOOLEAN			:String = "typ_boolean";
		private var TYP_NUMBER			:String = "typ_number";
		
		public function get initd():Boolean { return _Initd; }
		public function set initd(value:Boolean):void { _Initd = value; }
		
		// predefined variables
		public function get courseVarCurrentScore():int { return SiteModel.getInstance().currentScore; }
		public function get courseVarIsPassing():Boolean { return SiteModel.getInstance().isPassing(); }
		public function get courseVarIsComplete():Boolean { return SiteModel.getInstance().isComplete(); }
		public function get courseVarAllPagesViewed():Boolean { return SiteModel.getInstance().allNodesViewed(); }
		
		public function get lmsVarStudentName():String {
			var n:String = LMSConnector.getInstance().studentName;
			if (n.indexOf(",")) return n.split(",")[1] + " " + n.split(",")[0];
				else return n;
		}
		public function get lmsVarStudentID():String { return LMSConnector.getInstance().studentID };
		
		public function LogicManager(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():LogicManager {
			if (LogicManager._Instance == null) {
				LogicManager._Instance = new LogicManager(new SingletonEnforcer());
			}
			return LogicManager._Instance;
		}
		
		public function initialize():void {
			_Variables = new Array();
			_History = new Array();
			initd = true;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// resume
		
		public function parseSavedStateStr(s:String):void {
			if (!initd) initialize();
			if (s == "null") return;
			return;
		}
		
		public function getSavedStateStr():String {
			if (!initd) return "null";
			return "null";
		}
		
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// evaluation
		
		/*
		 
		<logic id="id">
			<if>
				<var>name</var>
				<is>equal | greater[_or_equal] | less[_or_equal] | not</is>
				<then>
					<action>goto</action>
					<target>page</target>
					<data>whereid</data>
				</then>
			</if>
			<set>
				<variable>variable name</variable>
				<value>value</value>
			</set>
		</logic>
		*/
		public function evaluate(d:XMLList):void {
			//trace("evaluating: " + d);
			if (d.@id && d.@maxoccur) {
				addLogicEntry(d);
			}
			var list:XMLList = d.children()
			var len:int = list.length();
			for (var i:int = 0; i < len; i++) {
				switch (String(list[i].name())) {
					case "if":
						handleIf(list[i],d.@id);
						break;
					case "set":
						handleSet(list[i],d.@id);
						break;
					case "do":
						handleDo(XMLList(list[i]),d.@id);
						break;
					default:
						trace("logic eval type not found: " +list[i].name());
				}
			}
		}
		
		/*<if>
				<variable>name</variable>
				<compare>equal | greater[_or_equal] | less[_or_equal] | not</compare>
				<to>compare</to>
				<then>
					<action>goto</action>
					<target>page</target>
					<data>whereid</data>
				</then>
			</if>*/
		private function handleIf(d:XML,id:String=""):Boolean {
			//trace("handle if: " + d);
			var v1:String = d.variable;
			var av1:String = getVariableValue(v1);
			var comp:String = d.compare;
			var v2:String = d.to;
			var result:Boolean = doCompare(av1, v2, comp);
			//trace(v1 +" [" + av1 + "] " + comp + " " + v2);
			//trace("result: " + result);
			if (result) {
				if (id) {
					if (updateLogicEntryRun(id)) {
						//trace(id + " is over the count!");
						return false;
					} else {
						handleDo(d.then);
					}
				} else {
					handleDo(d.then);
				}
			}
			return result;
		}
		
		private function handleDo(d:XMLList,id:String=""):void {
			//trace("doing: " + d);
			if (id.length) {
				if (updateLogicEntryRun(id)) {
					trace(id + " is over the count!");
					return;
				}
			} 
			var a:String = d.action;
			var t:String = d.target;
			var d:XMLList = d.data;
			switch(a) {
				case "goto":
					jumpToPageID(t);
					break;
				case "alert":
					message(d.title, d.content);
					break;
				case "popup":
					dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, XML(String(d.popup))));
					break;
				default:
					trace("Unrecognized action: "+a);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// IF comparison
		
		private function isNumber(n:String):Boolean {
			return isNaN(Number(n));
		}
		
		private function isBool(n:String):Boolean {
			if (n == "true" || n == "false") return true;
			return false;
		}
		
		private function isString(n:String):Boolean {
			if (isBool(n) || isNumber(n)) return false;
			return true;
		}
		
		// only valid comparisons for string and bool are equal and not equal
		private function isNaNCompareType(c:String):Boolean {
			if (c == IS_GREATER || c == IS_NOT_EQUAL) return true;
			return false;
		}
		
		private function isValidComparrison(a1:String, a2:String, c:String):Boolean {
			// strings and string compare
			if (isString(a1) && isString(a2) && isNaNCompareType(c)) return true;
			// boolean and boolean compare
			if (isBool(a1) && isBool(a2) && isNaNCompareType(c)) return true;
			// number and any compare
			if (isNumber(a1) && isNumber(a2)) return true;
			return false;
		}
		
		private function doCompare(a1:String, a2:String, c:String):Boolean {
			if (!isValidComparrison(a1, a2, c)) return false;
			if (isString(a1)) return compareStings(a1, a2, c);
			if (isBool(a1)) return compareBool(a1, a2, c);
			if (isNumber(a1)) return compareNumber(a1, a2, c);
			return false;
		}
		
		private function compareStings(a1:String, a2:String, c:String):Boolean {
			if (c == IS_EQUAL) {
				return (a1 == a2);
			} else if (c == IS_NOT_EQUAL) {
				return (a1 != a2);
			}
			return false;
		}
		
		// can treat bools and strings
		private function compareBool(a1:String, a2:String, c:String):Boolean {
			if (c == IS_EQUAL) {
				return (a1 == a2);
			} else if (c == IS_NOT_EQUAL) {
				return (a1 != a2);
			}
			return false;
		}
		
		private function compareNumber(a1:String, a2:String, c:String):Boolean {
			var n1:Number = Number(a1);
			var n2:Number = Number(a2);
			if (c == IS_EQUAL) {
				return (n1 == n2);
			} else if (c == IS_NOT_EQUAL) {
				return (n1 != n2);
			} else if (c == IS_GREATER) {
				return (n1 > n2);
			} else if (c == IS_GREATER_OR_EQUAL) {
				return (n1 >= n2);
			} else if (c == IS_LESS) {
				return (n1 < n2);
			} else if (c == IS_LESS_OR_EQUAL) {
				return (n1 <= n2);
			}
			return false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// vars
		
		/*<set>
				<variable>variable name</variable>
				<val>value</val>
			</set>*/
		private function handleSet(d:XML,id:String=""):void {
			if (id.length) {
				if (updateLogicEntryRun(id)) {
					//trace(id + " is over the count!");
					return;
				}
			} 
			//trace("handle set: " + d);
			var n:String = d.variable;
			var v:String = d.val;
			var p:Boolean = String(d.@persist).indexOf("true") == 0;
			var idx:int = getVariableIndex(n);
			if (idx >= 0) {
				updateVariableValue(n, v);
			} else {
				addVariable(n, v, p);
			}
		}
		
		private function addVariable(n:String, v:String, p:Boolean = false):void {
			var o:Object = new Object();
			o.name = n;
			o.val = v;
			o.persistant = p;
			o.type = "undefined";
			if (isNumber(v)) o.type = "number";
				else if (isBool(v)) o.type = "boolean";
				else if (isString(v)) o.type = "string";
			_Variables.push(o);
		}
		
		private function getVariableIndex(n:String):int {
			for (var i:int = 0; i < _Variables.length; i++) {
				if (_Variables[i].name == n) return i;
			}
			return -1;
		}
		
		private function updateVariableValue(n:String, v:String):Boolean {
			var idx:int = getVariableIndex(n);
			if (idx >= 0) {
				_Variables[idx].val = v;
				return true;
			} else {
				addVariable(n, v);
			}
			return false;
		}
		
		public function getVariableValue(n:String):String {
			// this could be called from a page template during development testing.
			// define the array so that the function doesn't error
			if (!_Variables) initialize();
			
			if (n.indexOf("courseVar") == 0) {
				switch(n) {
					case "courseVarCurrentScore":
						return String(courseVarCurrentScore);
						break;
					case "courseVarIsPassing":
						return String(courseVarIsPassing);
						break;
					default:
						trace("unrecognized course var: " + n);
				}
			} if (n.indexOf("lmsVar") == 0) {
				switch(n) {
					case "lmsVarStudentName":
						return lmsVarStudentName;
						break;
					case "lmsVarStudentID":
						return lmsVarStudentID;
						break;
					default:
						trace("unrecognized lms var: " + n);
				}
			} else {
				var idx:int = getVariableIndex(n);
				if (idx >= 0) {
					return _Variables[idx].val;
				}
			}
			return "~undefined~";
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// history
		
		private function addLogicEntry(d:XMLList):void {
			if (getLogicEntryIndex(d.@id) >= 0) return;
			var o:Object = new Object();
			o.id = d.@id;
			o.maxoccur = String(d.@maxoccur).length ? d.@maxoccur : 9999999;
			o.occurcount = 0;
			//trace("adding logic: " + d.@id);
			_History.push(o);
		}
		
		private function getLogicEntryIndex(n:String):int {
			for (var i:int = 0; i < _History.length; i++) {
				if (_History[i].id == n) return i;
			}
			return -1;
		}
		
		private function updateLogicEntryRun(n:String):Boolean {
			var idx:int = getLogicEntryIndex(n);
			if (idx >= 0) {
				_History[idx].occurcount++;
				//trace("updating run: " + _History[idx].id +" to " + _History[idx].occurcount );
				if (_History[idx].occurcount > _History[idx].maxoccur) return true;
					else return false;
			}
			return false;
		}
		
		private function isLogicEntryOverCount(n:String):Boolean {
			var idx:int = getLogicEntryIndex(n);
			if (idx >= 0) {
				if(_History[idx].occurcount > _History[idx].maxoccur) return true;
			}
			return false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// navigation
		
		private function restartPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.REFRESH_CURRENT_PAGE, true, false, "", ""));
		}
		
		private function jumpToPageID(i:String = ""):void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.PAGE_MENU_SELECTION, true, false, "", i));
		}
	
		private function gotoNextPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_NEXT_PAGE, true, false, "", ""));
		}
		
		private function gotoPrevPage():void {
			dispatchEvent(new NavChangeEvent(NavChangeEvent.GOTO_PREVIOUS_PAGE, true, false, "", ""));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// popup
		
		private function message(t:String, m:String, mdl:Boolean=false, pst:Boolean=false):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createPopUpXML(PopUpType.SIMPLE, t, m, "", mdl, pst)));
		}
		
		private function createPopUpXML(typ:String, t:String, m:String, icn:String="", mdl:Boolean=false, pmdl:Boolean=false, pst:Boolean=false):XML {
			var popup:String = "<popup id='' draggable='true'>";
			popup += "<type modal='" + mdl + "' pmodal='" + pmdl + "' persistant='" + pst + "'>" + typ + "</type>";
			popup += "<title>" + t + "</title>";
			popup += "<content><![CDATA[" + m + "]]></content>";
			popup += "<icon>" + icn + "</icon>";
			popup += "<size></size>";
			popup += "<hpos>"+ObjectStatus.PAGE_CENTER+"</hpos>";
			popup += "<vpos>"+ObjectStatus.PAGE_HIGH_MIDDLE+"</vpos>";
			popup += "<buttons>";
			if (typ == PopUpType.ERROR) popup += "<button event='close'>Close</button>";
			popup += "</buttons>";
			popup += "<custom></custom>";
			popup += "</popup>";
			
			var data:XML = new XML(popup);
			return data;
		}
		
	}
	
}

class SingletonEnforcer {}