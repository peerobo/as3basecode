package com.fc.air.base 
{
	import isle.susisu.twitter.Twitter;
	import isle.susisu.twitter.TwitterRequest;
	
	/**
	 * ...
	 * @author ndp
	 */
	public class TwitterAlt extends Twitter 
	{			
		private var _callbackURL:String;
		public function TwitterAlt(consumerKey:String, consumerKeySecret:String, accessToken:String="", accessTokenSecret:String="", proxy:String=null) 
		{
			super(consumerKey, consumerKeySecret, accessToken, accessTokenSecret, proxy);			
		}
		
		override public function oauth_requestToken(sendImmediate:Boolean = true):TwitterRequest 
		{
			var twitterReq:TwitterRequest = super.oauth_requestToken(false);
			if(_callbackURL)
				twitterReq.data["oauth_callback"] = encodeURIComponent(_callbackURL);
			twitterReq.send();
			return twitterReq;
		}
		
		public function set callbackURL(callback:String):void
		{
			_callbackURL = callback;
		}
	}

}