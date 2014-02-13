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
	
	public class ListImageList extends ListTemplate {

		private var ImageAssets			:Array;
		
		public function ListImageList():void {
			super();
			ImageAssets = new Array();
			dataareabg_mc.visible = false;
		}

		override protected function startInteraction():void {
			//trace("start interaction");
			state = STATE_READY;
			_Lists[_CurrentList].start();
			
			_CurrentItem = -1;
			
			//setItem(0, 0);
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		override protected function renderItems():void {
			dataareabg_mc.visible = true;
			var posDefined:Boolean = true;
			
			var listX:int = _Lists[_CurrentList].itemColumnX;
			var listY:int = _Lists[_CurrentList].itemColumnY;
			var listWidth:int = _Lists[_CurrentList].itemColumnWidth;
			var listSpc:int = _Lists[_CurrentList].itemColumnSpacingX;

			var dataX:int = _Lists[_CurrentList].dataColumnX;
			var dataY:int = _Lists[_CurrentList].dataColumnY;
			var dataWidth:int = _Lists[_CurrentList].dataColumnWidth;
			var dataHeight:int = _Lists[_CurrentList].dataColumnHeight;
			var dataAreaBorder:int = 10;
			
			/*
			<itemsize>200</itemsize>
				<itemposition>20,150</itemposition>
				<itemspacing>25</itemspacing>
				<datasize>400,300</datasize>
				<dataposition>300,150</dataposition>
			*/
			
			if (!listX) {
				listX = _PageRenderer.pageBorderLeft;
				posDefined = false;
			}
			if (!listY) listY = _PageRenderer.bodyTFBottomY + (_PageRenderer.pageBorderTop*2);
			if (!listWidth) listWidth = _PageRenderer.pageWidthThird;
			if (!listSpc) listSpc = 10;
			if (!dataX) dataX = _PageRenderer.pageWidthThird +(_PageRenderer.pageBorderLeft*2);
			if (!dataY) dataY = _PageRenderer.bodyTFBottomY + (_PageRenderer.pageBorderTop*2);
			if (!dataWidth) dataWidth = (_PageRenderer.pageWidthThird * 2) - (_PageRenderer.pageBorderTop * 2);
			if (!dataHeight) dataHeight = _PageRenderer.pageHeight - (_PageRenderer.pageBorderTop * 4) - _PageRenderer.bodyTFBottomY;
			
			dataareabg_mc.visible = true;
			dataareabg_mc.x = dataX-dataAreaBorder;
			dataareabg_mc.y = dataY - dataAreaBorder;
			dataareabg_mc.scaleX = (dataWidth+(dataAreaBorder*2))*.01;
			dataareabg_mc.scaleY = (dataHeight + (dataAreaBorder * 2)) * .01;

			var len:int = _Lists[_CurrentList].numItems;
			var cY:int = dataY;
			
			for (var i:int = 0; i < len; i++ ) {
				var hasImage:Boolean = false;
				var c:ChoiceItem = new ChoiceItem();
				c.listIdx = _CurrentList;
				c.itemIdx = i;

				c.x = listX;
				c.y = cY;
				c.setOrigionalProps();
				
				if (_Lists[_CurrentList].getItemImageURL(i)) {
					hasImage = true;
					var il:ImageLoader = new ImageLoader(_Lists[_CurrentList].getItemImageURL(i), c.imageloader_mc, {x:0,y:0,width:_Lists[_CurrentList].getItemImageWidth(i),height:_Lists[_CurrentList].getItemImageHeight(i)});
					ImageAssets.push(il);
				} else {
					c.imageloader_mc.visible = false
				}
				
				c.bg_mc.alpha = 0;
				c.hi_mc.alpha = 0;
				
				var tw:int = 0;
				var th:int = 0;
				
				if(!hasImage) {
					c.text_txt.width = listWidth-10;
					c.text_txt.autoSize = TextFieldAutoSize.LEFT;
					c.text_txt.wordWrap = true;
					c.text_txt.multiline = true;
					c.text_txt.text = _Lists[_CurrentList].getItemTitle(i);
					_PageRenderer.changeTextFieldSize(c.text_txt);
					c.text_txt.width = c.text_txt.textWidth + 10;
					tw = c.text_txt.textWidth + 20;
					th = 10 + c.text_txt.height;
				} else {
					c.text_txt.text = "";
					tw = _Lists[_CurrentList].getItemImageWidth(i)+10;
					th = _Lists[_CurrentList].getItemImageHeight(i) + 10;
				}
				
				c.bg_mc.scaleX = tw * .01;
				c.hi_mc.scaleX = tw * .01;

				c.bg_mc.scaleY = (th) * .01;
				c.hi_mc.scaleY = (th) * .01;
				
				if (hasImage && !posDefined) {
					c.x = ((dataX - listX) / 2) - (tw / 2);
					c.x += listX;
				}
				
				trace(_Lists[_CurrentList].getItemX(i)+", "+_Lists[_CurrentList].getItemY(i))
				
				if (_Lists[_CurrentList].getItemX(i)) {
					c.x = _Lists[_CurrentList].getItemX(i);
					c.y = _Lists[_CurrentList].getItemY(i);
				}
				
				_PageRenderer.interactionLayer.addChild(c);
				_Lists[_CurrentList].setItemRefMC(i, c);

				if (_Animate) {
					c.alpha = 0;
					TweenLite.to(c, 1, { alpha:1, delay:(i*.5), ease:Quadratic.easeOut, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
				
				cY += listSpc + (c.bg_mc.scaleY*100);
			}
		
		}
		
		override protected function onItemOver(e:Event):void {
			TweenLite.to(e.target.hi_mc, .25, { alpha:.25, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemOut(e:Event):void {
			TweenLite.to(e.target.hi_mc, .5, { alpha:0, ease:Quadratic.easeOut } );
		}
		
		override protected function onItemClick(e:Event):void {
			var l:int = ChoiceItem(e.target).listIdx;
			var i:int = ChoiceItem(e.target).itemIdx;
			setItem(l, i);
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
			if (l == _CurrentList && c == _CurrentItem) return;
			
			removeLastItem();
			
			_CurrentList = l;
			_CurrentItem = c;
			_Lists[_CurrentList].setItemCompleted(_CurrentItem);
			
			var dataX:int = _Lists[_CurrentList].dataColumnX;
			var dataY:int = _Lists[_CurrentList].dataColumnY;
			var dataWidth:int = _Lists[_CurrentList].dataColumnWidth;

			if (!dataX) dataX = _PageRenderer.pageWidthThird +(_PageRenderer.pageBorderLeft*2);
			if (!dataY) dataY = _PageRenderer.bodyTFBottomY + (_PageRenderer.pageBorderTop*2);
			if (!dataWidth) dataWidth = (_PageRenderer.pageWidthThird * 2) - (_PageRenderer.pageBorderTop * 2);
			
			var mc:DataItem = new DataItem();
			
			mc.x = dataX;
			mc.y = dataY;
			mc.text_txt.width = dataWidth;
			mc.text_txt.autoSize = TextFieldAutoSize.LEFT;
			mc.text_txt.wordWrap = true;
			mc.text_txt.multiline = true;
			mc.text_txt.htmlText = "<b>"+_Lists[_CurrentList].getItemTitle(_CurrentItem)+"</b><br><br>"+_Lists[_CurrentList].getItemText(_CurrentItem);
			
			_PageRenderer.changeTextFieldSize(mc.text_txt);
			
			_PageRenderer.interactionLayer.addChild(mc);
			_Lists[_CurrentList].setItemDataRefMC(_CurrentItem, mc);
			
			loadCurrentItemSheet(mc.sheetLayer_mc);
			
			mc.alpha = 0;
			TweenLite.to(mc, .5, { alpha:1, ease:Quadratic.easeOut} );
		}
		
		override protected function removeLastItem():void {
			if (_CurrentItem < 0) return;
			var mc:MovieClip = _Lists[_CurrentList].getItemDataRefMC(_CurrentItem);
			unloadCurrentItemSheet();
			//if(f) {
				//TweenLite.to(mc, .25, { y:"+50", alpha:0, ease:Quadratic.easeOut, onComplete:destroyItemDataMC, onCompleteParams:[mc] } );
			//} else {
				destroyItemDataMC(mc);
			//}
		}
		
		protected function destroyItemDataMC(mc:MovieClip):void {
			mc.visible = false;
			_PageRenderer.interactionLayer.removeChild(mc);
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