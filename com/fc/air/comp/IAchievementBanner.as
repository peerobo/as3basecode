package com.fc.air.comp 
{
	
	/**
	 * ...
	 * @author ndp
	 */
	public interface IAchievementBanner 
	{
		function get isShowing():Boolean;
		function setLabelAndShow(achName:String):void;
		function queue(achName:String):void;
	}
	
}