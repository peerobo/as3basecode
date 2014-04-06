package com.fc.air.base 
{
	import com.fc.air.comp.IAchievementBanner;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;	
	import flash.events.Event;
	CONFIG::isIOS{
		import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
		import com.adobe.ane.gameCenter.GameCenterController;
		import com.adobe.ane.gameCenter.GameCenterLeaderboardEvent;
	}
	CONFIG::isAndroid{
		import com.fc.FCAndroidUtility;
	}
	/**
	 * ...
	 * @author ndp
	 */
	public class GameService 
	{
		static public const HIGHSCORE_ITUNE_PRE:String = "cat";
		static public const OVERALL_HIGHSCORE:String = "overall";
		private var highscoreMap:Object;
		private var achiMap:Object;
		private var gameCenterLogged:Boolean;
		private var googlePlayLogged:Boolean;		
		public var achievementBanner:IAchievementBanner;
		
		// game center only
		CONFIG::isIOS{
			private var gcController:GameCenterController;					
			private var validCats:Array;
		}
		
		CONFIG::isAndroid{
			private var googlePlay:FCAndroidUtility;			
			public var googlePlayTaskDone:Function;	//function()
			public var googlePlayTaskRetValueReq:Array;
			public var googlePlayParam:Array;
		}
		
		
		public function initGameCenter():void
		{
			CONFIG::isIOS{
				if (GameCenterController.isSupported)
				{
					FPSCounter.log("init game center");
					gcController = new GameCenterController();
					//Authenticate 
					gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_NOT_AUTHENTICATED, gameCenterAuthenticatedFailed);				
					gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATION_CHANGED, gameCenterAuthenticatedChanged);				
					//Leadership
					gcController.addEventListener(GameCenterLeaderboardEvent.LEADERBOARD_VIEW_FINISHED, leaderBoardViewClose);
					gcController.addEventListener(GameCenterLeaderboardEvent.LEADERBOARD_CATEGORIES_LOADED, leaderboardeCategoriesLoaded);				
					gcController.addEventListener(GameCenterLeaderboardEvent.LEADERBOARD_CATEGORIES_FAILED, leaderboardeCategoriesFailed);	
					if (!gcController.authenticated) {
						gcController.addEventListener(GameCenterAuthenticationEvent.PLAYER_AUTHENTICATED, gameCenterAuthenticated);
						gcController.authenticate();
						FPSCounter.log("authen game center");
					}
				}
			}
		}
			
		CONFIG::isIOS{	
			private function leaderBoardViewClose(e:GameCenterLeaderboardEvent):void 
			{
				var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
				globalInput.disable = false;
			}
			
			private function gameCenterAuthenticatedChanged(e:GameCenterAuthenticationEvent):void 
			{
				gameCenterLogged = gcController.authenticated;
			}
			
			private function gameCenterAuthenticatedFailed(e:GameCenterAuthenticationEvent):void 
			{
				FPSCounter.log("cannot log in game center");
				gameCenterLogged = false;
			}
			
			private function leaderboardeCategoriesFailed(e:GameCenterLeaderboardEvent):void 
			{
				validCats = null;
			}
			
			private function leaderboardeCategoriesLoaded(e:GameCenterLeaderboardEvent):void 
			{
				validCats = e.leaderboardCategories;
			}
			
			protected function gameCenterAuthenticated(event:GameCenterAuthenticationEvent):void
			{
				gameCenterLogged = gcController.authenticated;
				FPSCounter.log("authen game center done");
				if (gcController.authenticated)
				{
					FPSCounter.log("authen game center ok");
					gcController.requestLeaderboardCategories();
				}
			}
		}
		
		public function GameService() 
		{
			highscoreMap = { };
			achiMap = { };
		}
		
		public function registerType(type:String):void
		{
			if (!highscoreMap.hasOwnProperty(type))
			{
				highscoreMap[type] = 0;
			}
		}
		
		public function getHighscore(type:String):int
		{
			return highscoreMap[type];
		}
		
		public function setHighscore(type:String, value:int):void
		{
			var catName:String;
			if (highscoreMap[type] >= value)
				return;
			highscoreMap[type ] = value;					
			CONFIG::isIOS{
				if (Util.isIOS && gameCenterLogged && validCats)
				{					
					if(validCats.indexOf(type) > -1)
						gcController.submitScore(value, type);				
				}				
			}
			CONFIG::isAndroid {
				if (Util.isAndroid)
				{					
					googlePlay.gpSetScore(type,value);
				}
			}			
		}
		
		public function save():void
		{
			for (var s:String in highscoreMap) 
			{
				Util.setPrivateValue(s, highscoreMap[s]);				
			}	
			var achStr:String = JSON.stringify(achiMap);
			Util.setPrivateValue("achi", achStr);
		}
		
		public function load():void
		{
			for (var s:String in highscoreMap) 
			{
				var tmpVal:String = Util.getPrivateKey(s);
				var val:int = parseInt(tmpVal);
				highscoreMap[s] = val;				
			}
			var achStr:String = Util.getPrivateKey("achi");
			if (achStr != null)
				achiMap = JSON.parse(achStr);
			else
				achiMap = { };
			
		}
		
		public function showGameCenterHighScore(cat:String):void 
		{
			CONFIG::isIOS{
				if (gcController && gameCenterLogged && validCats)
				{					
					if(validCats.indexOf(cat) > -1)
					{
						gcController.showLeaderboardView(cat);
						var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
						globalInput.disable = true;												
					}
				}
				else if (gcController && !gameCenterLogged && validCats)
				{
					gcController.authenticate();
				}
			}
		}
		
		public function showGameCenterAchievements():void 
		{
			CONFIG::isIOS{
				if (gcController && gameCenterLogged)
				{
					gcController.showAchievementsView();						
					var globalInput:GlobalInput = Factory.getInstance(GlobalInput);
					globalInput.setDisableTimeout(3);
				}
				else if (gcController && !gameCenterLogged && validCats)
				{
					gcController.authenticate();
				}
			}
		}
		
		public function initGooglePlayGameService():void 
		{
			CONFIG::isAndroid{
				// Initialize
				googlePlay = FCAndroidUtility.instance;
				
				googlePlay.addEventListener(FCAndroidUtility.ACHIEVEMENT_WRONG, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.ACHIVEMENT_WND_SHOWN, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.LEADERBOARD_WND_SHOWN, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.LICENSE_ERROR, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.NETWORK_ERROR, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.NOT_SIGN_IN, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.SERVICE_ERROR, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.SIGN_IN_FAILED, onGPResponse);
				googlePlay.addEventListener(FCAndroidUtility.SIGN_IN_OK, onGPResponse);
			}
		}
		
		private function onGPResponse(e:Event):void 
		{
			CONFIG::isAndroid{
				if(googlePlayTaskRetValueReq.indexOf(e.type) > -1)
				{
					if (googlePlayTaskDone is Function)
						googlePlayTaskDone.apply(this,googlePlayParam);
					googlePlayTaskDone = null;
					googlePlayTaskRetValueReq = null;
					googlePlayParam = null;
				}
			}
		}
				
		public function showGooglePlayLeaderboard():void 
		{
			CONFIG::isAndroid{				
				googlePlay.gpShowLeaderboard();									
			}
		}
		
		public function showGooglePlayAchievements():void 
		{
			CONFIG::isAndroid{				
				googlePlay.gpShowAchievement();
			}
		}
		
		public function unlockAchievement(type:String):void
		{
			var ach:String;
			var key:String = "achievement" + type;
			var checkDone:Boolean = achiMap.hasOwnProperty(key);
			//var checkDone:String = Util.getPrivateKey(key);
			if (checkDone)
				return;
			
			CONFIG::isIOS {
				if(gameCenterLogged)
				{					
					gcController.submitAchievement(type, 100);
					achiMap[key] = true;
				}
			}
			CONFIG::isAndroid {			
				googlePlayTaskDone = onGPUnlockAchievementOK;
				googlePlayParam = [key];
				googlePlayTaskRetValueReq = [FCAndroidUtility.SIGN_IN_OK];
				googlePlay.gpUnlockAchievement(type);			
			}
			
			if(!achievementBanner.isShowing)
				achievementBanner.setLabelAndShow(type);
			else
				achievementBanner.queue(type);								
			
		}
		
		private function onGPUnlockAchievementOK(key:String):void 
		{
			achiMap[key] = true;
		}
	}

}