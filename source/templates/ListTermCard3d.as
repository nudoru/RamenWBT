/*
List, Simple, Reveal with image

[ ] knock down card heights when a card is closed - can get cards out of camera view if they try to t

*/

package {

	import flash.geom.Rectangle;
	import org.papervision3d.objects.DisplayObject3D;
	import ramen.page.*
	import ramen.sheet.*
	import ramen.common.*
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;

	import com.nudoru.utils.Debugger;
	import com.nudoru.utils.BMUtils;	
	import com.greensock.TweenMax;
	import fl.motion.easing.*;
	import com.greensock.OverwriteManager;
	
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieAssetMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.utils.PrecisionMode;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.view.stats.StatsView;

	public class ListTermCard3d extends ListTemplate {

		private var ImageAssets			:Array;
		
		private var TheView				:BasicView;
		private var TheLight			:PointLight3D;
		private var PivotDO3D			:DisplayObject3D;
		private var TheCards			:Array = [];
		
		private static var ZDIFFERENCE	:int = 35;
		private static var CARD_WIDTH	:int = 180;
		private static var CARD_HEIGHT	:int = 250;
		
		public function ListTermCard3d():void {
			super();
			
			ImageAssets = new Array();
		}

		override protected function startInteraction():void {
			//trace("start interaction");
			
			//OverwriteManager.init(OverwriteManager.ALL_IMMEDIATE);
			
			TheView = new BasicView(_PageRenderer.pageWidth, _PageRenderer.pageHeight, false, true,CameraType.TARGET);
			
			_PageRenderer.fillInteractionLayer();
			_PageRenderer.interactionLayer.addChild(TheView);
			
			TheLight = new PointLight3D(true);
			TheLight.z = -2000;
			TheLight.y = -2000;
			TheLight.x = -2000;
			TheView.scene.addChild(TheLight);
			
			PivotDO3D = new DisplayObject3D();
			render3DItems(PivotDO3D);
			
			TheView.cameraAsCamera3D.target = DisplayObject3D.ZERO;
			TheView.cameraAsCamera3D.y = -700;
			TheView.cameraAsCamera3D.z = -1000;
			
			TheView.scene.addChild(PivotDO3D);
			TheView.startRendering();
			
			TweenMax.to(TheView.cameraAsCamera3D, 3, {y:-10, zoom:95, ease:Quadratic.easeOut, onComplete:startFrameAnimation } );

			
			state = STATE_READY;
			_Lists[_CurrentList].start();
			
			_CurrentItem = -1;
			
			dispatchEvent(new PageStatusEvent(PageStatusEvent.COMPLETED));
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// UI
		
		protected function startFrameAnimation():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	
		protected function onEnterFrame(e:Event):void {
			/*var mX:int = _PageRenderer.interactionLayer.mouseX;
			if (mX > 0 && mX < _PageRenderer.pageWidth) {
				var cTx:int = mX - (_PageRenderer.pageWidth >> 1);
				TheView.cameraAsCamera3D.x = cTx;
				//TweenMax.to(TheView.cameraAsCamera3D, .25, { x:cTx, ease:Quadratic.easeOut } );
			} else {
				//if(TheView.cameraAsCamera3D.x != 0)	TweenMax.to(TheView.cameraAsCamera3D,1,{x:0, ease:Quadratic.easeOut } );
			}*/
		}
		
		protected function render3DItems(do3d:DisplayObject3D):void {
			var posDefined:Boolean = true;
			
			var listX:int = _Lists[_CurrentList].itemColumnX;
			var listY:int = _Lists[_CurrentList].itemColumnY;
			var listWidth:int = _Lists[_CurrentList].itemColumnWidth;
			
			if (!listX) {
				listX = _PageRenderer.pageBorderLeft;
				posDefined = false;
			}
			if (!listY) listY = _PageRenderer.bodyTFBottomY + (_PageRenderer.pageBorderTop*2);
			if (!listWidth) listWidth = _PageRenderer.pageWidthActual;
			
			var len:int = _Lists[_CurrentList].numItems;
			var cX:int = listX;
			
			var cardSpc:int = (listWidth - (CARD_WIDTH * len)) / (len - 1);
			
			for (var i:int = 0; i < len; i++ ) {

				var materialsList:MaterialsList = new MaterialsList();
				
				if (_Lists[_CurrentList].getItemFrontURL(i).length) {
					var cardFaceBM:BitmapFileMaterial = new BitmapFileMaterial(_Lists[_CurrentList].getItemFrontURL(i),true);
					cardFaceBM.smooth = true;
					cardFaceBM.interactive = true;
					materialsList.addMaterial(cardFaceBM, "front");
				} else {
					var c:ChoiceItem = new ChoiceItem();
					c.front_mc.stop();
					c.listIdx = _CurrentList;
					c.itemIdx = i;
					c.front_mc.gotoAndStop(_Lists[_CurrentList].getItemStyle(i));
					c.text_txt.width = CARD_WIDTH-40;
					c.text_txt.autoSize = TextFieldAutoSize.CENTER;
					c.text_txt.wordWrap = true;
					c.text_txt.multiline = true;
					c.text_txt.text = _Lists[_CurrentList].getItemTitle(i);
					c.text_txt.y = (CARD_HEIGHT / 2) - (c.text_txt.height / 2);
					var cardFaceMC:MovieMaterial = new MovieMaterial(c, false, false, false, new Rectangle(0,0,CARD_WIDTH,CARD_HEIGHT));
					cardFaceMC.smooth = true;
					cardFaceMC.interactive = true;
					materialsList.addMaterial(cardFaceMC, "front");
				}
				
				if (_Lists[_CurrentList].getItemBackURL(i).length) {
					var cardBackBM:BitmapFileMaterial = new BitmapFileMaterial(_Lists[_CurrentList].getItemBackURL(i),true);
					cardBackBM.smooth = true;
					cardBackBM.interactive = true;
					materialsList.addMaterial(cardBackBM, "back");
				} else {
					var b:ChoiceItemBack = new ChoiceItemBack();
					b.listIdx = _CurrentList;
					b.itemIdx = i;
					b.text_txt.width = CARD_WIDTH-40;
					b.text_txt.autoSize = TextFieldAutoSize.CENTER;
					b.text_txt.wordWrap = true;
					b.text_txt.multiline = true;
					b.text_txt.text = _Lists[_CurrentList].getItemText(i);
					b.text_txt.y = (CARD_HEIGHT / 2) - (b.text_txt.height / 2);
					var cardBackMC:MovieMaterial = new MovieMaterial(b, false, false, false, new Rectangle(0,0,CARD_WIDTH,CARD_HEIGHT));
					cardBackMC.smooth = true;
					cardBackMC.interactive = true;
					materialsList.addMaterial(cardBackMC, "back");
				}
				

				var cardSide:ColorMaterial = new ColorMaterial(0xffffff);
				materialsList.addMaterial(cardSide,"left");
				materialsList.addMaterial(cardSide,"right");
				materialsList.addMaterial(cardSide,"top");
				materialsList.addMaterial(cardSide,"bottom");

				var cardCube:Cube = new Cube(materialsList, 180, 3, 250, 3, 3);
				cardCube.x = cX;
				if(i%2) {
					cardCube.y = listY;
				} else {
					cardCube.y = listY+50;
				}
				cardCube.z = getOrigionalZ(i);
				cardCube.localRotationY = 180;
				do3d.addChild(cardCube);
				
				addCard(cardCube);
				
				BMUtils.applyDropShadowFilter(TheView.viewport.getChildLayer(cardCube), 5, 45, 0x000000, .3, 5, 1);

				if (_Animate) {
					var tx:Number = cardCube.x;
					var ty:Number = cardCube.y;
					var tz:Number = cardCube.z;
					var tyr:Number = cardCube.localRotationY;
					cardCube.x = 0;
					cardCube.y = 1000;
					cardCube.z = -500;
					cardCube.localRotationY = -180;
					TweenMax.to(cardCube, 1, { x:tx, y:ty, z:tz, localRotationY:tyr, delay:(i * .5), ease:Back.easeOut, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
				
				cX += cardSpc + CARD_WIDTH;
			}
			
			// centers the object at 0,0
			do3d.x = (cX-(cardSpc + CARD_WIDTH)) / -2;
			do3d.y = (CARD_HEIGHT / -2)-_PageRenderer.bodyTFBottomY;
			
		}
		
		protected function onCardOver(e:InteractiveScene3DEvent):void {
			TweenMax.to(e.target, .25, { localRotationX:20, ease:Quadratic.easeOut } );
			TheView.viewport.buttonMode = true;
		}
		
		protected function onCardOut(e:InteractiveScene3DEvent):void {
			TweenMax.to(e.target, 1, {localRotationX:0, ease:Back.easeOut } );
			TheView.viewport.buttonMode = false;
		}
		
		protected function onCardClick(e:InteractiveScene3DEvent):void {
			setItem(_CurrentList, getCardDO3DIdx(e.target as DisplayObject3D));
		}

		override protected function setItem(l:int, c:int):void {
			if (l == _CurrentList && c == _CurrentItem) return;
			var card:DisplayObject3D = getCardDO3D(c);
			var cardLayer:ViewportLayer = TheCards[c].getVPLayer(TheView.viewport); // .getChildLayer(card);
			cardLayer.filters = [];
			disableItem(l, c);
			TweenMax.killTweensOf(card);
			// these apparently don't do anything
			card.localRotationX = 0;
			card.localRotationZ = 0;
			if (TheCards[c].selected) {
				//trace("hide");
				TheCards[c].selected = false;
				TweenMax.to(card, 1, { z:getOrigionalZ(c), localRotationZ:rnd(-5,5), localRotationY:-180, ease:Back.easeOut, onComplete:handleCardHide, onCompleteParams:[c] } );
				BMUtils.applyDropShadowFilter(cardLayer, 5, 45, 0x000000, .3, 5, 1);
			} else {
				//trace("show");
				TheCards[c].selected = true;
				// localRotationZ is still not 0 here
				TweenMax.to(card, .5, { z:getHighZ(), localRotationZ:0, localRotationY:0, ease:Quadratic.easeOut, onComplete:handleCardShow, onCompleteParams:[c] } );
				BMUtils.applyDropShadowFilter(cardLayer, 20, 45, 0x000000, .3, 10, 1);
			}
		}
		
		private function handleCardShow(c:int):void {
			adjustCameraToCard(c);
			enableItem(_CurrentList, c);
			var card:DisplayObject3D = getCardDO3D(c);
			trace(card.localRotationX + ", " + card.localRotationY + ", " + card.localRotationZ);
		}
		
		private function handleCardHide(c:int):void {
			adjustCameraToCard(c);
			enableItem(_CurrentList, c);
			var card:DisplayObject3D = getCardDO3D(c);
			trace(card.localRotationX + ", " + card.localRotationY + ", " + card.localRotationZ);
		}
		
		private function adjustCameraToCard(c:int):void {
			var cTx:int = c < (TheCards.length >> 1) ? -200 : 200;
			if (c == (TheCards.length >> 1)) cTx = 0;
			var cTz:int = -1000 + (getHighZ() >> 1);
			if (cTz > -1000) cTz = -1000;
			TweenMax.to(TheView.cameraAsCamera3D,1,{x:cTx, z:cTz, ease:Quadratic.easeInOut } );
		}
		
		private function addCard(c:DisplayObject3D):void {
			TheCards.push(new ListItem3D(c));
		}
		
		private function getCardDO3D(i:int):DisplayObject3D {
			return TheCards[i].DO3D as DisplayObject3D
		}
		
		private function getCardDO3DIdx(c:DisplayObject3D):int {
			for (var i:int = 0; i < TheCards.length; i++) {
				if (c == TheCards[i].DO3D) return i;
			}
			return -1;
		}
		
		private function getHighZ():int {
			var hZ:int = getOrigionalZ(TheCards.length);
			for (var i:int = 0; i < TheCards.length; i++) {
				if (TheCards[i].DO3D.z < hZ) hZ = TheCards[i].DO3D.z;
			}
			return hZ - ZDIFFERENCE;
		}
		
		private function getOrigionalZ(i:int):int {
			return i * ZDIFFERENCE+5;
		}
		
		override protected function enableItem(l:int, c:int):void {
			TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onCardOver);
			TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onCardOut);
			TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onCardClick);
		}
		
		override protected function disableItem(l:int, c:int):void {
			TweenMax.killTweensOf(TheCards[c]);
			TweenMax.killDelayedCallsTo(TheCards[c]);
			TheCards[c].DO3D.removeEventListener(InteractiveScene3DEvent.OBJECT_OVER, onCardOver);
			TheCards[c].DO3D.removeEventListener(InteractiveScene3DEvent.OBJECT_OUT, onCardOut);
			TheCards[c].DO3D.removeEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onCardClick);
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy
		
		protected function killAllItemAnimations():void {
			var len:int = _Lists[_CurrentList].numItems;
			for (var i:int = 0; i < len; i++) {
				TweenMax.killTweensOf(_Lists[_CurrentList].getItemRefMC(i));
			}
		}
		
		protected function unloadImages():void {
			for (var i:int = 0; i < ImageAssets.length; i++) {
				ImageAssets[i].destroy();
			}
		}
		
		// unloads eveything loaded by the page, remove listeners and frees up memory
		override public function destroy():void {
			//killAllItemAnimations();
			unloadImages();
			//removeLastItem();
			// destroy interaction specific content
			disableAllLists();
			stopAllLists();

			// remove all PV3D stuff
			for (var i:int = 0; i < TheCards.length; i++) {
				TheCards[i].DO3D.destroy();
			}
			TheCards = [];
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			TweenMax.killTweensOf(TheView.cameraAsCamera3D);
			TheView.stopRendering();
			TheView.renderer.destroy();
			TheView.viewport.destroy();
			removeChild(TheView);
			TheView = null;
			PivotDO3D = null;
			
			super.destroy();
		}
		
	}
}