package com.fc.air.base 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author ndp
	 */
	public class Graphics4Starling
	{
		private static var graphicsObjs:Dictionary;
		
		public function Graphics4Starling() 
		{
			
		}
		
		/**
		 * create new shape image object
		 * @return
		 */
		public static function beginDrawing():DisplayObject
		{
			if (!graphicsObjs)
				graphicsObjs = new Dictionary();
			
			var shape:Shape = new Shape();
			var textureRender:Texture = Texture.empty(1,1);
			var image:Image = new Image(textureRender);
			graphicsObjs[image] = shape;
			
			return image;
		}
		
		/**
		 * get Graphics obj for drawing
		 * @param	disp
		 * @return
		 */
		public static function getGraphicObject(disp:DisplayObject):Graphics
		{
			if (graphicsObjs[disp])
				return (graphicsObjs[disp] as Shape).graphics;
			else	
				return null;
		}
		
		/**
		 * update graphic for shape
		 * @param	disp
		 */
		public static function updateGraphics(disp:DisplayObject):void
		{
			if (graphicsObjs[disp])
			{				
				var image:Image = disp as Image;
				var texture:Texture = image.texture;
				texture.dispose();
				var shape:Shape = graphicsObjs[disp];
				var rec:Rectangle = shape.getBounds(null);
				if (rec.width == 0 || rec.height == 0)
				{
					image.texture = Texture.empty(1,1);
				}
				else
				{
					var bitmapData:BitmapData = new BitmapData(rec.right+2, rec.bottom+2, true, 0x000000FF);
					bitmapData.draw(shape,new Matrix(1,0,0,1,1,1));
					image.texture = Texture.fromBitmapData(bitmapData,true,false,Starling.contentScaleFactor);
				}
				image.readjustSize();
			}
		}
		
		/**
		 * destroy shape
		 * @param	disp
		 */
		public static function destroy(disp:DisplayObject):void
		{
			if (graphicsObjs[disp])
			{					
				graphicsObjs[disp] = null;
				(disp as Image).texture.dispose();
				disp.dispose();
				delete graphicsObjs[disp];
			}
		}
	}

}