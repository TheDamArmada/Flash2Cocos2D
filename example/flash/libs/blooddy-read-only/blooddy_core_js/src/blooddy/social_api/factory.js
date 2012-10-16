/*!
 * blooddy/social_api/factory.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.SocialApi' );

if ( !blooddy.SocialApi.factory ) {

	/**
	 * @class
	 * @namespace	blooddy
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.SocialApi.factory = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		var	$ =	blooddy;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var Factory = new Function(),
			FactoryPrototype = Factory.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{Location}				loc
		 * @param	{blooddy.SocialApi}
		 */
		FactoryPrototype.getApi = function(params, loc) {
			var search;
			if ( loc ) {
				try {
					search = loc.search.substr( 1 ).split( '&' );
				} catch ( e ) {
				}
			}
			if ( !params ) params = new Object();
			if ( search ) {
				var l = search.length,
					i,
					tmp;
				for ( i=0; i<l; i++ ) {
					tmp = search[ i ].split( '=', 2 );
					params[ decodeURIComponent( tmp[0] ) ] = decodeURIComponent( tmp[1] );
				}
			}
			// найдём маркеры api
			if (
				'secret_key' in params &&
				'app_id' in params &&
				'vid' in params &&
				'session_key' in params
			) {
				$.require( 'blooddy.SocialApi.MmApi' );
				return new $.SocialApi.MmApi(
					params.secret_key,
					params.app_id,
					params.vid,
					params.session_key
				);
			}
			return null;
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		FactoryPrototype.toString = function() {
			return '[Factory object]';
		};

		return Factory;

	}() );

}