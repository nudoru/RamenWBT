/*
List, Simple, Reveal with image

*/

package {

	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	public class ListSimpleRevealImage extends ListTemplate {

		private var ImageAssets			:Array;
		
		public function ListSimpleRevealImage():void {
			super();
			
			ImageAssets = new Array();
		}

		override protected function startInteraction():void {
			state = STATE_READY;
			_Lists[_CurrentList].start();
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderItems():void {
			var x:int = _Lists[_CurrentList].listX;
			var y:int = _Lists[_CurrentList].listY;

			var cWidth:int = _Lists[_CurrentList].listWidth;
			if (!x) x = _PageRenderer.pageBorderLeft + 50;
			if (!y) y = _PageRenderer.bodyTFBottomY + 30;
			if (!cWidth) cWidth = 200;
			
			var xGutter:int = 10;
			var ySpc:int = 10;
			var len:int = _Lists[_CurrentList].numItems;
			
			for (var i:int = 0; i < len; i++) {
				var c:ChoiceItem = new ChoiceItem();
				c.listIdx = _CurrentList;
				c.itemIdx = i;

				c.x = x;
				c.y = y;
				
				var imgWidth = 0;
				var imgHeight = 0;
				
				if(_Lists[_CurrentList].getItemImageURL(i)) {
					var il:ImageLoader = new ImageLoader(_Lists[_CurrentList].getItemImageURL(i), c.imageloader_mc, {x:0,y:0,width:_Lists[_CurrentList].getItemImageWidth(i),height:_Lists[_CurrentList].getItemImageHeight(i)});
					ImageAssets.push(il);
					imgWidth = _Lists[_CurrentList].getItemImageWidth(i);
					imgHeight = _Lists[_CurrentList].getItemImageHeight(i);
				} else {
					c.imageloader_mc.visible = false
				}

				c.hi_mc.alpha = 0;
				c.text_txt.width = cWidth;
				c.text_txt.autoSize = TextFieldAutoSize.LEFT;
				c.text_txt.wordWrap = true;
				c.text_txt.multiline = true;
				c.text_txt.htmlText = _Lists[_CurrentList].getItemText(i);
				_PageRenderer.changeTextFieldSize(c.text_txt);
				
				if (_Lists[_CurrentList].autoSizeParts) c.text_txt.width = c.text_txt.textWidth+5;

				if (imgWidth > 0) c.text_txt.x += imgWidth + xGutter;
				
				if (imgHeight > c.text_txt.height) c.text_txt.y = (imgHeight / 2) - (c.text_txt.height / 2);
				
				var cHeight:int = (imgHeight > c.text_txt.height ? imgHeight : c.text_txt.height);
				
				c.hi_mc.scaleX = (c.text_txt.x + c.text_txt.width+5) * .01;
				c.hi_mc.scaleY = (cHeight) * .01;
				
				c.bg_mc.scaleX = (c.text_txt.x + c.text_txt.width+11) * .01;
				c.bg_mc.scaleY = (cHeight + 6) * .01;
				
				c.text_txt.alpha = 0;
				c.text_txt.x -= 50;
				
				_PageRenderer.interactionLayer.addChild(c);
				_Lists[_CurrentList].setItemRefMC(i, c);
				
				if (_Animate) {
					c.alpha = 0;
					c.x -= 500;
					TweenLite.to(c, 1, { alpha:1, x:x, delay:(i*.5), ease:Back.easeOut, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
				
				y += ySpc + cHeight;
			}

		}
		
		override protected function enableItem(l:int, c:int):void {
			var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = true;
			mc.mouseChildren = false;
			mc.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.addEventListener(MouseEvent.CLICK, onItemClick);
			//AccessibilityManager.getInstance().addActivityItem(mc, "List Item "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableItem(l:int, c:int):void {
			var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = false;
			mc.removeEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.removeEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.removeEventListener(MouseEvent.CLICK, onItemClick);
		}

		override protected function onItemOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemClick(e:Event):void {
			var l:int = ChoiceItem(e.target).listIdx;
			var c:int = ChoiceItem(e.target).itemIdx;
			setItem(l, c);
		}

		override protected function setItem(l:int, c:int):void {
			if (_Lists[l].isItemCompleted(c)) {
				return;
			}
			_Lists[l].setItemCompleted(c);
			var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.bg_mc.gotoAndStop(2);
			TweenLite.to(mc.text_txt, 1, { alpha:1, x:(mc.text_txt.x+50), ease:Back.easeOut } );
			TweenLite.to(mc.hi_mc, .25, { alpha:0, ease:Quadratic.easeOut } );
			disableItem(l, c);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		protected function killAllItemAnimations():void {
			var len:int = _Lists[_CurrentList].numItems;
			for (var i:int = 0; i < len; i++) {
				TweenLite.killTweensOf(_Lists[_CurrentList].getItemRefMC(i));
			}
		}
		
		protected function unloadImages():void {
			for (var i:int = 0; i < ImageAssets.length; i++) {
				ImageAssets[i].destroy();
			}
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			killAllItemAnimations();
			unloadImages();
			// destroy interaction specific content
			disableAllLists();
			stopAllLists();

			super.destroy();
		}
		
	}
}