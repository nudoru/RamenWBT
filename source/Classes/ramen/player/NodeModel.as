package ramen.player {
	
	import ramen.common.*;
	import ramen.player.*;
	
	import com.nudoru.utils.GUID;
	import com.nudoru.utils.TimeKeeper;
	import flash.events.*;
	import flash.net.*;
	import com.nudoru.utils.Debugger;
	import flash.utils.Timer;
	
	public class NodeModel extends EventDispatcher {
		
		private var _Name					:String;
		private var _ID						:String;
		private var _GUID					:String
		private var _NodeType				:String;		// type is the node name
		private var _NodeSubType			:String;		// sub type is the "type" prop on the node tag
		private var _NodeMetaXML			:XMLList;
		private var _NodeConfigXML			:XMLList;
		private var _NodeLogicXML			:XMLList;
		private var _SWFFile				:String;
		private var _XMLFile				:String;
		private var _Scored					:Boolean;
		private var _Mandatory				:Boolean;
		private var _Scrolling				:Boolean;
		private var _Cropping				:Boolean;
		private var _RefreshOnTS			:Boolean;		// refresh on text size change
		private var _Status					:int;
		
		private var _ParentNode				:NodeModel
		
		private var _TOC					:Boolean;
		
		private var _ConfigDefaultPageX			:int;
		private var _ConfigDefaultPageY			:int;
		private var _ConfigDefaultPageWidth		:int;
		private var _ConfigDefaultPageHeight	:int;
		private var _ConfigDefaultPageShowBG	:Boolean;
		private var _ConfigDefaultPageShowMenu	:Boolean;
		
		private var _ConfigPageX			:int;
		private var _ConfigPageY			:int;
		private var _ConfigPageWidth		:int;
		private var _ConfigPageHeight		:int;
		private var _ConfigPageShowBG		:Boolean;
		private var _ConfigPageShowMenu		:Boolean;
		
		private var _MetaDescription		:String;
		private var _MetaKeywords			:Array;
		
		private var _XMLInitData			:XML;
		private var _XMLData				:XML;
		private var _XMLLoader				:URLLoader;
		
		private var _Children				:Array;
		private var _Depth					:int;
	
		private var _GlobalID				:int;
		private var _LocalID				:int;
		
		private var _LatencyTimer			:TimeKeeper;
		
		private static var _ModuleNumberCntr:int = 0;
		private static var _PageNumberCntr	:int = 0;
		
		public static const STATUS_UPDATE	:String = "status_update";
		
		private var _DLog					:Debugger;
		
		public function get name():String { return _Name }
		public function get id():String { return _ID }
		public function get parentid():String { return parentNode.id }
		public function get guid():String { return _GUID }
		public function get nodetype():String { return _NodeType }
		public function get nodesubtype():String { return _NodeSubType }
		public function get swffile():String { return _SWFFile }
		public function get xmlfile():String { return _XMLFile }
		public function get toc():Boolean { return _TOC }
		public function get scored():Boolean { return _Scored }
		public function get mandatory():Boolean { return _Mandatory }
		public function get scrolling():Boolean { return _Scrolling }
		public function get cropping():Boolean { return _Cropping }
		public function get refreshOnTextSzCh():Boolean { return _RefreshOnTS; }
		
		public function get parentNode():NodeModel {
			if(_Depth > 0)
				return _ParentNode;
			else 
				return undefined;
		}
		public function get childNodes():Array { return _Children }
		public function get depth():int { return _Depth }
		public function get globalIdx():int { return _GlobalID }
		public function get localIdx():int {return _LocalID }
		
		public function get status():int { return _Status }
		public function set status(n:int) { 
			if (n != _Status) {
				_DLog.addDebugText("node '"+id+"' status to: " + n);
				_Status = n ;
				updateStatus();
				dispatchEvent(new Event(NodeModel.STATUS_UPDATE));
			}
		}
		public function get numChildren():int { return _Children.length }
		public function get completed():Boolean { 
			if (!_Mandatory) {
				return true;
			}
			return (_Status >= ObjectStatus.COMPLETED)
		}
	
		public function get TOTALPAGES():int { return _PageNumberCntr }
	
		public function get configDefaultPageX():int {return _ConfigDefaultPageX }
		public function get configDefaultPageY():int {return _ConfigDefaultPageY }
		public function get configDefaultPageWidth():int {return _ConfigDefaultPageWidth }
		public function get configDefaultPageHeight():int {return _ConfigDefaultPageHeight }
		public function get configDefaultPageShowBG():Boolean {return _ConfigDefaultPageShowBG }
		public function get configDefaultPageShowMenu():Boolean {return _ConfigDefaultPageShowMenu }
		
		public function get configPageX():int {return _ConfigPageX }
		public function get configPageY():int {return _ConfigPageY }
		public function get configPageWidth():int {return _ConfigPageWidth }
		public function get configPageHeight():int {return _ConfigPageHeight }
		public function get configShowBG():Boolean {return _ConfigPageShowBG }
		public function get configShowMnu():Boolean {return _ConfigPageShowMenu }
		
		public function get latency():String { return _LatencyTimer.elapsedTimeFormattedHHMMSS() }
		
		public function get metaDescription():String { return _MetaDescription }
		public function get metaKeywords():Array { return _MetaKeywords }
		
		public function NodeModel(x:XML, d:int, p:NodeModel=undefined, i:int=-1) {
			_DLog = Debugger.getInstance();
			_Children = new Array();
			_XMLInitData = x;
			if(p) {
				_Depth = d;
				_LocalID = i;
				_ParentNode = p;
			} else {
				_Depth = 0;
				_LocalID = 0;
			}
	
			_Status = ObjectStatus.NOT_ATTEMPTED;
			_LatencyTimer = new TimeKeeper("node_"+_Depth+"_timer");
			parseInitData();
		}
		
		override public function toString():String { return "[NM "+(_NodeType == "module" ? "[M" : "[P") + _GlobalID + "] " + _ID + " ("+localIdx+") ]" }

		public function start():Boolean {
			//trace("-Start Node----------------------");
			//trace(id + " started: " + _Status);
			//updateStatus();
			if(_Status == ObjectStatus.NOT_ATTEMPTED) setIncomplete();
			_LatencyTimer.start();
			peformLogic();
			performParentLogic();
			return true;
		}
		
		public function updateNonMandatoryPages():void {
			//trace("update nonman pages");
			if (!_Mandatory) setComplete();
			for (var i:int = 0; i < _Children.length; i++) {
				_Children[i].updateNonMandatoryPages();
			}
		}
		
		private function peformLogic():void {
			if(_NodeLogicXML.length()) {
				trace("Logic on node: " + id);
				LogicManager.getInstance().evaluate(_NodeLogicXML);
			}
		}
		
		private function performParentLogic():void {
			var nReverseDepth = -1;
			var mParent	= null;
			do {
				mParent	= getParentAt(nReverseDepth);
				if (mParent) {
					mParent.peformLogic();
				} 
				nReverseDepth--;
			} while (Math.abs(nReverseDepth) < (depth + 1));
		}
		
		public function stop():Boolean {
			_LatencyTimer.stop();
			// TODO remmove this here and let the page set it
			//if(_Status == ObjectStatus.NOT_ATTEMPTED) setComplete();
			// better to set this here
			//updateStatus();
			//trace(id+" stopped after: "+latency);
			//trace("-Stop Node----------------------");
			return true;
		}
		
		public function setIncomplete():void { status = ObjectStatus.INCOMPLETE }
		public function setComplete():void { 
			if (_Scored) {
				//
				setPassed();
			} else {
				status = ObjectStatus.COMPLETED;
			}
		}
		public function setPassed():void { status = ObjectStatus.PASSED }
		public function setFailed():void { status = ObjectStatus.FAILED }
		public function setNotAttempted():void { status = ObjectStatus.NOT_ATTEMPTED }
		
		//public function reset():void { setNotAttempted() }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// param getters
		
		public function getParentID(d:int):int { return getParentAt(d).globalIdx }
	
		public function getParentAt(d:int):NodeModel {
			if (depth == 0 && d < 0) return undefined;
			if (d < 0) d = Math.max(0, depth + d);
			//trace("%% getting parent at: " + d);
			
			//if((d == undefined) || (parentNode.depth == d)) {
				if(parentNode.depth == d) {
					return parentNode;
				} else {
					return parentNode.getParentAt(d);
				}
			//}
			return undefined;
		}
		
		public function getChildAt(n:int):NodeModel {	
			if((n >= 0) && (n < numChildren)) return childNodes[n];
			return undefined;
		}
		
		public function getThisNodeStructureStr():String {
			return (_NodeType == "module" ? "[M" : "[P") + ", "+_ID+"] " + _Name + ", status: "+_Status+", scored: "+scored+", mand: "+_Mandatory;
		}
		
		public function getCourseStructureStr():String {
			var t:String = "";
			var spc:String = "";
			for(var d:int=0; d<_Depth; d++) { spc += "  " }
			t += spc + getThisNodeStructureStr()+"\n";
			for (var i:int = 0; i < _Children.length; i++) {
				t += _Children[i].getCourseStructureStr();
			}
			return t;
		}
		
		public function getThisNodeStatusStr():String {
			return _ID + "@" + _Status;
		}
		
		public function getCourseStatusStr():String {
			var t:String = "";
			t += getThisNodeStatusStr();// +",";
			for (var i:int = 0; i < _Children.length; i++) {
				t += ","+_Children[i].getCourseStatusStr();
			}
			return t;
		}
		
		// gets an array for main menu creation
		public function getCourseStructureData(tgta:Array):Array {
			var o:Object = new Object();
			o.depth = _Depth;
			o.type = _NodeType;
			o.name = _Name;
			o.id = _ID;
			o.parentid = parentNode ? parentNode.id : undefined;
			o.toc = _TOC;
			o.status = _Status;
			o.haspages = containsPages();
			o.pagesunder = getChildPageIDList();
			tgta.push(o);
			for(var i:int=0; i<_Children.length; i++) {
				_Children[i].getCourseStructureData(tgta);
			}
			return tgta;
		}
		
		public function containsPages():Boolean {
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "page") return true;
			}
			return false;
		}
		
		public function getChildPageIDList(a:Array=undefined):Array {
			if(!a) a = new Array();
			if(_NodeType == "page") a.push(id);
			for(var i:int=0; i<_Children.length; i++) {
				_Children[i].getChildPageIDList(a);
			}
			return a;
		}
		
		public function getNumModulesCompleted():int {
			var mc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].status >= ObjectStatus.COMPLETED) mc++;
			}
			return mc;
		}
		
		public function getNumModulesLocal():int {
			var mc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "module") mc++;
			}
			return mc;
		}
		
		public function getNumPagesLocal():int {
			var pc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "page") pc++;
			}
			return pc;
		}
		
		public function getNumPagesCompletedLocal():int {
			var pc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "page" && _Children[i].completed) pc++;
			}
			return pc;
		}
		
		public function getNumPagesCompleted():int {
			var pc:int = getNumPagesCompletedLocal();
			for(var i:int=0; i<_Children.length; i++) {
				pc += _Children[i].getNumPagesCompleted();
			}
			return pc;
		}
		
		// untested
		public function getNumMandatoryPagesLocal():int {
			var pc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "page" && _Children[i].mandatory) pc++;
			}
			return pc;
		}
		
		// untested
		public function getNumMandatoryPages():int {
			var pc:int = getNumMandatoryPagesLocal();
			for(var i:int=0; i<_Children.length; i++) {
				pc += _Children[i].getNumMandatoryPages();
			}
			return pc;
		}
		
		public function getHierarchy():Object {
			var hObj:Object = new Object();
			var cNode:Object = this;
			hObj.nDepth = _Depth;
			hObj.strType = _NodeType;
			for (var i:int=depth; i>0; i--) {			
				hObj["nID" + i] = cNode.id;
				cNode = cNode.parentNode;
			}
			return hObj;
		}
		
		// returns array the node names under this one
		public function getPathNameAsAry():Array {
			var nms:Array = new Array();
			var cNode:Object = this;
			for (var i:int=depth; i>-1; i--) {			
				nms.unshift(cNode.name);
				cNode = cNode.parentNode;
			}
			return nms;
		}
		
		// returns array the node IDs under this one
		public function getPathIDAsAry():Array {
			var nms:Array = new Array();
			var cNode:Object = this;
			for (var i:int=depth; i>-1; i--) {			
				nms.unshift(cNode.id);
				cNode = cNode.parentNode;
			}
			return nms;
		}
		
		// gets the breadcrumb trail
		public function getPathNameStr(d:String):String {
			var pa:Array = getPathNameAsAry();
			var t:String = "";
			for(var i:int=1; i<pa.length; i++) {
				t += pa[i];
				if(i < pa.length-1) t += " "+d+" ";
			}
			return t;
		}
		
		// get the string used by SWF address
		public function getPathIDStr(d:String):String {
			var pa:Array = getPathIDAsAry();
			var t:String = "";
			for(var i:int=1; i<pa.length; i++) {
				t += pa[i];
				if(i < pa.length-1) t += d;
			}
			return t;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// status, progress

		public function updateStatus():void {
			if(_Status == ObjectStatus.NOT_ATTEMPTED) setIncomplete()
			var nReverseDepth = -1;
			var mParent	= null;
			//trace("%% "+getThisNodeStructureStr() + " looking up...");
			do {
				//trace("%% get parent at: "+nReverseDepth);
				mParent	= getParentAt(nReverseDepth);
				//trace("%% got parent: "+mParent);
				if (mParent) {
					mParent.status = ObjectStatus.INCOMPLETE;
					//trace("%% compl check "+mParent.getNumModulesCompleted() + " vs " + mParent.numChildren);
					if (mParent.getNumModulesCompleted() == mParent.numChildren) {
						trace("%% SET complete "+mParent.getThisNodeStructureStr());
						mParent.setComplete();
					} else {
						//trace("%% NOT complete "+mParent.getThisNodeStructureStr());
					}
				} else {
					//trace("%% not parent");
				}
				nReverseDepth--;
			} while (Math.abs(nReverseDepth) < (depth + 1));
		}
		
		/*public function getNumPagesCompletedLocal():int {
			var pc:int = 0;
			for(var i:int=0; i<_Children.length; i++) {
				if(_Children[i].nodetype == "page" && _Children[i].completed) pc++;
			}
			return pc;
		}*/
		
		public function getNumScoredSections():int {
			var cntr:int = 0;
			if (nodetype == NodeType.SECTION && scored) cntr++;
			for(var i:int=0; i<_Children.length; i++) {
				cntr += _Children[i].getNumScoredSections();
			}
			return cntr;
		}
		
		// will not count the children of unscored sections or topics
		public function getNumScoredPages():int {
			if ((nodetype == NodeType.SECTION && !scored) || (nodetype == NodeType.TOPIC && !scored)) return 0;
			var cntr:int = 0;
			if (nodetype == NodeType.PAGE && scored) cntr++;
			for(var i:int=0; i<_Children.length; i++) {
				cntr += _Children[i].getNumScoredPages();
			}
			return cntr;
		}
		
		// will not count the children of unscored sections or topics
		public function getNumPagesWithStatus(s:int) {
			if (s == ObjectStatus.PASSED || s == ObjectStatus.FAILED) {
				if ((nodetype == NodeType.SECTION && !scored) || (nodetype == NodeType.TOPIC && !scored)) return 0;
			}
			var cntr:int = 0;
			if (nodetype == NodeType.PAGE && status == s) cntr++;
			for(var i:int=0; i<_Children.length; i++) {
				cntr += _Children[i].getNumPagesWithStatus(s);
			}
			return cntr;
		}
		
		public function resetScored():void {
			if (!SiteModel.getInstance().resetScoredPages) return;
			//trace("- reset scored");
			if (_Scored) _Status = ObjectStatus.NOT_ATTEMPTED;
			for (var i:int = 0; i < _Children.length; i++) {
				_Children[i].resetScored();
			}
			updateStatus();
		}
		
		public function resetScoredNodeID(n:String):void {
			if (id == n) {
				resetScored();
				for (var i:int = 0; i < _Children.length; i++) {
					_Children[i].resetScored();
				}
			} else {
				for (var j:int = 0; j < _Children.length; j++) {
					_Children[j].resetScoredNodeID(n);
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Navigation
		
		public function findNodeByGUID(g:String):NodeModel {
			if(guid == g) {
				return this;
			} else {
				var cn:NodeModel;
				for (var i:int=0; i<numChildren; i++){
					cn = childNodes[i].findNodeByGUID(g);
					if(cn) break;
				}
				return cn;
			}
		}
		
		public function findNodeByID(g:String):NodeModel {
			if(id == g) {
				return this;
			} else {
				var cn:NodeModel = null;
				for (var i:int=0; i<numChildren; i++){
					cn = childNodes[i].findNodeByID(g);
					if(cn) return cn;
				}
				return undefined;
			}
		}
		
		/*public function findNodeByName(g:String):NodeModel {
			if(name == g) {
				return this;
			} else {
				var cn:NodeModel = null;
				for (var i:int=0; i<numChildren; i++){
					cn = childNodes[i].findNodeByName(g);
					if(cn) return cn;
				}
				return undefined;
			}
		}*/
		
		public function getFirstPage():NodeModel {
			if((numChildren > 0) && (childNodes[0].nodetype == "page")) {
				return childNodes[0];
			} else {
				return childNodes[0].getFirstPage();
			}
		}
				
		public function getLastPage():NodeModel { 	
			if((numChildren > 0) && (childNodes[numChildren-1].nodetype == "page")) {
				return childNodes[numChildren-1];
			} else {
				return childNodes[numChildren-1].getLastPage();
			}
		}
		
		public function getNextPage():NodeModel {
			if(localIdx < parentNode.numChildren - 1) {
				return parentNode.childNodes[localIdx + 1];
			} else {
				trace("next going to next node");
				var nReverseDepth = -1;
				var mGrandParent = null;
				var mParent	= null;
				do {
					mParent	= getParentAt(nReverseDepth);
					mGrandParent = mParent.parentNode;
					if(mParent.localIdx + 1 < mGrandParent.numChildren) {	
						var mPage = mGrandParent.childNodes[mParent.localIdx + 1].getFirstPage();
						if (mPage) {
							mGrandParent.childNodes[mParent.localIdx + 1].resetScored();
							return mPage;
						} else {
							nReverseDepth--;
						}
					} else {
						nReverseDepth--;
					}
				} while(Math.abs(nReverseDepth) < depth)
			}
			return undefined;
		}
		
		
		public function getPreviousPage():NodeModel { 
			if(localIdx > 0) {
				return parentNode.childNodes[localIdx - 1];
			} else {
				trace("prev going to prev node");
				var nReverseDepth = -1;
				var mGrandParent = null;
				var mParent	= null;
				do {
					mParent	= getParentAt(nReverseDepth);
					mGrandParent = mParent.parentNode;
					if (mParent.localIdx > 0) {
						mGrandParent.childNodes[mParent.localIdx - 1].resetScored();
						return mGrandParent.childNodes[mParent.localIdx - 1].getLastPage();
					} else {
						nReverseDepth--;
					}
				} while(Math.abs(nReverseDepth) < depth)
			}
			return undefined;
		}

		public function isLinearNextPage():Boolean {
			if(localIdx < parentNode.numChildren - 1) {
				return true;
			} else {
				var nReverseDepth = -1;
				var mGrandParent = null;
				var mParent	= null;
				do {
					mParent	= getParentAt(nReverseDepth);
					mGrandParent = mParent.parentNode;
					if(mParent.localIdx + 1 < mGrandParent.numChildren) {	
						var mPage = mGrandParent.childNodes[mParent.localIdx + 1].getFirstPage();
						if(mPage) {
							return true;
						} else {
							nReverseDepth--;
						}
					} else {
						nReverseDepth--;
					}
				} while(Math.abs(nReverseDepth) < depth)
			}
			return false;
		}
		
		
		public function isLinearPreviousPage():Boolean { 
			if(localIdx > 0) {
				return true;
			} else {
				var nReverseDepth = -1;
				var mGrandParent = null;
				var mParent	= null;
				do {
					mParent	= getParentAt(nReverseDepth);
					mGrandParent = mParent.parentNode;
					if(mParent.localIdx > 0)
						return true;
					else
						nReverseDepth--;
				} while(Math.abs(nReverseDepth) < depth)
			}
			return false;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// XML parsing
		
		private function parseInitData():void {
			//_DLog.addDebugText("Node XML parsing ...");
			
			_NodeType = String(_XMLInitData.name());

			// get a unique index
			if(_NodeType == NodeType.PAGE) {
				_GlobalID = _PageNumberCntr;
				_PageNumberCntr++;
			} else if (_NodeType == NodeType.SECTION) {
				_NodeType = "section";
				_GlobalID = _ModuleNumberCntr;
				_ModuleNumberCntr++;
			} else if (_NodeType == NodeType.TOPIC) {
				_NodeType = "topic";
				_GlobalID = _ModuleNumberCntr;
				_ModuleNumberCntr++;
			} else if (_NodeType == NodeType.MODULE) {
				_NodeType = "module";
				_GlobalID = _ModuleNumberCntr;
				_ModuleNumberCntr++;
			} else {
				trace("unrecognized node type: " + _NodeType);
				return;
			}
			
			_NodeSubType = _XMLInitData.@type;
			_Name = _XMLInitData.@name;
			_ID = _XMLInitData.@id;
			_GUID = _XMLInitData.@guid;
			_SWFFile = _XMLInitData.@swf;
			_XMLFile = _XMLInitData.@xml;
			// default to true
			_TOC = String(_XMLInitData.@toc).indexOf("f") == 0 ? false : true;
			// default to false
			_Scored = String(_XMLInitData.@scored).indexOf("t") == 0 ? true : false;
			// defrault to true
			_Mandatory = String(_XMLInitData.@mandatory).indexOf("f") == 0 ? false : true;
			// default to false
			_Scrolling = String(_XMLInitData.@scroll).indexOf("t") == 0 ? true : false;
			// default to false
			_Cropping = String(_XMLInitData.@crop).indexOf("t") == 0 ? true : false;
			// defrault to true
			_RefreshOnTS = String(_XMLInitData.@refreshontxtszch).indexOf("f") == 0 ? false : true;
			_NodeMetaXML = _XMLInitData.meta;
			_NodeConfigXML = _XMLInitData.config;
			_NodeLogicXML = _XMLInitData.logic;
			
			if(!_ID || !_ID == "undefined") _ID = _NodeType.charAt(0)+"-"+_GlobalID;
			if(!_GUID || !_GUID == "undefined") _GUID = GUID.getGUID();

			if (_NodeSubType == NodeType.TYPE_ASSESSMENT) _Scored = true;

			var len:int = _XMLInitData.children().length();
			for (var i:int = 0; i < len; i++) {
				if(NodeType.validMajorType(_XMLInitData.children()[i].name())) _Children.push(new NodeModel(_XMLInitData.children()[i],_Depth+1,this,_Children.length));
			}
			//_DLog.addDebugText("Node XML parsing COMPLETE");
		}

		private function parseMeta(d:XMLList):void {
			//_DLog.addDebugText("Node, parsing meta");
			_MetaKeywords = new Array();
			_MetaDescription = String(_NodeMetaXML.description);
			_MetaKeywords = String(_NodeMetaXML.keywords).split(",");
		}
		
		private function parseConfig(d:XMLList):void {
			//_DLog.addDebugText("Node, parsing config");
			_ConfigDefaultPageShowBG = String(d.showbg).indexOf("t") == 0 ? true : false
			_ConfigDefaultPageShowMenu = String(d.showmenu).indexOf("t") == 0 ? true : false
			_ConfigDefaultPageX = int(String(d.pageposition).split(",")[0]);
			_ConfigDefaultPageY	= int(String(d.pageposition).split(",")[1]);
			_ConfigDefaultPageWidth = int(String(d.pagesize).split(",")[0]);
			_ConfigDefaultPageHeight = int(String(d.pagesize).split(",")[1]);
			_ConfigPageShowBG = String(d.showbg).indexOf("t") == 0 ? true : false
			_ConfigPageShowMenu = String(d.showmenu).indexOf("t") == 0 ? true : false
			_ConfigPageX = int(String(d.position).split(",")[0]);
			_ConfigPageY = int(String(d.position).split(",")[1]);
			_ConfigPageWidth = int(String(d.size).split(",")[0]);
			_ConfigPageHeight = int(String(d.size).split(",")[1]);
		}
		
	}
}