////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.api.ru.vkontakte {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.connection.LocalConnection;
	import by.blooddy.core.net.loading.URLLoader;
	import by.blooddy.core.utils.xml.XMLUtils;
	import by.blooddy.crypto.MD5;
	import by.blooddy.social.api.SocialAPI;
	import by.blooddy.social.commands.InputSocialAPICommands;
	import by.blooddy.social.commands.OutputSocialAPICommands;
	import by.blooddy.social.data.SocialUserData;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 18:52:52
	 */
	public class VKontakteAPI extends SocialAPI {
		
		//--------------------------------------------------------------------------
		//
		//  Namespace
		//
		//--------------------------------------------------------------------------

		use namespace social;

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const SOCIAL_DOMAIN:String =	'vkontakte.ru';
		
		public static const SOCIAL_URL:String =		'http://' + SOCIAL_DOMAIN + '/';
		
		public static const API_URL:String =		'http://api.' + SOCIAL_DOMAIN + '/api.php';

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _METHODS:Object = new Object();
		_METHODS[ OutputSocialAPICommands.REQUEST_APP_INSTALL ] =		'isAppUser';
		_METHODS[ OutputSocialAPICommands.REQUEST_APP_SETTINGS ] =		'getUserSettings';
		_METHODS[ OutputSocialAPICommands.REQUEST_USERS ] =				'getProfiles';
		_METHODS[ OutputSocialAPICommands.REQUEST_USER_FRIENDS ] =		'getFriends';
		_METHODS[ OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS ] =	'getAppFriends';
		_METHODS[ OutputSocialAPICommands.REQUEST_USER_BALANCE ] =		'getUserBalance';
		
		/**
		 * @private
		 */
		private static const _PARSERS:Object = new Object();
		_PARSERS[ OutputSocialAPICommands.REQUEST_APP_INSTALL ] =		parse_appInstall;
		_PARSERS[ OutputSocialAPICommands.REQUEST_APP_SETTINGS ] =		parse_appSettings;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USERS ] =				parse_users;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USER_FRIENDS ] =		parse_userFriends;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS ] =	parse_userAppFriends;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USER_BALANCE ] =		parse_userBalance;
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function parse_appInstall(xml:XML):Command {
			var result:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				result = new Command( InputSocialAPICommands.RESPONSE_APP_INSTALL_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {
				
				result = new Command( InputSocialAPICommands.RESPONSE_APP_INSTALL );
				result.push( XMLUtils.parseToBoolean( xml ) );
				
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		private static function parse_appSettings(xml:XML):Command {
			var result:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				result = new Command( InputSocialAPICommands.RESPONSE_APP_SETTINGS_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {
				
				result = new Command( InputSocialAPICommands.RESPONSE_APP_SETTINGS );
				result.push( XMLUtils.parseListToInt( xml.settings ) );
				
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		private static function parse_users(xml:XML):Command {
			var result:Command;

			if ( xml.name().toString() == 'error' ) {

				result = new Command( InputSocialAPICommands.RESPONSE_USERS_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );

			} else {

				result = new Command( InputSocialAPICommands.RESPONSE_USERS );
				var birthday:String;
				var arr:Array;
				for each ( var user:XML in xml.user ) {
					var data:SocialUserData = new SocialUserData( XMLUtils.parseListToString( user.uid ) );
					data.firstName =	XMLUtils.parseListToString( user.first_name );
					data.lastName =		XMLUtils.parseListToString( user.last_name );
					data.nickName =		XMLUtils.parseListToString( user.nickname );
					data.sex =			XMLUtils.parseListToInt( user.sex ) - 1;
					birthday =			XMLUtils.parseListToString( user.bdate );
					if ( birthday ) {
						arr =			birthday.split( '.' );
						data.birthday =	new Date( parseInt( arr[ 2 ] ), parseInt( arr[ 1 ] ) - 1, parseInt( arr[ 0 ] ) );
					}
					data.photo =		XMLUtils.parseListToString( user.photo );
					if ( data.photo && data.photo.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.photo = SOCIAL_URL + data.photo;
					}
					data.mediumPhoto =	XMLUtils.parseListToString( user.photo_medium );
					if ( data.mediumPhoto && data.mediumPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.mediumPhoto = SOCIAL_URL + data.mediumPhoto;
					}
					data.bigPhoto =		XMLUtils.parseListToString( user.photo_big );
					if ( data.bigPhoto && data.bigPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.bigPhoto = SOCIAL_URL + data.bigPhoto;
					}		
					data.url =			SOCIAL_URL +'id' + data.id;
					result.push( data );
				}
				
			}

			return result;
		}

		/**
		 * @private
		 */
		private static function parse_userFriends(xml:XML):Command {
			var result:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				result = new Command( InputSocialAPICommands.RESPONSE_USER_FRIENDS_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {
				
				result = new Command( InputSocialAPICommands.RESPONSE_USER_FRIENDS );
				var list:XMLList = xml.uid;
				for each ( var uid:XML in list ) {
					result.push( XMLUtils.parseToString( uid ) );
				}
				
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		private static function parse_userAppFriends(xml:XML):Command {
			var result:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				result = new Command( InputSocialAPICommands.RESPONSE_USER_APP_FRIENDS_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {
				
				result = new Command( InputSocialAPICommands.RESPONSE_USER_APP_FRIENDS );
				var list:XMLList = xml.uid;
				for each ( var uid:XML in list ) {
					result.push( XMLUtils.parseToString( uid ) );
				}
				
			}
			
			return result;
		}

		/**
		 * @private
		 */
		private static function parse_userBalance(xml:XML):Command {
			var result:Command;
			
			if ( xml.name().toString() == 'error' ) {
				
				result = new Command( InputSocialAPICommands.RESPONSE_USER_BALANCE_ERROR );
				result.push( XMLUtils.parseListToInt( xml.error_code ) );
				
			} else {

				result = new Command( InputSocialAPICommands.RESPONSE_USER_BALANCE );
				result.push( XMLUtils.parseListToInt( xml.balance ) );
				
			}
			
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function VKontakteAPI(appID:String, viewerID:String, secretKey:String, connectionName:String=null, wrapper:Object=null) {
			super();

			this._appID = appID;
			this._viewerID = viewerID;
			this._secretKey = secretKey;

			if ( // если есть враппер, то используем его
				wrapper &&
				'external' in wrapper &&
				wrapper is IEventDispatcher &&
				'showInstallBox' in wrapper &&
				'showSettingsBox' in wrapper &&
				'showInviteBox' in wrapper &&
				'showPaymentBox' in wrapper
			) {

				this._wrapper = wrapper.external;
				this._wrapper.addEventListener( 'onApplicationAdded',	this.handler_wrapperEvent, false, 0, true );
				this._wrapper.addEventListener( 'onSettingsChanged',	this.handler_wrapperEvent, false, 0, true );
				this._wrapper.addEventListener( 'onBalanceChanged',		this.handler_wrapperEvent, false, 0, true );

			} else if ( connectionName ) { // если нету, то используем LocalConnection

				this._connection = new LocalConnection();
				this._connection.allowDomain( '*' );
				try {
					this._connection.open( '_out_' + connectionName );
				} catch ( e:Error ) {
					this._connection = null;
				}
				if ( this._connection ) {
					this._connection.client = {
						initConnection:		this.initConnection,
						onApplicationAdded:	this.onApplicationAdded,
						onSettingsChanged:	this.onSettingsChanged,
						onBalanceChanged:	this.onBalanceChanged
					};
					this._connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR,			this.handler_asyncError, false, 0, true );
					this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError, false, 0, true );
					this._connection.addEventListener( StatusEvent.STATUS,					this.handler_status, false, 0, true );
					this._connection.targetName = '_in_' + connectionName;
					this._connection.call( 'initConnection' );
				}

			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _wrapper:Object;
		
		/**
		 * @private
		 */
		private var _connection:LocalConnection;

		/**
		 * @private
		 */
		private var _inited:Boolean = false;

		/**
		 * @private
		 */
		private var _cache:Vector.<Array>;
		
		/**
		 * @private
		 */
		private const _requestHash:Object = new Object();
		
		/**
		 * @private
		 */
		private const _loadersHash:Dictionary = new Dictionary();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _appID:String;
		
		public function get appID():String {
			return this._appID;
		}
		
		/**
		 * @private
		 */
		private var _viewerID:String;
		
		public function get viewerID():String {
			return this._viewerID;
		}
		
		/**
		 * @private
		 */
		private var _secretKey:String;

		public function get secretKey():String {
			return this._secretKey;
		}

		//--------------------------------------------------------------------------
		//
		//  Social methods
		//
		//--------------------------------------------------------------------------

		social override function requestAppInstall():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_APP_INSTALL );
		}

		social override function requestAppSettings():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_APP_SETTINGS );
		}

		social override function requestUsers(...usersID):void {
			var vars:URLVariables = new URLVariables();
			vars.uids = usersID.join( ',' );
			vars.fields = 'uid,first_name,last_name,nickname,sex,bdate,photo,photo_medium,photo_big'; 
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USERS, vars );
		}

		social override function requestUserFriends():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USER_FRIENDS );
		}
		
		social override function requestUserAppFriends():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS );
		}

		social override function requestUserBalance():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USER_BALANCE );
		}

		social override function showAppInstall():void {
			this.localRequest( OutputSocialAPICommands.SHOW_APP_INSTALL );
		}

		social override function showAppSettings(settings:uint=0):void {
			this.localRequest( OutputSocialAPICommands.SHOW_APP_SETTINGS, settings );
		}

		social override function showUserFriendsInvite(excludeIDs:Array=null):void {
			this.localRequest( OutputSocialAPICommands.SHOW_USER_FRIENDS_INVITE, excludeIDs );
		}

		social override function showUserBalance(votes:uint=0):void {
			this.localRequest( OutputSocialAPICommands.SHOW_USER_BALANCE, votes );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $call(commandName:String, ...parameters):void {
			super.$invokeCallInputCommand( new Command( commandName, parameters ) );
		}

		//----------------------------------
		//  local
		//----------------------------------

		/**
		 * @private
		 */
		private function localRequest(commandName:String, ...parameters):void {
			if ( this._wrapper ) {
				parameters.unshift( commandName );
				this._wrapper[ commandName ].apply( this._wrapper, parameters );
			} else if ( this._connection ) {
				parameters.unshift( commandName );
				if ( this._inited ) {
					this._connection.call.apply( null, parameters );
				} else {
					if ( !this._cache ) this._cache = new Vector.<Array>();
					this._cache.push( parameters );
				}
			} else {
				super.$invokeCallInputCommand( new Command( commandName, parameters ) );
			}
		}
		
		//----------------------------------
		//  local responce methods
		//----------------------------------
		
		/**
		 * @private
		 */
		private function initConnection():void {
			this._connection.removeEventListener( StatusEvent.STATUS, this.handler_status );
			this._inited = true;
			if ( this._cache ) {
				while ( this._cache.length > 0 ) {
					this._connection.call.apply( null, this._cache.shift() );
				}
				this._cache = null;
			}
		}
		
		/**
		 * @private
		 */
		private function onApplicationAdded():void {
			this.$call( InputSocialAPICommands.ON_APP_INSTALL_CHANGED );
		}
		
		/**
		 * @private
		 */
		private function onSettingsChanged(settings:uint):void {
			this.$call( InputSocialAPICommands.ON_APP_SETTINGS_CHANGED, settings );
		}
		
		/**
		 * @private
		 */
		private function onBalanceChanged(balance:uint):void {
			this.$call( InputSocialAPICommands.ON_USER_BALANCE_CHANGED, balance );
		}
		
		//----------------------------------
		//  remote
		//----------------------------------
		
		/**
		 * @private
		 */
		private function remoteRequest(method:String, vars:URLVariables=null):void {

			if ( !vars ) vars = new URLVariables();
			// формируем базовые переменные
			vars.api_id =	this._appID;
			vars.v =		'2.0';
			vars.method =	_METHODS[ method ];
			
			// получаем долбанную строку
			var arr:Array = new Array();
			for ( var key:String in vars ) {
				arr.push( key );
			}
			arr.sort();
			
			var data:String = '';
			const l:uint = arr.length;
			for ( var i:uint = 0; i<l; ++i ) {
				data += arr[ i ] + '=' + vars[ arr[i] ];
			}
			
			if ( data in this._requestHash ) return; // такой запрос уже в процессе

			vars.sig = MD5.hash( this._viewerID + data + this._secretKey );

			var asset:RequestAsset = new RequestAsset();
			asset.method = method;
			asset.vars = vars;

			this._requestHash[ data ] = asset;

			this.requestMethod( data );
			
		}

		/**
		 * @private
		 */
		private function requestMethod(data:String):void {
			var asset:RequestAsset = this._requestHash[ data ];
			var request:URLRequest = new URLRequest( API_URL );
			request.data = asset.vars;
			request.contentType = MIME.VARS;
			var loader:URLLoader = new URLLoader( request );
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete );
			this._loadersHash[ loader ] = data;
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
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );

			var data:String = this._loadersHash[ loader ];
			delete this._loadersHash[ loader ];

			var xml:XML;
			if ( !( event is ErrorEvent ) ) {
				try {
					xml = new XML( loader.content );
				} catch ( e:Error ) {
				}
			}
			
			if ( !xml || ( xml.name().toString() == 'error' && XMLUtils.parseListToInt( xml.error_code ) == 1 ) ) { // ошибка таймаута запросим попозже
				setTimeout( this.requestMethod, 3E3, data );
			} else {

				var asset:RequestAsset = this._requestHash[ data ];
				delete this._requestHash[ data ];

				super.$invokeCallInputCommand( _PARSERS[ asset.method ]( xml ) );
				
			}
		}

		/**
		 * @private
		 */
		private function handler_asyncError(event:AsyncErrorEvent):void {
			// ignore
		}

		/**
		 * @private
		 */
		private function handler_securityError(event:SecurityErrorEvent):void {
			if ( this._connection.connected ) {
				this._connection.close();
			}
			this._connection.targetName = null;
			this._connection.removeEventListener( StatusEvent.STATUS,					this.handler_status );
			this._connection.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_securityError );
			this._connection.removeEventListener( AsyncErrorEvent.ASYNC_ERROR,			this.handler_asyncError );
			this._connection = null;
			this._cache = null;
		}

		/**
		 * @private
		 */
		private function handler_status(event:StatusEvent):void {
			if ( event.level == 'status' ) {
				this.initConnection();
			}
		}

		/**
		 * @private
		 */
		private function handler_wrapperEvent(event:Object):void {
			switch ( event.type ) {
				case 'onApplicationAdded':	this.onApplicationAdded();					break;
				case 'onSettingsChanged':	this.onSettingsChanged( event.settings );	break;
				case 'onBalanceChanged':	this.onBalanceChanged( event.balance );		break;
			}
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.net.URLVariables;

/**
 * @private
 */
internal final class RequestAsset {
	
	public function RequestAsset() {
		super();
	}
	
	public var vars:URLVariables;
	
	public var method:String;
	
}