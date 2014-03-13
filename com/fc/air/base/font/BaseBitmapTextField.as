package com.fc.air.base.font 
{	
	import starling.display.QuadBatch;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * bitmap textfield with multi colors support
	 * @author ndp
	 */
	public class BaseBitmapTextField extends TextField 
	{
		private var minusRanges:Array;
		public var colorRanges:Array;
		public var colors:Array;
		public var leading:int;
		
		public function BaseBitmapTextField(width:int, height:int, text:String, fontName:String="Verdana",
                                  fontSize:Number=12, color:uint=0x0, bold:Boolean=false) 
		{
			super(width, height, text, fontName,
                                  fontSize, color, bold);
		}
		
		public function reset():void
		{
			colors = null;
			colorRanges = null;
			autoSize = TextFieldAutoSize.NONE;
			alpha = 1;
			autoScale = false;
			text = "";
			x = y = 0;
			scaleX = scaleY = 1;
			visible = true;
			touchable = true;
			filter = null;
			rotation = 0;
			pivotX = pivotY = 0;			
		}
		
		public function removeLines(num:int):void
		{
			var regExp:RegExp = /[^\r\n]+[\r\n]+/;
			var _originText:String = text;
			var res:Array = regExp.exec(_originText);			
			var totalDelC:int = 0;
			while(res && num > 0)
			{				
				_originText = _originText.replace(res[0], "");				
				totalDelC += res[0].length;
				num--;
				res = regExp.exec(_originText);
			}
			var len:int = colorRanges.length;
			for (var i:int = 0; i < len; i++) 
			{
				colorRanges[i] -= totalDelC;
				if (colorRanges[i] < 1)
				{
					colorRanges.splice(i, 1);
					colors.splice(i, 1);
					i--;
					len--;
				}
			}				
			text = _originText;			
		}
		
		public function setContent(...args):void 
		{
			var len:int = args.length;
			var str:String = "";
			var range:int;
			colorRanges = [];
			for (var i:int = 0; i < len; i++) 
			{
				str += args[i];
				range = str.length;
				colorRanges.push(range);
			}
			text = str;
		}
		
		public function setContentColor(...args):void 
		{
			colors = args;
		}
		
		public function add(changeText:String, color:uint):void 
		{
			var _originTxt:String = text;
			_originTxt += changeText;
			if (!colors || !colorRanges) {
				if(text.length > 0) {
					colors = [this.color];
					colorRanges = [text.length];
				} else {
					colors = [];
					colorRanges = [];
				}
			}
			colors.push(color);
			colorRanges.push(_originTxt.length);
			text = _originTxt;
		}	
		
		public function get numLines():int
		{
			var _originText:String = text;
			var cloneStr:String = new String(_originText);
			var regExp:RegExp = /[^\r\n]+[\r\n]*/;
			var res:Array = regExp.exec(cloneStr);			
			var count:int = 0;
			while(res)
			{				
				cloneStr = cloneStr.replace(res[0], "");
				count++;
				res = regExp.exec(cloneStr);
			}
			return count+1;
		}
		
		override protected function createComposedContents():void 
		{
			if (super.mImage) 
            { 
                mImage.removeFromParent(true); 
                mImage = null; 
            }
            
            if (mQuadBatch == null) 
            { 
                mQuadBatch = new QuadBatch(); 
                mQuadBatch.touchable = false;
                addChild(mQuadBatch); 
            }
            else
                mQuadBatch.reset();
            
            var bitmapFont:BaseBitmapFont = getBitmapFont(mFontName) as BaseBitmapFont;
            if (bitmapFont == null) throw new Error("Bitmap font not registered: " + mFontName);
            
            var width:Number  = mHitArea.width;
            var height:Number = mHitArea.height;
            var hAlign:String = mHAlign;
            var vAlign:String = mVAlign;
            
            if (isHorizontalAutoSize)
            {
                width = int.MAX_VALUE;
                hAlign = HAlign.LEFT;
            }
            if (isVerticalAutoSize)
            {
                height = int.MAX_VALUE;
                vAlign = VAlign.TOP;
            }
            
			// color ranges (only character)
			var colorRangesClone:Array = colorRanges ? colorRanges.concat() : null;						
			bitmapFont.colorRanges = colorRangesClone;
			bitmapFont.colors = colors;
			var oldLineHeight:int = bitmapFont.lineHeight;
			bitmapFont.lineHeight += leading;
			
            bitmapFont.fillQuadBatch(mQuadBatch,
                width, height, mText, mFontSize, mColor, hAlign, vAlign, mAutoScale, mKerning);
            				
			bitmapFont.colorRanges = null;
			bitmapFont.colors = null;	
			bitmapFont.lineHeight = oldLineHeight;
				
            mQuadBatch.batchable = mBatchable;
            
            if (mAutoSize != TextFieldAutoSize.NONE)
            {
                mTextBounds = mQuadBatch.getBounds(mQuadBatch, mTextBounds);
                
                if (isHorizontalAutoSize)
                    mHitArea.width  = mTextBounds.x + mTextBounds.width;
                if (isVerticalAutoSize)
                    mHitArea.height = mTextBounds.y + mTextBounds.height;
            }
            else
            {
                // hit area doesn't change, text bounds can be created on demand
                mTextBounds = null;
            }
		}
		
	}

}