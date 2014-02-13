package ramen.page {
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.Viewport3D;
	
	public class  ListItem3D extends SimpleListItem {
		
		public var DO3D:DisplayObject3D;
		public var sortPosition		:int=0;
		
		public var origionalZPos	:int;
		public var targetZPos		:int;
		
		public function ListItem3D(d:DisplayObject3D=undefined):void {
			super();
			DO3D = d;
		}
		
		public function getVPLayer(v:Viewport3D):ViewportLayer {
			return v.getChildLayer(DO3D);
		}
		
	}
	
}