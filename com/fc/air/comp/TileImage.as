package com.fc.air.comp 
{
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
			reset();
			var tW:int = tex.width;
			var tH:int = tex.height;
			var fillX:int = w / (tW*scale);
			var fillY:int = h / (tH*scale);
			var oW:int = w % (tW*scale);
			var oH:int = h % (tH*scale);
			var crop:Boolean = oW != 0 || oH != 0;
			var oXTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, oW, tH));
			var oYTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, tW, oH));
			var oXYTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, oW, oH));
			var oXImg:Image = new Image(oXTex);
			var oYImg:Image = new Image(oYTex);
			var oXYImg:Image = new Image(oXYTex);			
			var img:Image = new Image(tex);					
			img.smoothing = TextureSmoothing.NONE;
			img.scaleX = img.scaleY = scale;
			oXYImg.smoothing = TextureSmoothing.NONE;
			oXYImg.scaleX = oXYImg.scaleY = scale;
			oYImg.smoothing = TextureSmoothing.NONE;
			oYImg.scaleX = oYImg.scaleY = scale;
			oXImg.smoothing = TextureSmoothing.NONE;
			oXImg.scaleX = oXImg.scaleY = scale;
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