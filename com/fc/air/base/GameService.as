package com.fc.air.base 
{
	import com.fc.air.comp.IAchievementBanner;
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	CONFIG::isIOS{
		import com.adobe.ane.gameCenter.GameCenterAuthenticationEvent;
		import com.adobe.ane.gameCenter.GameCenterController;
		import com.adobe.ane.gameCenter.GameCenterLeaderboardEvent;
	}
	CONFIG::isAndroid{
		import com.freshplanet.ane.AirGooglePlayGames.AirGooglePlayGames;
		import com.freshplanet.ane.AirGooglePlayGames.AirGooglePlayGamesEvent;
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
		private var gameCenterLogged:Boolean;
		private var googlePlayLogged:Boolean;		
		private var achievementBanner:IAchievementBanner;
		
		// game center only
		CONFIG::isIOS{
			private var gcController:GameCenterController;					
			private var validCats:Array;
		}
		
		CONFIG::isAndroid{
			private var googlePlay:AirGooglePlayGames;			
			private var callbackSignInOK:CallbackObj;
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
			highscoreMap[type ] = value;					
			CONFIG::isIOS{
				if (Util.isIOS && gameCenterLogged && validCats)
				{					
					if(validCats.indexOf(type) > -1)
						gcController.submitScore(value, type);				
				}				
			}
			CONFIG::isAndroid {
				if (Util.isAndroid && googlePlayLogged)
				{					
					googlePlay.reportScore(type, value);
				}
			}
			saveHighscore();
		}
		
		public function saveHighscore():void
		{
			for (var s:String in highscoreMap) 
			{
				Util.setPrivateValue(s, highscoreMap[s]);
				if(highscoreMap[s] > 0)
					FPSCounter.log(s,highscoreMap[s]);
			}			
		}
		
		public function loadHighscore():void
		{
			for (var s:String in highscoreMap) 
			{
				var tmpVal:String = Util.getPrivateKey(s);
				var val:int = parseInt(tmpVal);
				highscoreMap[s] = val;
				if(val > 0)
					FPSCounter.log(s,val);
			}
			
		}
		
		public function showGameCenterHighScore(cat:String):void 
		{
			CONFIG::isIOS{
				if (gcController && gameCenterLogged && validCats)
				{
					var catName:String = HIGHSCORE_ITUNE_PRE + cat.substr(0, 1).toUpperCase() + cat.substr(1);
					if(validCats.indexOf(catName) > -1)
					{
						gcController.showLeaderboardView(catName);
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
		
		public function initGooglePlayGameService():void 
		{
			CONFIG::isAndroid{
				// Initialize
				googlePlay = AirGooglePlayGames.getInstance();
				googlePlay.addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_SUCCESS, onGooglePlayResponse);
				googlePlay.addEventListener(AirGooglePlayGamesEvent.ON_SIGN_OUT_SUCCESS, onGooglePlayResponse);
				googlePlay.addEventListener(AirGooglePlayGamesEvent.ON_SIGN_IN_FAIL, onGooglePlayResponse);
				googlePlay.startAtLaunch();							
			}
		}
				
		public function showGooglePlayLeaderboard(cat:String):void 
		{
			CONFIG::isAndroid{
				if(googlePlay && googlePlayLogged)
				{
					googlePlay.showLeaderboard(cat);
				}
				else if(googlePlay)
				{
					googlePlay.signIn();
					callbackSignInOK = new CallbackObj(googlePlay.showLeaderboard, [cat]);
				}
			}
		}
		
		CONFIG::isAndroid{
			private function onGooglePlayResponse(e:AirGooglePlayGamesEvent):void 
			{
				switch(e.type)
				{
					case AirGooglePlayGamesEvent.ON_SIGN_IN_SUCCESS:
						googlePlayLogged = true;
						FPSCounter.log("play login ok");
						if (callbackSignInOK)
						{	
							callbackSignInOK.execute();
							callbackSignInOK = null;
						}
					break;
					case AirGooglePlayGamesEvent.ON_SIGN_IN_FAIL:
						googlePlayLogged = false;						
						FPSCounter.log("play login fail");
					break;
					case AirGooglePlayGamesEvent.ON_SIGN_OUT_SUCCESS:
						googlePlayLogged = false;
						googlePlay.signIn();
					break;
				}
			}
		}
		
		public function unlockAchievement(type:String):void
		{
			var ach:String;
			var key:String = "achievement" + type;
			var checkDone:String = Util.getPrivateKey(key);
			if (checkDone)
				return;
			
			CONFIG::isIOS {
				if(gameCenterLogged)
				{					
					gcController.submitAchievement(type, 100);
					Util.setPrivateValue(key, "available");
				}
			}
			CONFIG::isAndroid {
				if(googlePlayLogged)
				{					
					googlePlay.reportAchievement(type);
					Util.setPrivateValue(key, "available");
				}
			}
			
			if (gameCenterLogged || googlePlayLogged)
			{
				if(!achievementBanner.isShowing)
					achievementBanner.setLabelAndShow(type);
				else
					achievementBanner.queue(type);								
			}
		}
	}

}