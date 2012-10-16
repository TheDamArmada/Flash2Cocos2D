/*!
 * @author  BlooDHounD <http://www.blooddy.by>
 * @created 11.05.11 16:11
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.cookie ) {

	/**
	 * @package
	 * @final
	 * @namespace	blooddy.utils.crypto
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.cookie = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		var	doc =	window.document,
			n =		/([.*+?^=!:${}()|[\]\/\\])/g;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Cookie = new Function(),
			CookiePrototype = Cookie.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------


		/**
		 * @method
		 * @param	{String}	name
		 * @return	{String}
		 */
		CookiePrototype.get = function(name) {
			name = encodeURIComponent( name ).replace( n, '\\$1' );
			var match = document.cookie.match( new RegExp( '(?:^|;)\\s?' + name + '=(.*?)(?:;|$)','i' ) );
			return ( match && match[ 1 ] ? decodeURIComponent( match[ 1 ] ) : null );
		};

		/**
		 * @method
		 * @param	{String}	name
		 * @param	{String}	value
		 * @param	{Number}	time
		 * @param	{String}	path
		 * @param	{String}	domain
		 * @param	{Boolean}	secure
		 */
		CookiePrototype.set = function(name, value, time, path, domain, secure) {
				if ( !value ) value = '';
				var result = name + '=' + encodeURIComponent( value.toString() );
				if ( !time ) time = 0;
				if ( time ) {
					var d = new Date();
					d.setTime( d.getTime() + time );
					result += '; expires=' + d.toString();
				}
				if ( path ) result += ';path=' + path;
				if ( domain ) result += '; domain=' + domain;
				if ( secure ) result += '; secure';
				doc.cookie = result;
		};

		/**
		 * @method
		 * @param	{String}	key
		 */
		CookiePrototype.del = function(key) {
			this.set( name, null, -( new Date() ).getTime() );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		CookiePrototype.toString = function() {
			return '[Cookie object]';
		};

		return Cookie;

	}() );

}