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
		
		public function TileImage() 
		{
			super();				
		}
		
		public function draw(tex:Texture, w:int, h:int):void
		{
			reset();
			var tW:int = tex.width;
			var tH:int = tex.height;
			var fillX:int = w / tW;
			var fillY:int = h / tH;
			var oW:int = w % tW;
			var oH:int = h % tH;
			var crop:Boolean = oW != 0 || oH != 0;
			var oXTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, oW, tH));
			var oYTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, tW, oH));
			var oXYTex:Texture = Texture.fromTexture(tex, new Rectangle(0, 0, oW, oH));
			var oXImg:Image = new Image(oXTex);
			var oYImg:Image = new Image(oYTex);
			var oXYImg:Image = new Image(oXYTex);			
			var img:Image = new Image(tex);					
			img.smoothing = TextureSmoothing.NONE;
			oXYImg.smoothing = TextureSmoothing.NONE;
			oYImg.smoothing = TextureSmoothing.NONE;
			oXImg.smoothing = TextureSmoothing.NONE;
			for (var i:int = 0; i < fillX; i++) 
			{
				for (var j:int = 0; j < fillY; j++) 
				{
					img.x = tW * i;
					img.y = tH * j;
					this.addImage(img);						
					//img = new Image(tex);
					//addChild(img);
				}
			}
			if (crop)
			{
				if(oH!=0)
				{
					for (i = 0; i <  fillX; i++) 
					{
						oYImg.x = tW * i;
						oYImg.y = tH * fillY;
						this.addImage(oYImg);
						//addChild(oYImg);
						//oYImg = new Image(oYTex);
					}
				}
				if(oW!=0)
				{
					for (i = 0; i <  fillY; i++) 
					{
						oXImg.x = tW * fillX;
						oXImg.y = tH * i;
						this.addImage(oXImg);
						//this.addChild(oXImg);
						//oXImg = new Image(oXTex);
					}
				}
				if (oW != 0 && oH != 0)
				{
					oXYImg.x = tW * fillX;
					oXYImg.y = tH * fillY;
					this.addImage(oXYImg);
					//this.addChild(oXYImg);
				}
			}
		}
		
	}

}