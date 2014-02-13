package ramen.player {
	
	import ramen.common.*;
	import ramen.player.*;
	
	import flash.events.*;
	import flash.net.*;
	import com.nudoru.utils.Debugger;
	
	public class SiteModel extends EventDispatcher {
		
		private static var _Instance			:SiteModel;
		
		private var _SDVersion					:Number = 1;		// suspend data version, sould be a Number - 1, 1.2, 2, etc.
		private var _SDDelimeter				:String = "~~";		// suspend data delimeter
		
		private var _XMLFile					:String;
		private var _SiteXMLData				:XML;
		private var _ThemeXMLData				:XML;
		private var _XMLLoader					:URLLoader;
		
		private var _Nodes						:Array;
		private var _SiteNodeStructure			:Array;
		
		private var _LastLocation				:String;			// the SWF address last location, stored as the LMS lastlocation var
		private var _SDLastLocation				:String;			// storted in the suspend data and used for locally shared objects
		
		private var _CurrentNode				:NodeModel;
		private var _CurrentModule				:int;
		
		private var _ScoreMode					:String = "status";
		
		private var _DLog						:Debugger;
		
		public static const ERROR				:String = "error";
		public static const IO_ERROR			:String = "io_error";
		public static const LOADED				:String = "loaded";
		public static const PAGE_CHANGE			:String = "pagechange";
		public static const PAGE_STATUS_CHANGE	:String = "pagestatuschange";
		public static const SITE_COMPLETED		:String = "sitecompleted";
		public static const ALL_SCORED_PAGES_COMPLETED	:String = "all_scored_pages_completed";
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// META DATA
		
		public function get metaTitle():String { 
			return _SiteXMLData.meta.title;
		}
		public function get metaID():String { 
			return _SiteXMLData.meta.id;
		}
		public function get metaVersion():String {
			return _SiteXMLData.meta.version;
		}
		public function get metaLastUpdt():String { 
			return _SiteXMLData.meta.lastupdate;
		}
		public function get metaAuthor():String {
			return _SiteXMLData.meta.author;
		}
		public function get metaNotes():String { 
			return _SiteXMLData.meta.notes;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// CONFIG DATA
		
		public function get configUseLSO():Boolean { 
			return (_SiteXMLData.config.uselso == "true");
		}
		public function get configUseKeyCommands():Boolean { 
			return (_SiteXMLData.config.useplayerkeycommands == "true");
		}
		public function get configUseAccessibility():Boolean { 
			return (_SiteXMLData.config.useaccessibility == "true");
		}
		public function get configShowWarnings():Boolean { 
			return (_SiteXMLData.config.showwarnings == "true");
		}
		public function get configCheatKeyEnabled():Boolean { 
			return (_SiteXMLData.config.cheatkeyenabled == "true");
		}
		public function get configSndBGEnabled():Boolean { 
			return (_SiteXMLData.config.sbgenabled == "true");
		}
		public function get configSndFXEnabled():Boolean { 
			return (_SiteXMLData.config.sfxenabled == "true");
		}
		public function get configSWFAddressEnabled():Boolean { 
			return (_SiteXMLData.config.swfaddressenabled == "true");
		}
		public function get configThemeFile():String { 
			return _SiteXMLData.config.themefile;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// LMS DATA
		
		public function get configLMSEnabled():Boolean {
			return !(_SiteXMLData.lms.mode == "none");
		}
		public function get simulateLMSEnabled():Boolean {
			return (_SiteXMLData.lms.simulatelms == "true");
		}
		
		public function get LMSMode():String { return _SiteXMLData.lms.mode; }
		public function get completionCriteria():String { return _SiteXMLData.lms.completioncriteria; }
		public function get recordFailingStatus():Boolean { return _SiteXMLData.lms.recordfailing; }
		public function get masteryScore():int { return _SiteXMLData.lms.masteryscore; }
		
		public function get allowScoredReanswer():Boolean { return (_SiteXMLData.lms.allowscoredreanswer == "true"); }
		public function get resetScoredPages():Boolean { return (_SiteXMLData.lms.resetscoredpages == "true"); }
		
		public function get forcelinearnav():Boolean { return (_SiteXMLData.lms.forcelinearnav == "true"); }
		
		public function get currentScore():int { return getPassingPct(); }
		
		public function get interactionForceAnswer():Boolean { return (_SiteXMLData.lms.intr_forceanswer == "true"); }
		public function get iteractionNumberOfTries():int { return _SiteXMLData.lms.intr_numtries; }
		public function get iteractionForceCA():Boolean { return (_SiteXMLData.lms.intr_forceca == "true"); }
		public function get interactionUseIObjs():Boolean { return (_SiteXMLData.lms.intr_useiobjects == "true"); }
		
		public function get exitPromptNonComplete():String { return _SiteXMLData.lms.exitpromptnoncomplete }
		public function get exitPromptComplete():String { return _SiteXMLData.lms.exitpromptcomplete }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// THEME DATA
		
		public function get configSiteWidth():int { 
			return int(String(_ThemeXMLData.size).split(",")[0]);
		}
		public function get configSiteHeight():int { 
			return int(String(_ThemeXMLData.size).split(",")[1]);
		}
		public function get configSiteHAlign():String { 
			return String(_ThemeXMLData.halign);
		}
		public function get configSiteVAlign():String { 
			return String(_ThemeXMLData.valign);
		}
		public function get configHSnap():int { 
			return int(_ThemeXMLData.halign.@snap);
		}
		public function get configVSnap():int { 
			return int(_ThemeXMLData.valign.@snap);
		}
		
		public function get configDefaultPageX():int {
			return int(String(_ThemeXMLData.pageposition).split(",")[0]);
		}
		public function get configDefaultPageY():int {
			return int(String(_ThemeXMLData.pageposition).split(",")[1]);
		}
		public function get configDefaultPageWidth():int {
			return int(String(_ThemeXMLData.pagesize).split(",")[0]);
		}
		public function get configDefaultPageHeight():int {
			return int(String(_ThemeXMLData.pagesize).split(",")[1]);
		}
	
		public function get configInterfaceBGFile():String {
			return String(_ThemeXMLData.interfacefile);
		}
		public function get configNavigationFile():String {
			return String(_ThemeXMLData.navigationfile);
		}
		public function get configBackgroundFile():String {
			return String(_ThemeXMLData.background);
		}
		public function get configOverlayFile():String {
			return String(_ThemeXMLData.overlayfile);
		}
		public function get configSharedResFile():String {
			return String(_ThemeXMLData.sharedresources);
		}
		public function get configAudioBGFile():String {
			if (!configSndBGEnabled) return "";
			return String(_ThemeXMLData.backgroundaudio);
		}
		public function get configAudioSFXFile():String {
			if (!configSndFXEnabled) return ""
			return String(_ThemeXMLData.soundeffects);
		}
		public function get configCSSFile():String {
			return String(_ThemeXMLData.cssfile);
		}
		public function get configFontFile():String {
			return String(_ThemeXMLData.fontfile);
		}
		public function get configFontList():Array {
			return String(_ThemeXMLData.fontlist).split(",") 
		}
		public function get configPageTransition():String { 
			return String(_ThemeXMLData.pagetransition);
		}
		public function get validPageTransition():Boolean {
			if (configPageTransition.length > 1 && configPageTransition != PageTransition.NONE) return true;
			return false;
		}
		public function get configCropPageArea():Boolean {
			return (_ThemeXMLData.croppagearea == "true");
		}
		public function get configScrollPageArea():Boolean {
			return (_ThemeXMLData.scrollpagearea == "true");
		}
		public function get configThemeColors():Array { return _ThemeXMLData.colors.split(","); }
		public function get configThemeHiColor():String { return _ThemeXMLData.highlightcolor; }
		public function get configThemeHiStyle():String { return _ThemeXMLData.highlightstyle ; }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// OTHER STUFF
		
		public function get currentSWFAddressLocation():String {
			if (!_CurrentNode) return "";
			return "/"+_CurrentNode.getPathIDStr("/")+"/";
		}
		
		public function get currentSiteNodePg():NodeModel { return _CurrentNode }
		
		public function get currentModule():int { return _CurrentModule }
		public function set currentModule(n:int) { _CurrentModule = n }
		
		public function get lastLocation():String { return _LastLocation }
		public function get sdLastLocation():String { return _SDLastLocation }
		
		public function get TOTALSITEPAGES():Number { return _Nodes[0].TOTALPAGES }
		
		public function get currentModuleNumPagesLocal():Number { return _CurrentNode.parentNode.numChildren }
		public function get currentPageNumberLocal():Number { return _CurrentNode.localIdx + 1 }
		public function get currentPageNumberGlobal():Number { return _CurrentNode.globalIdx + 1}
		public function get currentPagePathStr():String { return _CurrentNode.getPathNameStr(">") }
		
		public function get currentProgressPctGlobal():int {
			//getNumPagesCompleted()
			return (currentPageNumberGlobal/TOTALSITEPAGES) * 100;
		}
		
		public function get currentPageName():String { return _CurrentNode.name }
		public function get currentPageID():String { return _CurrentNode.id }
		public function get currentPageParentID():String { return _CurrentNode.parentid }
		public function get currentPageXML():String { return _CurrentNode.xmlfile }
		public function get currentPageSWF():String { return _CurrentNode.swffile }
		public function get currentPageTOC():Boolean { return _CurrentNode.toc }
		public function get currentPageStatus():Number { return _CurrentNode.status }
		public function get currentPageScored():Boolean { return _CurrentNode.scored }
		public function get currentPageCompleted():Boolean { return _CurrentNode.completed }
		
		public function get currentPageX():int { return configDefaultPageX }
		public function get currentPageY():int { return configDefaultPageY }
		public function get currentPageWidth():int { return configDefaultPageWidth }
		public function get currentPageHeight():int { return configDefaultPageHeight }
		
		public function SiteModel(singletonEnforcer:SingletonEnforcer) {}
		
		public static function getInstance():SiteModel {
			if (SiteModel._Instance == null) {
				SiteModel._Instance = new SiteModel(new SingletonEnforcer());
			}
			return SiteModel._Instance;
		}
		
		public function init():void {
			_DLog = Debugger.getInstance();
		}
		
		override public function toString():String {
			return "[SiteModel: '"+metaTitle+"']";
		}
		
		// all of this is passed to the navigation file from the View on page change
		public function getCurrentPageInfoObject():Object {
			var o:Object = new Object();
			o.currentPageID = currentPageID;
			o.currentPageStatus = currentPageStatus;
			o.currentPageParentID = currentPageParentID;
			o.structureDataUnderCurrentNode = getStructureDataUnderCurrentNode();
			o.totalSitePages = TOTALSITEPAGES;
			o.allNodeStatus = getCourseStatusStr();
			o.currentModuleNumPagesLocal = currentModuleNumPagesLocal;
			o.currentPageNumberLocal = currentPageNumberLocal;
			o.currentPageNumberGlobal = currentPageNumberGlobal;
			o.currentPagePathStr = currentPagePathStr;
			o.currentProgressPctGlobal = currentProgressPctGlobal;
			o.isLinearPreviousPage = isLinearPreviousPage();
			o.isLinearNextPage = isLinearNextPage();
			return o;
		}
		
		// passed to a loaded page on init
		public function getPageEntryObject():Object {
			var o:Object = new Object();
			o.status = currentPageStatus;
			o.scored = currentPageScored;
			return o;
		}
		
		public function traceCourseStructure():String {
			var t:String = "--------------------\n";
			for(var i:int=0; i<_Nodes.length; i++) {
				t += _Nodes[i].getCourseStructureStr();
			}
			t += "--------------------";
			return t;
		}
		
		public function getCourseStatusStr():String {
			var t:String = "";
			for(var i:int=0; i<_Nodes.length; i++) {
				t += _Nodes[i].getCourseStatusStr();
			}
			return t;
		}
		
		// sample:
		// 1~~2009,3,18@10,16~~root@0,chapter1@0,ch1_pg1@0,ch1_pg2@0,ch1_pg3@0,chapter2@0,ch2_pg4@0,ch2_pg5@0,ch2_pg6@0,chapter3@0,ch3_pg7@0,ch3_pg8@0,ch3_pg9@0~~no_custom_variables~~
		public function getSuspendData():String {
			var s:String = String(_SDVersion) + _SDDelimeter;
			s += getDateStr() + "@" + getTimeStr() + _SDDelimeter;
			s += currentSWFAddressLocation + _SDDelimeter;
			s += getCourseStatusStr() + _SDDelimeter;
			s += Settings.getInstance().getPrefsDataString() + _SDDelimeter;
			s += LogicManager.getInstance().getSavedStateStr() + _SDDelimeter;
			s += AssessmentManager.getInstance().getSavedStateStr() + _SDDelimeter;
			return s;
		}
		
		public function getDateStr():String {
			var now = new Date();
			return String(now.getFullYear() + "," + (now.getMonth() + 1) + "," + now.getDate());
		}
		
		public function getTimeStr():String {
			var now = new Date();
			// + "," + now.getSeconds() + "," + now.getMilliseconds()
			return String(now.getHours() + ":" + now.getMinutes());
		}
		
		public function parseSuspendData(s:String = ""):Boolean {
			if (!s) return false;
			var data:Array = s.split(_SDDelimeter);
			if (data.length < 6) {
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Bad or no suspend data."));
				return false;
			}
			var ver:Number = Number(data[0]);
			var date:String = data[1];
			var lastloc:String = data[2];
			var status:String = data[3];
			var settings:String = data[4];
			var vars:String = data[5];
			var assmnt:String = data[6];
			if (_SDVersion < ver) {
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Suspend data is from a newer player version."));
			} else if (_SDVersion > ver) {
				dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "Suspend data is from an older player version."));
			}
			_DLog.addDebugText("Parsing suspend data from: " + date);
			_DLog.addDebugText("... status: " + status);
			_DLog.addDebugText("... vars: " + vars);
			
			updateCourseStatusFromStr(status);
			Settings.getInstance().parsePrefsSavedStateStr(settings);
			LogicManager.getInstance().parseSavedStateStr(vars);
			AssessmentManager.getInstance().parseSavedStateStr(assmnt);
			_SDLastLocation = lastloc;
			
			return true;
		}
		
		public function updateCourseStatusFromStr(s:String):void {
			var pairs:Array = s.split(",");
			for (var i:int = 0; i < pairs.length; i++) {
				var idStat:Array = pairs[i].split("@");
				//trace("set " + idStat[0] + " to " +idStat[1] +" ...");
				setModuleStatusByID(idStat[0], int(idStat[1]));
			}
			if (resetScoredPages) {
				resetAllScoredNodes();
			}
			updateModuleStatus();
		}
		
		public function updateModuleStatus():void {
			for(var i:int=0; i<_Nodes.length; i++) {
				_Nodes[i].updateStatus();
			}
			allNodesViewed();
		}
		
		/*
		 * Completion criteria
				entrance
				view_last_page
				view_all_pages
				
				mastery_score
				mastery_score&view_all_pages
		 */
		
		public function isComplete():Boolean {
			_DLog.addDebugText("isComplete by "+completionCriteria+"? ...");
			if (completionCriteria == "entrance") return true;
			if (completionCriteria == "view_all_pages") return allNodesViewed();
			if (completionCriteria == "view_last_page") return getLastPage().completed;
			if (completionCriteria == "mastery_score") {
				if (recordFailingStatus && !isPassing()) return true;
				return isPassing();
			}
			if (completionCriteria == "mastery_score&view_all_pages" && allNodesViewed()) {
				if (recordFailingStatus && !isPassing()) return true;
				return isPassing();
			}
			_DLog.addDebugText("... NOPE!");
			return false;
		}
		
		public function isScored():Boolean {
			if (completionCriteria.indexOf("mastery_score") == 0) return true;
			return false;
		}
		
		public function isPassing():Boolean {
			if (getNumScoredPages() == 0) return true;
			//if (!isScored()) return true;
			//if (!allNodesViewed()) return false;
			if (getPassingPct() >= masteryScore) return true;
			return false;
		}
		
		public function allNodesViewed():Boolean {
			var mc:Number = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				if(_Nodes[i].completed) mc++;
			}
			if(mc == _Nodes.length) {
				trace("COURSE COMPLETED");
				dispatchEvent(new Event(SiteModel.SITE_COMPLETED));
				return true;
			}	
			return false;
		}
		
		/*
		 * Old function, replaced with mandatory page check on 11.17.09
		public function allNodesViewed():Boolean {
			var mc:Number = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				if(_Nodes[i].completed) mc++;
			}
			if(mc == _Nodes.length) {
				trace("COURSE COMPLETED");
				dispatchEvent(new Event(SiteModel.SITE_COMPLETED));
				return true;
			}
			//trace("all nodes NOT viewed");	
			return false;
		}
		*/
		
		private function getNumPagesCompleted():int {
			var mc:Number = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				mc += _Nodes[i].getNumPagesCompleted();
			}
			return mc;
		}
		
		// untested
		private function getNumMandatoryPages():int {
			var mc:Number = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				mc += _Nodes[i].getNumMandatoryPages();
			}
			return mc;
		}
		
		public function setCurrentPageModule(cn:NodeModel,s:Boolean = false):Boolean {
			if(cn) {
				//trace("%% setCurrentPageModule ...");
				if(_CurrentNode) stopCurrentPageNode();
				_CurrentNode = cn;
				//startCurrentPageNode();
				updateModuleStatus();
				if(!s) dispatchEvent(new Event(SiteModel.PAGE_CHANGE));
				_LastLocation = currentSWFAddressLocation;
				return true
			}
			return false
		}
		
		public function startCurrentPageNode():void {
			currentSiteNodePg.start()
			_LastLocation = currentSiteNodePg.id
		}
		
		public function stopCurrentPageNode():void {
			currentSiteNodePg.stop()
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// param getters
		
		//TODO check for current status and broadcast event on change
		public function setCurrentPageNotAttempted():void { currentSiteNodePg.setNotAttempted() }
		public function setCurrentPageIncomplete():void { currentSiteNodePg.setIncomplete() }
		public function setCurrentPageComplete():void { currentSiteNodePg.setComplete() }
		public function setCurrentPagePassed():void { 
			currentSiteNodePg.setPassed()
			areAllScoredPagesCompleted();
		}
		public function setCurrentPageFailed():void { 
			currentSiteNodePg.setFailed()
			areAllScoredPagesCompleted();
		}
		
		public function getCourseDataPacket():Object {
			var o:Object = new Object();
			o.sitestructure = getCourseStructureData();
			o.title = metaTitle;
			o.verstion = metaVersion;
			o.author = metaAuthor;
			o.lastupdate = metaLastUpdt;
			o.notes = metaNotes;
			return o;
		}
		
		public function getCourseStructureData(r:Boolean=false):Array {
			if(r) updateSiteNodeStructure()
			return _SiteNodeStructure;
		}
		
		public function updateSiteNodeStructure():void {
			_SiteNodeStructure = new Array();
			for(var i:int=0; i<_Nodes.length; i++) {
				_Nodes[i].getCourseStructureData(_SiteNodeStructure);
			}
		}
		
		// TODO optimze this and don't get getCourseStructureData() first
		public function getStructureDataUnderCurrentNode():Array {
			var a:Array = new Array();
			
			var siteStructure:Array = getCourseStructureData();
			var cpID:String = currentPageID;
			var cpPID:String = currentPageParentID;
			var len:int = siteStructure.length;
			
			for(var i:int=0; i<len; i++) {
				//trace(cpPID +" ? "+siteStructure[i].parentid)
				if(siteStructure[i].parentid == cpPID) {
					//trace(siteStructure[i].id)
					a.push(siteStructure[i]);
				}
			}
			
			return a;
		}
		
		private function moduleObjContainsID(mobj:Object,id:String):Boolean {
			var parry:Array = mobj.pagesunder
			for(var i:Number=0; i<parry.length; i++) {
				if(parry[i] == id) return true
			}
			return false
		}
		
		private function updateNonMandatoryPages():void {
			for(var i:int=0; i<_Nodes.length; i++) {
				_Nodes[i].updateNonMandatoryPages();
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Navigation
		
		public function getFirstPage():NodeModel {
			return _Nodes[currentModule].getFirstPage();
		}
		
		public function getLastPage():NodeModel {
			return _Nodes[_Nodes.length-1].getLastPage();
		}
		
		public function getModuleByID(id:String, rset:Boolean = false):NodeModel {
			var cn:NodeModel = null;
			for (var i:int=0; i<_Nodes.length; i++){
				cn = _Nodes[i].findNodeByID(id);
				if(cn) {
					if (cn.nodetype == NodeType.MODULE ||cn.nodetype == NodeType.SECTION ||cn.nodetype == NodeType.TOPIC) {
						if(!rset) {
							currentModule = i;
							if (resetScoredPages) {
								cn.resetScored();
							}
						}
						return cn.getFirstPage();
					} else if(cn.nodetype == NodeType.PAGE) {
						if(!rset) currentModule = i;
						return cn;
					}
				}
			}
			dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "No module found with the ID '"+id+"'"));
			return undefined;
		}
		
		public function setModuleStatusByID(id:String,s:int):Boolean {
			var cn:NodeModel = null;
			for (var i:int=0; i<_Nodes.length; i++){
				cn = _Nodes[i].findNodeByID(id);
				if(cn) {
					cn.status = s;
					return true;
				}
			}
			return false;
		}
		
		// TODO this should be depreciated and never used
		public function getModuleByName(id:String):NodeModel {
			var cn:NodeModel = null;
			for (var i:int=0; i<_Nodes.length; i++){
				cn = _Nodes[i].findNodeByName(id);
				if(cn) {
					if (cn.nodetype == NodeType.MODULE ||cn.nodetype == NodeType.SECTION ||cn.nodetype == NodeType.TOPIC) {
						currentModule = i;
						if (resetScoredPages) {
							cn.resetScored();
						}
						return cn.getFirstPage();
					} else if(cn.nodetype == NodeType.PAGE) {
						currentModule = i;
						return cn;
					}
				}
			}
			dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "No module found with the ID '"+id+"'"));
			return undefined;
		}
		
		public function getPreviousPage(cn:NodeModel):NodeModel {
			if(cn) {
				return cn.getPreviousPage();
			} else {
				return _CurrentNode.getNextPage();
			}
		}
		
		public function getNextPage(cn:NodeModel):NodeModel {
			if(cn) {
				return cn.getNextPage();
			} else {
				return _CurrentNode.getPreviousPage();
			}
		}
		
		public function isLinearNextPage():Boolean {
			return _CurrentNode.isLinearNextPage();
		}
		
		public function isLinearPreviousPage():Boolean {
			return _CurrentNode.isLinearPreviousPage();
		}
		
		public function gotoNodeID(s:String, src:String = ""):Boolean {
			var cn:NodeModel = getModuleByID(s, true);
			
			if (src == NavChangeEvent.MAIN_MENU_SELECTION && forcelinearnav) {
				// since the main nav will go to the first page in the section, test for the whole section and the first page. both will be incomplete if not entered
				if (!cn.parentNode.completed && !cn.completed) {
					trace("FORCE LINEAR - Can't nav to uncompleted section!");
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "You may not skip ahead to this lesson."));
					return false;
				}
			}
			
			if (src == NavChangeEvent.PAGE_MENU_SELECTION && forcelinearnav) {
				if (!cn.completed) {
					trace("FORCE LINEAR - Can't nav to uncompleted page!");
					dispatchEvent(new PlayerError(PlayerError.WARNING, "00000", "You may not skip ahead to this page."));
					return false;
				}
			}
			
			cn = getModuleByID(s);
			
			if(cn) {
				setCurrentPageModule(cn);
				return true;
			}
			return false;
		}
		
		public function gotoNodeName(s:String):Boolean {
			var cn:NodeModel = getModuleByName(s);
			if(cn) {
				setCurrentPageModule(cn);
				return true;
			}
			return false;
		}
		
		public function gotoPreviousPage():Boolean {
			var cn:NodeModel = getPreviousPage(currentSiteNodePg);
			if (cn) {
				setCurrentPageModule(cn);
				return true;
			}
			return false;
		}
		
		public function gotoNextPage():Boolean {
			var cn:NodeModel = getNextPage(currentSiteNodePg);
			if(cn) {
				setCurrentPageModule(cn);
				return true;
			}
			return false;
		}
		
		public function refreshCurrentPage():void {
			dispatchEvent(new Event(SiteModel.PAGE_CHANGE));
		}
		
		// format "/parent/nodeid/"
		// only the nodeid matters
		public function gotoSWFAddressLocation(n:String):Boolean {
			var strPrse:Array = n.split("/");
			if(strPrse.length < 3) {
				setCurrentPageModule(getFirstPage());
				return false;
			}
			gotoNodeID(strPrse[strPrse.length-2]);
			return true;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Progress
		
		//public function isCurrentPageCompleted():Boolean { return currentSiteNodePg.isCompleted() }
		
		public function getPercentLocCourse():Number {
			return Math.floor((currentPageNumberGlobal / TOTALSITEPAGES) * 100);
		}
		
		public function getPercentCompletedCourse():Number {
			var t:Number = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				t += _Nodes[i].getNumPagesCompleted();
			}
			return Math.floor((t / TOTALSITEPAGES) * 100);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// page status
		
		public function getNumScoredSections():int {
			var cntr:int = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				cntr += _Nodes[i].getNumScoredSections();
			}
			return cntr;
		}
		
		// will not count the children of unscored sections or topics
		public function getNumScoredPages():int {
			var cntr:int = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				cntr += _Nodes[i].getNumScoredPages();
			}
			return cntr;
		}
		
		public function getNumNotattemptedPages():int { return getNumPagesWithStatus(ObjectStatus.NOT_ATTEMPTED); }
		public function getNumIncompletePages():int { return getNumPagesWithStatus(ObjectStatus.INCOMPLETE); }
		public function getNumCompletePages():int { return getNumPagesWithStatus(ObjectStatus.COMPLETED); }
		// will not count the children of unscored sections or topics
		public function getNumPassedPages():int { return getNumPagesWithStatus(ObjectStatus.PASSED); }
		// will not count the children of unscored sections or topics
		public function getNumFailedPages():int { return getNumPagesWithStatus(ObjectStatus.FAILED); }
		
		private function getNumPagesWithStatus(s:int) {
			var cntr:int = 0;
			for(var i:int=0; i<_Nodes.length; i++) {
				cntr += _Nodes[i].getNumPagesWithStatus(s);
			}
			return cntr;
		}
		
		public function areAllScoredPagesCompleted():Boolean {
			var sp:int = getNumScoredPages();
			var ap:int = getNumPassedPages() + getNumFailedPages();
			if (sp == ap) {
				dispatchEvent(new Event(SiteModel.ALL_SCORED_PAGES_COMPLETED));
				return true;
			}
			return false;
		}
		
		public function getPassingPct():Number {
			if(_ScoreMode == "status") {
				if (!getNumScoredPages()) return 100;
				return (getNumPassedPages() / getNumScoredPages()) * 100;
			} else {
				return 100;
			}
		}
		
		public function resetAllScoredNodes():void {
			for(var i:int=0; i<_Nodes.length; i++) {
				_Nodes[i].resetScored();
			}
		}
		
		public function resetScoredNodeID(n:String):void {
			for(var i:int=0; i<_Nodes.length; i++) {
				_Nodes[i].resetScoredNodeID(n);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// XML parsing
		
		public function load(d:String):void {
			_XMLFile = d;
			if(_XMLFile) {
				loadSiteXML();
			}
		}
		
		private function loadSiteXML():void {
			_DLog.addDebugText("Site load: "+_XMLFile);
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(Event.COMPLETE, onSiteXMLLoaded);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onSiteIOError);
			_XMLLoader.load(new URLRequest(_XMLFile))
		}
		
		private function onSiteIOError(event:Event):void {
			dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "Cannot load the configuration file '"+_XMLFile+"'"));
		}
		
		private function onSiteXMLLoaded(event:Event):void {
			_XMLLoader.removeEventListener(Event.COMPLETE, onSiteXMLLoaded);
			_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSiteIOError);
			try {
				_SiteXMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "Cannot parse the configuration file. Invalid XML markup, an element is malformed."));
				return;
			}
			parseXML();
		}
		
		
		private function parseXML():void {
			_DLog.addDebugText("Site XML parsing ...");
			_Nodes = new Array();
			for each(var m:XML in _SiteXMLData.structure.module) {
				_Nodes.push(new NodeModel(m,0));
			}
			
			updateSiteNodeStructure();
			updateNonMandatoryPages();
			_DLog.addDebugText("Site XML parsing COMPLETE");

			loadThemeXML();
		}
		
		private function loadThemeXML():void {
			_DLog.addDebugText("Site load: "+configThemeFile);
			_XMLLoader = new URLLoader();
			_XMLLoader.addEventListener(Event.COMPLETE, onThemeXMLLoaded);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onThemeIOError);
			_XMLLoader.load(new URLRequest(configThemeFile))
		}
		
		private function onThemeIOError(event:Event):void {
			dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "Cannot load the theme file '"+configThemeFile+"'"));
		}
		
		private function onThemeXMLLoaded(event:Event):void {
			try {
				_ThemeXMLData = new XML(_XMLLoader.data);
			} catch (e:*) {
				dispatchEvent(new PlayerError(PlayerError.FATAL, "20000", "Cannot parse the theme file. Invalid XML markup, an element is malformed."));
				return;
			}
			dispatchEvent(new Event(SiteModel.LOADED));
		}

	}
}

class SingletonEnforcer {}