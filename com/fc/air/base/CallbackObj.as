package com.fc.air.base 
{
	/**
	 * ...
	 * @author ndp
	 */
	public class CallbackObj 
	{
		public var f:Function;
		public var p:Array;
		public var optionalData:Object;
		
		public function CallbackObj(f:Function,p:Array=null,optionalData:Object=null) 
		{
			this.f = f;
			this.p = p;
			this.optionalData = optionalData;
		}
		
		public function execute():void
		{
			if(f is Function)
				f.apply(this, p);
		}
		
	}

}