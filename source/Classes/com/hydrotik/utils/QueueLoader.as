/*
 * Copyright 2007-2008 (c) Donovan Adams, http://blog.hydrotik.com/
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


package com.hydrotik.utils {
	
    import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
    import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.system.LoaderContext;
	import com.hydrotik.utils.QueueLoaderEvent;

    public class QueueLoader implements IEventDispatcher {
		
		// Colophon
		
		public static const VERSION:String = "QueueLoader 3.0.8";
		
		public static const AUTHOR:String = "Donovan Adams - donovan[(at)]hydrotik.com based on as2 version by Felix Raab - f.raab[(at)]betriebsraum.de";
		
		// List of file types
		
		public static const FILE_IMAGE:int = 1;
		
		public static const FILE_SWF:int = 2;
		
		public static const FILE_AUDIO:int = 3;
		
		public static const FILE_CSS:int = 4;
		
		public static const FILE_XML:int = 5;
		
		// Private
		
		private var _loader:Loader;
		
		private var _uLoader:URLLoader;
		
		private var queuedItems:Array;
		
		private var currItem:Object;
		
		private var itemsToInit:Array;
		
		private var loadedItems:Array;
		
		private var isStarted:Boolean;
		
		private var isStopped:Boolean;
		
		private var isLoading:Boolean;

		private var dispatcher:EventDispatcher;
		
		private var _count:int = 0;
		
		private var _max:int = 0;
		
		private var _queuepercentage:Number;
		
		private var _ignoreErrors:Boolean;
		
		private var  _currType:int;
		
		private var _currFile:*;
		
		private var _loaderContext:LoaderContext;
		
		/**
		 * QueueLoader AS 3
		 *
		 * @author: Donovan Adams, E-Mail: donovan[(at)]hydrotik.com, url: http://www.hydrotik.com/
		 * @author: Based on Felix Raab's QueueLoader for AS2, E-Mail: f.raab[(at)]betriebsraum.de, url: http://www.betriebsraum.de
		 * @version: 3.0.8
		 *
		 * @description QueueLoader is a linear asset loading tool with progress monitoring. It's largely used to load a sequence of images or a set of external assets in one step. Please contact me if you make updates or enhancements to this file. If you use QueueLoader, I'd love to hear about it. Special thanks to Felix Raab for the original AS2 version! Please contact me if you find any errors or bugs in the class or documentation.
		 *
		 * @todo: HTTP error event processing
		 * @todo: Convert targ to container for clarity
		 * @todo: add FLV loading
		 * @todo: Bandwidth checking?
		 * @todo: add undefined target error dispatch
		 *
		 * @history 03.08.2007 - 3.0 Initial port to AS3.0 (Donovan Adams)
		 * @history 03.16.2007 - 3.0.1 Added get method for data
		 * @history 08.10.2007 - 3.0.2 Rewrote data output using custom event QueueLoaderEvent class.
		 * @history 08.13.2007 - 3.0.3 Added QueueLoader progress and event.
		 * @history 08.14.2007 - 3.0.4 Added IO Error event.
		 * @history 09.10.2007 - 3.0.5 Fixed ITEM_INIT duped dispatching, changed item name to title to match custom event
		 * @history 09.14.2007 - 3.0.6 Added External mp3 and filetype cheking as well as direct access to file for easier swf access
		 * @history 10.29.2007 - 3.0.7 Added LoaderContext for accessing loaded class references/Added stopping of loading/Loader unloading of memory for Garbage Collection
		 * @history 10.29.2007 - 3.0.8 Added CSS/XML filetype, Optimized Loader, removeItemAt
		 *
		 * @example This example shows how to use QueueLoader in a basic application:
				<code>
					import com.hydrotik.utils.QueueLoader;
					import com.hydrotik.utils.QueueLoaderEvent;
					
					
					//Instantiate the QueueLoader
					var _oLoader:QueueLoader = new QueueLoader();
					
					//Run a loop that loads 3 images from the flashassets/images/slideshow folder
					var image:Sprite = new Sprite();
					addChild(image);
					//Add a load item to the loader
					_oLoader.addItem(prefix("") + "flashassets/images/slideshow/1.jpg", image, {title:"Image"});
					
					//Add event listeners to the loader
					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_START, onQueueStart, false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.ITEM_START, onItemStart, false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.ITEM_PROGRESS, onItemProgress, false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.ITEM_INIT, onItemInit,false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.ITEM_ERROR, onItemError,false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_PROGRESS, onQueueProgress, false, 0, true);
					_oLoader.addEventListener(QueueLoaderEvent.QUEUE_INIT, onQueueInit,false, 0, true);
					
					//Run the loader
					_oLoader.execute();
					
					//Listener functions
					function onQueueStart(event:QueueLoaderEvent):void {
						trace(">> "+event.type);
					}
					
					function onItemStart(event:QueueLoaderEvent):void {
						trace("\t>> "+event.type, "item title: "+event.title);
					}
					
					function onItemProgress(event:QueueLoaderEvent):void {
						trace("\t>> "+event.type+": "+[" percentage: "+event.percentage]);
					}
					
					function onQueueProgress(event:QueueLoaderEvent):void {
						trace("\t>> "+event.type+": "+[" queuepercentage: "+event.queuepercentage]);
					}
					
					function onItemInit(event:QueueLoaderEvent):void {
						trace("\t>> name: "+event.title + " event:" + event.type+" - "+["target: "+event.targ, "w: "+event.width, "h: "+event.height]+"\n");
					}
					
					function onItemError(event:QueueLoaderEvent):void {
						trace("\n>>"+event.message+"\n");
					}
					
					function onQueueInit(event:QueueLoaderEvent):void {
						trace("** "+event.type);
					}
				</code>
		 */ 
		/**
		 * @param	ignoreErrors:Boolean false for stopping the queue on an error, true for ignoring errors.
		 * @return	void
		 * @description Contructor for QueueLoader
		 */
        public function QueueLoader(ignoreErrors:Boolean = false, loaderContext:LoaderContext = null) {
			dispatcher = new EventDispatcher(this);
			reset();
			_loaderContext = loaderContext;
			_loader = new Loader();
			_uLoader = new URLLoader();
			_ignoreErrors = ignoreErrors;
            configureListeners(_loader.contentLoaderInfo);
        }
		/**
		 * @param	url:String - asset file path
		 * @param	targ:* - target location
		 * @param	info:Object - data
		 * @return	void
		 * @description Adds an item to the loading queue
		 */
		public function addItem(url:String, targ:*, info:Object):void{
			addItemAt(queuedItems.length, url, targ, info);
			
		}
		
		/**
		 * @param	index:Number - insertion index
		 * @param	url:String - asset file path
		 * @param	targ:* - target location
		 * @param	info:Object - data to be stored and retrieved later
		 * @return	void
		 * @description Adds an item to the loading queue at a specific position
		 */
		public function addItemAt(index:Number, url:String, targ:*, info:Object):void {
			queuedItems.splice(index, 0, {url:url, targ:targ, info:info});
			itemsToInit.splice(index, 0, {url:url, targ:targ, info:info});
			if(isLoading) _max++;
			//trace("______________== MAX: "+_max);
		}
		
		/**
		 * @param	index:Number - removal index
		 * @return	void
		 * @description Removes an item to the loading queue at a specific position
		 */
		public function removeItemAt(index:Number):void {
			queuedItems.splice(index, 1);
			itemsToInit.splice(index, 1);
			if(isLoading) _max--;
			//trace("______________== MAX: "+_max);
		}
		
		/**
		 * @param	index:Number - removal index
		 * @return	void
		 * @description allows input of a sort function for sorting the array see Array.sort();
		 */
		public function sort(... args):void {
			queuedItems.sort(args);
			itemsToInit.sort(args);
		}
		
		/**
		 * @description Executes the loading sequence
		 * @return	void
		 */
		public function execute():void {
			isStarted = true;
			isLoading = true;
			isStopped = false;
			loadNextItem();	
		}
		
		
		
		/**
		 * @description Stops Loading
		 * @return	void
		 */
		public function stop():void {
			isStarted = true;
			isLoading = false;
			isStopped = true;		
			reset();
		}
		
		
		/**
		 * @description Removes Items Loaded from memory for Garbage Collection
		 */
		public function dispose():void {
			for(var i:int = 0; i<loadedItems.length;i++){
				loadedItems[i].loaderInfo.loader.unload();
				loadedItems[i] = null;
			}
			_loader = null;
			_max = 0;
			reset();
		}
		
		
		
		
		// --== Implemented interface methods ==--
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void{
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
			   
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
					   
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
		
		
		
		
		// --== Private Methods ==--
		
		// --== Listeners and Handlers ==--
        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.INIT, completeHandler, false, 0, true);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
            dispatcher.addEventListener(Event.OPEN, openHandler, false, 0, true);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
        }

       

        private function ioErrorHandler(event:IOErrorEvent):void {
			if(event.text != ""){
				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "io error: "+event.text + " could not be loaded into " + currItem.targ.name, _count, queuedItems.length, _max));
				if(_ignoreErrors){
					loadedItems.push(currItem.targ);	
					_count++;
					isQueueComplete();
				}
			}
		}

        private function openHandler(event:Event):void {
			if (isStarted) {
				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_START, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, 0, 0, 0, "", _count, queuedItems.length, _max));
				isStarted = false;		
			}
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_START, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max));
        }

        private function progressHandler(event:ProgressEvent):void { 
			if (isLoading){
				_queuepercentage =  (((_count * (100/(_max + 1))) + ((event.bytesLoaded/event.bytesTotal) * (100/(_max + 1)))) * .01);
				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_PROGRESS, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, event.bytesLoaded, event.bytesTotal, event.bytesLoaded/event.bytesTotal, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max));
				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_PROGRESS, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, event.bytesLoaded, event.bytesTotal, event.bytesLoaded/event.bytesTotal, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max));
			}
		}
		
		private function completeHandler(event:Event):void {
			
			event.target.removeEventListener(Event.INIT, completeHandler);
			event.target.removeEventListener(Event.COMPLETE, completeHandler);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			event.target.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            event.target.removeEventListener(Event.OPEN, openHandler);
          
			
			//trace("**** "+event.target.hasEventListener(Event.COMPLETE))
			var w:Number = 0;
			var h:Number = 0;
			
			if(_currType == FILE_XML){
				trace("currItem.targ: "+currItem.targ);
				_currFile = event.target.data;
				currItem.targ = new XML(_currFile);
			}
			
			if(_currType == FILE_CSS){
				_currFile = event.target.data;
			}
			
			if(_currType == FILE_IMAGE || _currType == FILE_SWF){
				var loader:Loader = Loader(event.target.loader);
				loadedItems.push(loader.content);
				 _currFile = loader.content;
				var info:LoaderInfo = LoaderInfo(event.target);
				w = info.width;
				h = info.height;
			}
			
			
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_INIT, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 100, _queuepercentage, w, h,  "", _count, queuedItems.length, _max));
			_count++;
			
			isQueueComplete();
        }
		
		private function loadNextItem():void {		
			currItem = queuedItems.shift();		
				if (!isStopped) {				
					_currType = 0;
					if(currItem.url.match(".jpg") != null) _currType = FILE_IMAGE;
					if(currItem.url.match(".gif") != null) _currType = FILE_IMAGE;
					if(currItem.url.match(".png") != null) _currType = FILE_IMAGE;
					if(currItem.url.match(".swf") != null) _currType = FILE_SWF;
					if(currItem.url.match(".mp3") != null) _currType = FILE_AUDIO;
					if(currItem.url.match(".css") != null) _currType = FILE_CSS;
					if(currItem.url.match(".xml") != null) _currType = FILE_XML;
					var request:URLRequest = new URLRequest(currItem.url);
					switch (_currType) {
						case FILE_IMAGE:
							//trace("Image File");
							if (currItem.targ == undefined) {	
								dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "QueueLoader error: "+currItem.info.title + " could not be loaded into " + currItem.targ.name + "/" + currItem.targ.name, _count, queuedItems.length, _max));
							} else {
								_loader = new Loader();
								configureListeners(_loader.contentLoaderInfo);
								_loader.load(request, _loaderContext);
								currItem.targ.addChild(_loader);
							}
							break;
						case FILE_SWF:
							//trace("External SWF File");
							if (currItem.targ == undefined) {	
								dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "QueueLoader error: "+currItem.info.title + " could not be loaded into " + currItem.targ.name + "/" + currItem.targ.name, _count, queuedItems.length, _max));
							} else {
								_loader = new Loader();
								configureListeners(_loader.contentLoaderInfo);
								_loader.load(request, _loaderContext);
								currItem.targ.addChild(_loader);
							}
							break;
						case FILE_AUDIO:
							//trace("External Audio");
							currItem.targ.addEventListener(Event.COMPLETE, completeHandler);
							currItem.targ.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
							currItem.targ.addEventListener(ProgressEvent.PROGRESS, progressHandler);
							currItem.targ.load(request);
							break;
						case FILE_XML:
							//trace("XML");
							_uLoader = new URLLoader();
							_uLoader.addEventListener(Event.COMPLETE, completeHandler);
            				_uLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            				_uLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
							_uLoader.load(request);
							break;
						case FILE_CSS:
							//trace("CSS");
							_uLoader = new URLLoader();
							_uLoader.addEventListener(Event.COMPLETE, completeHandler);
            				_uLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            				_uLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
							_uLoader.load(request);
							break;
						default:
							trace("None Detected");
					}
					//request = null;
			}	
			
		}
		
		//--== checks for completion ==--
		private function isQueueComplete():void {
			if (!isStopped) {		
				if (queuedItems.length == 0) {	
					isLoading = false;
					loadedItems = loadedItems;	
					dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_INIT, currItem.targ, _currFile, currItem.url, currItem.info.title, _currType, 0, 0, 0, _queuepercentage, 0, 0, "", _count, queuedItems.length, _max));
					//reset()
				} else {
					loadNextItem();
				}			
			}
		}
		
		
		// --== resets data ==--
		private function reset():void {
			//trace(_queuepercentage);
			_count = 0;
			//loadedItems = null;
			_queuepercentage = 0;
			queuedItems = new Array();
			itemsToInit = new Array();
			loadedItems = new Array();
			currItem = null;
			_currFile = null;	
			_max = 0;
			_queuepercentage = 0;
			
			if(dispatcher.hasEventListener(Event.INIT) && dispatcher != null) dispatcher.removeEventListener(Event.INIT, completeHandler);
            if(dispatcher.hasEventListener(IOErrorEvent.IO_ERROR) && dispatcher != null) dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            if(dispatcher.hasEventListener(Event.OPEN) && dispatcher != null) dispatcher.removeEventListener(Event.OPEN, openHandler);
            if(dispatcher.hasEventListener(ProgressEvent.PROGRESS) && dispatcher != null) dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
    }
}