/*!
 * blooddy/utils/crypto/json.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils.crypto' );

if ( !blooddy.utils.crypto.json ) {

	/**
	 * @class
	 * @namespace	blooddy.utils.crypto
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.crypto.json = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	win =	window,
			_r0 =	/^[\],:{}\s]*$/,
			_r1 =	/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,
			_r2 =	/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
			_r3 =	/(?:^|:|,)(?:\s*\[)+/g;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var	JJSON = new Function(),
			JJSONPrototype = JJSON.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{Object}	o
		 * @return	{String}
		 */
		JJSONPrototype.serialize = ( win.JSON && win.JSON.stringify
			?	win.JSON.stringify
			:	function(o) {
					throw '';
				}
		);

		/**
		 * @method
		 * @param	{String}	s
		 * @return	{String}
		 */
		JJSONPrototype.deserialize = ( win.JSON && win.JSON.parse
			?	win.JSON.parse
			:	function(s) {
					if ( _r0.test( s.replace( _r1, '@' ).replace( _r2, ']' ).replace( _r3, '' ) ) ) {
						return eval( '(' + s + ')' );
					}
					throw '';
				}
		);

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		JJSONPrototype.toString = function() {
			return '[json object]';
		};

		return JJSON;

	}() );

}