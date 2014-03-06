package com.fc.air
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import starling.core.Starling;
	
	public class FPSCounter extends Sprite
	{
		private var last:uint = getTimer();
		private var ticks:uint = 0;
		private var tf:TextField;
		private static var self:FPSCounter;
		private var log:String;
		
		public function FPSCounter(xPos:int = 0, yPos:int = 0, color:uint = 0xffffff, fillBackground:Boolean = false, backgroundColor:uint = 0x000000, w:int= 300, h:int = 300)
		{
			x = xPos;
			y = yPos;
			tf = new TextField();			
			tf.defaultTextFormat = new TextFormat("Arial", 18, color, true );
			tf.text = "----- fps";			
			tf.multiline = true;
			tf.selectable = false;
			tf.wordWrap = true;
			tf.background = fillBackground;
			tf.backgroundColor = backgroundColor;
			tf.width = w;
			tf.height = h;
			tf.mouseEnabled = false;			
			addChild(tf);			
			addEventListener(Event.ENTER_FRAME, tick);
			self = this;
			log = "";
		}
		
		public function tick(evt:Event):void
		{
			if (parent)
			{
				ticks++;
				var now:uint = getTimer();
				var delta:uint = now - last;
				if (delta >= 1000)
				{
					//trace(ticks / delta * 1000+" ticks:"+ticks+" delta:"+delta);
					var fps:Number = ticks / delta * 1000;
					var str:String = fps.toFixed(1) + " fps";
					str += " - " + Starling.current.mSupport.drawCount + " drw"; 
					str += " - " + (System.totalMemory * 0.000000954).toFixed(2) + " MB";
					str += " - " + Starling.current.nativeStage.fullScreenWidth + "x" + Starling.current.nativeStage.fullScreenHeight;					
					str += " - " + ( Util.isAndroid? ("Android: " + Util.deviceID) : (Util.isIOS? "IOS: " + Util.deviceID : "not device") );
					tf.text = str + log;
					ticks = 0;
					last = now;
					tf.scrollV = tf.maxScrollV;
				}
			}
		}
		
		public static function log(...args):void
		{
			if(self.parent)
			{
				self.log += "\n" + args.join(" ");				
			}
			trace.apply(null, args);
		}
	}
}
