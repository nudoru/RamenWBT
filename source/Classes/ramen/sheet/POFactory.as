/*
 * Simple Factory to automate page object creation
 */

package ramen.sheet {
	
	import ramen.page.*;
	
	import flash.display.Sprite;
	
	public class POFactory {
		
		public static function createPO(t:String, pr:Sheet, tgt:Sprite, x:XMLList):IPageObject {
			var o:IPageObject;
			
			switch(t) {
				case "text":
					o = new POText(pr, tgt, x);
					break;
				case "textbox":
					o = new POTextBox(pr, tgt, x);
					break;
				case "graphic":
					o = new POGraphic(pr, tgt, x);
					break;
				case "button":
					o = new POButton(pr, tgt, x);
					break;
				/*case "flvplayerbox":
					o = new POFLVPlayer(pr, tgt, x);
					break;*/
				case "gradrect":
					o = new POGradRect(pr, tgt, x);
					break;
				case "gradroundrect":
					o = new POGradRoundRect(pr, tgt, x);
					break;
				case "hotspot":
					o = new POHotspot(pr, tgt, x);
					break;
				case "group":
					o = new POGroup(pr, tgt, x);
					break;
				case "shape":
					o = new POShape(pr, tgt, x);
					break;
				case "interactiveswf":
					o = new POInteractiveSWF(pr, tgt, x);
					break;
				case "eventmanager":
					o = new POEM(pr, tgt, x);
					break;
				case "audioplayer":
					o = new POAudioPlayer(pr, tgt, x);
					break;
				default:
					trace("POFactory, no such type: "+o);
			}
			
			return o;
		}
		
		
	}
	
}