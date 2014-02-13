/*
 * This is a catch all class to standardize various status, props and types
 */

package ramen.common {
	
	public class ObjectStatus {
		
		// for misc items
		public static const NOT_INIT		:int = -1;
		public static const INIT			:int = 1;
		
		// for nodes/pages, items
		public static const NOT_ATTEMPTED	:int = 0;
		public static const INCOMPLETE		:int = 1;
		public static const COMPLETED		:int = 2;
		public static const PASSED			:int = 3;
		public static const FAILED			:int = 4;
		
		// positioning
		public static const LEFT			:String = "left";
		public static const MIDDLE			:String = "middle";
		public static const RIGHT			:String = "right";
		public static const TOP				:String = "top";
		public static const HIGH_MIDDLE		:String = "high_middle";
		public static const CENTER			:String = "center";
		public static const LOW_MIDDLE		:String = "low_middle";
		public static const BOTTOM			:String = "bottom";
		
		public static const PAGE_LEFT		:String = "page_left";
		public static const PAGE_CENTER		:String = "page_center";
		public static const PAGE_RIGHT		:String = "page_right";
		public static const PAGE_TOP		:String = "page_top";
		public static const PAGE_HIGH_MIDDLE:String = "page_high_middle";
		public static const PAGE_MIDDLE		:String = "page_vmiddle";
		public static const PAGE_LOW_MIDDLE	:String = "page_low_middle";
		public static const PAGE_BOTTOM		:String = "page_bottom";
		
		public function ObjectStatus():void {
			//
		}
		
	}
	
}