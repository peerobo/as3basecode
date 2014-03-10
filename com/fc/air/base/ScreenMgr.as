package com.fc.air.base 
{
	import flash.utils.getQualifiedClassName;
	import starling.display.DisplayObject;
	/**
	 * ...
	 * @author ndp
	 */
	public class ScreenMgr 
	{		
		public static var currScr:DisplayObject;
		
		public function ScreenMgr()
		{
			
		}
		
		public static function showScreen(c:Class):void
		{			
			var scr:DisplayObject = Factory.getInstance(c) as DisplayObject;			
			if (currScr == scr)
				return;
			if (currScr)
				currScr.removeFromParent();
			PopupMgr.flush();
			LayerMgr.getLayer(LayerMgr.LAYER_GAME).addChildAt(scr,0);
			currScr = scr;						
		}
		
	}

}