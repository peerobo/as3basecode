package com.fc.air.base 
{
	import com.fc.air.Util;
	/**
	 * ...
	 * @author ndp
	 */
	public class GameSave 
	{
		public var state:String;
		public static const STATE_APP_LAUNCH:String = "launch";
		public static const STATE_APP_INGAME:String = "ingame";
		public static const STATE_APP_PURCHASE:String = "purchase";
		public static const STATE_APP_RESTORE:String = "restore";
		
		public var data:Object;
		
		private const STORE_KEY:String = "gamestate";
		private var fList:Array;
		
		public function registerValidate(f:Function):void
		{
			if (fList.indexOf(f) < 0)
				fList.push(f);
		}
		
		public function GameSave() 
		{
			fList = [];
		}				
		
		public function saveState():void
		{
			data = { state: STATE_APP_LAUNCH};
			for each (var f:Function in fList) 
			{
				f();
			}
			Util.setPrivateValue(STORE_KEY, JSON.stringify(data));
		}
		
		public function loadState():void
		{
			var ret:String = Util.getPrivateKey(STORE_KEY);
			if (ret)
			{
				data = JSON.parse(ret);
				state = data.hasOwnProperty("state") ? data.state : STATE_APP_LAUNCH;
			}
			else
			{
				state = STATE_APP_LAUNCH;
			}
		}				
		
	}

}