package com.fc.air.comp 
{
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.res.Asset;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author ndp
	 */
	public class BGText extends LoopableSprite 
	{
		private var font:String;
		private var text:String;
		private var bg:String;
		private var color:int;
		
		public function BGText() 
		{
			super();		
		}
		
		public function setText(font:String, text:String, bg:String, color:int = 0xFFFFFF):void
		{
			this.color = color;
			this.bg = bg;
			this.text = text;
			this.font = font;			
		}
		
		override public function onAdded(e:Event):void 
		{
			super.onAdded(e);
			
			var bg:DisplayObject = Asset.getBaseImage(bg);
			var tf:BaseBitmapTextField = BFConstructor.getTextField(1, 1, text, font,color);
			tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			bg.width = tf.width + 60;
			bg.height = tf.height + 60;
			tf.x = 30;
			tf.y = 30;
			
			addChild(bg);
			addChild(tf);			
		}
		
	}

}