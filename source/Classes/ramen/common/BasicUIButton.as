package ramen.common {
	import flash.display.SimpleButton;
	import flash.text.TextField;

	public class BasicUIButton extends SimpleButton	{
		
		public var _Label:String = ""
		
		public var label_txt:TextField
		
		public function get label():String { return _Label }
		public function set label(t:String):void {
			_Label = t;
			//this.label_txt.text = _Label;
		}
		
		public function BasicUIButton():void {
			//super();
		}
	}
	
}