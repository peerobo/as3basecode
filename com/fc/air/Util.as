package com.fc.air
{
	import com.fc.air.base.BaseButton;
	import com.fc.air.base.CallbackObj;
	import com.fc.air.base.Factory;
	import com.fc.air.base.font.BaseBitmapTextField;
	import com.fc.air.base.GlobalInput;
	import com.fc.air.base.IAP;
	import com.fc.air.base.LangUtil;
	import com.fc.air.base.LayerMgr;
	import com.fc.air.comp.IInfoDlg;
	import com.fc.air.comp.ILoading;
	import com.fc.air.res.ResMgr;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.IHash;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.crypto.prng.Random;
	import com.hurlant.util.Hex;	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	import flash.data.EncryptedLocalStore;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	CONFIG::isAndroid {
		import com.freshplanet.ane.AirDeviceId;
		import com.leadbolt.aslib.LeadboltController;
		import com.leadbolt.aslib.LeadboltAdEvent;		
		import com.fc.air.base.SocialForAndroid;
		import com.fc.FCAndroidUtility;
		import com.vungle.extensions.events.VungleEvent;
		import com.vungle.extensions.Vungle;
		import com.vungle.extensions.VungleOrientation;
	}
	
	CONFIG::isIOS {
		import com.freshplanet.ane.AirDeviceId;
		import com.adobe.ane.social.SocialServiceType;
		import com.adobe.ane.social.SocialUI;
		import com.leadbolt.aslib.LeadboltController;
		import com.leadbolt.aslib.LeadboltAdEvent;
		import com.vungle.extensions.events.VungleEvent;
		import com.vungle.extensions.Vungle;
		import com.vungle.extensions.VungleOrientation;
	}
	
	/**
	 * ...
	 * @author ndp
	 */
	public class Util
	{
		public static const HOVER_FILTER:int = 0;
		public static const DISABLE_FILTER:int = 1;
		public static const DOWN_FILTER:int = 2;
		public static var isInitAd:Boolean;			
		private static var appSpecific:Object;
		static public var isBannerAdShowed:Boolean;
		static private var relayoutFuntions:Array;
		public static var iLoading:ILoading;
		public static var iInfoDlg:IInfoDlg;
		
		private static var currentAdType:int;
		private static const AD_FULLSCREEN:int = 0;
		private static const AD_BANNER:int = 1;
		private static const AD_MORE_GAME:int = 2;
		static private var videoAdViewedCallback:Function;
		static private var videoAdStartCallback:Function;
		static private var videoAdDoneCallback:Function;
		CONFIG::isAndroid {
			//private static var leadBoltBanner:LeadboltController;
			//private static var leadBoltFullscreen:LeadboltController;
			//static private var leadBoldMoreGames:LeadboltController;
			static private var leadBoltController:LeadboltController;
		}
		
		CONFIG::isIOS {
			//private static var leadBoltBanner:LeadboltController;
			//private static var leadBoltFullscreen:LeadboltController;
			//static private var leadBoldMoreGames:LeadboltController;
			static private var leadBoltController:LeadboltController;			
		}
		
		static private var rnd:Random;
		static private var timerTween:Timer;
		static private var tweenList:Dictionary;		
		static private var initVideoAdDone:Boolean;
		
		public static function getFilter(type:int):FragmentFilter
		{
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			switch (type)
			{
				case HOVER_FILTER: 
					colorMatrixFilter.adjustBrightness(0.1);
					colorMatrixFilter.adjustContrast(0.05);
					break;
				case DISABLE_FILTER: 
					colorMatrixFilter.adjustSaturation(-1);
					break;
				case DOWN_FILTER: 
					colorMatrixFilter.adjustBrightness(0.2);
					colorMatrixFilter.adjustContrast(0.4);
					break;
			}
			return colorMatrixFilter;
		}				
		
		public function Util()
		{
		
		}	
		
		CONFIG::isAndroid {
			public static const BASE:int = 1
			public static const BASE_1_1:int = 2
			public static const CUPCAKE:int = 3
			public static const CUR_DEVELOPMENT:int = 10000
			public static const DONUT:int = 4
			public static const ECLAIR:int = 5
			public static const ECLAIR_0_1:int = 6
			public static const ECLAIR_MR1:int = 7
			public static const FROYO:int = 8
			public static const GINGERBREAD:int = 9
			public static const GINGERBREAD_MR1:int = 10
			public static const HONEYCOMB:int = 11
			public static const HONEYCOMB_MR1:int = 12
			public static const HONEYCOMB_MR2:int = 13
			public static const ICE_CREAM_SANDWICH:int = 14
			public static const ICE_CREAM_SANDWICH_MR1:int = 15
			public static const JELLY_BEAN:int = 16
			public static const JELLY_BEAN_MR1:int = 17
			public static const JELLY_BEAN_MR2:int = 18
			public static const KITKAT:int = 19
			private static var initAndroidDone:Function;
			public static function initAndroidUtility(enableGooglePlay:Boolean, onInitDone:Function):void
			{				
				if(!FCAndroidUtility.instance.isInit)
				{
					FCAndroidUtility.instance.init(enableGooglePlay);
					initAndroidDone = onInitDone;
					if (enableGooglePlay)
					{
						/*FCAndroidUtility.instance.addEventListener(FCAndroidUtility.ACHIEVEMENT_WRONG, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.ACHIVEMENT_WND_SHOWN, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.LEADERBOARD_WND_SHOWN, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.LICENSE_ERROR, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.NETWORK_ERROR, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.NOT_SIGN_IN, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.SERVICE_ERROR, onGPResponse);*/
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.SIGN_IN_FAILED, onGPResponse);
						FCAndroidUtility.instance.addEventListener(FCAndroidUtility.SIGN_IN_OK, onGPResponse);
					}
					else
					{
						if(initAndroidDone is Function)
							initAndroidDone();
						initAndroidDone = null;
					}
				}
			}
			
			static private function onGPResponse(e:Event):void 
			{
				if (e.type == FCAndroidUtility.SIGN_IN_FAILED || e.type == FCAndroidUtility.SIGN_IN_OK)
				{
					if(initAndroidDone is Function)
						initAndroidDone();
					initAndroidDone = null;
					FCAndroidUtility.instance.removeEventListener(FCAndroidUtility.SIGN_IN_FAILED, onGPResponse);
					FCAndroidUtility.instance.removeEventListener(FCAndroidUtility.SIGN_IN_OK, onGPResponse);
				}
			}

			public static function get androidVersionInt():int
			{
				return FCAndroidUtility.instance.getVersionInt();
			}
			
			public static function setAndroidFullscreen(value:Boolean):void
			{
				if (androidVersionInt >= KITKAT)
					FCAndroidUtility.instance.setImmersive(value);
			}
			
			public static function initVideoAd(appID:String, landscape:Boolean, viewDone:Function, videoStart:Function, videoStop:Function):void		
			{			
				if (isDesktop)
					return;
				if (Vungle.isSupported() && !initVideoAdDone)
				{			
					initVideoAdDone = true;
					Vungle.create([appID], landscape? VungleOrientation.LANDSCAPE:VungleOrientation.PORTRAIT);
					Vungle.vungle.addEventListener(VungleEvent.AD_VIEWED, onVideoAdViewed);
					Vungle.vungle.addEventListener(VungleEvent.AD_STARTED, onVideoAdViewed);
					Vungle.vungle.addEventListener(VungleEvent.AD_FINISHED, onVideoAdViewed);
					videoAdViewedCallback = viewDone;
					videoAdStartCallback = videoStart;
					videoAdDoneCallback = videoStop;
				}
				
			}
			
			static private function onVideoAdViewed(e:VungleEvent):void 
			{
				if (e.type == VungleEvent.AD_VIEWED)
				{
					var percentComplete:Number=e.watched/e.length;
					if(percentComplete>=1)
					{
						if (videoAdViewedCallback is Function)
							videoAdViewedCallback();
					}
				}
				else if (e.type == VungleEvent.AD_STARTED)
				{
					if (videoAdStartCallback is Function)
						videoAdStartCallback();
				}
				else if (e.type == VungleEvent.AD_FINISHED)
				{
					if (videoAdDoneCallback is Function)
						videoAdDoneCallback();
				}
			}
			
			public static function isVideoAdAvailable():Boolean
			{								
				return Vungle.vungle.isAdAvailable();
			}
			
			public static function showVideoAd():void
			{
				Vungle.vungle.displayAd();
			}
		}	
		
		CONFIG::isIOS {
			public static function initVideoAd(appID:String, landscape:Boolean, viewDone:Function, videoStart:Function, videoStop:Function):void		
			{			
				if (Vungle.isSupported() && !initVideoAdDone)
				{			
					initVideoAdDone = true;
					Vungle.create([appID], landscape? VungleOrientation.LANDSCAPE:VungleOrientation.PORTRAIT);
					Vungle.vungle.addEventListener(VungleEvent.AD_VIEWED, onVideoAdViewed);
					Vungle.vungle.addEventListener(VungleEvent.AD_STARTED, onVideoAdViewed);
					Vungle.vungle.addEventListener(VungleEvent.AD_FINISHED, onVideoAdViewed);
					videoAdViewedCallback = viewDone;
					videoAdStartCallback = videoStart;
					videoAdDoneCallback = videoStop;
				}
				
			}
			
			static private function onVideoAdViewed(e:VungleEvent):void 
			{
				if (e.type == VungleEvent.AD_VIEWED)
				{
					var percentComplete:Number=e.watched/e.length;
					if(percentComplete>=1)
					{
						if (videoAdViewedCallback is Function)
							videoAdViewedCallback();
					}
				}
				else if (e.type == VungleEvent.AD_STARTED)
				{
					if (videoAdStartCallback is Function)
						videoAdStartCallback();
				}
				else if (e.type == VungleEvent.AD_FINISHED)
				{
					if (videoAdDoneCallback is Function)
						videoAdDoneCallback();
				}
			}
			
			public static function isVideoAdAvailable():Boolean
			{				
				return Vungle.vungle.isAdAvailable();
			}
			
			public static function showVideoAd():void
			{
				Vungle.vungle.displayAd();
			}
		}
		public static function get isFullApp():Boolean
		{			
			var iap:IAP = Factory.getInstance(IAP);
			var ret:Boolean = Util.isIOS ? iap.checkBought(appSpecific["iapIOS"]) : iap.checkBought(appSpecific["iapAndroid"]);
			if (Util.isDesktop)
				ret = true;
			return ret;
		}
		
		CONFIG::isAndroid {
			public static function shareOnFBAndroid(msg:String,image:BitmapData, onComplete:Function):void
			{
				var social:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				social.share(SocialForAndroid.FACEBOOK_TYPE, msg, image, onComplete);
			}
			
			public static function shareOnTTAndroid(msg:String,image:BitmapData, onComplete:Function):void
			{
				var social:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				social.share(SocialForAndroid.TWITTER_TYPE, msg, image, onComplete);
			}
			
			public static function getUsernameAndroidFB():String
			{
				var social:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				var retStr:String = social.FBName;				
				if (!retStr)
					retStr = LangUtil.getText("notlogged");
				return "(as " + retStr + ")";
			}
			
			public static function getUsernameAndroidTwitter():String
			{
				var social:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				var retStr:String = social.TwitterName;		
				if (!retStr)
					retStr = LangUtil.getText("notlogged");
				return "(as " + retStr + ")";
			}
		}			
		
		CONFIG::isIOS{
			public static function shareOnIOS(isFB:Boolean,msg:String,image:BitmapData):void
			{
				if(SocialUI.isSupported)
				{
					var sUI:SocialUI = new SocialUI(isFB ? SocialServiceType.FACEBOOK : SocialServiceType.TWITTER);
					sUI.setMessage(msg);
					sUI.addImage(image);
					sUI.addEventListener(Event.COMPLETE,onShareIOSDone);
					sUI.addEventListener(ErrorEvent.ERROR,onShareIOSDone);
					sUI.addEventListener(Event.CANCEL,onShareIOSDone);
					sUI.launch();
					var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
					globalInput.setDisableTimeout(3);
				}
				else
				{
					var str:String = LangUtil.getText("shareUnavailable");
					str = Util.replaceStr(str, ["@type"], [type == SocialServiceType.FACEBOOK ? "Facebook":"Twitter"]);					
					showInfoDlg(str, null);					
				}
			}
			
			private static function onShareIOSDone(e:Event):void 
			{
				switch (e.type) 
				{
					case Event.COMPLETE:
						
					break;
					case Event.CANCEL:
						
					break;
					case ErrorEvent.ERROR:
						
					break;
					default:
				}
				var ed:EventDispatcher = e.currentTarget as EventDispatcher;
				ed.removeEventListener(Event.COMPLETE,onShareIOSDone);
				ed.removeEventListener(ErrorEvent.ERROR,onShareIOSDone);
				ed.removeEventListener(Event.CANCEL,onShareIOSDone);			
			}
		}
		
		public static function rateMe():void
		{			
			navigateToURL(new URLRequest(appSpecific["applink"]));
		}
		
		public static function get deviceID():String
		{
			CONFIG::isAndroid {	
				return AirDeviceId.getInstance().getID(appSpecific["appname"]);
			}
			CONFIG::isIOS {	
				return AirDeviceId.getInstance().getID(appSpecific["appname"]);
			}
			return "not a device";
		}
		
		public static function g_centerScreen(disp:DisplayObject):void
		{
			disp.x = Util.appWidth - disp.width >> 1;
			disp.y = Util.appHeight - disp.height >> 1;
		}
		
		public static function g_replaceAndColorUp(textField:BaseBitmapTextField, strs2Replace:Array, strs2ReplaceWith:Array, colorup:Array = null):void		
		{
			var str:String = textField.text;
			if (colorup)
			{
				textField.colorRanges = [];
				textField.colors = [];
			}
			var len:int = strs2Replace.length;
			var regexp:RegExp;
			for (var i:int = 0; i < len; i++) 
			{
				regexp = new RegExp(strs2Replace[i]);
				var res:Array = regexp.exec(str);
				if (res)
				{
					str = str.replace(res[0], strs2ReplaceWith[i]);
					if (colorup)
					{
						textField.colors.push(null, colorup[i]);
						textField.colorRanges.push(res.index, res.index + strs2ReplaceWith[i].length);
					}
				}
			}
			textField.text = str;
		}
		
		public static function replaceStr(str:String, strs2Replace:Array, strs2ReplaceWith:Array):String		
		{
			var len:int = strs2Replace.length;
			var regexp:RegExp;
			for (var i:int = 0; i < len; i++) 
			{
				regexp = new RegExp(strs2Replace[i]);
				var res:Array = regexp.exec(str);
				if (res)
				{
					str = str.replace(res[0], strs2ReplaceWith[i]);				
				}
			}
			return  str;
		}
		
		public static function g_centerChild(p:DisplayObject, c:DisplayObject):void
		{
			c.x = p.width - c.width >> 1;
			c.y = p.height - c.height >> 1;
		}
		
		public static function initAd():void
		{
			isInitAd = false;
			if (!Util.isFullApp)
			{

				//CONFIG::isIOS{
					//leadBoltBanner = new LeadboltController(appSpecific["banner"]);
					//leadBoltBanner.registerDisplayAdEventListeners();					
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);	
					//
					//leadBoltFullscreen = new LeadboltController(appSpecific["fullscreen"]);
					//leadBoltFullscreen.registerDisplayAdEventListeners();					
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);	
					//
					//leadBoldMoreGames = new LeadboltController(appSpecific["moregames"]);
					//leadBoldMoreGames.registerDisplayAdEventListeners();
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);	
					//
				//}
				//CONFIG::isAndroid {
					//leadBoltBanner = new LeadboltController(appSpecific["banner"]);					
					//leadBoltBanner.registerDisplayAdEventListeners();					
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoltBanner.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					//
					//leadBoltFullscreen = new LeadboltController(appSpecific["fullscreen"]);
					//leadBoltFullscreen.registerDisplayAdEventListeners();					
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoltFullscreen.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					//
					//leadBoldMoreGames = new LeadboltController(appSpecific["moregames"]);
					//leadBoldMoreGames.registerDisplayAdEventListeners();					
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					//leadBoldMoreGames.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);	
				//}
				isInitAd = true;
			}
		}
		
		CONFIG::isAndroid{
			
			private static function onLeadBoltAdEvent(e:LeadboltAdEvent):void 
			{				
				var target:LeadboltController = e.currentTarget as LeadboltController;
				switch (e.type) 
				{
					case LeadboltAdEvent.ON_AD_FAILED:
						FPSCounter.log("lead bolt ad failed");
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
							hideLoading();
					break;
					case LeadboltAdEvent.ON_AD_CACHED:						
						target.loadAd();
						if(currentAdType == AD_BANNER)
							relayoutAfterAd(true);
					break;
					case LeadboltAdEvent.ON_AD_LOADED:
						if(currentAdType == AD_BANNER)
							isBannerAdShowed = true;
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
						{
							LayerMgr.lockGameLayer = true;
							hideLoading();
						}
					break;
					case LeadboltAdEvent.ON_AD_CLICKED:
						target.destroyAd();
						LayerMgr.lockGameLayer = false;
					break;
					case LeadboltAdEvent.ON_AD_CLOSED:
						LayerMgr.lockGameLayer = false;
					break;
					case LeadboltAdEvent.ON_AD_ALREADYCOMPLETED:						
						if(currentAdType == AD_BANNER)
						{
							relayoutAfterAd(false);
							isBannerAdShowed = false;
						}
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
							hideLoading();
					break;
					default:
				}			
			}					
		}
		
		CONFIG::isIOS{
			private static function onLeadBoltAdEvent(e:LeadboltAdEvent):void 
			{				
				var target:LeadboltController = e.currentTarget as LeadboltController;
				switch (e.type) 
				{
					case LeadboltAdEvent.ON_AD_FAILED:
						FPSCounter.log("lead bolt ad failed");
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
							hideLoading();
					break;
					case LeadboltAdEvent.ON_AD_CACHED:						
						target.loadAd();
						if(currentAdType == AD_BANNER)
							relayoutAfterAd(true);
					break;
					case LeadboltAdEvent.ON_AD_LOADED:
						if(currentAdType == AD_BANNER)
							isBannerAdShowed = true;
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
						{
							LayerMgr.lockGameLayer = true;
							hideLoading();
						}
					break;
					case LeadboltAdEvent.ON_AD_CLICKED:
						target.destroyAd();
						LayerMgr.lockGameLayer = false;
					break;
					case LeadboltAdEvent.ON_AD_CLOSED:
						LayerMgr.lockGameLayer = false;
					break;
					case LeadboltAdEvent.ON_AD_ALREADYCOMPLETED:						
						if(currentAdType == AD_BANNER)
						{
							relayoutAfterAd(false);
							isBannerAdShowed = false;
						}
						if (currentAdType == AD_FULLSCREEN || currentAdType == AD_MORE_GAME)
							hideLoading();
					break;
					default:
				}
			}					
		}
		
		static private function relayoutAfterAd(adShowed:Boolean):void 
		{
			var len:int = relayoutFuntions ? relayoutFuntions.length : 0;
			for (var i:int = 0; i < len; i++) 
			{
				var f:Function = relayoutFuntions[i];
				f.apply(null, [adShowed]);
			}
		}
		
		static public function registerRelayoutAfterAd(f:Function, isRemove:Boolean):void
		{
			if(!relayoutFuntions)
				relayoutFuntions = [];
			var idx:int = relayoutFuntions.indexOf(f);
			if (isRemove)
			{
				if (idx > -1)
					relayoutFuntions.splice(idx, 1);
			}
			else
			{
				if (idx == -1)
					relayoutFuntions.push(f);
			}
		}		
		
		public static function showBannerAd():void
		{
			if (isInitAd)
			{	
				FPSCounter.log("show banner");
				CONFIG::isIOS{					
					//leadBoltBanner.destroyAd();
					//leadBoltBanner.loadAdToCache();
					if(currentAdType != AD_BANNER)
						createLeadBoltController(appSpecific["banner"]);
					else
						leadBoltController.destroyAd();
					leadBoltController.loadAdToCache();
					Starling.juggler.delayCall(showBannerAd, 120);
					currentAdType = AD_BANNER;
				}
				CONFIG::isAndroid {					
					//leadBoltBanner.destroyAd();
					//leadBoltBanner.loadAdToCache();	
					if(currentAdType != AD_BANNER)
						createLeadBoltController(appSpecific["banner"]);
					else
						leadBoltController.destroyAd();
					leadBoltController.loadAdToCache();					
					currentAdType = AD_BANNER;
				}
			}
		}
		
		//public static function hideBannerAd():void
		//{
			//if(isInitAd)
			//{
				//FPSCounter.log("hide banner");
				//CONFIG::isIOS {
					//leadBoltBanner.destroyAd();
				//}
				//CONFIG::isAndroid {
					//leadBoltBanner.destroyAd();
				//}
				//isBannerAdShowed = false;
			//}
		//}
		
		public static function showFullScreenAd():void
		{
			if (isInitAd)
			{
				if (isDesktop)
					return;
				CONFIG::isIOS {
					//leadBoltFullscreen.loadAdToCache();
					createLeadBoltController(appSpecific["fullscreen"]);
					leadBoltController.loadAdToCache();
					showLoading();
					currentAdType = AD_FULLSCREEN;
				}
				CONFIG::isAndroid {
					//leadBoltFullscreen.loadAdToCache();
					createLeadBoltController(appSpecific["fullscreen"]);
					leadBoltController.loadAdToCache();
					showLoading();
					currentAdType = AD_FULLSCREEN;
				}
			}
		}
		
		public static function showMoreGames():void
		{
			if (isInitAd)
			{
				if (isDesktop)
					return;
				CONFIG::isIOS {
					//leadBoldMoreGames.loadAdToCache();
					createLeadBoltController(appSpecific["moregames"]);
					leadBoltController.loadAdToCache();
					showLoading();
					currentAdType = AD_MORE_GAME;
				}
				CONFIG::isAndroid {
					//leadBoldMoreGames.loadAdToCache();
					createLeadBoltController(appSpecific["moregames"]);
					leadBoltController.loadAdToCache();
					showLoading();
					currentAdType = AD_MORE_GAME;
				}
			}
		}
		
		//public static function hideMoreGames():void
		//{
			//if (isInitAd)
			//{
				//if (isDesktop)
					//return;
				//CONFIG::isIOS {
					//leadBoldMoreGames.destroyAd();
					//hideLoading();
				//}
				//CONFIG::isAndroid {
					//leadBoldMoreGames.destroyAd();
					//hideLoading();
				//}
			//}
		//}
		
		public static function hideLoading():void
		{
			//TODO: close ad loading
			if(iLoading)
				iLoading.close();
		}
		
		public static function showLoading():void
		{
			//TODO: show ad loading
			if(iLoading)
				iLoading.show();
		}
		
		private static function createLeadBoltController(id:String):void
		{
			CONFIG::isIOS {
				if (leadBoltController)
				{
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					leadBoltController.destroyAd();
				}
				leadBoltController = new LeadboltController(id);
				leadBoltController.registerDisplayAdEventListeners();					
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
			}
			
			CONFIG::isAndroid {
				if (leadBoltController)
				{
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					leadBoltController.destroyAd();
				}
				leadBoltController = new LeadboltController(id);
				leadBoltController.registerDisplayAdEventListeners();					
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
				leadBoltController.addEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
			}
		}
		
		public static function hideAd():void
		{
			CONFIG::isAndroid {
				if (leadBoltController)
				{
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					leadBoltController.destroyAd();
				}
				hideLoading();
			}
			CONFIG::isIOS {
				if (leadBoltController)
				{
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_LOADED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLICKED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CLOSED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_COMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_FAILED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_ALREADYCOMPLETED, onLeadBoltAdEvent);
					leadBoltController.removeEventListener(LeadboltAdEvent.ON_AD_CACHED, onLeadBoltAdEvent);
					leadBoltController.destroyAd();
				}
				hideLoading();
			}
		}
		
		public static function showInfoDlg(msg:String, callback:CallbackObj):void
		{
			//TODO: show info dlg
			if(iInfoDlg)
				iInfoDlg.showInfo(msg, callback);
		}
		
		public static function numberWithCommas(number:Number):String
		{
			var str:String = number.toString();
			var pattern:RegExp = /(-?\d+)(\d{3})/;
			while (pattern.test(str))
				str = str.replace(pattern, "$1,$2");
			return str;
		}
		
		public static function get appWidth():int
		{
			return Starling.current.stage.stageWidth;
		}
		
		public static function get appHeight():int
		{
			return Starling.current.stage.stageHeight;
		}
		
		public static function get deviceWidth():int
		{
			CONFIG::isIOS {
				return Starling.current.nativeStage.fullScreenWidth;
			}
			if(isDesktop)
				return Starling.current.nativeStage.fullScreenWidth;
			else
				return Starling.current.nativeStage.stageWidth;
		}
		
		public static function get deviceHeight():int
		{
			CONFIG::isIOS {
				return Starling.current.nativeStage.fullScreenHeight;
			}
			if (isDesktop)
				return Starling.current.nativeStage.fullScreenHeight;
			else
				return Starling.current.nativeStage.stageHeight;
		}
		
		public static function getLocalData(soName:String):SharedObject
		{
			var result:SharedObject = SharedObject.getLocal(appSpecific["appname"] + "_" + soName);
			return result;
		}
		
		public static function g_fit(disp:DisplayObject, fitObj:*):void
		{
			var rec:Rectangle;
			if (fitObj is Rectangle)
			{
				rec = fitObj;
			}
			else if (fitObj is DisplayObject)
			{
				rec = fitObj.getBounds(fitObj);
			}
			disp.width = disp.width > rec.width ? rec.width : disp.width;
			disp.scaleY = disp.scaleX;
			
			disp.height = disp.height > rec.height ? rec.height : disp.height;
			disp.scaleX = disp.scaleY;
			
			disp.x = rec.x + (rec.width - disp.width >> 1);
			disp.y = rec.y + (rec.height - disp.height >> 1);
		}
		
		public static function registerPool():void
		{
			Factory.registerPoolCreator(Image, function():Image
				{
					var img:Image = new Image(Texture.empty(1, 1));
					img.smoothing = TextureSmoothing.BILINEAR;
					return img;
				}, function(img:Image):void
				{									
					img.x = img.y = 0;
					img.scaleX = img.scaleY = 1;
					img.touchable = true;
					img.visible = true;
					img.filter = null;
					img.pivotY = img.pivotX = 0;
					img.rotation = 0;
					img.alpha = 1;						
					img.smoothing = TextureSmoothing.BILINEAR;
					img.dispose();
					img.skewX = img.skewY = 0;					
				});						
				
			Factory.registerPoolCreator(MovieClip, function():MovieClip
				{
					var vc:Vector.<Texture> = new Vector.<Texture>();
					vc.push(Texture.empty(1, 1));
					var mc:MovieClip = new MovieClip(vc, 1);
					Starling.juggler.add(mc);
					return mc;
				}, function(mv:MovieClip):void
				{
					var fr:int = mv.numFrames;
					for (var i:int = 0; i < fr-1; i++) 
					{
						mv.removeFrameAt(1);						
					}
					mv.x = mv.y = 0;
					mv.scaleX = mv.scaleY = 1;
					mv.touchable = true;
					mv.visible = true;
					mv.filter = null;
					mv.pivotY = mv.pivotX = 0;
					mv.rotation = 0;
					mv.alpha = 1;						
					mv.smoothing = TextureSmoothing.BILINEAR;
					mv.stop();
					mv.filter = null;
					Starling.juggler.remove(mv);
				}
				);
			
			Factory.registerPoolCreator(BaseBitmapTextField, function():BaseBitmapTextField
				{
					return new BaseBitmapTextField(1, 1, "");
				}, function(txt:BaseBitmapTextField):void
				{
					txt.reset();
				});
			
			Factory.registerPoolCreator(CallbackObj, function():CallbackObj
				{
					return new CallbackObj(null);
				}, function(c:CallbackObj):void
				{
					c.f = null;
					c.p = null;
					c.optionalData = null;
				});
			Factory.registerPoolCreator(Quad, function():Quad
				{
					return new Quad(1, 1);
				});
			Factory.registerPoolCreator(Scale9Image, function():Scale9Image
				{
					var scale9Textures:Scale9Textures = new Scale9Textures(Texture.empty(1, 1), new Rectangle(0, 0, 0, 0));
					var scale9Img:Scale9Image = new Scale9Image(scale9Textures);
					return scale9Img;
				}, function(img:Scale9Image):void
				{
					img.x = img.y = 0;
					img.scaleX = img.scaleY = 1;
					img.touchable = true;
					img.visible = true;
					img.filter = null;
					img.pivotY = img.pivotX = 0;
					img.rotation = 0;
					img.alpha = 1;										
				});
			Factory.registerPoolCreator(BaseButton, function():BaseButton
				{
					var bt:BaseButton = new BaseButton();					
					return bt;
				}, function(bt:BaseButton):void
				{
					bt.destroy();
				});
		}
		
		
		static public function get isIOS():Boolean
		{							
			CONFIG::isIOS {
				return AirDeviceId.getInstance().isOnIOS;
			}
			return false;
		}
		
		static public function get isAndroid():Boolean
		{
			CONFIG::isAndroid {
				return AirDeviceId.getInstance().isOnAndroid;
			}
			return false;
		}
		
		static public function get isDesktop():Boolean
		{
			return (Capabilities.os.indexOf("Windows ") != -1);
		}
		
		static public function setPrivateValue(key:String, value:String):void
		{
			if (EncryptedLocalStore.isSupported)
			{
				
				var hash:IHash = Crypto.getHash("sha1");
				var bytes:ByteArray = new ByteArray();
				bytes.writeUTFBytes(appSpecific["appname"] + "_" + key);
				var retBytes:ByteArray = hash.hash(bytes);				
				var hashKey:String = Hex.fromArray(retBytes, false);								
				if (value == null)
				{
					EncryptedLocalStore.removeItem(hashKey)
				}
				else
				{
					bytes = new ByteArray();
					bytes.writeUTFBytes(value);		
					EncryptedLocalStore.setItem(hashKey, bytes);
				}
			}
		}
		
		static public function getPrivateKey(key:String):String
		{
			if (EncryptedLocalStore.isSupported)
			{
				var hash:IHash = Crypto.getHash("sha1");
				var bytes:ByteArray = new ByteArray();
				bytes.writeUTFBytes(appSpecific["appname"] + "_" + key);
				var retBytes:ByteArray = hash.hash(bytes);				
				var hashKey:String = Hex.fromArray(retBytes, false);
				var storedValue:ByteArray = EncryptedLocalStore.getItem(hashKey);
				return storedValue ? storedValue.readUTFBytes(storedValue.length) : null;
			}
			return null;
		}				
		
		static public function g_takeSnapshot():BitmapData
		{
			var image:BitmapData = new BitmapData(Util.deviceWidth, Util.deviceHeight, true, 0xFFFFFFFF);
			Starling.current.stage.drawToBitmapData(image);
			return image;
		}
		
		static public function initApp(objAppSpecific:Object):void 
		{
			appSpecific = objAppSpecific;
			var iap:IAP = Factory.getInstance(IAP);
			iap.registerIDs(appSpecific);			
			
			CONFIG::isAndroid {
				var social:SocialForAndroid = Factory.getInstance(SocialForAndroid);
				social.registerIDs(appSpecific);
			}
		}
		
		static public function getRandom(maxValue:int=256):Number
		{
			if(!rnd)
			{
				rnd = new Random(ARC4);			
				rnd.autoSeed();
			}
			return Number(rnd.nextByte()) / 256 * maxValue;
		}
		
		/**
		 * 
		 * @param	obj object to tween
		 * @param	props props to change
		 * @param	onUpdate function(obj,props)
		 * @param	onComplete function(obj,props)
		 */
		static public function tweenWithTimer(obj:Object, props:Object, onUpdate:Function, onComplete:Function):void
		{
			if (!timerTween)
			{
				timerTween = new Timer(1000 / Starling.current.nativeStage.frameRate);
				timerTween.addEventListener(TimerEvent.TIMER, onTimerTween);
				timerTween.start();
				tweenList = new Dictionary();
			}
			if (tweenList[obj] == null)
			{
				tweenList[obj] = {
					obj:obj,
					props:props,
					update:onUpdate,
					complete:onComplete
				};
			}
		}
		
		public static function get adBannerHeight():int 
		{
			var h:int = 0.124 * Starling.current.nativeStage.fullScreenHeight;
			//h = h > 135 ? 135 : h;
			h = h > 60 ? 60 : h;
			return  h;
		}
		
		static public function get internetAvailable():Boolean
		{
			var resMgr:ResMgr = Factory.getInstance(ResMgr);
			return resMgr.isInternetAvailable;
		}
		
		static private function onTimerTween(e:TimerEvent):void 
		{
			for each(var item:Object in tweenList)
			{
				var obj:Object = item.obj;
				var props:Object = item.props;
				var onUpdate:Function = item.update;
				var onComplete:Function = item.complete;
				var bool:Boolean = true;
				for (var name:String in props) 
				{
					if (obj.hasOwnProperty(name))
					{
						if (!props.hasOwnProperty("tmp" + name))
							props["tmp" + name] = obj[name];						
						props["tmp" + name] = props["tmp" + name] + (props[name] - props["tmp" + name]) / 3;
						bool &&= Math.abs(int(props["tmp" + name] * 100) - int(props[name] * 100)) <= 1;
						obj[name] = props["tmp" + name];
						if (bool)
							obj[name] = props[name];
					}
				}
				if (onUpdate is Function)
					onUpdate(obj, props);
				if (bool)
				{
					if(onComplete is Function)
						onComplete(obj, props);					
					delete tweenList[obj];
				}
			}
		}
	}

}

