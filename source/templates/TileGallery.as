package {
	
	import ramen.common.*;
	import ramen.page.*;

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import com.nudoru.utils.BMUtils;
	import com.nudoru.utils.Debugger;
	import com.greensock.TweenLite;
	import fl.motion.easing.*;
	
	import com.nudoru.utils.BMUtils;
	
	public class TileGallery extends Template {
		
		private var _Lists			:Array;
		
		private var _ImageAssets	:Array;
		
		private var _SelectedListIdx:int;
		private var _SelectedItemIdx:int;

		private var _CurrentToolTip:Sprite;
		
		private var _CurrentItemContentContainer:Sprite;
		private var _CurrentPOList	:Array;
		
		private var _LastPageBMImage:Bitmap;
		private var _LastPageImage	:Sprite;
		
		public function TileGallery():void {
			_Lists = new Array();
			_ImageAssets = new Array();
			_CurrentPOList = new Array();
			_SelectedListIdx = -1;
			_SelectedItemIdx = -1;
			
			super();		// will trigger renderInteraction()
		}
		
		override protected function renderInteraction():void {
			var x:XMLList = _PageRenderer.interactionXML;
			var len:int = x.list.length();
			for(var i:int=0; i<len; i++) {
				_Lists.push(new PageList(x.list[i]));
			}
			if (_Lists.length) renderList(0);
		}

		/*
		* Render the list
		*/
		
		private function renderList(n:int):void {		
			var len:int = _Lists[n].numItems;
			if (len > 8) len = 8;
			
			var cmc:SimpleListItem;
			
			var itemColX:int = _Lists[n].itemColumnX;
			var itemColY:int = _Lists[n].itemColumnY;
			var itemColWidth:int = _Lists[n].itemColumnWidth;
			var itemColHeight:int = _Lists[n].itemColumnHeight;
			var itemColXSpc:int = _Lists[n].itemColumnSpacingX;
			
			if (!itemColX) itemColX = 100;
			if (!itemColY) itemColY = 100;
			if (!itemColWidth) itemColWidth = 100;
			if (!itemColHeight) itemColHeight = 100;
			if (!itemColXSpc) itemColXSpc = 3;
			
			var colCntr:int = 0;
			var itemColXStart:int = itemColX;
			
			for(var i:int=0; i<len; i++) {
				cmc = new SimpleListItem();
				
				cmc.x = itemColX;
				cmc.y = itemColY;
				
				cmc.scaleX = cmc.scaleY = .67;
				cmc.frame_mc.visible = false;
				
				var il:ImageLoader = new ImageLoader(_Lists[n].getItemThumbnail(i), cmc.imageLoader_mc, {x:0,y:0,width:_Lists[n].getItemWidth(i),height:_Lists[n].getItemHeight(i)});
				_ImageAssets.push(il);
				cmc.zoom_mc.alpha = 0;
				cmc.imageLoader_mc.x -= int((_Lists[n].getItemWidth(i)-150)/2)
				cmc.imageLoader_mc.y -= int((_Lists[n].getItemHeight(i)-150)/2)
				cmc.listIdx = n;
				cmc.itemIdx = i;
				cmc.origionalXPos = cmc.imageLoader_mc.x;
				cmc.origionalYPos = cmc.imageLoader_mc.y;
				cmc.origionalXScale = cmc.scaleX;

				if (true) {
					cmc.y += 50
					cmc.alpha = 0;
					TweenLite.to(Sprite(cmc), 1, {y:itemColY, alpha:1, delay:(i + 1) * .1, ease:Quadratic.easeOut, onComplete:enableItem, onCompleteParams:[cmc]});
				}

				_Lists[n].setItemRefMC(i, cmc);
				
				_PageRenderer.interactionLayer.addChild(cmc);
				
				itemColX += itemColWidth;

				if (++colCntr >= itemColXSpc) {
					colCntr = 0;
					itemColX = itemColXStart;
					itemColY += itemColHeight;
				}
			}
		}

		private function enableItem(s:SimpleListItem):void {
			s.addEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			s.addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
			s.addEventListener(MouseEvent.CLICK, onItemClick);
			s.buttonMode = true;
			s.mouseChildren = false;
		}
		
		private function disableItem(s:SimpleListItem):void {
			s.addEventListener(MouseEvent.MOUSE_OVER, onItemOver);
			s.addEventListener(MouseEvent.MOUSE_OUT, onItemOut);
			s.addEventListener(MouseEvent.CLICK, onItemClick);
			s.buttonMode = true;
			s.mouseChildren = false;
		}
		
		private function disableAllItems():void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				disableItem(_PageRenderer.interactionLayer.getChildAt(i) as SimpleListItem);
			}
		}
		
		private function onItemOver(e:MouseEvent):void {
			_SelectedListIdx = SimpleListItem(e.target).listIdx;
			_SelectedItemIdx = SimpleListItem(e.target).itemIdx;
			
			_PageRenderer.interactionItemToTop(e.target);

			TweenLite.to(e.target, 1, {scaleX:1, scaleY:1, ease:Back.easeOut});

			blurOthers(Sprite(e.target));
			
			//applyDropShadowFilter(s:*, distance:Number,  angle:Number, color:Number, alpha:Number, blur:Number, strength:Number)
			BMUtils.applyDropShadowFilter(Sprite(e.target), 3,  45, 0x000000, .5, 5, 1)
			
			Sprite(e.target).addEventListener(MouseEvent.MOUSE_MOVE, centerImage);
			
			TweenLite.to(e.target.zoom_mc, 1, { alpha:1, ease:Quadratic.easeOut } );
			
			//e.target.frame_mc.visible = true;
			
			_CurrentToolTip = createToolTip(this, e.target.x - 70, e.target.y + 68, _Lists[_SelectedListIdx].getItemTitle(_SelectedItemIdx), _Lists[_SelectedListIdx].getItemText(_SelectedItemIdx))
			_CurrentToolTip.alpha = 0;
			TweenLite.to(_CurrentToolTip, .5, { alpha:.9, ease:Quadratic.easeOut, delay:.25 } );
		}
		
		private function centerImage(e:MouseEvent):void {
			var border:int = 50;
			var offs:int = 75;
			var mPosX = e.target.mouseX + offs;
			var mPosY = e.target.mouseY + offs;
			var iWidth:int = _Lists[_SelectedListIdx].getItemWidth(_SelectedItemIdx);
			var iHeight:int = _Lists[_SelectedListIdx].getItemHeight(_SelectedItemIdx);
			var xRat:Number = (iWidth-150+border) / 150;
			var yRat:Number = (iHeight-150+border) / 150;
			var tX:int = ((mPosX * xRat)*-1)-offs+(border/2);
			var tY:int = ((mPosY * yRat)*-1)-offs+(border/2);
			//TweenLite.to(e.target.imageLoader_mc,.25,{x:tX, y:tY, ease:Quadratic.easeOut})
			e.target.imageLoader_mc.x = tX;
			e.target.imageLoader_mc.y = tY;
		}
		
		private function onItemOut(e:MouseEvent):void {
			e.target.hi_mc.alpha = 0;
			clearBlur();
			TweenLite.to(e.target, 1.5, { scaleX:.67, scaleY:.67, ease:Bounce.easeOut } );
			Sprite(e.target.mask_mc).removeEventListener(MouseEvent.MOUSE_MOVE, centerImage);
			
			e.target.imageLoader_mc.x = SimpleListItem(e.target).origionalXPos;
			e.target.imageLoader_mc.y = SimpleListItem(e.target).origionalYPos;
			TweenLite.to(e.target.zoom_mc, 1, { alpha:0, ease:Quadratic.easeOut } );
			
			e.target.frame_mc.visible = false;
			
			TweenLite.to(_CurrentToolTip, .25, { alpha:0, ease:Quadratic.easeOut, onComplete:removeSprite, onCompleteParams:[_CurrentToolTip] } );
		}
		
		private function removeSprite(s:Sprite) {
			this.removeChild(s);
			s.visible = false;
			s = null;
		}
		
		
		private function onItemClick(e:MouseEvent):void {
			_SelectedListIdx = SimpleListItem(e.target).listIdx;
			_SelectedItemIdx = SimpleListItem(e.target).itemIdx;
			//trace(_Lists[_SelectedListIdx].getItemHeight(_SelectedItemIdx));
			createLightBox(_Lists[_SelectedListIdx].getItemThumbnail(_SelectedItemIdx), _Lists[_SelectedListIdx].getItemText(_SelectedItemIdx), _Lists[_SelectedListIdx].getItemWidth(_SelectedItemIdx), _Lists[_SelectedListIdx].getItemHeight(_SelectedItemIdx), 30 );
		}
		
		private function blurOthers(s:Sprite):void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				var c:Sprite = Sprite(_PageRenderer.interactionLayer.getChildAt(i));
				if (s == c) continue;
				BMUtils.applyBlurFilter(c,5,5);
			}
		}
		
		private function clearBlur():void {
			var len:int = _PageRenderer.interactionLayer.numChildren;
			for (var i:int = 0; i < len; i++) {
				BMUtils.clearAllFilters(Sprite(_PageRenderer.interactionLayer.getChildAt(i)));
			}
		}
		
		private function createToolTip(tgt:Sprite, x:int, y:int, tt:String, txt:String):Sprite {
			var middleX = 400;
			
			var ttip:tooltip = new tooltip();
			tgt.addChild(ttip);
			var txtBrdr:int = 5;
			ttip.x = x;
			ttip.y = y;
			ttip.title_txt.autoSize = TextFieldAutoSize.LEFT;
			ttip.text_txt.autoSize = TextFieldAutoSize.LEFT;
			ttip.title_txt.text = tt;
			ttip.text_txt.text = txt;
			
			if (ttip.title_txt.width > ttip.text_txt.width) ttip.text_txt.width = ttip.title_txt.width;
			
			var bodyXS = ((txtBrdr*2) + (ttip.title_txt.textWidth > ttip.text_txt.textWidth ? ttip.title_txt.textWidth : ttip.text_txt.textWidth)) * .01;
			ttip.bg_mc.body_mc.scaleX = bodyXS;
			if (ttip.text_txt.length > 0) {
				// there is body text
				ttip.bg_mc.body_mc.scaleY = (txtBrdr + ttip.text_txt.y + ttip.text_txt.height - 10) * .01;
				ttip.bg_mc.side_mc.scaleY = (txtBrdr + ttip.text_txt.y + ttip.text_txt.height) * .01;
			} else {
				// just a title
				ttip.bg_mc.body_mc.scaleY = (txtBrdr + ttip.title_txt.y + ttip.title_txt.height - 12) * .01;
				ttip.bg_mc.side_mc.scaleY = (txtBrdr + ttip.title_txt.y + ttip.title_txt.height - 2) * .01;
			}
				
			// mirror it to the left
			if(x >= middleX) {
				ttip.bg_mc.scaleX *= -1;
				ttip.title_txt.x += (bodyXS*-100) - 15;
				ttip.text_txt.x += (bodyXS*-100) - 15;
			}
			
			return ttip;
		}
		
		protected function createLightBox(file:String, caption:String, w:int, h:int, border:int=10 ):void {
			dispatchEvent(new PopUpCreationEvent(PopUpCreationEvent.OPEN, this, createLightboxPopUpXML(file, caption,w, h, border)));
		}

		protected function createLightboxPopUpXML(file:String, caption:String, w:int, h:int, border:int=10 ):XML {
			var popup:String = "<popup id='lightbox' draggable='false'>";
			popup += "<type modal='true' persistant='false'>lightbox</type>";
			popup += "<hpos>middle</hpos>";
			popup += "<vpos>center</vpos>";
			popup += "<size>"+w+","+h+"</size>";
			popup += "<url>"+file+"</url>";
			popup += "<border>"+border+"</border>";
			popup += "<content><![CDATA["+caption+"]]></content>";
			popup += "</popup>";
			var data:XML = new XML(popup);
			return data;
		}
		
		override public function handlePopUpEvent(e:PopUpEvent):void {
			//trace("template from PM, type: " + e.type + ", from: " + e.data + " to: " + e.callingobj + " about: " + e.buttondata);
		}
		
		/*
		 * Support functions
		 */
		
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