/*
List, Simple, Reveal with image

image on front
image on back
sheet on back
sheet on front
position individual cards
*/

package {

	import com.nudoru.utils.SWFLoader;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.BMUtils;	
	import com.greensock.TweenLite;
	import fl.motion.easing.*;

	public class ListTermCard extends ListTemplate {

		private var ImageAssets			:Array;

		private var MinScale			:Number = .9;
		
		private static var CARD_WIDTH	:int = 180;
		private static var CARD_HEIGHT	:int = 250;
		
		public function ListTermCard():void {
			super();
			
			ImageAssets = new Array();
		}

		override protected function startInteraction():void {
			//trace("start interaction");
			
			state = STATE_READY;
			_Lists[_CurrentList].start();
			
			_CurrentItem = -1;
			
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		
		override protected function renderItems():void {
			var posDefined:Boolean = true;
			
			var listX:int = _Lists[_CurrentList].itemColumnX;
			var listY:int = _Lists[_CurrentList].itemColumnY;
			var listWidth:int = _Lists[_CurrentList].itemColumnWidth;
			
			if (!listX) {
				listX = _PageRenderer.pageBorderLeft;
				posDefined = false;
			}
			if (!listY) listY = ((_PageRenderer.pageHeight - _PageRenderer.bodyTFBottomY)/2)-(CARD_HEIGHT/2)+_PageRenderer.bodyTFBottomY;
			if (!listWidth) listWidth = _PageRenderer.pageWidthActual;
			
			var len:int = _Lists[_CurrentList].numItems;
			var cX:int = listX;
			
			var cardSpc:int = (listWidth - (CARD_WIDTH * len)) / (len - 1);
			
			for (var i:int = 0; i < len; i++ ) {

				var c:ChoiceItem = new ChoiceItem();
				c.choiceIdx = i;
				c.listIdx = _CurrentList;
				
				c.x = cX;
				c.y = listY;
				
				if (i % 2) c.y += 50;
				
				if (_Lists[_CurrentList].getItemX(i)) c.x = _Lists[_CurrentList].getItemX(i);
				if (_Lists[_CurrentList].getItemY(i)) c.y = _Lists[_CurrentList].getItemY(i);
				
				c.x += (CARD_WIDTH / 2);
				c.y += (CARD_HEIGHT / 2);
				
				c.front_mc.front_mc.stop();
				if (_Lists[_CurrentList].getItemFrontURL(i).length) {
					ImageAssets.push(new SWFLoader(_Lists[_CurrentList].getItemFrontURL(i), c.front_mc.imageloader_mc, { x:0, y:0, width:CARD_WIDTH, height:CARD_HEIGHT } ));
				} else {
					c.front_mc.front_mc.gotoAndStop(_Lists[_CurrentList].getItemStyle(i));				
					c.front_mc.text_txt.width = CARD_WIDTH-40;
					c.front_mc.text_txt.autoSize = TextFieldAutoSize.CENTER;
					c.front_mc.text_txt.wordWrap = true;
					c.front_mc.text_txt.multiline = true;
					c.front_mc.text_txt.text = _Lists[_CurrentList].getItemTitle(i);
					c.front_mc.text_txt.y = (CARD_HEIGHT / 2) - (c.front_mc.text_txt.height / 2);
				}
				
				if (_Lists[_CurrentList].getItemBackURL(i).length) {
					ImageAssets.push(new SWFLoader(_Lists[_CurrentList].getItemBackURL(i), c.back_mc.imageloader_mc, { x:0, y:0, width:CARD_WIDTH, height:CARD_HEIGHT } ));
				} else {
					c.back_mc.text_txt.text = _Lists[_CurrentList].getItemText(i);
					c.back_mc.text_txt.y = (CARD_HEIGHT / 2) - (c.back_mc.text_txt.height / 2);
				}
				c.back_mc.visible = false;
				
				_PageRenderer.interactionLayer.addChild(c);
				_Lists[_CurrentList].setItemRefMC(i, c);
				
				c.scaleX = c.scaleY = MinScale;
				
				c.setOrigionalProps();
				
				if (_Animate) {
					c.y = -500;
					c.rotation = rnd(0, 200);
					TweenLite.to(c, 1, { y:c.origionalYPos, rotation:c.origionalRotation, delay:((i+1)*.5), ease:Quadratic.easeOut, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
				
				cX += cardSpc + CARD_WIDTH;
			}
			
		}
		
		override protected function onItemOver(e:Event):void {
			TweenLite.to(e.target, 3, { x:e.target.x+rnd(-5,5), y:e.target.y+rnd(-5,5), rotation:rnd( -2, 2), ease:Quadratic.easeOut } );
			//if(ChoiceItem(e.target).selected) 
			itemToTop(e.target as MovieClip);
		}
		
		override protected function onItemOut(e:Event):void {
			TweenLite.to(e.target, 1, {x:e.target.x+rnd(-2,2), y:e.target.y+rnd(-2,2), rotation:rnd(-2,2), ease:Quadratic.easeOut } );
		}
		
		override protected function onItemClick(e:Event):void {
			setItem(_CurrentList, ChoiceItem(e.target).choiceIdx);
		}

		private function itemToTop(i:MovieClip):void {
			_PageRenderer.interactionLayer.setChildIndex(i, _PageRenderer.interactionLayer.numChildren - 1);
		}
		
		private function itemToBack(i:MovieClip):void {
			_PageRenderer.interactionLayer.setChildIndex(i, 0);
		}
		
		/*// only supports 1 list for now
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
		}*/
		
		override protected function setItem(l:int, c:int):void {
			_CurrentList = l;
			_CurrentItem = c;
			_Lists[_CurrentList].setItemCompleted(_CurrentItem);
			var mc:ChoiceItem = _Lists[_CurrentList].getItemRefMC(_CurrentItem);
			itemToTop(mc);
			disableItem(_CurrentList, c);
			if (!mc.selected) {
				mc.selected = true;
				loadItemSheet(c, mc.back_mc.sheetLayer_mc);
				TweenLite.to(mc, .25, { scaleX:0, scaleY:1.1, ease:Quadratic.easeOut, onComplete:finishFtoBFlip, onCompleteParams:[mc,c] } );
			} else {
				mc.selected = false;
				//unloadItemSheet(mc.back_mc.sheetLayer_mc);
				TweenLite.to(mc, .25, { scaleX:0, scaleY:1.1, ease:Quadratic.easeOut, onComplete:finishBtoFFlip, onCompleteParams:[mc,c] } );
			}
		}
	
		private function finishFtoBFlip(c:ChoiceItem,i:int):void {
			c.front_mc.visible = false;
			c.back_mc.visible = true;
			TweenLite.to(c, .25, { scaleX:1, scaleY:1, rotation:0, ease:Quadratic.easeIn, onComplete:completeFlip, onCompleteParams:[c, i, false]} );
		}
		
		private function finishBtoFFlip(c:ChoiceItem,i:int):void {
			c.front_mc.visible = true;
			c.back_mc.visible = false;
			TweenLite.to(c, .25, { scaleX:MinScale, scaleY:MinScale, rotation:rnd(-5,5), ease:Quadratic.easeIn, onComplete:completeFlip, onCompleteParams:[c, i, true]} );
		}
		
		private function completeFlip(c:ChoiceItem, i:int, d:Boolean):void {
			enableItem(_CurrentList, i);
			if (d) itemToBack(c);
		}
		
		private function loadItemSheet(c:int, t:Sprite):void {
			if (ChoiceItem(_Lists[_CurrentList].getItemRefMC(c)).sheet) return;
			var sXML:XMLList = _Lists[_CurrentList].getItemSheetXML(c);
			if (!sXML.length()) return;
			ChoiceItem(_Lists[_CurrentList].getItemRefMC(c)).sheet = new Sheet();
			ChoiceItem(_Lists[_CurrentList].getItemRefMC(c)).sheet.initialize(sXML, t);
			ChoiceItem(_Lists[_CurrentList].getItemRefMC(c)).sheet.addEventListener(Sheet.RENDERED, onSheetRendered);
			ChoiceItem(_Lists[_CurrentList].getItemRefMC(c)).sheet.checkSheetLoaded();
		}
		
		override protected function onSheetRendered(e:Event):void {
			e.target.removeEventListener(Sheet.RENDERED, onSheetRendered);
			e.target.start();
		}
		
		override protected function removeLastItem():void {
			var mc:MovieClip = _Lists[_CurrentList].getItemRefMC(_CurrentItem);
			mc.next_btn.visible = mc.prev_btn.visible = false;
			mc.prev_btn.removeEventListener(MouseEvent.CLICK, prevItem);
			mc.next_btn.removeEventListener(MouseEvent.CLICK, nextItem);
			unloadCurrentItemSheet();
		}
		
		override protected function enableItem(l:int, c:int):void {
			var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = true;
			//mc.front_mc.mouseChildren = false;
			//mc.back_mc.mouseChildren = false;
			mc.mouseChildren = false;
			mc.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.addEventListener(MouseEvent.CLICK, onItemClick);
		}
		
		override protected function disableItem(l:int, c:int):void {
			var mc:MovieClip = _Lists[l].getItemRefMC(c);
			mc.buttonMode = false;
			mc.removeEventListener(MouseEvent.ROLL_OVER, onItemOver);
			mc.removeEventListener(MouseEvent.ROLL_OUT, onItemOut);
			mc.removeEventListener(MouseEvent.CLICK, onItemClick);
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
		
		protected function unloadItemSheets():void {
			var len:int = _Lists[_CurrentList].numItems;
			for (var i:int = 0; i < len; i++) {
				if (ChoiceItem(_Lists[_CurrentList].getItemRefMC(i)).sheet) {
					ChoiceItem(_Lists[_CurrentList].getItemRefMC(i)).sheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
					ChoiceItem(_Lists[_CurrentList].getItemRefMC(i)).sheet.stop();
					ChoiceItem(_Lists[_CurrentList].getItemRefMC(i)).sheet.destroy();
					ChoiceItem(_Lists[_CurrentList].getItemRefMC(i)).sheet = null;
				}
			}
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			killAllItemAnimations();
			unloadImages();
			unloadItemSheets();
			removeLastItem();
			// destroy interaction specific content
			disableAllLists();
			stopAllLists();

			super.destroy();
		}
		
	}
}