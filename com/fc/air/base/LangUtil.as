package com.fc.air.base 
{
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import flash.net.URLLoaderDataFormat;
	/**
	 * ...
	 * @author ducnh
	 */
	public class LangUtil 
	{
		public static const XMLPATH:String = Asset.TEXT_FOLDER + "localization.xml";
		
		public static const LOCALIZE_VI:String = "vi";
		public static const LOCALIZE_EN:String = "en";
		public static var localize:String = LOCALIZE_EN;
		
		
		public static var localizeData:Object = new Object();
		
		public static function init(str:String):void
		{
			str = str.replace(/\\n/g,"\n");
			var xml:XML = XML(str);
			localizeData = {};
			for each( var child:XML in xml.children())
			{
				localizeData[child.name()] = { };
				for each(var keyXML:XML in child.children())
				{
					localizeData[child.name()][keyXML.name()] = keyXML.text();					
				}
			}						
		}
		
		public static function getText(key:String):String
		{
			if (localizeData[localize].hasOwnProperty(key))
			{
				return localizeData[localize][key];
			}else
			{
				return key;
			}
			
		}				
		
		static public function loadXMLData():void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			resMgr.load(XMLPATH, URLLoaderDataFormat.TEXT, init);
		}
	}

}