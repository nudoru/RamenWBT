//http://www.stevensacks.net/2008/02/06/as3-geturl-solved/

package net.stevensacks.utils
{
	import flash.net.navigateToURL;	
	import flash.net.URLRequest;
	
	public class Web
	{
		public static function getURL(url:String, window:String = null):void
		{
			var req:URLRequest = new URLRequest(url);
			//trace("getURL", url);
			try 
			{
				navigateToURL(req, window);
			} 
			catch (e:Error) 
			{
				//trace("Navigate to URL failed", e.message);
			}
		}
	}
}