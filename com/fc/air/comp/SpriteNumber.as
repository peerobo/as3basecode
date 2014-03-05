package com.fc.air.comp 
{
	import com.fc.air.base.Factory;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class SpriteNumber extends QuadBatch 
	{
		private var numberTexs:Vector.<Texture>;
		public var spacing:int = 6;
		public function SpriteNumber() 
		{
			super();
			
		}
		
		/**
		 * assign numeric textures
		 * @param	numberTexs	0=>9,.
		 */
		public function init(numberTexs:Vector.<Texture>):void
		{
			this.numberTexs = numberTexs;
		}
		
		public function set text(value:String):void
		{
			reset();
			var numbers:Array = value.split("");
			var img:Image = Factory.getObjectFromPool(Image);	
			var posX:int = 0;
			for (var i:int = 0; i < numbers.length; i++) 
			{				
				var no:int = isNaN(parseInt(numbers[i]))? 10 : parseInt(numbers[i]);
				img.texture = numberTexs[no];
				img.readjustSize();
				img.x = posX;
				img.y = no == 10 ? numberTexs[0].height - img.height : 0;
				posX += img.width + spacing;
				addImage(img);
			}
		}
		
	}

}