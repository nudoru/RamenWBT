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
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.BezierThroughPlugin;
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

	public class ListStackCard3d extends ListTemplate {

		private var ImageAssets			:Array;
		
		private var TheView				:BasicView;
		private var TheLight			:PointLight3D;
		private var PivotDO3D			:DisplayObject3D;
		private var TheCards			:Array = [];
		
		private var LeftStack			:Array = [];
		private var RightStack			:Array = [];
		
		private var LeftStackX			:int = 0;
		private var LeftStackY			:int = 0;
		private var RightStackX			:int = 350;
		private var RightStackY			:int = 0;
		
		private var HoldInteraction		:Boolean = false;
		
		private static var CARD_DEPTH	:int = 3;
		private static var CARD_WIDTH	:int = 180;
		private static var CARD_HEIGHT	:int = 250;
		
		public function ListStackCard3d():void {
			super();
			
			ImageAssets = new Array();
		}

		override protected function startInteraction():void {
			//trace("start interaction");
			TweenPlugin.activate([BezierThroughPlugin]);
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
			TheView.cameraAsCamera3D.y = 0;
			TheView.cameraAsCamera3D.z = -1000;
			TheView.cameraAsCamera3D.zoom = 50;
			
			TheView.scene.addChild(PivotDO3D);
			TheView.startRendering();
			
			TweenMax.to(TheView.cameraAsCamera3D, 3, {y:-500, zoom:105, ease:Quadratic.easeOut, onComplete:startFrameAnimation } );
			
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
				TheView.cameraAsCamera3D.x = cTx>>1;
				//TweenMax.to(TheView.cameraAsCamera3D, .25, { x:cTx, ease:Quadratic.easeOut } );
			} else {
				//if(TheView.cameraAsCamera3D.x != 0)	TweenMax.to(TheView.cameraAsCamera3D,1,{x:0, ease:Quadratic.easeOut } );
			}*/
			/*var mY:int = _PageRenderer.interactionLayer.mouseY;
			if (mY > 0 && mY < _PageRenderer.pageHeight) {
				var cTy:int = mY - (_PageRenderer.pageHeight >> 1);
				TheView.cameraAsCamera3D.y = cTy;
				//TweenMax.to(TheView.cameraAsCamera3D, .25, { x:cTx, ease:Quadratic.easeOut } );
			} else {
				//if(TheView.cameraAsCamera3D.x != 0)	TweenMax.to(TheView.cameraAsCamera3D,1,{x:0, ease:Quadratic.easeOut } );
			}*/
		}
		
		protected function render3DItems(do3d:DisplayObject3D):void {
			var posDefined:Boolean = true;
			
			var sZ:int = 0;
			
			var len:int = _Lists[_CurrentList].numItems;
			
			for (var i:int = 0; i < len; i++ ) {
				LeftStack.push(i);
				
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

				var cardCube:Cube = new Cube(materialsList, CARD_WIDTH, CARD_DEPTH, CARD_HEIGHT, 3, 3);
				cardCube.x = LeftStackX;
				cardCube.y = LeftStackY;
				cardCube.z = sZ;
				cardCube.localRotationZ = 0;
				cardCube.localRotationY = 180;
				do3d.addChild(cardCube);
				
				addCard(cardCube);
				
				BMUtils.applyDropShadowFilter(TheView.viewport.getChildLayer(cardCube), 2, 45, 0x000000, .3, 2,1);

				sZ += CARD_DEPTH + 1;
				
				if (_Animate) {
					var tx:Number = cardCube.x;
					var ty:Number = cardCube.y;
					var tz:Number = cardCube.z;
					cardCube.z = -1000;
					TweenMax.to(cardCube, 1, { x:tx, y:ty, z:tz, delay:((len-i) * .3), ease:Quadratic.easeIn, onComplete:enableItem, onCompleteParams:[_CurrentList, i] } );
				} else {
					enableItem(_CurrentList, i);
				}
				
			}
			
			do3d.x =RightStackX/2*-1;
			do3d.y = -80;// ((CARD_HEIGHT + LeftStackY) / 2) - _PageRenderer.bodyTFBottomY - 100;
			
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
		
		protected function onCardOver(e:InteractiveScene3DEvent):void {
			TweenMax.to(e.target, .25, { localRotationZ:rnd(-5,5), ease:Quadratic.easeOut } );
			TheView.viewport.buttonMode = true;
		}
		
		protected function onCardOut(e:InteractiveScene3DEvent):void {
			TweenMax.to(e.target, 1, {localRotationZ:rnd( -2, 2), ease:Back.easeOut } );
			TheView.viewport.buttonMode = false;
		}
		
		protected function onCardClick(e:InteractiveScene3DEvent):void {
			setItem(_CurrentList, getCardDO3DIdx(e.target as DisplayObject3D));
		}

		override protected function setItem(l:int, c:int):void {
			if (HoldInteraction) return;
			disableItem(l, c);
			var card:DisplayObject3D = getCardDO3D(c);
			TweenMax.killTweensOf(card);
			card.localRotationX = 0;
			card.localRotationZ = 0;
			
			if (isInLeftStack(c)) {
				var rz:int = getNextRightZ();
				moveToRightStack(c);
				TheCards[c].selected = true;
				TheCards[c].sortPosition = 1;
				TweenMax.to(card, 1, { bezierThrough:[ { z: -200, localRotationY:0, localRotationZ: 0, x:(RightStackX - LeftStackX) / 2, y:0 }, { z:rz, localRotationY:0, x:RightStackX, y:RightStackY } ], ease:Quadratic.easeOut, onComplete:onCompleteCardAnim, onCompleteParams:[c] } );
				HoldInteraction = true;
			} else if (isInRightStack(c)) {
				var topLeft:Boolean = LeftStack.length ? true : false;
				var lz:int = getNextLeftZ();
				moveToLeftStack(c);
				TheCards[c].selected = false;
				TheCards[c].sortPosition = 0;
				if (topLeft) TweenMax.to(card, 1, { bezierThrough:[ { z: -100, localRotationY: -180, x:LeftStackX - 100, y:CARD_HEIGHT }, { z: 50 }, { z:lz, localRotationY: -180, localRotationZ: rnd( -5, 5), x:LeftStackX, y:RightStackY } ], ease:Quadratic.easeOut, onComplete:onCompleteCardAnim, onCompleteParams:[c] } );
					else TweenMax.to(card, 1, { bezierThrough:[ { z: -100, localRotationY: -90, x:(RightStackX - LeftStackX) / 2, y:0 }, { z:lz, localRotationY: -180, localRotationZ: rnd( -5, 5), x:LeftStackX, y:RightStackY } ], ease:Quadratic.easeOut, onComplete:onCompleteCardAnim, onCompleteParams:[c] } );
				HoldInteraction = true;
			}
			
			adjustCameraToCards();
		}
		
		private function onCompleteCardAnim(c:int):void {
			HoldInteraction = false;
			//enableItem(_CurrentList, c);
			// will only enable the items on top of the stacks
			enableAllItems(_CurrentList);
		}
		
		private function adjustCameraToCards():void {
			var cTx:int = LeftStackX;
			var cTy:int = -500;
			var cTz:int = 105;
			if (RightStack.length) {
				cTx = RightStackX;
				cTy = -100;
				cTz = 135;
			}
			TweenMax.to(TheView.cameraAsCamera3D,1,{x:cTx, y:cTy, zoom:cTz, ease:Quadratic.easeInOut } );
		}

		private function isInLeftStack(c:int):Boolean {
			return getLeftStackIdx(c) > -1 ? true : false;
		}
		
		private function isInRightStack(c:int):Boolean {
			return getRightStackIdx(c) > -1 ? true : false;
		}
		
		private function getLeftStackIdx(c:int):int {
			for (var i:int = 0; i < LeftStack.length; i++) {
				if (LeftStack[i] == c) return i;
			}
			return -1;
		}
		
		private function getRightStackIdx(c:int):int {
			for (var i:int = 0; i < RightStack.length; i++) {
				if (RightStack[i] == c) return i;
			}
			return -1;
		}
		
		private function moveToRightStack(c:int):void {
			var spos:int = getLeftStackIdx(c);
			LeftStack.splice(spos, 1);
			RightStack.unshift(c);
		}
		
		private function moveToLeftStack(c:int):void {
			var spos:int = getRightStackIdx(c);
			RightStack.splice(spos, 1);
			LeftStack.push(c);
		}
		
		private function zSortLeftStack():void {
			var sZ:int = 0;
			for (var i:int = 0; i < LeftStack.length; i++) {
				trace(TheCards[LeftStack[i]].DO3D.z +" to " + sZ);
				TheCards[LeftStack[i]].DO3D.z = sZ;
				sZ += CARD_DEPTH + 1;
				
			}
		}
		
		private function zSortRightStack():void {
			var sZ:int = 0;
			for (var i:int = 0; i<RightStack.length; i++) {
				TheCards[RightStack[i]].DO3D.z = sZ;
				sZ -= (CARD_DEPTH + 1)*-1;
			}
		}
		
		private function getNextLeftZ():int {
			if (LeftStack.length) {
				return TheCards[LeftStack[LeftStack.length - 1]].DO3D.z + CARD_DEPTH + 1;
			} else {
				return 0;
			}
		}
		
		private function getNextRightZ():int {
			if (RightStack.length) {
				return TheCards[RightStack[0]].DO3D.z - CARD_DEPTH - 1;
			} else {
				return 0;
			}
		}

		override protected function enableItem(l:int, c:int):void {
			if(getLeftStackIdx(c) == 0 || getRightStackIdx(c) == 0) {
				TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onCardOver);
				TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onCardOut);
				TheCards[c].DO3D.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onCardClick);
			}
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