/*
 * Simple Factory to automate view creation
 */

package ramen.player {
	
	import flash.display.Sprite;
	
	public class SiteViewFactory {
		
		public static function createView(t:String,c:Sprite,d:SiteModel):AbstractView {
			var o:AbstractView = new CenteredView(c, d);
			return o;
		}

	}
	
}