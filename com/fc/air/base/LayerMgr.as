package com.fc.air.base
{
	import starling.core.Starling;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author ndp
	 */
	public class LayerMgr 
	{
		static private var root:Sprite;
		private static var layers:Array;
		
		private static const NUM_LAYERS:int = 4;
		public static const LAYER_GAME:int = 0;					
		public static const LAYER_TOOLTIP:int = 1;
		public static const LAYER_DIALOG:int = 2;
		public static const LAYER_EFFECT:int = 3;				
		
		
		static private var _lockGameLayer:Boolean;
		
		public function LayerMgr() 
		{
			
		}
		
		static public function init(root:Sprite):void 
		{
			LayerMgr.root = root;					
			layers = [];
			for (var i:int = 0; i < NUM_LAYERS; i++) 
			{
				var l:Sprite = new Sprite();
				root.addChild(l);				
				layers.push(l);
			}
			
			PopupMgr.init(getLayer(LAYER_DIALOG));
		}
		
		static public function getLayer(layerIdx:int):Sprite
		{
			return layers[layerIdx];
		}
		
		static public function get lockGameLayer():Boolean 
		{
			return _lockGameLayer;
		}
		
		static public function set lockGameLayer(value:Boolean):void 
		{
			_lockGameLayer = value;
			if (value)
				getLayer(LAYER_GAME).flatten();
			else
				getLayer(LAYER_GAME).unflatten();
		}
	}

}