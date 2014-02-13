/*
This class should be uses as a base for creating custom page content.
*/

package {
	
	import ramen.common.*;
	import ramen.page.*;
	import ramen.sheet.*;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class GenericTemplate extends Template {
		
		public function GenericTemplate():void {
			// initialized the template and will trigger renderPageCustomContent()
			super();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// rendering
		
		// all template specific stuff goes here
		override protected function renderInteraction():void {
			// get the XML from the pages' <customcontent> block
			var x:XMLList = _PageRenderer.interactionXML;			
			
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// from player
		
		override public function handlePopUpEvent(e:PopUpEvent):void {
			trace("template from PM, type: " + e.type + ", from: "+e.data+" to: " + e.callingobj+" about: "+e.buttondata);
		}
		
		override public function handleKeyPress(k:int, isAlt:Boolean = false, isCtrl:Boolean = false, isShift:Boolean = false, l:int=0):void {
			trace("template from PM, keycode: " + k + " alt: " + isAlt + " ctrl: " + isCtrl + " shift: " + isShift + " location: " + l);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// util
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			//trace("generictemplate, destroy!");
			super.destroy();
			// destroy any interaction content here
		}
		
	}
}