
package ramen.player {
	
	public class PageTransition {
		
		public static const NONE			:String = "none";
		public static const SLIDE			:String = "slide";
		public static const SQUEEZE			:String = "squeeze";
		public static const XFADE_QUICK		:String = "xfade_quick";
		public static const XFADE_SLOW		:String = "xfade_slow";

		public static const DUR_QUICK		:Number = .25;
		public static const DUR_MEDIUM		:Number = .5;
		public static const DUR_SLOW		:Number = 1;
		
		public static const DIR_BACK		:int = -1;
		public static const DIR_NONE		:int = 0;
		public static const DIR_NEXT		:int = 1;
		
		public function PageTransition():void {
			//
		}
		
	}
	
}