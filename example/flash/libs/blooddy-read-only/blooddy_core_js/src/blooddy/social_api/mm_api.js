/*!
 * blooddy/social_api/mm_api.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.SocialApi' );

if ( !blooddy.SocialApi.MmApi ) {

	blooddy.require( 'blooddy.utils.crypto.md5' );
	blooddy.require( 'blooddy.utils.crypto.json' );

	/**
	 * @property
	 * @final
	 * @namespace	blooddy.SocialApi
	 * @extends		blooddy.SocialApi
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.SocialApi.MmApi = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =				blooddy,
			SocialApi =		$.SocialApi,
			utils =			$.utils,
			crypto =		utils.crypto,

			METHOD_USERS =				'users.getInfo',
			METHOD_APP_FRIENDS =		'friends.getAppUsers',
			METHOD_IS_APP_INSTALED =	'users.isAppUser',

			msie =			$.browser.getMSIE(),


			_methods =		new Object(),

			_requests =		new Object();

		//--------------------------------------------------------------------------
		//
		//  Private class metods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @static
		 * @param	{Array}		data
		 * @param	{Array}
		 */
		_methods[ METHOD_USERS ] = function(data) {
			var	result = new Array(),
				l = data.length,
				i,
				row,
				user;
			for ( i=0; i<l; i++ ) {

				row = data[ i ];
				user = new SocialApi.User();

				user.id = row.uid;

				if ( 'first_name' in row )
					user.firstName = row.first_name;

				if ( 'last_name' in row )
					user.lastName = row.last_name;

				if ( 'nick' in row )
					user.nickName = row.nick;

				if ( 'sex' in row )
					user.sex = ( row.sex ? 0 : 1 );

				if ( 'birthday' in row ) {
					var arr = row.birthday.split( '.' );
					user.birthday = new Date(
						arr[2] || 0,
						arr[1] || 0,
						arr[0] || 0
					);
				}

				if ( 'pic' in row ) {
					user.avatarSmall = row.pic_small;
					user.avatarMedium = row.pic;
					user.avatarBig = row.pic_big;
				}

				user.uri = row.link;

				result.push( user );
			}
			return result;
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var MmApi = function(secretKey, appID, viewerID, session) {
			MmApi.superPrototype.constructor.call( this );
			this._secretKey =	secretKey;
			this._appID =		appID;
			this._viewerID =	viewerID;
			this._session =		session;
		};

		$.extend( MmApi, SocialApi );

		var	MmApiPrototype =		MmApi.prototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{String}
		 */
		MmApiPrototype._secretKey = null;

		/**
		 * @private
		 * @type	{String}
		 */
		MmApiPrototype._appID = null;

		/**
		 * @private
		 * @type	{String}
		 */
		MmApiPrototype._viewrID = null;

		/**
		 * @private
		 * @type	{String}
		 */
		MmApiPrototype._session = null;

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{String}	methodName
		 * @param	{Boolean}	isSession
		 * @param	{Object}	vars
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		var request = function(methodName, isSession, vars, onData, onFail) {
			if ( !vars ) vars = new Object();
			vars.method =		methodName;
			vars.app_id =		this._appID;
			if ( isSession ) {
				vars.session_key =	this._session;
			} else {
				vars.uid = this._viewerID;
			}

			var	hash = SocialApi.createHash( vars ),
				asset, i;

			if ( hash in _requests ) {

				asset = _requests[ hash ];

			} else {

				vars.sig = crypto.md5.hashString( this._viewerID + hash + this._secretKey );

				asset = {
					hash:		hash,
					vars:		vars,
					responder:	null,
					onData:		new Array(),
					onFail:		new Array()
				};
				createResponder( asset );

				_requests[ hash ] = asset;

			}

			if ( onData ) {
				i = utils.indexOf( asset.onData, onData );
				if ( i < 0 ) asset.onData.push( onData );
			}
			if ( onFail ) {
				i = utils.indexOf( asset.onFail, onFail );
				if ( i < 0 ) asset.onFail.push( onFail );
			}
		};

		/**
		 * @private
		 * @param	{Object}	asset
		 */
		var createResponder = function(asset) {
			var responder = $.Flash.dataLoader.load( 'http://www.appsmail.ru/platform/api', null, asset.vars );
			responder.onData = onDataApi;
			responder.onFail = onFailApi;
			asset.responder = responder;
		};

		/**
		 * @private
		 * @param	{Object}	responder
		 * @return	{Object}
		 */
		var getAsset = function(responder) {
			var	asset,
				hash;
			for ( hash in _requests ) {
				asset = _requests[ hash ];
				if ( asset.responder === responder ) {
					return asset;
				}
			}
			return null;
		};

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{String}	data
		 */
		var onDataApi = function(data) {
			var asset,
				callbacks;

			try {

				var o = crypto.json.deserialize( data );

				if ( 'error' in o ) {

					if ( o.error.error_code == 2 ) { // request one more time
						onFailApi.call( this );
						return;
					} else {
						throw new Error( o.error.error_msg );
					}

				} else {

					asset = getAsset( this );
					callbacks = asset.onData;
					var	parse = _methods[ asset.vars.method ]; // метод преобразователь
					if ( parse ) {
						o = parse( o );
						if ( !o ) throw new Error( 'wrong data' );
					}

				}

			} catch ( e ) {

				if ( !asset ) asset = getAsset( this );
				o = e.message;
				callbacks = asset.onFail;

			}

			delete _requests[ asset.hash ];
			var l = callbacks.length;
			while ( l-- ) {
				callbacks.pop()( o );
			}

		};

		/**
		 * @private
		 * @param	{String}	message
		 */
		var onFailApi = function(message) {
			// повторим через 3 секунды
			var asset = getAsset( this );
			if ( msie ) {
				setTimeout(
					function() {
						createResponder( asset );
					},
					3e3
				)
			} else {
				setTimeout( createResponder, 3e3, asset );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @override
		 * @param	{Array}		userIDs
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		MmApiPrototype.requestUsers = function(userIDs, onData, onFail) {
			request.call( this,
				METHOD_USERS,
				true,
				{
					uids: userIDs.join( ',' )
				},
				onData,
				onFail
			);
		};

		/**
		 * @method
		 * @override
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		MmApiPrototype.requestAppFriends = function(onData, onFail) {
			request.call( this,
				METHOD_APP_FRIENDS,
				true,
				null,
				onData,
				onFail
			);
		};

		/**
		 * @method
		 * @override
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		MmApiPrototype.requestIsAppInstalled = function(onData, onFail) {
			request.call( this,
				METHOD_IS_APP_INSTALED,
				true,
				null,
				onData,
				onFail
			);
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		MmApiPrototype.toString = function() {
			return '[MmApi object]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		MmApi.toString = function() {
			return '[class MmApi]';
		};

		return MmApi;

	}() );

}