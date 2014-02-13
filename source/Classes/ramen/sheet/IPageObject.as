package ramen.sheet {

	public interface IPageObject {
		
		function setLoaded():void;
		function render():void;
		function getObject():*;
		function destroy():void;
		
	}
	
}