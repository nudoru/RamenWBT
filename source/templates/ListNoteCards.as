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
	
	public class ListNoteCards extends ListTemplate {

		private var ImageAssets			:Array;
		
		public function ListNoteCards():void {
			super();
			
			ImageAssets = new Array();
		}

		override protected function startInteraction():void {
			//trace("start interaction");
			state = STATE_READY;
			_Lists[_CurrentList].start();
			
			setItem(0, 0);
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderItems():void {
			var x:int = _Lists[_CurrentList].listX;
			var y:int = _Lists[_CurrentList].listY;

			if (!x) x = _PageRenderer.pageCenterX;
			if (!y) y = _PageRenderer.bodyTFBottomY + 30;

			var len:int = _Lists[_CurrentList].numItems-1;
			
			for (var i:int = len; i > -1; i--) {
				var c:ChoiceItem = new ChoiceItem();
				c.listIdx = _CurrentList;
				c.itemIdx = i;

				c.x = x;
				c.y = y;

				c.next_btn.visible = c.prev_btn.visible = false;
				
				c.title_txt.htmlText = _Lists[_CurrentList].getItemTitle(i);
				_PageRenderer.changeTextFieldSize(c.title_txt);
				
				c.text_txt.htmlText = _Lists[_CurrentList].getItemText(i);
				_PageRenderer.changeTextFieldSize(c.text_txt);
				
				_PageRenderer.interactionLayer.addChild(c);
				_Lists[_CurrentList].setItemRefMC(i, c);
				
				c.scaleX = c.scaleY = .9
				
				c.rotation = rnd( -5, 5);
				
				c.setOrigionalProps();
				
				if (_Animate&& false) {
					c.x = -1500;
					c.y = -1100;
					c.rotation = rnd(0, 200);
					TweenLite.to(c, 1, { alpha:1, x:c.origionalXPos, y:c.origionalYPos, rotation:c.origionalRotation, delay:((len-i+1)*.5), ease:Quadratic.easeOut, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
			}

		}
		
		override protected function onItemOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemClick(e:Event):void {
			//
		}

		// only supports 1 list for now
		override protected function nextItem(e:*=null):void {
			var nitm:int = _CurrentItem + 1;
			if (nitm > _Lists[_CurrentList].numItems - 1) return;
			setItem(_CurrentList, nitm);
		}
		
		// only supports 1 list for now
		override protected function prevItem(e:*=null):void {
			var nitm:int = _CurrentItem - 1;
			if (nitm < 0) return;
			setItem(_CurrentList, nitm);
		}
		
		override protected function setItem(l:int, c:int):void {
			removeLastItem();
			_CurrentList = l;
			_CurrentItem = c;
			hideCardsBeforeIdx(_CurrentItem);
			_Lists[_CurrentList].setItemCompleted(_CurrentItem);
			var mc:MovieClip = _Lists[_CurrentList].getItemRefMC(_CurrentItem);
			mc.next_btn.visible = mc.prev_btn.visible = false;
			if (_CurrentItem > 0) {
				mc.prev_btn.visible = true;
				mc.prev_btn.addEventListener(MouseEvent.CLICK, prevItem);
			}
			if (_CurrentItem < _Lists[_CurrentList].numItems - 1) {
				mc.next_btn.visible = true;
				mc.next_btn.addEventListener(MouseEvent.CLICK, nextItem);
			}
			loadCurrentItemSheet(mc.sheetLayer_mc);
			TweenLite.killTweensOf(mc);
			TweenLite.to(mc, .5, { x:mc.origionalXPos, y:mc.origionalYPos, rotation:0, ease:Quadratic.easeOut} );
		}
		
		protected function hideCardsBeforeIdx(c:int):void {
			var len:int = _Lists[_CurrentList].numItems-1;
			for (var i:int = 0; i < len; i++) {
				var mc:ChoiceItem = _Lists[_CurrentList].getItemRefMC(i);
				TweenLite.killTweensOf(mc);
				if (i < c) {
					//mc.visible = false;
					//mc.rotation = ChoiceItem(mc).origionalRotation;
					TweenLite.to(mc, 1, { x:mc.origionalXPos+200, y:mc.origionalYPos+1000, rotation:rnd(-200,50), ease:Quadratic.easeIn} );
				} else {
					//mc.visible = true;
					TweenLite.to(mc, 1, { x:mc.origionalXPos, y:mc.origionalYPos, rotation:mc.origionalRotation, ease:Quadratic.easeOut} );
				}
			}
		}
		
		override protected function removeLastItem():void {
			var mc:MovieClip = _Lists[_CurrentList].getItemRefMC(_CurrentItem);
			mc.next_btn.visible = mc.prev_btn.visible = false;
			mc.prev_btn.removeEventListener(MouseEvent.CLICK, prevItem);
			mc.next_btn.removeEventListener(MouseEvent.CLICK, nextItem);
			unloadCurrentItemSheet();
		}
		
		override protected function enableItem(l:int, c:int):void {
			/*var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = true;
			mc.mouseChildren = false;
			mc.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.addEventListener(MouseEvent.CLICK, onItemClick);*/
			//AccessibilityManager.getInstance().addActivityItem(mc, "List Item "+String(LETTER_LIST[c]).toUpperCase(),String(LETTER_LIST[c]).toUpperCase());
		}
		
		override protected function disableItem(l:int, c:int):void {
			/*var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = false;
			mc.removeEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.removeEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.removeEventListener(MouseEvent.CLICK, onItemClick);*/
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
			removeLastItem();
			// destroy interaction specific content
			disableAllLists();
			stopAllLists();

			super.destroy();
		}
		
	}
}