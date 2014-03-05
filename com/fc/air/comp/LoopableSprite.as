package com.fc.air.comp 
{
	import com.fc.air.base.Factory;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class LoopableSprite extends Sprite implements IAnimatable 
	{
		public var interval:Number;
		private var countTime:Number;		
		
		public function LoopableSprite() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			interval = -1;						
		}				
		
		public function onRemoved(e:Event):void 
		{
			Starling.juggler.remove(this);
			var num:int = this.numChildren;
			for (var i:int = 0; i < num; i++) 
			{
				Factory.toPool(getChildAt(i));
			}
			removeChildren();
		}
		
		public function onAdded(e:Event):void 
		{
			
			Starling.juggler.add(this);	
			countTime = 0;
		}
		
		public function update(time:Number):void
		{
			
		}
		
		/* INTERFACE starling.animation.IAnimatable */
		
		public function advanceTime(time:Number):void 
		{
			if (interval > -1)
			{
				countTime += time;
				if (countTime > interval)
				{
					countTime -= interval;
					update(interval);
				}
			}
			else
			{
				update(time);
			}
		}
	}

}