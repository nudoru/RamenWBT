/*
Broadcast from the Viewer when the user clicks on a UI navigation element.
The Controller passes either the name or ID to the Model to change the page
*/

package ramen.common {
	
	import flash.events.*;
	
	public class NavChangeEvent extends Event {
		
		public static const MAIN_MENU_SELECTION	:String = "mainMenuSelection";
		public static const PAGE_MENU_SELECTION	:String = "pageMenuSelection";
		public static const PAGE_JUMP_SELECTION	:String = "pageJumpSelection";
		
		public static const GOTO_NEXT_PAGE		:String = "gotoNextPage";
		public static const GOTO_PREVIOUS_PAGE	:String = "gotoPreviousPage";
		
		public static const REFRESH_CURRENT_PAGE:String = "refreshCurrentPage";
		
		public static const SHOW_EXIT_PROMPT	:String = "show_exit_prompt";
		
		public var selectionName				:String;
		public var selectionID					:String;
		
		public function NavChangeEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, selName:String=" ", selID:String=" "):void {
			super(type, bubbles, cancelable);
			selectionName = selName;
			selectionID = selID;
		}
		
		public override function clone():Event {
			return new NavChangeEvent(type, bubbles, cancelable, selectionName, selectionID);
		}
		
		public override function toString():String {
			return formatToString("NavChangeEvent", "type", "bubbles", "cancelable", "eventPhase", "selectionName", "selectionID");
		}
		
	}
	
}