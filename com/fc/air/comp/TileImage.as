package com.fc.air.comp 
{
	import com.fc.air.base.Factory;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class TileImage extends QuadBatch 
	{
		public var scale:Number;
		
		public function TileImage() 
		{
			super();
			scale = 1;
		}					
		
		public function draw(tex:Texture, w:int, h:int):void
		{
			var oXYImg:Image;
			var oYImg:Image;
			var oXImg:Image;
			reset();
			var tW:int = tex.width;
			var tH:int = tex.height;
			var fillX:int = w / (tW*scale);
			var fillY:int = h / (tH*scale);
			var oW:int = w % (tW*scale);
			var oH:int = h % (tH*scale);
			var crop:Boolean = oW != 0 || oH != 0;			
			var rec:Rectangle = Factory.getObjectFromPool(Rectangle);
			rec.x = 0;
			rec.y = 0;
			rec.width = oW;
			rec.height = tH;
			var oXTex:Texture = Texture.fromTexture(tex, rec);
			rec.width = tW;
			rec.height = oH;
			var oYTex:Texture = Texture.fromTexture(tex, rec);
			rec.width = oW;
			rec.height = oH;
			var oXYTex:Texture = Texture.fromTexture(tex, rec);			
			Factory.toPool(rec);
			if(oW)
				oXImg = new Image(oXTex);
			if(oH)
				oYImg = new Image(oYTex);
			if(oW && oH)
				oXYImg = new Image(oXYTex);			
			var img:Image = new Image(tex);					
			img.smoothing = TextureSmoothing.NONE;
			img.scaleX = img.scaleY = scale;
			if (oXYImg)
			{
				oXYImg.smoothing = TextureSmoothing.NONE;
				oXYImg.scaleX = oXYImg.scaleY = scale;
			}
			if (oYImg)
			{
				oYImg.smoothing = TextureSmoothing.NONE;
				oYImg.scaleX = oYImg.scaleY = scale;
			}
			if (oXImg)
			{
				oXImg.smoothing = TextureSmoothing.NONE;
				oXImg.scaleX = oXImg.scaleY = scale;
			}
			for (var i:int = 0; i < fillX; i++) 
			{
				for (var j:int = 0; j < fillY; j++) 
				{
					img.x = tW*scale * i;
					img.y = tH*scale * j;
					this.addImage(img);						
				}
			}
			if (crop)
			{
				if(oH!=0)
				{
					for (i = 0; i <  fillX; i++) 
					{
						oYImg.x = tW*scale * i;
						oYImg.y = tH*scale * fillY;
						this.addImage(oYImg);						
					}
				}
				if(oW!=0)
				{
					for (i = 0; i <  fillY; i++) 
					{
						oXImg.x = tW*scale * fillX;
						oXImg.y = tH*scale * i;
						this.addImage(oXImg);						
					}
				}
				if (oW != 0 && oH != 0)
				{
					oXYImg.x = tW*scale * fillX;
					oXYImg.y = tH*scale * fillY;
					this.addImage(oXYImg);					
				}
			}
		}
		
	}

}