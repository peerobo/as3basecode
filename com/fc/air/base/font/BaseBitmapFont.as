package com.fc.air.base.font 
{
	import starling.core.Starling;
	import starling.display.QuadBatch;
	import starling.text.BitmapChar;
	import starling.text.BitmapFont;
	import starling.text.CharLocation;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * support multi color for bitmap font
	 * @author ndp
	 */
	public class BaseBitmapFont extends BitmapFont 
	{
		public var colorRanges:Array;
		public var colors:Array;
		public function BaseBitmapFont(texture:Texture=null, fontXml:XML=null) 
		{			
			if (fontXml)
			{
				for each (var charElement:XML in fontXml.chars.char)
				{
					var y:Number = parseFloat(charElement.attribute("y"));
					charElement.@y = y*Starling.contentScaleFactor;
					var x:Number = parseFloat(charElement.attribute("x"));
					charElement.@x = x*Starling.contentScaleFactor;
					var h:Number = parseFloat(charElement.attribute("height"));
					charElement.@height = Math.ceil(h*Starling.contentScaleFactor);
					var w:Number = parseFloat(charElement.attribute("width"));
					charElement.@width = Math.ceil(w * Starling.contentScaleFactor);
					var xoffset:Number = parseFloat(charElement.attribute("xoffset"));
					charElement.@xoffset = xoffset * Starling.contentScaleFactor;
					var yoffset:Number = parseFloat(charElement.attribute("yoffset"));
					charElement.@yoffset = yoffset * Starling.contentScaleFactor;
					var xadvance:Number = parseFloat(charElement.attribute("xadvance"));
					charElement.@xadvance = xadvance * Starling.contentScaleFactor;					
				}
				var baseLine:Number = parseFloat(fontXml.common.attribute("base"));
				fontXml.common.@base = baseline*Starling.contentScaleFactor;
				var lineHeight:Number = parseFloat(fontXml.common.attribute("lineHeight"));				
				fontXml.common.@lineHeight = lineHeight*Starling.contentScaleFactor;
			}
			
			super(texture, fontXml);			
		}
		
		override public function fillQuadBatch(quadBatch:QuadBatch, width:Number, height:Number, text:String, fontSize:Number = -1, color:uint = 0xffffff, hAlign:String = "center", vAlign:String = "center", autoScale:Boolean = true, kerning:Boolean = true):void 
		{
			var charLocations:Vector.<CharLocation> = arrangeChars(width, height, text, fontSize, 
                                                                   hAlign, vAlign, autoScale, kerning);
            var numChars:int = charLocations.length;
            mHelperImage.color = color;
            
            if (numChars > 8192)
                throw new ArgumentError("Bitmap Font text is limited to 8192 characters.");
			var checkMultiColor:Boolean = colorRanges && colors;
			var startColorIdx:int = 0;
			while (colorRanges && colorRanges[startColorIdx] < 1)
				startColorIdx++;
			var currentColor:int = checkMultiColor ? (colors[startColorIdx] != null?colors[startColorIdx]:color):color;			
			var currentColorIdx:int = startColorIdx;
			var colorsLength:int = colors ? colors.length : 0;
            for (var i:int=0; i<numChars; ++i)
            {				
                var charLocation:CharLocation = charLocations[i];
                mHelperImage.texture = charLocation.char.texture;
                mHelperImage.readjustSize();
                mHelperImage.x = charLocation.x;
                mHelperImage.y = charLocation.y;
                mHelperImage.scaleX = mHelperImage.scaleY = charLocation.scale;
				mHelperImage.color = currentColor;
                quadBatch.addImage(mHelperImage);
				if(checkMultiColor)
				{
					while(i >= colorRanges[currentColorIdx]-1)
					{
						currentColorIdx++;
						currentColor = currentColorIdx < colorsLength ? (colors[currentColorIdx] != null?colors[currentColorIdx]:color) : color;
					}
				}
            }
		}
		
		override protected function arrangeChars(width:Number, height:Number, text:String, fontSize:Number=-1,
                                      hAlign:String="center", vAlign:String="center",
                                      autoScale:Boolean=true, kerning:Boolean=true):Vector.<CharLocation>
        {
            var j:int;
			if (text == null || text.length == 0) return new <CharLocation>[];
            if (fontSize < 0) fontSize *= -mSize;
            
            var lines:Vector.<Vector.<CharLocation>>;
            var finished:Boolean = false;
            var charLocation:CharLocation;
            var numChars:int;
            var containerWidth:Number;
            var containerHeight:Number;
            var scale:Number;
            var lenColor:int = colorRanges?colorRanges.length:0;
			var colorRangesClone:Array = colorRanges ? colorRanges.concat():null;
            while (!finished)
            {
                scale = fontSize / mSize;
                containerWidth  = width / scale;
                containerHeight = height / scale;
                
                lines = new Vector.<Vector.<CharLocation>>();
                
                if (mLineHeight <= containerHeight)
                {
                    var lastWhiteSpace:int = -1;
                    var lastCharID:int = -1;
                    var currentX:Number = 0;
                    var currentY:Number = 0;
                    var currentLine:Vector.<CharLocation> = new <CharLocation>[];
                    
                    numChars = text.length;
                    for (var i:int=0; i<numChars; ++i)
                    {
                        var lineFull:Boolean = false;
                        var charID:int = text.charCodeAt(i);
                        var char:BitmapChar = getChar(charID);
                        
                        if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
                        {
                            lineFull = true;
							for (j = 0; j < lenColor; j++) 
							{
								if (i < colorRangesClone[j])
									colorRanges[j]--;
							}
                        }
                        else if (char == null)
                        {
                            trace("[Starling] Missing character: " + String.fromCharCode(charID));
							for (j = 0; j < lenColor; j++) 
							{
								if (i < colorRangesClone[j])
									colorRanges[j]--;
							}
                        }
                        else
                        {
                            if (charID == CHAR_SPACE || charID == CHAR_TAB)
                            {
								lastWhiteSpace = i;
								for (j = 0; j < lenColor; j++) 
								{
									if (i < colorRangesClone[j])
										colorRanges[j]--;
								}
							}
                            
                            if (kerning)
                                currentX += char.getKerning(lastCharID);
                            
                            charLocation = mCharLocationPool.length ?
                                mCharLocationPool.pop() : new CharLocation(char);
                            
                            charLocation.char = char;
                            charLocation.x = currentX + char.xOffset;
                            charLocation.y = currentY + char.yOffset;
                            currentLine.push(charLocation);
                            
                            currentX += char.xAdvance;
                            lastCharID = charID;
                            
                            if (charLocation.x + char.width > containerWidth)
                            {
                                // remove characters and add them again to next line
                                var numCharsToRemove:int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
                                var removeIndex:int = currentLine.length - numCharsToRemove;
                                
                                currentLine.splice(removeIndex, numCharsToRemove);
                                
                                if (currentLine.length == 0)
                                    break;
                                
                                i -= numCharsToRemove;
                                lineFull = true;
                            }
                        }
                        
                        if (i == numChars - 1)
                        {
                            lines.push(currentLine);
                            finished = true;
                        }
                        else if (lineFull)
                        {
                            lines.push(currentLine);
                            
                            if (lastWhiteSpace == i)
                                currentLine.pop();
                            
                            if (currentY + 2*mLineHeight <= containerHeight)
                            {
                                currentLine = new <CharLocation>[];
                                currentX = 0;
                                currentY += mLineHeight;
                                lastWhiteSpace = -1;
                                lastCharID = -1;
                            }
                            else
                            {
                                break;
                            }
                        }
                    } // for each char
                } // if (mLineHeight <= containerHeight)
                
                if (autoScale && !finished && fontSize > 3)
                {
                    fontSize -= 1;
                    lines.length = 0;
                }
                else
                {
                    finished = true; 
                }
            } // while (!finished)
            
            var finalLocations:Vector.<CharLocation> = new <CharLocation>[];
            var numLines:int = lines.length;
            var bottom:Number = currentY + mLineHeight;
            var yOffset:int = 0;
            
            if (vAlign == VAlign.BOTTOM)      yOffset =  containerHeight - bottom;
            else if (vAlign == VAlign.CENTER) yOffset = (containerHeight - bottom) / 2;
            
            for (var lineID:int=0; lineID<numLines; ++lineID)
            {
                var line:Vector.<CharLocation> = lines[lineID];
                numChars = line.length;
                
                if (numChars == 0) continue;
                
                var xOffset:int = 0;
                var lastLocation:CharLocation = line[line.length-1];
                var right:Number = lastLocation.x - lastLocation.char.xOffset 
                                                  + lastLocation.char.xAdvance;
                
                if (hAlign == HAlign.RIGHT)       xOffset =  containerWidth - right;
                else if (hAlign == HAlign.CENTER) xOffset = (containerWidth - right) / 2;
                
                for (var c:int=0; c<numChars; ++c)
                {
                    charLocation = line[c];
                    charLocation.x = scale * (charLocation.x + xOffset);
                    charLocation.y = scale * (charLocation.y + yOffset);
                    charLocation.scale = scale;
                    
                    if (charLocation.char.width > 0 && charLocation.char.height > 0)
                        finalLocations.push(charLocation);
                    
                    // return to pool for next call to "arrangeChars"
                    mCharLocationPool.push(charLocation);
                }
            }
            
            return finalLocations;
        }
		
	}	
}