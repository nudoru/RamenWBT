package ramen.common {

	public interface ITemplate {
		
		function measure():Object;
		function initialize(xd:String, initObj:Object):void;
		function start():void;
		function destroy():void;
	}
	
}