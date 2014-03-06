package  com.fc.air.base
{
	import com.fc.air.base.font.BaseBitmapFont;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;

	/**
	 * ...
	 * @author ndp
	 */
	public class BFConstructor implements IAnimatable
	{				
		private var xmls:Object = { };
		private var listFonts:Array;
		private var nativeSize:Object;
		
		public function BFConstructor() 
		{	
			listFonts = [];
		}				
		
		public static function getTextImage(width:int,height:int,text:String,font:String,color:int=0xFFFFFF,hAlign:String="center",vAlign:String="center",autoscale:Boolean=false):Sprite
		{
			return TextField.getBitmapFont(font).createSprite(width, height, text, -1, color, hAlign, vAlign, autoscale);
		}
		
		public static function getBitmapChar(font:String, charCode:int):Texture
		{
			return TextField.getBitmapFont(font).getChar(charCode).texture;
		}
		
		public static function getTextField(width:int, height:int, text:String,font:String, color:int = 0xFFFFFF, hAlign:String = "center", vAlign:String = "center", autoscale:Boolean = false):BaseBitmapTextField
		{			
			var bitmapFont:BitmapFont = TextField.getBitmapFont(font);			
			var textField:BaseBitmapTextField = Factory.getObjectFromPool(BaseBitmapTextField);
			textField.width = width;
			textField.height = height;
			textField.fontName = font;
			textField.fontSize = bitmapFont.size;
			textField.color = color;
			textField.hAlign = hAlign;
			textField.vAlign = vAlign;			
			textField.autoScale = autoscale;	
			textField.text = text;
			return textField;
		}
		
		public static function getNativeSize(font:String):int
		{			
			return TextField.getBitmapFont(font).size;
		}
		
		/**
		 * use when textfield has only 10-15 characters
		 * @param	width
		 * @param	height
		 * @param	text
		 * @param	font
		 * @param	color
		 * @param	hAlign
		 * @param	vAlign
		 * @param	autoscale
		 * @return
		 */
		public static function getShortTextField(width:int, height:int, text:String, font:String, color:int = 0xFFFFFF, hAlign:String = "center", vAlign:String = "center", autoscale:Boolean = false):BaseBitmapTextField
		{
			var txtField:BaseBitmapTextField = getTextField(width, height, text, font, color, hAlign, vAlign, autoscale);
			txtField.batchable = true;
			return txtField;
		}
		
		static public function init():void 
		{
			Starling.juggler.add(Factory.getInstance(BFConstructor));
		}
		
		static public function storeXML(xml:XML, name:String):void 
		{
			var ins:BFConstructor = Factory.getInstance(BFConstructor);
			ins.xmls[name] = xml.copy();
			ins.listFonts.push(name);
			
		}
		
		static public function getFontBySize(fontSize:int):String 
		{
			var ins:BFConstructor = Factory.getInstance(BFConstructor);
			var len:int = ins.listFonts.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (ins.nativeSize[ins.listFonts[i]] >= fontSize)
					return ins.listFonts[i];					
			}
			return "";
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			if (resMgr.assetProgress == 1)
			{				
				nativeSize = { };								
				for each (var name:String in listFonts) 
				{
					var xml:XML = this.xmls[name];
					var fontTex:Texture = Asset.getBaseTexture(name);
					var bmpFont:BaseBitmapFont = new BaseBitmapFont(fontTex, xml);					
					TextField.registerBitmapFont(bmpFont, name);
					nativeSize[name] = bmpFont.size;
				}				
				Starling.juggler.remove(this);
				
				// sort font from small to big
				var len:int = listFonts.length;
				var tmpF:String;
				for (var i:int = 0; i < len-1; i++) 
				{
					for (var j:int = i+1; j < len; j++) 
					{
						var size1:int = nativeSize[listFonts[i]];
						var size2:int = nativeSize[listFonts[j]];
						if (size1 > size2)
						{
							tmpF = listFonts[2];
							listFonts[2] = listFonts[1];
							listFonts[1] = tmpF;
						}
					}
				}
			}
		}
	}

}