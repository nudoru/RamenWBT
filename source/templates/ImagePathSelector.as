package {
	
	import ramen.common.*;
	import ramen.page.*;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;
	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.BMUtils;
	import com.pixelfumes.reflect.*;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class ImagePathSelector extends Template {
		
		private var _Lists			:Array;
		
		private var _ImageAssets	:Array;
		
		private var _SelectedListIdx:int;
		private var _SelectedItemIdx:int;

		public function ImagePathSelector():void {
			_Lists = new Array();
			_ImageAssets = new Array();
			_SelectedListIdx = -1;
			_SelectedItemIdx = -1;
			
			super();		// will trigger renderInteraction()
			
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		override protected function renderInteraction():void {
			var x:XMLList = _PageRenderer.interactionXML;
			var len:int = x.list.length();
			for(var i:int=0; i<len; i++) {
				//_Lists.push(new PageList(XMLList(x.list[i])));
				_Lists.push(new PageList(x.list[i]));
			}
			if (_Lists.length) renderList(0);
		}
		
		/*
		* Render the list
		*/
		
		private function renderList(n:int):void {
			var startScl:Number = .5;
			var listIdx:int = 0;
			
			var len:int = _Lists[n].numItems;
			
			var itemColX:int = _Lists[n].itemColumnX;
			var itemColY:int = _Lists[n].itemColumnY;
			var itemColWidth:int = _Lists[n].itemColumnWidth;
			var itemColXSpc:int = _Lists[n].itemColumnSpacingX;
			
			if (!itemColWidth) itemColWidth = 180;
			if (!itemColXSpc) itemColXSpc = 25;
			if (!itemColX) itemColX = _PageRenderer.getPageCenteredX(((itemColWidth*startScl)*len)+(itemColXSpc*(len-1)))-(itemColWidth*startScl)/2;
			if (!itemColY) itemColY = _PageRenderer.pageCenterY - 75;
			
			for(var i:int=0; i<len; i++) {
				var xpos:int = itemColX
				var ypos:int = itemColY
				var cmc:SimpleListItem = new SimpleListItem();
				
				cmc.x = xpos + 90;
				cmc.y = ypos;
				cmc.scaleX = cmc.scaleY = startScl;
				applyDarkGlow(Sprite(cmc.imageLoader_mc));
				
				cmc.title_mc.title_txt.text = _Lists[n].getItemTitle(i);
				cmc.title_mc.title_txt.cacheAsBitmap = true;
				
				if(_Lists[n].getItemMediaURL(i)) {
					var il:ImageLoader = new ImageLoader(_Lists[n].getItemMediaURL(i), cmc.imageLoader_mc, {x:0,y:0,width:itemColWidth,height:itemColWidth,reflection:true});
					_ImageAssets.push(il);
					cmc.bg_mc.visible = false;
				} else {
					cmc.imageLoader_mc.visible = false
				}
				
				cmc.listIdx = n;
				cmc.itemIdx = i;
				
				_PageRenderer.interactionLayer.addChild(cmc);
				itemColX += (itemColWidth * startScl) + itemColXSpc;
				
				// just a little beginning animation
				if (true) {
					var ty:int = ypos + 90;
					var ts:int = cmc.scaleX;
					var dly:Number = (i + 1) * .15;
					cmc.y += 100
					cmc.scaleX = cmc.scaleY = 0;
					cmc.alpha = 0;
					TweenLite.to(Sprite(cmc), .75, {alpha:1, y:ty, scaleX:.5, scaleY:.5, delay:dly, ease:Back.easeOut, onComplete:enableItem, onCompleteParams:[cmc]});
				}
			}
			
		}

		private function enableItem(i:SimpleListItem):void {
			i.addEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			i.addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
			i.addEventListener(MouseEvent.CLICK, onItemClick);
			i.buttonMode = true;
			i.mouseChildren = false;
		}
		
		private function disableItem(i:SimpleListItem):void {
			TweenLite.killTweensOf(i);
			i.removeEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			i.removeEventListener(MouseEvent.MOUSE_OUT, onItemOut);
			i.removeEventListener(MouseEvent.CLICK, onItemClick);
			i.buttonMode = false;
		}
		
		private function disableAllItems():void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				disableItem(_PageRenderer.interactionLayer.getChildAt(i) as SimpleListItem);
			}
		}
		
		private function onItemOver(e:Event):void {
			_PageRenderer.interactionItemToTop(e.target);
			blurOthers(e.target as Sprite)
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				adjustSpriteOnMouseProx(Sprite(_PageRenderer.interactionLayer.getChildAt(i)),Sprite(e.target));
			}
		}
		
		private function onItemOut(e:Event):void {
			allBackToNormalScale()
		}
		
		private function onItemClick(e:Event):void {
			_SelectedListIdx = SimpleListItem(e.target).listIdx;
			_SelectedItemIdx = SimpleListItem(e.target).itemIdx;
			fadeOtherItems(e.target as Sprite);
			TweenLite.to(Sprite(e.target), 1, {x:_PageRenderer.pageCenterX, y:_PageRenderer.pageCenterY-30, scaleX:2, scaleY:2, ease:Back.easeIn, onComplete:performItemAction});
			//performItemAction();
		}
		
		private function performItemAction():void {
			//trace("jump to "+_Lists[_SelectedListIdx].getItemLink(_SelectedItemIdx));
			jumpToPage(_Lists[_SelectedListIdx].getItemLink(_SelectedItemIdx),_Lists[_SelectedListIdx].getItemLink(_SelectedItemIdx));
		}
		
		private function adjustSpriteOnMouseProx(mc:Sprite,mc2:Sprite):void {
			var dx:int = mc2.x - mc.x;
			var dy:int = mc2.y - mc.y;
			var ds:Number = Math.sqrt(Math.pow(Math.abs(dx), 2) + Math.pow(Math.abs(dy), 2));
			var tgtscl:Number = ((800 * .5) - ds) * .3;
			if (tgtscl > 100) tgtscl = 100;
			if (tgtscl < 20) tgtscl = 20;
			tgtscl *= .01;
			TweenLite.to(mc, .5, {alpha:tgtscl, scaleX:tgtscl, scaleY:tgtscl, ease:Quadratic.easeOut});
		}
		
		private function allBackToNormalScale():void {
			clearBlur();
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				TweenLite.to(Sprite(_PageRenderer.interactionLayer.getChildAt(i)), 2, {alpha:1, scaleX:.5, scaleY:.5, ease:Quadratic.easeOut});
			}
		}
		
		private function fadeOtherItems(excl:Sprite):void {
			disableAllItems();
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				if (Sprite(_PageRenderer.interactionLayer.getChildAt(i)) == excl) continue;
				TweenLite.to(Sprite(_PageRenderer.interactionLayer.getChildAt(i)), 1, {alpha:0, scaleX:0, scaleY:0, ease:Back.easeIn});
			}
		}
		
		private function blurOthers(s:Sprite):void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				var c:Sprite = Sprite(_PageRenderer.interactionLayer.getChildAt(i));
				if (s == c) continue;
				BMUtils.applyBlurFilter(c,3,3);
			}
		}
		
		private function clearBlur():void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				BMUtils.clearAllFilters(Sprite(_PageRenderer.interactionLayer.getChildAt(i)));
			}
		}
	
		/*
		 * Support functions
		 */

		private function applyDarkGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0x000000;
			glow.alpha = .2;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
		private function applyDeepDarkGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0x000000;
			glow.alpha = .8;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
		private function applyLightGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0xffffff;
			glow.alpha = .5;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// misc
		
		private function unloadImages():void {
			for (var i:int = 0; i < _ImageAssets.length; i++) {
				_ImageAssets[i].destroy();
			}
		}
		
		// called by the player on page changes
		override public function destroy():void {
			disableAllItems();
			unloadImages();
			super.destroy();
		}
		
	}
}