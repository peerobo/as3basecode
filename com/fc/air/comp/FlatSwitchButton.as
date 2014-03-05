package com.fc.air.comp 
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.BFConstructor;
	import com.fc.air.base.Factory;
	import com.fc.air.res.Asset;
	import flash.desktop.NativeProcessStartupInfo;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class FlatSwitchButton extends Sprite 
	{
		private var _value:Boolean;
		private var onClicked:Function;	// param: FlatSwitchButton.value
		private const PADDNG:int = BaseButton.PADDNG;
		
		public function FlatSwitchButton() 
		{
			super();
			
		}
		
		public function init(trueDesc:String, falseDesc:String, backgroundTexture:String, selectedTexture:String, onClicked:Function):void		
		{
			this.onClicked = onClicked;
			var trueTxt:TextField = BFConstructor.getTextField(1, 1, trueDesc, BaseButton.DefaultFont, 0xFFFF80);
			trueTxt.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			trueTxt.name = "true";
			trueTxt.touchable = false;
			addChild(trueTxt);
			var falseTxt:TextField = BFConstructor.getTextField(1, 1, falseDesc, BaseButton.DefaultFont, 0xFFFF80);
			falseTxt.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			falseTxt.name = "false";
			falseTxt.touchable = false;
			addChild(falseTxt);
			
			trueTxt.x = PADDNG/2;
			trueTxt.y = PADDNG;
			falseTxt.x = trueTxt.x + trueTxt.width + PADDNG;
			falseTxt.y = trueTxt.y;
			
			var bg:DisplayObject = Asset.getBaseImage(backgroundTexture);
			bg.width = falseTxt.x + falseTxt.width + PADDNG/2;
			bg.height = falseTxt.y + falseTxt.height + PADDNG;
			addChildAt(bg, 0);
			var selectedBG:DisplayObject = Asset.getBaseImage(selectedTexture);
			selectedBG.touchable = false;
			selectedBG.name = "selected";
			addChildAt(selectedBG, 1);			
			selectedBG.x = falseTxt.x;			
			selectedBG.width = falseTxt.width;
			selectedBG.height = bg.height;
			_value = false;
			Factory.addMouseClickCallback(this, onClick);
		}
		
		private function onClick():void 
		{
			value = !value;
			onClicked.apply(this,[value]);
		}
		
		public function destroy():void
		{
			Factory.removeMouseClickCallback(this);
			for (var i:int = 0; i < numChildren; i++) 
			{ 
				Factory.toPool(getChildAt(i));
			}
			removeChildren();
		}
		
		public function get value():Boolean 
		{
			return _value;
		}
		
		public function set value(value:Boolean):void 
		{
			_value = value;
			
			var txt:TextField = (!value ? getChildByName("true"):getChildByName("false")) as TextField;
			var selectedBG:DisplayObject = getChildByName("selected");
			selectedBG.x = txt.x - PADDNG/2;			
			selectedBG.width = txt.width + PADDNG;
		}
		
	}

}