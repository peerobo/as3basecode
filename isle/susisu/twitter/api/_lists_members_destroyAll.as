package isle.susisu.twitter.api
{
	
	import flash.net.URLRequestMethod;
	
	import isle.susisu.twitter.TwitterRequest;
	import isle.susisu.twitter.TwitterTokenSet;
	import isle.susisu.twitter.utils.encodeText;
	
	public function _lists_members_destroyAll(
		tokenSet:TwitterTokenSet,
		listId:String=null,
		slug:String=null,
		ownerId:String=null,
		ownerScreenName:String=null,
		userIds:Array=null,
		screenNames:Array=null
	):TwitterRequest
	{
		//parameters
		var parameters:Object=new Object();
		if(listId!=null)
		{
			parameters["list_id"]=listId;
		}
		if(slug!=null)
		{
			parameters["slug"]=encodeText(slug);
		}
		if(ownerId!=null)
		{
			parameters["owner_id"]=ownerId;
		}
		if(ownerScreenName!=null)
		{
			parameters["owner_screen_name"]=ownerScreenName;
		}
		if(userIds!=null)
		{
			parameters["user_id"]=encodeText(userIds.join(","));
		}
		if(screenNames!=null)
		{
			parameters["screen_name"]=encodeText(screenNames.join(","));
		}
		//make request
		var request:TwitterRequest=new TwitterRequest(tokenSet,TwitterURL.lists_members_DESTROY_ALL,URLRequestMethod.POST,parameters);
		
		return request;
	}
	
}