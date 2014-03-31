package com.fc.air.base 
{
	import com.fc.air.Util;
	import flash.geom.Point;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author ndp
	 */
	public class EffectMgr 
	{
		public static var DEFAULT_FONT:String;
		
		public function EffectMgr() 
		{
			
		}
		
		public static function floatObject(obj:DisplayObject, pos:Point, dir:String = "y", time:Number = 0.5):void
		{			
			LayerMgr.getLayer(LayerMgr.LAYER_EFFECT).addChild(obj);
			
			var t:Tween = new Tween(obj, time, Transitions.EASE_OUT);
			t.delay = 0;
			t.animate(dir, pos[dir]);
			t.onComplete = onFloatObjectComplete;
			t.onCompleteArgs = [t, obj];		
			Starling.juggler.add(t);
		}
		
		private static function onFloatObjectComplete(t:Tween,obj:DisplayObject):void
		{
			t.reset(t.target, 0.5);			
			t.fadeTo(0);
			Starling.juggler.add(t);
			t.onComplete = onFadeComplete;
			t.onCompleteArgs = [obj];
		}
		
		private static function onFadeComplete(obj:DisplayObject):void
		{
			obj.removeFromParent(true);
		}				
		
		public static function floatTextMessageEffect(text:String, pos:Point, color:uint = 0xFF0000, time:Number = 0.5):void
		{
			var txt:TextField = BFConstructor.getTextField(1, 1, text, DEFAULT_FONT, color);
			txt.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;			
			txt.text = text;
			txt.x = pos.x - txt.width / 2;
			txt.y = pos.y - txt.height / 2;
			txt.touchable = false;
			pos.y -= 240;
			floatObject(txt, pos,"y",time);
		}
		
		public static function floatTextMessageEffectCenter(text:String, color:uint = 0xFF0000, time:Number = 0.5):void
		{
			var p:Point = new Point(Util.appWidth >> 1, Util.appHeight >> 1);			
			floatTextMessageEffect(text, p, color, time);			
		}
		
		public static function interpolate(obj:DisplayObject, destPt:Point, interPt:Point, time:Number = 0.4, autoRemove:Boolean = true, onComplete:Function=null):void
		{
			var tween:Tween = new Tween(obj, time);
			tween.onUpdate = onCurveDispWithTween;
			var start:Point = new Point(obj.x, obj.y);
			tween.onUpdateArgs = [start, interPt, destPt, tween];
			tween.onCompleteArgs = [obj,onComplete,autoRemove];
			tween.onComplete = onDoneInterpolate;
			Starling.juggler.add(tween);
		}
		
		static private function onDoneInterpolate(disp:DisplayObject,onComplete:Function,autoRemove:Boolean):void 
		{
			if (autoRemove)
				disp.removeFromParent();
			if (onComplete is Function)
				onComplete();
		}
		
		private static function onCurveDispWithTween(start:Point, mid:Point, end:Point, tween:Tween):void
		{
			var tt:Number = tween.progress;
			var disp:DisplayObject = tween.target as DisplayObject;
			var pt:Point = onCurveDisp(start, mid, end, tt);
			disp.x = pt.x;
			disp.y = pt.y;
			return;
		}
		
		private static function onCurveDisp(start:Point, mid:Point, end:Point, t:Number):Point
		{
			var x:Number = (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * mid.x + t * t * end.x;
			var y:Number = (1 - t) * (1 - t) * start.y + 2 * (1 - t) * t * mid.y + t * t * end.y;
			return new Point(x, y);
		}
		
	}

}