/*
Base class for a Centered site
last updated: 2.17.08

Tweener docs: http://hosted.zeh.com.br/tweener/docs/en-us/
*/

package ramen.player {
	
	import ramen.common.*;
	import ramen.player.*;
	
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.events.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	import com.nudoru.utils.BMUtils;
	import com.nudoru.utils.Debugger;
	
	public class CenteredView extends AbstractView implements ISiteView{
		
		private var _DLog				:Debugger;
		
		public static const LOADED		:String = "loaded";
		
		public function CenteredView(cntr:Sprite,d:SiteModel):void {
			super(cntr,d);
			
			_DLog = Debugger.getInstance();
			_DLog.addDebugText("CenteredView, init'd");
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// UI Navigation
		
		override public function onPageChange(e:Event):void {
			updateUI();
		}
		
		override public function updateUI():void {
			//_DLog.addDebugText("CenteredView, VIEW UPDATE UI");
			updateResourcesOnPageChange();
		}

		//----------------------------------------------------------------------------------------------------------------------------------
		// UI Adjust
		
		override public function adjustUI(a:Boolean):void {
			// default to centered locations
			var tgtX:int = (_ViewContainter.stage.stageWidth >> 1) - (_ConfigSiteWidth >> 1);
			var tgtY:int = (_ViewContainter.stage.stageHeight >> 1) - (_ConfigSiteHeight >> 1);
			
			if(_ConfigHAlign == "left") tgtX = 0;
			if(_ConfigHAlign == "right") tgtX = _ViewContainter.stage.stageWidth - _ConfigSiteWidth;
			if(_ConfigVAlign == "top") tgtY = 0;
			if(_ConfigVAlign == "bottom") tgtY = _ViewContainter.stage.stageHeight - _ConfigSiteHeight;
			
			if(_ConfigHSnap > 9) {
				tgtX -= tgtX % _ConfigHSnap;
				tgtY -= tgtY % _ConfigVSnap;
			}
			
			// keep the site from moving off of the stage
			if(tgtX < 0) tgtX = 0;
			if(tgtY < 0) tgtY = 0;
			
			if(!a) {
				_MainUICont.x = tgtX;
				_MainUICont.y = tgtY;
			} else {
				// animate
				TweenLite.to(_MainUICont, 1, {x:int(tgtX), y:int(tgtY), ease:Quadratic.easeOut, delay:.25});
			}

		}
	
	}
}