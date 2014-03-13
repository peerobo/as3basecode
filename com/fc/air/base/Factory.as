package com.fc.air.base 
{	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.EventDispatcher;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;	
	/**
	 * 
	 * @author PhuongND
	 */
	public class Factory implements IAnimatable 
	{
		private var map:Object;	// "key" => { obj: Object, time: int}
		private var pool:Object;	// "key" => [instance1, instance2,...]
		private var objCreator:Object;	// "key" => Function
		private var objResetor:Object;	// "key" => Function
		private var mapPersistent:Object; // "key" => obj
		private var touchDict:Dictionary = new Dictionary();	// touchObj => [f,p];
		
		private static var _ins:Factory;
		private static function get ins():Factory {
			if(!_ins) _ins = new Factory();
			return _ins;
		}
		private static const DESTROYTIME:int = 5 * 60 * 1000;		
		
		/**
		 * create/get object from commom pool
		 * @param	C
		 */
		private function getObjectFromPool(C:Class):*
		{
			var key:String = getQualifiedClassName(C);
			var obj:*= null;
			var instances:Array;
			if (!pool.hasOwnProperty(key))			
				pool[key] = [];			
			instances = pool[key];
			if (instances.length > 0)
			{
				obj = instances[instances.length-1];
				instances.splice(instances.length - 1, 1);				
			}
			else
			{
				obj = createObjForPool(key);
			}
			return obj;
		}
		
		private function createObjForPool(key:String):* 
		{
			if (objCreator.hasOwnProperty(key))
			{
				return objCreator[key].apply(this);
			}
			else
			{
				try {
					var C:Class = getDefinitionByName(key) as Class;
					return new C();
				}catch (e:Error) {
					return null;
				}
			}
		}
				
		private function registerPoolCreator(C:Class, f:Function, r:Function = null):void
		{
			var key:String = getQualifiedClassName(C);
			objCreator[key] = f;
			if (r is Function)
			{
				objResetor[key] = r;
			}
		}
		
		private function toPool(obj:Object):void
		{
			var key:String = getQualifiedClassName(obj);
			var instances:Array = pool[key];
			if(instances)
				instances.push(obj);			
			if (objResetor.hasOwnProperty(key))
			{								
				objResetor[key].apply(this, [obj]);				
			}
		}
		
		public static function toPool(obj:Object):void
		{
			ins.toPool(obj);
		}
		
		/**
		 * register constructor and reset function
		 * @param	C Class
		 * @param	f constructor
		 * @param	r reset function: reset(obj:Object):void
		 */
		public static function registerPoolCreator(C:Class, f:Function, r:Function = null):void
		{
			ins.registerPoolCreator(C, f, r);
		}
		
		public static function getObjectFromPool(C:Class):*
		{
			return ins.getObjectFromPool(C);
		}
		
		public function Factory() 
		{			
			Starling.juggler.add(this);
			map = new Object();
			pool = new Object();
			mapPersistent = new Object();
			objCreator = new Object();
			objResetor = new Object();
		}
		
		public function getTmpInstance(C:Class):*
		{
			var key:String = getQualifiedClassName(C);
			var obj:*= null;
			
			if (map.hasOwnProperty(key))
			{
				obj = map[key]["obj"];
				map[key]["time"] = 0;
			}
			else
			{
				obj = new C();
				map[key] = {
					obj: obj,
					time: 0
				};
			}
			return obj;
		}
		
		public static function getTmpInstance(C:Class):*
		{
			return ins.getTmpInstance(C);
		}
		
		public static function getInstance(C:Class):*
		{
			return ins.getInstance(C);
		}
		
		public static function killInstance(C:Class):void
		{
			ins.killInstance(C);
		}
		
		public function killInstance(C:Class):* 
		{
			var key:String = getQualifiedClassName(C);
			var obj:*= null;
			
			if (mapPersistent.hasOwnProperty(key))
			{							
				delete mapPersistent[key];
			}					
		}
		
		public function getInstance(C:Class):* 
		{
			var key:String = getQualifiedClassName(C);
			var obj:*= null;
			
			if (mapPersistent.hasOwnProperty(key))
			{
				obj = mapPersistent[key];				
			}
			else
			{
				obj = new C();
				mapPersistent[key] = obj;
			}
			return obj;
		}

		public static function addMouseClickCallback(eventDispatcher:EventDispatcher, f:Function, p:Array = null):void
		{
			if(eventDispatcher.hasEventListener(TouchEvent.TOUCH))			
				eventDispatcher.removeEventListener(TouchEvent.TOUCH,onMouseClickCallback);
			
			eventDispatcher.addEventListener(TouchEvent.TOUCH, onMouseClickCallback);
			ins.touchDict[eventDispatcher] = [f, p];
		}
		
		public static function removeMouseClickCallback(eventDispatcher:EventDispatcher):void
		{
			eventDispatcher.removeEventListener(TouchEvent.TOUCH, onMouseClickCallback);
			delete ins.touchDict[eventDispatcher];
		}
		
		static private function onMouseClickCallback(e:TouchEvent):void 
		{
			if (e.getTouch(e.currentTarget as DisplayObject, TouchPhase.ENDED))
			{
				var arrCall:Array = ins.touchDict[e.currentTarget];
				arrCall[0].apply(ins,arrCall[1]);
			}
		}		
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			var dt:int = time * 1000;
			for (var key:String in map) 
			{
				map[key]["time"] += dt;
				if (map[key]["time"] >= DESTROYTIME)
					delete map[key];
			}
		}
		
	}

}