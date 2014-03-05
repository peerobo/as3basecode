package com.fc.air.res 
{
	import air.net.URLMonitor;
	import com.fc.air.base.CallbackObj;
	import com.fc.air.base.Factory;
	import com.fc.air.FPSCounter;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.as3commons.zip.Zip;
	import org.as3commons.zip.ZipFile;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	/**
	 * ...
	 * @author ndp
	 */
	public class ResMgr 
	{
		private var assetMgr:AssetManager;
		public var assetProgress:Number;
		
		// dynamic loading
		private var urlLoader:URLLoader;
		private var urlRequest:URLRequest;
		private var waitList:Array;	// CallbackObj		
		private var monitor:URLMonitor;
		
		private var extraContentList:Array;
		private var extraOnCompleteFunc:Function;
		private var extraOnAdvanceFunction:Function;
		private var extraCurrentIdx:int;
		private var extraURLLoader:URLLoader;
		private var extraURLRequest:URLRequest;
		public var extraCurrentByte:uint;
		public var extraCurrentByte2Load:uint;	
		public var extraCurrentProgressStr:String;
		public var isInternetAvailable:Boolean;
		
		public function ResMgr() 
		{
			assetMgr = new AssetManager(Starling.contentScaleFactor);			
			assetMgr.verbose = false;
			
			monitor = new URLMonitor(new URLRequest("http://www.google.com"));		
			monitor.addEventListener(StatusEvent.STATUS, onMonitor);
			
			// for dynamic loading
			urlLoader = new URLLoader();			
			urlLoader.addEventListener(Event.COMPLETE, onLoadedItem);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadItemError);
			urlRequest = new URLRequest();
			
			// for extra content download
			extraURLLoader = new URLLoader();
			extraURLRequest = new URLRequest();
			extraURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			extraURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onExtraContentSecurityError);
			extraURLLoader.addEventListener(IOErrorEvent.IO_ERROR, onExtraIOError);
			extraURLLoader.addEventListener(ProgressEvent.PROGRESS, onExtraDonwloadProgress);
			extraURLLoader.addEventListener(Event.OPEN, onExtraStartDownloadNewItem);
			extraURLLoader.addEventListener(Event.COMPLETE, onCompleteAnItem);
			extraCurrentIdx = -1;
			
			waitList = [];		
			checkInternet();
			NativeApplication.nativeApplication.addEventListener(Event.NETWORK_CHANGE, onNetworkChange);			
			
		}				
		
		private function updateInternalProgress():void
		{
			if (extraCurrentIdx > -1)
			{
				extraCurrentByte = extraURLLoader.bytesLoaded;
				extraCurrentByte2Load = extraURLLoader.bytesTotal;				
				Starling.juggler.delayCall(updateInternalProgress, 0.2);
			}			
		}
		
		private function onNetworkChange(e:Event):void 
		{
			checkInternet();
		}
		
		public function checkInternet():void
		{			
			monitor.start();
		}
		
		private function onMonitor(e:StatusEvent):void 
		{
			FPSCounter.log("internet available:", monitor.available);
			isInternetAvailable = monitor.available;
		}
		
		private function onLoadedItem(e:Event):void 
		{			
			var callbackObj:CallbackObj = waitList[0];
			if (!callbackObj.p)
				callbackObj.p = [];
			callbackObj.p.splice(0, 0, urlLoader.data);
			callbackObj.f.apply(this, callbackObj.p);
			waitList.splice(0, 1);
			if (waitList.length > 0)
				continueLoad();
		}
		
		private function onLoadItemError(e:IOErrorEvent):void 
		{
			waitList.splice(0, 1);
			if (waitList.length > 0)
				continueLoad();
		}
		
		/**
		 * load dynamic content
		 * @param	url url to load
		 * @param	dataType URLLoaderDataFormat.xxx
		 * @param	onComplete callback function with at least 1 param: f(loadedData:*):void
		 * @param	onCompleteParam optional params, ex: f(loadedData:*,param1,param2):void
		 */
		public function load(url:String, dataType:String, onComplete:Function, onCompleteParam:Array=null):void
		{
			var len:int = waitList.length;
			var item:CallbackObj = Factory.getObjectFromPool(CallbackObj);
			item.f = onComplete;
			item.p = onCompleteParam;
			item.optionalData = { url:url, dataType:dataType };				
			waitList.push(item);			
							
			if (waitList.length == 1)
			{
				continueLoad();
			}
			
		}
		
		private function continueLoad():void
		{
			var item:CallbackObj = waitList[0];
			var url:String = item.optionalData.url;
			var dataType:String = item.optionalData.dataType;
			
			urlRequest.url = url;
			urlLoader.dataFormat = dataType;
			urlLoader.load(urlRequest);
			
		}
		
		public function start():void
		{
			assetMgr.purge();
			updateInternalProgress();
			
			assetMgr.enqueue(Asset.getBasicTextureAtlURL());			
			assetMgr.loadQueue(onAssetProgress);			
		}
		
		private function onAssetProgress(progress:Number):void 
		{
			assetProgress = progress;			
		}
		
		public function getTexture(texAtl:String,tex:String):Texture
		{
			return assetMgr.getTextureAtlas(texAtl).getTexture(tex);
		}
		
		public function getTextures(texAtl:String, tex:String):Vector.<Texture>
		{
			return assetMgr.getTextureAtlas(texAtl).getTextures(tex);
		}
		
		public function getXML(name:String):XML
		{
			return assetMgr.getXml(name);
		}
		
		/**
		 * load texture atlas
		 * @param	name texture name
		 * @param	onProgress function(progress:Number):void
		 * @param	isExternal in program directory or cache directory
		 * @return can download Texture
		 */
		public function loadTextureAtlas(name:String, onProgress:Function, isExternal:Boolean = false):Boolean		
		{
			if (assetMgr.getTextureAtlas(name + (Asset.isResourceByScaleContent ? Asset.contentSuffix : "")))
			{
				onProgress(1);
				return true;
			}			
			// TODO: check if assetMgr is free or not
			// code here			
			if (assetMgr.numQueuedAssets < 1)
			{				
				assetMgr.enqueue(Asset.getTextureAtlURL(name,isExternal));
				assetMgr.loadQueue(onProgress);
				return true;							
			}
			else
			{
				return false;
			}
		}
		
		public function removeTextureAtlas(name:String):void
		{
			assetMgr.removeTextureAtlas(name + (Asset.isResourceByScaleContent ? Asset.contentSuffix : ""),true);
		}
		
		/**
		 * get extra content from remote server
		 * @param	assetList
		 * @param	onComplete function():void
		 * @param	onAdvanceFunction function(idx:int):void
		 */ 		
		public function getExtraContent(assetList:Array = null, onComplete:Function = null, onAdvanceFunction:Function = null):void
		{
			//onComplete();
			//onAdvanceFunction(idx:int);
			if(assetList)
			{	
				extraContentList = assetList.concat();
				extraOnCompleteFunc = onComplete;
				extraOnAdvanceFunction = onAdvanceFunction;				
				extraCurrentIdx = 0;
			}						

			while (checkCacheDirectoryForFiles([extraContentList[extraCurrentIdx]]))
			{				
				extraOnAdvanceFunction(extraCurrentIdx);
				extraCurrentIdx++;
				if (extraCurrentIdx >= extraContentList.length)
				{
					extraCurrentIdx = -1;
					extraOnCompleteFunc();
					return;
				}
			}
			extraOnAdvanceFunction(extraCurrentIdx);
			downloadExtraContent();			
		}
		
		private function downloadExtraContent():void 
		{
			extraURLRequest.url = extraContentList[extraCurrentIdx];
			extraURLLoader.load(extraURLRequest);
		}
		
		public function checkCacheDirectoryForFiles(urls:Array):Boolean
		{
			var check:Boolean = true;
			var regexp:RegExp = /\/(([^\/]+)\.\w+$)/;
			for (var i:int = 0; i < urls.length; i++) 
			{
				var result:Array = regexp.exec(urls[i]);
				if (result)
				{
					result[2] = result[2].replace(/@\dx/, "");
					var entryFile:File = File.cacheDirectory.resolvePath(result[2] + "/"+result[1]);
					check &&= entryFile.exists;
					if (!check)
						break;
				}
				else
				{
					check &&= false;
					break;
				}
			}
			return check;
		}
		
		private function onCompleteAnItem(e:Event):void 
		{
			var byteArray:ByteArray = extraURLLoader.data;
			var fileName:String = extraURLRequest.url;
			var directory:String;
			extraCurrentByte = extraCurrentByte2Load;
			if (fileName.indexOf(".zip") > -1)
			{
				extraCurrentProgressStr = "Extracting sounds...";
				extractZip();
			}
			else
			{
				extraCurrentProgressStr = "Saving...";
				// save file to cache folder				
				var file:File = File.cacheDirectory.resolvePath(url2cache(fileName));
				var fr:FileStream = new FileStream();
				fr.open(file, FileMode.WRITE);
				fr.writeBytes(byteArray);
				fr.close();				
			}				
			extraCurrentIdx++;
			if (extraCurrentIdx == extraContentList.length)
			{
				extraCurrentIdx = -1;
				extraOnCompleteFunc();
				return;
			}
			getExtraContent();
		}
		
		private function url2cache(url:String):String
		{
			var file:File;
			var fileName:String = url;
			var directory:String;
			var regexp:RegExp;
			if (url.indexOf(".zip") > -1)
			{
				regexp = /\/(([^\/]+)\.\w+$)/;
			}
			else
			{
				regexp = /\/((\w*)@\dx\.\w+)/g;
			}	
			var result:Array = regexp.exec(fileName);		
			if (result)
			{
				fileName = result[1];
				directory = result[2];
			}
			var retStr:String = "";
			if (url.indexOf(".zip") > -1)
			{
				retStr = directory;
			}
			else
			{
				retStr = directory + "/" + fileName;
			}
			
			return retStr;
		}
		
		private function extractZip():void 
		{			
			var fr:FileStream;
			var directory:String = url2cache(extraURLRequest.url);
			// mark as downloaded
			var zip:Zip = new Zip();
			zip.loadBytes(extraURLLoader.data);
			var count:int = zip.getFileCount();
			for (var i:int = 0; i < count; i++) 
			{
				var zipFile:ZipFile = zip.getFileAt(i);
				
				file = File.cacheDirectory.resolvePath(directory + "/" + zipFile.filename);
				fr = new FileStream();
				fr.open(file, FileMode.WRITE);
				fr.writeBytes(zipFile.content);
				fr.close();				
			}
			fr = new FileStream();
			var file:File = File.cacheDirectory.resolvePath(directory + "/" + directory + ".zip");
			fr.open(file, FileMode.WRITE);
			fr.writeBytes(new ByteArray());
			fr.close();
		}
		
		private function onExtraStartDownloadNewItem(e:Event):void 
		{
			extraCurrentProgressStr = "Requesting..." + extraURLRequest.url;
			extraCurrentByte = 0;
			extraCurrentByte2Load = 0;
			trace(extraCurrentProgressStr);
		}
		
		private function onExtraDonwloadProgress(e:ProgressEvent):void 
		{
			extraCurrentProgressStr = "Downloading...";
			extraCurrentByte2Load = extraURLLoader.bytesTotal;
			extraCurrentByte = extraURLLoader.bytesLoaded;			
		}
		
		private function onExtraIOError(e:IOErrorEvent):void 
		{
			extraCurrentProgressStr = "IO Error on link: " + extraURLRequest.url + ". Please contact us!";
			trace(extraCurrentProgressStr);
		}
		
		private function onExtraContentSecurityError(e:SecurityErrorEvent):void 
		{
			extraCurrentProgressStr = "Security Error on link: " + extraURLRequest.url + ". Please contact us!";
			trace(extraCurrentProgressStr);
		}
	}

}