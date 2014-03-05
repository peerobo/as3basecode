package com.fc.air.comp
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import starling.display.DisplayObject;

	public class ShakeObject
	{
		public var AMP:int = 4;
		
		private var numShake:int;
		private var delayMil:int;
		private var delayTimer:Timer;
		private var timer:Timer;
		private var oldX:int;
		private var oldY:int;
		private var shakeObj:DisplayObject;
		private var nShake:int;
		private var dt:int;
		private var cd:int;
		private var callback:Function;
	
		public function ShakeObject()
		{
		}
		
		public function setCallback(f:Function):void
		{
			callback = f;
		}
		
		public function shake(obj:DisplayObject, timeMilsecond:int, dt:int = 10, delayMil:int = 0, numShake:int = 0):void
		{
			oldX = obj.x;
			oldY = obj.y;
			this.dt = dt;
			shakeObj = obj;
			this.delayMil = delayMil;
			this.numShake = numShake;
			nShake = timeMilsecond / dt;
			
			if (delayMil > 0)
			{
				if (delayTimer == null)
				{
					delayTimer = new Timer(delayMil, 1);
					delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompDelay);
				}
				delayTimer.start();
			}
			else
			{
				startShakeTimer();
			}
		}
		
		public function stopShake():void
		{
			numShake = 0;
			onComp(null);
		}
		
		private function startShakeTimer():void
		{
			
			cd = nShake;
			if (timer == null)
			{
				timer = new Timer(dt, nShake);
				timer.addEventListener(TimerEvent.TIMER, onTimer);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComp);
			}
			timer.repeatCount += nShake;
			timer.start();
		}
		
		private function onCompDelay(e:TimerEvent):void
		{
			numShake--;
			delayTimer.stop();
			if (numShake <= 0) {
				delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCompDelay);
				delayTimer = null;
			}
			startShakeTimer();
		}
		
		private function onTimer(e:TimerEvent):void
		{
			cd--;
			var amp:Number = (cd / nShake) * AMP;
			shakeObj.x = oldX + getMinusOrPlus()*(Math.random()*amp);  
			shakeObj.y = oldY + getMinusOrPlus()*(Math.random()*amp); 
		}
		
		private function onComp(e:TimerEvent):void
		{
			timer.stop();
			shakeObj.x = oldX;
			shakeObj.y = oldY;
			if (numShake <= 0) {
				shakeObj = null;
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComp);
				timer = null;
				if (callback != null) {
					callback();
				}
			}
			else {
				if (delayMil > 0)
				{
					if (delayTimer == null)
					{
						delayTimer = new Timer(delayMil, 1);
						delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompDelay);
					}
					delayTimer.repeatCount += 2;
					delayTimer.start();
				}
				else
				{
					startShakeTimer();
				}
			}
			
		}
		
		private function getMinusOrPlus():int
		{
			var rand : Number = Math.random()*2;
			if (rand<1) return -1
			else return 1;
		}
	}
}