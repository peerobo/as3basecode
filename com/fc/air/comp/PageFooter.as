package com.fc.air.comp 
{
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author ndp
	 */
	public class PageFooter extends LoopableSprite 
	{
		private var currPageDisp:Image;
		private var pageDisp:Image;
		
		private var _currPape:int=0;
		private var _totalPage:int=0;
		private var padding:int=0;
		
		private var quadBatch:QuadBatch;
		
		public function PageFooter() 
		{
			super();
			quadBatch = new QuadBatch();
		}
		
		public function initTexture(pageDisp:Image, currPageDisp:Image, padding:int = 24):void
		{
			this.pageDisp = pageDisp;
			this.currPageDisp = currPageDisp;
			this.padding = padding;
			Util.g_centerChild(currPageDisp, pageDisp);			
		}
		
		public function setState(currPage:int, totalPage:int):void
		{			
			_totalPage = totalPage;
			_currPape = currPage;
			quadBatch.reset();
			for (var i:int = 0; i < totalPage; i++) 
			{
				pageDisp.x = i * (pageDisp.width + padding);				
				quadBatch.addImage(pageDisp);
				if (i == currPage)
				{
					Util.g_centerChild(pageDisp, currPageDisp);
					currPageDisp.x += pageDisp.x;
					currPageDisp.y += pageDisp.y;
					quadBatch.addImage(currPageDisp);
				}
			}
			
		}
		
		public function get totalPage():int 
		{
			return _totalPage;
		}			
		
		public function get currPape():int 
		{
			return _currPape;
		}		
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			addChild(quadBatch);
		}
		
		override public function onRemoved(e:Event):void 
		{
			quadBatch.removeFromParent();
			super.onRemoved(e);			
		}
	}

}