package ramen.player {

	import flash.events.Event;

	public interface ISiteView {
		
		function onPageChange(e:Event):void;
		function updateUI():void;
		function adjustUI(a:Boolean):void;
		
	}
	
}