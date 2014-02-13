package ramen.player {

	public interface INodeModel {
		
		function getCourseStuctureStr():String;
		function getCourseStuctureData():Array;
		function start():Boolean;
		function stop():Boolean;
		function updateStatus():void;
	}
	
}