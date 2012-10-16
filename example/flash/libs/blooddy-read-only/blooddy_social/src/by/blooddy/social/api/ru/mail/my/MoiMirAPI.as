////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.api.ru.mail.my {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.URLLoader;
	import by.blooddy.core.utils.xml.XMLUtils;
	import by.blooddy.crypto.MD5;
	import by.blooddy.social.api.SocialAPI;
	import by.blooddy.social.commands.InputSocialAPICommands;
	import by.blooddy.social.commands.OutputSocialAPICommands;
	import by.blooddy.social.data.SocialUserData;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
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
	 * @created					26.05.2010 18:51:45
	 */
	public class MoiMirAPI extends SocialAPI {
		
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
		
		public static const SOCIAL_DOMAIN:String =	'my.mail.ru';
		
		public static const SOCIAL_URL:String =		'http://' + SOCIAL_DOMAIN + '/';
		
		public static const API_URL:String =		'http://www.appsmail.ru/platform/api';
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _METHODS:Object = new Object();
		_METHODS[ OutputSocialAPICommands.REQUEST_APP_INSTALL ] =		'users.isAppUser';
		_METHODS[ OutputSocialAPICommands.REQUEST_APP_SETTINGS ] =		'hasAppPermission';
		_METHODS[ OutputSocialAPICommands.REQUEST_USERS ] =				'users.getInfo';
		_METHODS[ OutputSocialAPICommands.REQUEST_USER_FRIENDS ] =		'friends.get';
		_METHODS[ OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS ] =	'friends.getAppUsers';
		_METHODS[ OutputSocialAPICommands.SHOW_USER_BALANCE ] =			'payments.openDialog';
		
		/**
		 * @private
		 */
		private static const _PARSERS:Object = new Object();
		_PARSERS[ OutputSocialAPICommands.REQUEST_APP_INSTALL ] =		parse_appInstall;
		_PARSERS[ OutputSocialAPICommands.REQUEST_APP_SETTINGS ] =		parse_appSettings;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USERS ] =				parse_users;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USER_FRIENDS ] =		parse_userFriends;
		_PARSERS[ OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS ] =	parse_userAppFriends;
		
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
				result.push( XMLUtils.parseListToBoolean( xml.isAppUser ) );
				
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
				var settings:uint = 0;
				XMLUtils.parseListToBoolean( xml.stream );
				XMLUtils.parseListToBoolean( xml.notifications );
				result.push( settings );
				
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
					data.nickName =		XMLUtils.parseListToString( user.nick );
					data.sex =			XMLUtils.parseListToInt( user.sex );
					birthday =			XMLUtils.parseListToString( user.bdate );
					if ( birthday ) {
						arr =			birthday.split( '.' );
						data.birthday =	new Date( parseInt( arr[ 2 ] ), parseInt( arr[ 1 ] ) - 1, parseInt( arr[ 0 ] ) );
					}
					data.photo =		XMLUtils.parseListToString( user.pic_small );
					if ( data.photo && data.photo.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.photo = SOCIAL_URL + data.photo;
					}
					data.mediumPhoto =	XMLUtils.parseListToString( user.pic );
					if ( data.mediumPhoto && data.mediumPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.mediumPhoto = SOCIAL_URL + data.mediumPhoto;
					}
					data.bigPhoto =		XMLUtils.parseListToString( user.pic_big );
					if ( data.bigPhoto && data.bigPhoto.indexOf( SOCIAL_DOMAIN ) < 0 ) {
						data.bigPhoto = SOCIAL_URL + data.bigPhoto;
					}		
					data.url =			XMLUtils.parseListToString( user.link );
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
				for each ( var user:XML in xml.user ) {
					result.push( XMLUtils.parseToString( user ) );
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
				for each ( var user:XML in xml.user ) {
					result.push( XMLUtils.parseToString( user ) );
				}
				
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
		public function MoiMirAPI(appID:String, viewerID:String, secretKey:String, session:String) {
			super();

			this._appID = appID;
			this._viewerID = viewerID;
			this._secretKey = secretKey;
			this._session = session;

		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
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
		
		/**
		 * @private
		 */
		private var _session:String;
		
		public function get session():String {
			return this._session;
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
			var vars:URLVariables = new URLVariables();
			vars.ext_perm = 'notifications,stream';
			this.remoteRequest( OutputSocialAPICommands.REQUEST_APP_SETTINGS, vars );
		}
		
		social override function requestUsers(...usersID):void {
			var vars:URLVariables = new URLVariables();
			vars.uids = usersID.join( ',' );
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USERS, vars );
		}
		
		social override function requestUserFriends():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USER_FRIENDS );
		}
		
		social override function requestUserAppFriends():void {
			this.remoteRequest( OutputSocialAPICommands.REQUEST_USER_APP_FRIENDS );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  remote
		//----------------------------------
		
		/**
		 * @private
		 */
		private function remoteRequest(method:String, vars:URLVariables=null):void {
			
			if ( !vars ) vars = new URLVariables();
			// формируем базовые переменные
			vars.format =		'xml';
			vars.api_id =		this._appID;
			vars.method =		_METHODS[ method ];
			vars.session_key =	this._session;
			
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
			
			if ( !xml || ( xml.name().toString() == 'error' && XMLUtils.parseListToInt( xml.error_code ) == 6 ) ) { // ошибка таймаута запросим попозже
				setTimeout( this.requestMethod, 3E3, data );
			} else {
				
				var asset:RequestAsset = this._requestHash[ data ];
				delete this._requestHash[ data ];
				
				super.$invokeCallInputCommand( _PARSERS[ asset.method ]( xml ) );
				
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