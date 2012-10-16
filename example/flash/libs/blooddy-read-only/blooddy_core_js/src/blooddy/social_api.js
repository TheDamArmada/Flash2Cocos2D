/*!
 * blooddy/social_api.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.SocialApi ) {

	blooddy.require( 'blooddy.Flash.dataLoader' );

	/**
	 * @class
	 * @namespace	blooddy
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.SocialApi = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =			blooddy,
			EEvent =	$.Event;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var SocialApi = function() {
			SocialApi.superPrototype.constructor.call( this );
		};

		$.extend( SocialApi, $.events.EventDispatcher );

		var	SocialApiPrototype = SocialApi.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{Array}		userIDs
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		SocialApiPrototype.requestUsers = function(userIDs, onData, onFail) {
			onFail( 'connection absent' );
		};

		/**
		 * @method
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		SocialApiPrototype.requestAppFriends = function(onData, onFail) {
			onData( new Array() );
		};

		/**
		 * @method
		 * @param	{Function}	onData
		 * @param	{Function}	onFail
		 */
		SocialApiPrototype.requestIsAppInstalled = function(onData, onFail) {
			onData( false );
		};

		/**
		 * @method
		 */
		SocialApiPrototype.showInstallBox = function(onData, onFail) {
			this.dispatchEvent( new EEvent( 'showInstallBox' ) );
		};

		/**
		 * @method
		 */
		SocialApiPrototype.showSettingsBox = function() {
			this.dispatchEvent( new EEvent( 'showSettingsBox' ) );
		};

		/**
		 * @method
		 */
		SocialApiPrototype.showInviteBox = function() {
			this.dispatchEvent( new EEvent( 'showInviteBox' ) );
		};

		/**
		 * @method
		 */
		SocialApiPrototype.showPaymentBox = function() {
			this.dispatchEvent( new EEvent( 'showPaymentBox' ) );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		SocialApiPrototype.toString = function() {
			return '[SocialApi object]';
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
		 * @param	{Object}	vars
		 * @return	{String}
		 */
		SocialApi.createHash = function(vars) {
			// получаем долбанную строку
			var arr = new Array(),
				key,
				result = '',
				i, l;
			for ( key in vars ) {
				arr.push( key );
			}
			arr.sort();

			l = arr.length;
			for ( i=0; i<l; i++ ) {
				if ( vars[ arr[i] ] != null ) {
					result += arr[ i ] + '=' + vars[ arr[i] ];
				}
			}
			return result;
		};

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		SocialApi.toString = function() {
			return '[class SocialApi]';
		};

		return SocialApi;

	}() );

	blooddy.require( 'blooddy.SocialApi.User' );

}