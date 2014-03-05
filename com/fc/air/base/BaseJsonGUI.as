package com.fc.air.base
{
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.comp.LoopableSprite;
	import com.fc.air.res.Asset;
	import com.fc.air.res.ResMgr;
	import feathers.display.Scale9Image;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.utils.HAlign;

	public class BaseJsonGUI extends LoopableSprite
	{			
		public static var guiConfig:Object;	
		private static var loader:URLLoader;
		protected static var mvIndex:Array;
		protected static var btnIndex:Object;
		
		public var guiId:String = "";
		public var layers:Object = new Object();		
		private var buttons:Object = new Object();
		private var images:Object = new Object();
		private var textFields:Object = new Object();
		private var rects:Object = new Object();
		private var arrs:Object = new Object();
		
		public function BaseJsonGUI(guiId:String)
		{
			super();
			this.guiId = guiId;
			var o:Object = guiConfig;
			var guiCfg:Object = guiConfig["gui"][guiId];
			
		}
		
		override public function onAdded(e:Event):void
		{
			super.onAdded(e);
			// init new objects
			layers = new Object();
			buttons = new Object();
			images = new Object();
			textFields = new Object();
			rects = new Object();
			arrs = new Object();
			
			// load new config
			var o:Object = guiConfig;
			var guiCfg:Object = guiConfig["gui"][guiId];
			readCfg(guiCfg as Array);			
		}
		
		public static function setConfigAllGUIs(str:String):void
		{
			var cfg:Object = JSON.parse(str);
			guiConfig = cfg;
			// load 9slice
			var s9:Object = guiConfig["9slice"];
			var s:String;
			var obj:Object = Asset.scaleRecCollection;
			for (s in s9) {
				var oRect:Object = s9[s];
				var r:Rectangle = new Rectangle(oRect["l"], oRect["t"], oRect["w"], oRect["h"]);
				obj[s] = r;
			}
			// load mvIndex
			mvIndex = guiConfig["mvIndex"];
		}
		
		// abstract function
		public function onButtonClick(btnId:String, btnObject:BaseButton):void
		{
		}
		
		// get GUI component
		public function getLayer(layerId:String):Sprite
		{
			if (layerId in layers) {
				return layers[layerId];
			}
			return null;
		}
		
		public function getArray(arrId:String):Array
		{
			if (arrId in arrs) {
				return arrs[arrId];
			}
			return null;
		}
		
		public function getRectArea(rectId:String):Rectangle
		{
			if (rectId in rects) {
				return rects[rectId];
			}
			return null;
		}
		
		public function getImage(imgId:String):Image
		{
			if (imgId in images) {
				var img:Object = images[imgId];
				if (img is Image) {
					return (Image)(img);
				}
				return null;
			}
			return null;
		}
		
		public function getScale9Image(imgId:String):Scale9Image
		{
			if (imgId in images) {
				var img:Object = images[imgId];
				if (img is Scale9Image) {
					return (Scale9Image)(img);
				}
				return null;
			}
			return null;
		}
		
		public function getButton(btnId:String):BaseButton
		{
			if (btnId in buttons) {
				return (BaseButton)(buttons[btnId]);
			}
			return null;
		}
		
		public function getTextField(textId:String):TextField
		{
			if (textId in textFields) {
				return (TextField)(textFields[textId]);
			}
			return null;
		}
		
		// load GUI config
		public function readCfg(guiCfg:Array):void
		{
			var layerData:Array;
			var i:int;
			for (i = guiCfg.length - 1; i >= 0; i--) {
				layerData = guiCfg[i];
				loadLayerData(layerData);
			}
		}
		
		private function loadLayerData(layerData:Array):void
		{
			// add new layer
			var layer:Sprite = new Sprite();
			this.addChild(layer);
			
			// add layer component
			var i:int;
			var disObj:DisplayObject;
			for (i = 0; i < layerData.length; i++)
			{
				var obj:Object = layerData[i];
				switch (obj["type"]) 
				{
					case "layer":
						layers[obj["n"]] = layer;
						if (obj["n"] in this)
						{
							this[obj["n"]] = layer;
						}
						break;
					case "mc":
						disObj = loadImage(obj);
						layer.addChild(disObj);
						if ("n" in obj) {
							images[obj["n"]] = disObj;
						}
						break;
					case "bt":
						disObj = loadButton(obj);
						layer.addChild(disObj);
						if ("n" in obj) {
							buttons[obj["n"]] = disObj;
						}
						break;
					case "tx":
						disObj = loadText(obj);
						layer.addChild(disObj);
						if ("n" in obj) {
							textFields[obj["n"]] = disObj;
						}
						break;
					case "s":
						loadSpecialMovie(obj);
						break;
				}
				//trace(obj);
			}
		}
		
		public function handleButtonClick(btnId:String, btnObject:BaseButton):void
		{
			onButtonClick(btnId, btnObject);
		}
		
		private function loadSpecialMovie(obj:Object):void
		{
			var name:String = obj["n"];
			if (name == "") return;
			
			var objX:int = obj["x"] ;
			var objY:int = obj["y"] ;
			var objW:int = obj["w"] ;
			var objH:int = obj["h"] ;
			
			switch (obj["src"]) {
				case "rectArea":
					var r:Rectangle = new Rectangle(objX, objY, objW, objH);
					rects[name] = r;
					if ("i" in obj) {
						makeReference(r, name, obj["i"]);
					}
					else {
						makeReference(r, name, -1);
					}
					break;
			}
		}
		
		private function loadButton(obj:Object):BaseButton
		{
			var btnConfig:Object = guiConfig["button"];
			var elem:Object = btnConfig[obj["dt"]];
			var objX:int = obj["x"] ;
			var objY:int = obj["y"] ;
			var objW:int = obj["w"] ;
			var objH:int = obj["h"] ;
			var btn:BaseButton;
			//TODO: base button
			btn = Factory.getObjectFromPool(BaseButton);
			var disObj:DisplayObject;
			var i:int;
			// load elements
			for (i = 0; i < elem.length; i++)
			{
				var bObj:Object = elem[i];
				switch (bObj["type"]) 
				{
					case "mc":
						disObj = loadImage(bObj);
						btn.addIcon(disObj);
						break;
					case "tx":
						disObj = loadText(bObj);
						btn.setLabel(disObj as TextField);
						break;
				}
			}
			// set pos
			btn.x = objX;
			btn.y = objY;
			//btn.width = objW;
			//btn.height = objH;
			
			btn.btnId = obj["n"];
			btn.gui = this;
			// name
			if ("i" in obj) {
				makeReference(btn, obj["n"], obj["i"]);
			}
			else {
				makeReference(btn, obj["n"], -1);
			}
			// skew
			if ("skewX" in obj) {
				btn.skewX = obj["skewX"] * Math.PI / 180;
			}
			if ("skewY" in obj) {
				btn.skewY = obj["skewY"] * Math.PI / 180;
			}
			if (("l" in obj) && (btn.label != null)) {
				btn.label.text = LangUtil.getText(obj["l"]);
			}
			return btn;
		}
		
		private function loadImage(obj:Object):DisplayObject
		{
			var retVal:DisplayObject;
			var objX:int = obj["x"] ;
			var objY:int = obj["y"] ;
			var objW:int = obj["w"] ;
			var objH:int = obj["h"] ;
			var src:String = mvIndex[obj["src"]];
			
			retVal = Asset.getBaseImage(src);			
			retVal.x = objX;
			retVal.y = objY;
			
			// filter
			if ("filter" in obj) {
				var fData:Object = obj["filter"];
				var fMatrix:ColorMatrixFilter = new ColorMatrixFilter();
				var br:Number = fData["br"] / 180;
				var ct:Number = fData["ct"] / 180;
				var sat:Number = fData["sat"] / 100;
				var hue:Number = fData["hue"] / 180;
				if (br != 0) fMatrix.adjustBrightness(br);
				if (ct != 0) fMatrix.adjustContrast(ct);
				if (sat != 0) fMatrix.adjustSaturation(sat * 3);
				if (hue != 0) fMatrix.adjustHue(hue);
				retVal.filter = fMatrix;
			}
			// alpha
			if ("alpha" in obj) {
				retVal.alpha = obj["alpha"] / 100;
			}
			// name
			if ("i" in obj) {
				makeReference(retVal, obj["n"], obj["i"]);
			}
			else {
				makeReference(retVal, obj["n"], -1);
			}
			// skew
			if ("skewX" in obj) {
				retVal.skewX = obj["skewX"] * Math.PI / 180;
			}
			if ("skewY" in obj) {
				retVal.skewY = obj["skewY"] * Math.PI / 180;
			}
			// rotate
			if ("ro" in obj) {
				retVal.rotation = obj["ro"] * Math.PI / 180;
			}
//			if ("sx" in obj) {
//				retVal.scaleX = obj["sx"];
//			}
//			if ("sy" in obj) {
//				retVal.scaleY = obj["sy"];
//			}
			if ("sx" in obj) {
				retVal.width *= obj["sx"];
			}
			if ("sy" in obj) {
				retVal.height *= obj["sy"];
			}
			return retVal;
		}
		
		private function loadText(obj:Object):BaseBitmapTextField
		{
			var objX:int = obj["x"] ;
			var objY:int = obj["y"] ;
			var objW:int = obj["w"] ;
			var objH:int = obj["h"] ;
			var objSX:Number = obj["sx"];
			var objSY:Number = obj["sy"];
			var fontColor:uint = obj["c"];
			var fontSize:int = obj["s"];
			var text:String = "text";			
			var fontName:String = "";								
			fontName = BFConstructor.getFontBySize(fontSize);			
			var txt:BaseBitmapTextField = BFConstructor.getTextField(objW, objH, text, fontName, fontColor);
			txt.scaleX = objSX;			
			txt.scaleY = objSY;
			txt.x = objX;
			txt.y = objY;
			txt.text = LangUtil.getText(obj["l"]);
			if ("i" in obj) {
				makeReference(txt, obj["n"], obj["i"]);
			}
			else {
				makeReference(txt, obj["n"], -1);
			}
			txt.hAlign =  obj["a"] == "justify" ? HAlign.CENTER : obj["a"];
			txt.touchable = false;
			return txt;
		}
		
		private function makeReference(comp:Object, name:String, arrIndex:int):void
		{
			if (name in this) {
				var ar:Array;
				var arrIndex:int;
				if (arrIndex >= 0) {
					if (!(name in arrs)) {
						arrs[name] = new Array();
					}
					ar = arrs[name];
					ar[arrIndex] = comp;
					if (name in this) {
						this[name] = ar;
					}
				}
				else {
					if (name in this) {
						this[name] = comp;
					}
				}
			}
		}						
		
		override public function onRemoved(e:Event):void 
		{
			destroy();
			super.onRemoved(e);			
		}
		
		public function destroy():void
		{
			for each(var layer:Sprite in layers) {
				var num:int = layer.numChildren;
				for (var i:int = 0; i < num; i++) 
				{
					var disp:DisplayObject = layer.getChildAt(i);
					Factory.toPool(disp);					
				}
				layer.removeChildren();
				layer.removeFromParent();
			}
			
			// init new objects
			layers = null;
			buttons = null;
			images = null;
			textFields = null;
			rects = null;
			arrs = null;
		}
		
		public static function loadCfg():void
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			resMgr.load(Asset.TEXT_FOLDER + Asset.BASE_GUI + "/",URLLoaderDataFormat.TEXT,setConfigAllGUIs);
		}
		
	}
}