/*
 * This is a catch all class to standardize various status, props and types
 */

package ramen.page {
	
	public class RamenInteractionType {
		
		// types
		/*
		USE THE TYPES IN com.nudoru.lms.interactiontype
		*/

		// subtypes
		public static const MC_SINGLE_SELECT			:String = "single_select";
		public static const MC_MULTI_SELECT				:String = "multi_select";
		public static const MC_BINARY					:String = "binary";
		public static const DND_MATHCING				:String = "matching";
		public static const DND_SORTING					:String = "sorting";
		public static const MC_COLUMNS					:String = "mc_columns";
		public static const SELECTION					:String = "selection";
		
		public function InteractionType():void {
			//
		}
		
	}
	
}