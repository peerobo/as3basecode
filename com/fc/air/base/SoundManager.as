package com.fc.air.base
{	
	import com.fc.air.FPSCounter;
	import com.fc.air.Util;
	import com.fc.movthecat.Constants;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	
	/**
	 * SoundManager
	 * - play/get a sound
	 * - auto download sound if not available
	 * - auto play theme song when download complete
	 * @author ndp
	 */
	public class SoundManager
	{
		static public const SO_SOUND:String = "soSound";
		private var _mute:Boolean;
		private var _muteMusic:Boolean;
		private var _currentPlayingSound:Array; // array of object sound: { channel: SoundChannel, url: String, isThemeMusic: boolean }
		private var _loadList:Array; // array of object loader: {url: String, isThemeMusic: boolean}
		private var _urlLoader:URLLoader; // song downloader
		private var completeSound:Object;
		private var soundVolume:int;	// 0-100
		private var onDownloadDone:Function;
		
		/**
		 * get sound. if sound not loaded => auto load sound for later use
		 * @param	soundName sound file (mp3 only)
		 * @return null if not loaded
		 */
		public static function getSound(soundName:String):Sound
		{
			var soundManager:SoundManager = Factory.getInstance(SoundManager);
			return soundManager.getSound(soundName);
		}			
		
		public function removeSound(name:String):void
		{
			delete completeSound[name];
		}
		
		/**
		 * auto download and play sound. if the sound is not theme song it will not autoplay when downloaded
		 * @param	soundName sound file (mp3 only)
		 * @param	isThemeMusic only one song can play at a time and loop infinitely (int.MAX_VALUE time)
		 * @param	loopCount time playing
		 */
		public static function playSound(soundName:String, isThemeMusic:Boolean = false, loopCount:int = 0, volume:Number = 1, startTime:Number = 0):SoundChannel		
		{
			var soundManager:SoundManager = Factory.getInstance(SoundManager);
			return soundManager.playSound(soundName, isThemeMusic, loopCount, volume, startTime);
		}
		
		public static function playSoundWithDelay(soundName:String, isThemeMusic:Boolean = false, loopCount:int = 0,delay:Number =0):void
		{
			var soundManager:SoundManager = Factory.getInstance(SoundManager);
			if (delay == 0)
			{
				soundManager.playSound(soundName, isThemeMusic, loopCount);
			}
			else
			{				
				Starling.juggler.delayCall(soundManager.playSound, delay, soundName, isThemeMusic, loopCount);
			}			
		}
		
		public function SoundManager()
		{
			soundVolume = 100;
			CONFIG::isIOS{
				SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
			}			
		}			
		
		public function queueSound(url:String,name:String):void
		{
			var alreadyQueue:Boolean = false;
			var len:int = _loadList.length;
			url += Constants.CONTENT_VER;
			for (var i:int = 0; i < len; i++)
			{
				if (_loadList[i].url == url) // already queue
				{
					alreadyQueue = true;
					break;
				}				
			}
			if (!alreadyQueue)							
				_loadList.push( { url: url, name: name } );	
			// init loader if needed
			if (!_urlLoader)
			{
				_urlLoader = new URLLoader();
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_urlLoader.addEventListener(Event.COMPLETE, downloadSoundComplete);
				// start download
				_urlLoader.load(new URLRequest(_loadList[0].url));
			}
		}
		
		public function loadSoundSettings():void {
			var localData:SharedObject = Util.getLocalData(SO_SOUND);
			if (!localData.data.hasOwnProperty("mute"))
				localData.data["mute"] = false;
			_mute = localData.data["mute"];
			if (!localData.data.hasOwnProperty("muteMusic"))
				localData.data["muteMusic"] = false;
			_muteMusic = localData.data["muteMusic"];
		}
		
		/**
		 * get sound. if sound not loaded => auto load sound for later use
		 * @param	url get sound from url
		 * @return null if not loaded
		 */
		public function getSound(url:String):Sound
		{
			var snd:Sound = null;			
			var sndName:String = url;
			sndName = sndName.replace(Constants.CONTENT_VER, "");			
			if (completeSound)
				snd = completeSound[sndName];
			if (!snd && (!completeSound || !completeSound[sndName]))
				loadNewSound(url);
			return snd;
		}
		
		/**
		 * auto download and play sound. if the sound is not theme song it will not autoplay when downloaded
		 * @param	url url to music file (mp3 only)
		 * @param	isThemeMusic only one song can play at a time and loop infinitely (int.MAX_VALUE time)
		 * @param	loopCount time playing
		 */
		public function playSound(url:String, isThemeMusic:Boolean = false, loopCount:int = 0, volume:Number = 1, startTime:Number = 0):SoundChannel		
		{
			var sndName:String;
			sndName = url;			
			sndName = sndName.replace(Constants.CONTENT_VER, "");
			if (!isThemeMusic && _mute)
				return null;
			var soundTranform:SoundTransform = new SoundTransform();
			soundTranform.volume = volume * (!isThemeMusic ? this.soundVolume/100 : 1);
			var sndCh:SoundChannel = null;
			var snd:Sound = (completeSound && completeSound[sndName] is Sound) ? completeSound[sndName] : null;
			if(snd)
			{
				if (isThemeMusic)			
				{
					
					sndCh = snd.play(startTime, int.MAX_VALUE, soundTranform);					
					if (_muteMusic && sndCh)
						sndCh.stop();
				}
				else
				{				
					sndCh = snd.play(startTime, loopCount, soundTranform);
				}
			}
			if (sndCh != null) // sound loaded
			{
				if (!_currentPlayingSound)
					_currentPlayingSound = [];
				// remove old theme music
				var len:int = _currentPlayingSound.length;
				var alreadyAdd:Boolean = false;
				for (var i:int = 0; i < len; i++)
				{
					if (_currentPlayingSound[i].isThemeMusic && isThemeMusic)
					{
						if (_currentPlayingSound[i].url == url) // already playing
						{
							alreadyAdd = true;
							sndCh.stop();							
							continue;
						}
						_currentPlayingSound[i].channel.stop();						
						_currentPlayingSound.splice(i, 1);
						i--;
						len--;						
					}
				}
				// add new sound
				if (!alreadyAdd)
				{
					_currentPlayingSound.push({channel: sndCh, url: url, isThemeMusic: isThemeMusic});
					if (!isThemeMusic)
						sndCh.addEventListener(Event.SOUND_COMPLETE, soundComplete);
				}
			}
			else // not loaded
			{							
				if (!completeSound || !completeSound[sndName])					
					loadNewSound(url, isThemeMusic);
			}
			return sndCh;
		}
		
		public function loadAll(onDownloadDone:Function):void 
		{
			this.onDownloadDone = onDownloadDone;
			if (_loadList.length == 0)
			{
				onDownloadDone(1);
				this.onDownloadDone = null;
			}
		}
		
		private function loadNewSound(url:String, isThemeMusic:Boolean = false):void
		{
			if (!_loadList)			
				_loadList = [];	
			var alreadyQueue:Boolean = false;
			var len:int = _loadList.length;
			url += Constants.CONTENT_VER;
			for (var i:int = 0; i < len; i++)
			{
				if (_loadList[i].url == url) // already queue
				{
					alreadyQueue = true;
					_loadList[i].isThemeMusic = isThemeMusic;
				}
				else if (isThemeMusic) // only one theme music
				{
					_loadList[i].isThemeMusic = false;
				}
			}
			if (alreadyQueue)
				return;				
			// queue url
			_loadList.push( { url: url, isThemeMusic: isThemeMusic } );			
			// init loader if needed
			if (!_urlLoader)
			{
				_urlLoader = new URLLoader();
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_urlLoader.addEventListener(Event.COMPLETE, downloadSoundComplete);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				// start download
				_urlLoader.load(new URLRequest(_loadList[0].url));
			}			
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{			
			FPSCounter.log(e.text,_loadList[0].url);
		}
		
		private function downloadSoundComplete(e:Event):void
		{
			var snd:Sound = new Sound();
			snd.loadCompressedDataFromByteArray(_urlLoader.data, (_urlLoader.data as ByteArray).length);
			var sndName:String = _loadList[0].url;			
			sndName = sndName.replace(Constants.CONTENT_VER, "");
			if (_loadList[0].hasOwnProperty("name"))
				sndName = _loadList[0].name;
			if (!completeSound)			
				completeSound = { };			
			completeSound[sndName] = snd;
			// play instantly if it is theme song
			if (_loadList[0].isThemeMusic)
				this.playSound(sndName, true);
			// remove loaded sound
			_loadList.splice(0, 1);
			var len:int = _loadList.length;
			if (len == 0) // dispose loader
			{
				_urlLoader.removeEventListener(Event.COMPLETE, downloadSoundComplete);
				_urlLoader = null;
				if (onDownloadDone is Function)
				{
					onDownloadDone(1);
					onDownloadDone = null;
				}
			}
			else // continue load remaining sound
			{
				_urlLoader.close();
				_urlLoader.load(new URLRequest(_loadList[0].url));
				if (onDownloadDone is Function)
					onDownloadDone(1 / _loadList.length);
			}
		}
		
		private function soundComplete(e:Event):void
		{
			var sndCh:SoundChannel = e.currentTarget as SoundChannel;
			sndCh.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			var len:int = _currentPlayingSound.length;
			for (var i:int = 0; i < len; i++)
			{
				if (_currentPlayingSound[i].channel == sndCh)
				{
					_currentPlayingSound.splice(i, 1);
					return;
				}
			}
		}
		
		public function get mute():Boolean
		{
			return _mute;
		}
		
		public function set mute(value:Boolean):void
		{
			var i:int;
			if (_currentPlayingSound)
			{
				var len:int = _currentPlayingSound.length;
				if (value) // mute
				{
					for (i = 0; i < len; i++)
					{
						if (!_currentPlayingSound[i].isThemeMusic)
						{
							_currentPlayingSound[i].channel.stop();
							_currentPlayingSound.splice(i, 1);
							len--;
							i--;
						}
						
					}
				}
				/*else 		// unmute
				   {
				   for (i = 0; i < len; i++)
				   {
				   var sndCh:SoundChannel =  _assetMgr.playSound(_currentPlayingSound[i].url, 0, int.MAX_VALUE);
				   _currentPlayingSound[i].channel = sndCh;
				   }
				 }*/
			}
			_mute = value;
			// save
			var localData:SharedObject = Util.getLocalData(SO_SOUND);
			localData.data["mute"] = _mute;
		}
		
		public function get muteMusic():Boolean
		{
			return _muteMusic;
		}
		
		public function set muteMusic(value:Boolean):void
		{
			var transform:SoundTransform;
			var sndCh:SoundChannel;
			if (_muteMusic == value)
				return;
			_muteMusic = value;
			var i:int;
			if (_currentPlayingSound)
			{
				var len:int = _currentPlayingSound.length;
				if (value) // mute
				{
					for (i = 0; i < len; i++)
					{
						if (_currentPlayingSound[i].isThemeMusic)
						{
							sndCh = _currentPlayingSound[i].channel;
							transform = sndCh.soundTransform;
							Util.tweenWithTimer(transform, { volume: 0, chann:sndCh }, onSoundVolumeUpdate,null);							
							break;
						}
					}
				}
				else // unmute
				{
					for (i = 0; i < len; i++)
					{
						if (_currentPlayingSound[i].isThemeMusic)
						{
							sndCh = _currentPlayingSound[i].channel;
							transform = sndCh.soundTransform;
							Util.tweenWithTimer(transform, { volume: 1, chann:sndCh }, onSoundVolumeUpdate,null);
							break;
						}
					}
				}
			}
			// save
			var localData:SharedObject = Util.getLocalData(SO_SOUND);
			localData.data["muteMusic"] = _muteMusic;
		}
		
		private function onSoundVolumeUpdate(obj:Object,props:Object):void 
		{
			(props["chann"] as SoundChannel).soundTransform = obj as SoundTransform;
		}
				
		public static function get instance():SoundManager
		{
			return Factory.getInstance(SoundManager);
		}
		
		public static function get soundVolume():int 
		{	
			var soundManager:SoundManager = Factory.getInstance(SoundManager);
			return soundManager.soundVolume;			
		}
		
		public static function set soundVolume(value:int):void 
		{
			var soundManager:SoundManager = Factory.getInstance(SoundManager);
			soundManager.soundVolume = value;
		}
	}

}