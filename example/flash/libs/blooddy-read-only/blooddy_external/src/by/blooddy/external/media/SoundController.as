////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.media {
	
	import by.blooddy.core.events.DynamicEvent;
	import by.blooddy.core.managers.resource.ResourceManagerProxy;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.external.ExternalConnectionController;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.10.2009 19:29:51
	 */
	public class SoundController extends ExternalConnectionController {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getTransform(transform:Object=null):SoundTransform {
			if ( !transform ) return null;
			if ( transform is SoundTransform ) return transform as SoundTransform;
			var result:SoundTransform = new SoundTransform();
			if ( isNaN( transform.volume ) )		result.volume =			transform.volume;
			if ( isNaN( transform.pan ) )			result.pan =			transform.pan;
			if ( isNaN( transform.leftToLeft ) )	result.leftToLeft =		transform.leftToLeft;
			if ( isNaN( transform.leftToRight ) )	result.leftToRight =	transform.leftToRight;
			if ( isNaN( transform.rightToLeft ) )	result.rightToLeft =	transform.rightToLeft;
			if ( isNaN( transform.rightToRight ) )	result.rightToRight =	transform.rightToRight;
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function SoundController(container:DisplayObjectContainer, sharedObject:ProxySharedObject=null) {
			super( container, sharedObject || ProxySharedObject.getLocal( 'sound' ) );
			super.externalConnection.client = this;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _manager:ResourceManagerProxy = new ResourceManagerProxy();
		
		/**
		 * @private
		 */
		private var _lastID:uint = 0;
		
		/**
		 * @private
		 */
		private var _loaders:Dictionary = new Dictionary( true );
		
		/**
		 * @private
		 */
		private var _loaders_id:Object = new Object();
		
		/**
		 * @private
		 */
		private var _channels:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */
		private var _channels_id:Object = new Object();

		/**
		 * @private
		 */
		private var _sounds:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function load(uri:String):void {
			var name:String = uri.split( '#', 2 )[ 0 ];
			this._manager.loadResourceBundle( name );
			this._manager.lockResourceBundle( name );
		}

		public function loadAndPlay(uri:String, startTime:Number=0, loops:int=0, transform:Object=null, afterLoad:Boolean=false):uint {
			var arr:Array = uri.split( '#', 2 );
			var loader:ILoadable = this._manager.loadResourceBundle( arr[0], int.MAX_VALUE );
			if ( !loader.complete ) {
				if ( !afterLoad ) return 0;
				var plays:Vector.<PlayAsset> = this._loaders[ loader ];
				if ( !plays ) {
					this._loaders[ loader ] = plays = new Vector.<PlayAsset>();
					loader.addEventListener( Event.COMPLETE,	this.handler_complete );
					loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete );
				}
				var asset:PlayAsset = new PlayAsset( loader, this._lastID++, uri, startTime, loops, getTransform( transform ) );
				plays.push( asset );
				this._loaders_id[ asset.id ] = asset;
				return this._lastID;
			}
			return this.play( uri, startTime, loops, transform );
		}

		public function play(uri:String, startTime:Number=0, loops:int=0, transform:Object=null):uint {
			var id:uint = this.$play( this._lastID + 1, uri, startTime, loops, transform );
			if ( id ) this._lastID = id;
			return id;
		}

		public function stop(id:uint):void {
			var channel:SoundChannel = this._channels_id[ id ];
			if ( channel ) {
				channel.stop();
				delete this._channels_id[ id ];
				delete this._channels[ channel ];
			} else {
				var asset:PlayAsset = this._loaders_id[ id ];
				delete this._loaders_id[ id ];
				var loader:ILoadable = asset.loader;
				var plays:Vector.<PlayAsset> = this._loaders[ loader ];
				if ( plays.length <= 1 ) {
					delete this._loaders[ asset.loader ];
					loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
					loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
				} else {
					var i:int = plays.indexOf( asset );
					plays.splice( i, 1 );
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected override methods
		//
		//--------------------------------------------------------------------------
		
		protected override function construct():void {
		}
		
		protected override function destruct():void {
			var key:Object;
			for ( key in this._channels_id ) {
				this.stop( uint( key ) );
			}
			for ( key in this._sounds ) {
				delete this._sounds[ key ];
			}
			this._manager.clear();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $play(id:uint, uri:String, startTime:Number=0, loops:int=0, transform:Object=null):uint {
			var arr:Array = uri.split( '#', 2 );

			var sound:Sound = this._sounds[ uri ];
			if ( !sound ) {
				this._sounds[ uri ] = sound = this._manager.getSound( arr[0], arr[1] );
			}

			if ( sound ) {
				var channel:SoundChannel = sound.play( startTime, loops, getTransform( transform ) );
				if ( channel ) {
					channel.addEventListener( Event.SOUND_COMPLETE, this.handler_soundComplete );
					return id;
				}
			}
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
			var plays:Vector.<PlayAsset> = this._loaders[ loader ];
			if ( plays ) {
				var p:Boolean = !( event is ErrorEvent );
				delete this._loaders[ loader ];
				for each (  var asset:PlayAsset in plays ) {
					delete this._loaders_id[ asset.id ];
					if ( p ) this.$play( asset.id, asset.uri, asset.startTime, asset.loops, asset.transform );
				}
			}
		}

		/**
		 * @private
		 */
		private function handler_soundComplete(event:Event):void {
			var channel:SoundChannel = event.target as SoundChannel;
			var id:uint = this._channels[ channel ];
			delete this._channels_id[ id ];
			delete this._channels[ channel ];
			var e:DynamicEvent = new DynamicEvent( Event.SOUND_COMPLETE );
			e.id = id;
			this.externalConnection.dispatchEvent( e );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.loading.ILoadable;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PlayAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class PlayAsset {

	public function PlayAsset(loader:ILoadable, id:uint, uri:String, startTime:Number, loops:int, transform:SoundTransform) {
		super();
		this.loader = loader;
		this.id = id;
		this.uri =			uri;
		this.startTime =	startTime;
		this.loops =		loops;
		this.transform =	transform;
	}

	public var loader:ILoadable;
	public var id:uint;

	public var uri:String;
	public var startTime:Number;
	public var loops:int;
	public var transform:SoundTransform;

}