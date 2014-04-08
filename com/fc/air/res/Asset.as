package com.fc.air.res
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.Factory;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.URLLoaderDataFormat;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class Asset
	{
		public static const ASSET_FOLDER:String = "asset/textures/";
		public static const TEXT_FOLDER:String = "asset/texts/";
		public static const SOUND_FOLDER:String = "asset/sounds/";
		public static const BASE_GUI:String = "gui";								
		public static var contentSuffix:String;		
		static private var scaleRecs:Object;
		static private var LIST_FONTS:Array;
		private static var WALL_LIST:Array;		
		private static var URL_EXTRA_RES:String;
		static private var defaultButton:String;
		private static var particleCfgList:Object;	
		
		public static var isResourceByScaleContent:Boolean;
		
		public function Asset()
		{
		
		}
		
		public static function get scaleRecCollection():Object
		{
			return scaleRecs;
		}
		
		static public function getBasicTextureAtlURL():Array // png/atf, xml 
		{
			var list:Array = [ASSET_FOLDER + BASE_GUI + contentSuffix + ".atf", 
					ASSET_FOLDER + BASE_GUI + contentSuffix + ".xml"];
					
			for each(var s:String in LIST_FONTS)
				list.push(TEXT_FOLDER + s + ".xml");
				
			for each(s in WALL_LIST)
				list.push(ASSET_FOLDER + s + Asset.contentSuffix +  ".atf", ASSET_FOLDER + s + Asset.contentSuffix + ".xml");
				
			return list;
		}
		
		
		
		static public function getTextureAtlURL(name:String, isExternal:Boolean =false):Array // png/atf, xml 
		{
			var arr:Array;
			if(!isExternal)
				arr = [ASSET_FOLDER + name + (isResourceByScaleContent?contentSuffix:"") + ".atf", ASSET_FOLDER + name + (isResourceByScaleContent?contentSuffix:"") + ".xml"];
			else
			{
				var file:String = name + "/" + name + (isResourceByScaleContent?contentSuffix:"");
				arr = [File.cacheDirectory.resolvePath( file + ".atf"), File.cacheDirectory.resolvePath(file + ".xml")];
			}
			return arr;
		}
		
		public static function getImage(texAtl:String,str:String):DisplayObject
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var tex:Texture = resMgr.getTexture(texAtl + (isResourceByScaleContent?contentSuffix:""), str);
			if (getRec(str))
			{				
				var simg:Scale9Image = Factory.getObjectFromPool(Scale9Image);								
				simg.textures = new Scale9Textures(tex, getRec(str));				
				simg.readjustSize();
				simg.width = tex.width;
				simg.height = tex.height;				
				return simg;
			}
			else
			{
				var img:Image = Factory.getObjectFromPool(Image);				
				img.texture = tex;
				img.readjustSize();
				return img;
			}
		}
		
		public static function getBaseImage(str:String):DisplayObject
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var tex:Texture = resMgr.getTexture(Asset.BASE_GUI + Asset.contentSuffix, str);
			if (getRec(str))
			{				
				var simg:Scale9Image = new Scale9Image(new Scale9Textures(tex, getRec(str)));				
				//simg.textures = ;				
				simg.readjustSize();
				simg.width = tex.width;
				simg.height = tex.height;				
				return simg;
			}
			else
			{
				var img:Image = Factory.getObjectFromPool(Image);				
				img.texture = tex;
				img.readjustSize();
				return img;
			}
		}
				
		
		public static function getBaseTexture(str:String):Texture
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			var tex:Texture = resMgr.getTexture(Asset.BASE_GUI + Asset.contentSuffix, str);
			return tex;
		}
		
		public static function getBaseTextures(str:String):Vector.<Texture>
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			return resMgr.getTextures(Asset.BASE_GUI + Asset.contentSuffix, str);			
		}
		
		static public function init(listFont:Array, urlExtraContent:String, wallList:Array, defaultButton:String):void
		{
			Asset.defaultButton = defaultButton;
			var scale:int = int(Starling.contentScaleFactor * 1000)
			if (scale <= 250)
				contentSuffix = "@1x";
			else if (scale <= 375)
				contentSuffix = "@1.5x";
			else if (scale <= 500)
				contentSuffix = "@2x";
			else if (scale <= 750)			
				contentSuffix = "@3x";			
			else
				contentSuffix = "@4x";
			scaleRecs = { };
			LIST_FONTS = listFont;
			URL_EXTRA_RES = urlExtraContent;
			WALL_LIST = wallList;
		}
		
		public static function getRec(name:String):Rectangle
		{
			var rec:* = null;
			if (!scaleRecs)
				scaleRecs = { };
			if (!scaleRecs.hasOwnProperty(name))
			{
				switch (name)
				{				
					default: 
					{
						
						rec = null;
						break;
					}
				}
				scaleRecs[name] = rec;
			}
			return scaleRecs[name];
		}
	
		public static function getTAName(cat:String):String
		{
			return cat + (isResourceByScaleContent?contentSuffix:"");
		}
		
		public static function getExtraContent(cat:String, isWithSoundZip:Boolean = false):Array
		{
			var urls:Array = [];
			urls.push(URL_EXTRA_RES + cat + "/" + cat + (isResourceByScaleContent?contentSuffix:"") + ".atf");
			urls.push(URL_EXTRA_RES + cat + "/" + cat + (isResourceByScaleContent?contentSuffix:"") + ".xml");
			if(isWithSoundZip)
				urls.push(URL_EXTRA_RES + cat + "/" + cat + ".zip");
			return urls;
		}
		
		public static function getDefaultBt():BaseButton
		{
			return getBaseBt(defaultButton);
		}
		
		public static function getBaseBt(...names):BaseButton
		{			
			var bt:BaseButton = Factory.getObjectFromPool(BaseButton);
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			
			for (var i:int = 0; i < names.length; i++) 
			{				
				var img:DisplayObject = getBaseImage(names[i]);				
				bt.addIcon(img);
			}
			
			return bt;
		}
		
		public static function getBaseBtWithTexture(...texs):BaseButton
		{			
			var bt:BaseButton = Factory.getObjectFromPool(BaseButton);
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			for (var i:int = 0; i < texs.length; i++) 
			{
				var img:Image = Factory.getObjectFromPool(Image);
				img.texture = texs[i] as Texture;
				img.readjustSize();
				bt.addIcon(img);
			}			
			return bt;
		}				
		
		public static function getBaseBtWithImage(...imgs):BaseButton
		{
			var bt:BaseButton = Factory.getObjectFromPool(BaseButton);
			for (var i:int = 0; i < imgs.length; i++) 
			{				
				bt.addIcon(imgs[i]);
			}			
			return bt;
		}		
		
		static public function loadParticleCfg(list:Array):void 
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			for (var i:int = 0; i < list.length; i++) 
			{
				resMgr.load(Asset.TEXT_FOLDER + list[i] + ".pex", URLLoaderDataFormat.TEXT, loadComplete, [list[i]]);
			}
			
		}
		
		private static function loadComplete(xmlData:String,name:String):void
		{
			if (!particleCfgList)
			{
				particleCfgList = { };				
			}						
			particleCfgList[name] = new XML(xmlData);
		}
		
		static public function getUniqueParticleSys(name:String, tex:Texture):PDParticleSystem		
		{
			var particleSystem:PDParticleSystem = new PDParticleSystem( particleCfgList[name], tex);
			return particleSystem;
		}
		
		static public function getMovieClip(textures:Vector.<Texture>, fps:int = 24, mv:MovieClip = null):MovieClip
		{
			if(!mv)
			{
				mv = Factory.getObjectFromPool(MovieClip);
			}
			else	// reset
			{
				var fr:int = mv.numFrames;
				for (var i:int = 0; i < fr-1; i++) 
				{
					mv.removeFrameAt(1);						
				}
				mv.stop();
				mv.filter = null;
				Starling.juggler.remove(mv);
			}									
			mv.setFrameTexture(0, textures[0]);			
			fr = textures.length;
			for (i = 1; i < fr; i++) 
			{
				mv.addFrame(textures[i]);
			}
			mv.fps = fps;
			mv.texture = textures[0];
			mv.readjustSize();
			mv.scaleX = mv.scaleY = 1;
			mv.currentFrame = 0;
			Starling.juggler.add(mv);
			return mv;
		}
		
		static public function cloneMV(source:MovieClip, dest:MovieClip):void
		{
			var len:int = source.numFrames;
			
			for (var j:int = 0; j < len; j++) 
			{
				if(dest.numFrames > j)
					dest.setFrameTexture(j, source.getFrameTexture(j));
				else
					dest.addFrame( source.getFrameTexture(j));
			}
			if (len < dest.numFrames)
			{
				var remain:int = dest.numFrames - len;
				for (var k:int = 0; k < remain; k++) 
				{
					dest.removeFrameAt(len)
				}
			}	
			dest.texture = dest.getFrameTexture(0);
			dest.readjustSize();
			dest.smoothing = source.smoothing;
			dest.fps = source.fps;
			dest.width = source.width;
			dest.height = source.height;
			
		}
	}

}