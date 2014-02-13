package ramen.player {
	
	public class NodeType {
		
		public static var MODULE			:String = "module"
		public static var SECTION			:String = "section"
		public static var TOPIC				:String = "topic"
		public static var PAGE				:String = "page"
		
		public static var TYPE_ASSESSMENT	:String = "type_assessment"
		public static var TYPE_HIDDEN		:String = "type_hidden"
		
		public function NodeType():void { }
	
		public static function validMajorType(n:String):Boolean {
			if (n == NodeType.MODULE) return true;
			if (n == NodeType.SECTION) return true;
			if (n == NodeType.TOPIC) return true;
			if (n == NodeType.PAGE) return true;
			return false;
		}
		
	}
	
}