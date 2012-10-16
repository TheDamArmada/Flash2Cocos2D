/*!
 * blooddy/utils/crypto.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.crypto ) {

	/**
	 * @package
	 * @final
	 * @namespace	blooddy.utils.crypto
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.crypto = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Crypto = new Function(),
			CryptoPrototype = Crypto.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------


		/**
		 * @method
		 * @param	{String}	s
		 * @return	{Array}
		 */
		CryptoPrototype.strToBin = function(s) {
			var	result = new Array(),
				l = s.length,
				i,
				x,
				y;
			for ( i=0; i<l; i++ ) {
				/* Decode utf-16 surrogate pairs */
				x = s.charCodeAt( i );
				if ( 0xD800 <= x && x <= 0xDBFF ) {
					y = ( i + 1 < l ? s.charCodeAt( i + 1 ) : 0 );
					if ( 0xDC00 <= y && y <= 0xDFFF ) {
						x = 0x10000 + ( ( x & 0x03FF ) << 10 ) + ( y & 0x03FF );
						i++;
					}
				}
				/* Encode output as utf-8 */
				if ( x <= 0x7F )			result.push(
												x
											);
				else if (x <= 0x7FF)		result.push(
												0xC0 | ( ( x >>>  6 ) & 0x1F ),
												0x80 | (   x         & 0x3F )
											);
				else if ( x <= 0xFFFF )		result.push(
												0xE0 | ( ( x >>> 12 ) & 0x0F ),
												0x80 | ( ( x >>>  6 ) & 0x3F ),
												0x80 | (   x          & 0x3F )
											);
				else if ( x <= 0x1FFFFF )	result.push(
												0xF0 | ( ( x >>> 18 ) & 0x07 ),
												0x80 | ( ( x >>> 12 ) & 0x3F ),
												0x80 | ( ( x >>>  6 ) & 0x3F ),
												0x80 | (   x          & 0x3F )
											);
			}
			return result;
		};

		/**
		 * @method
		 * @param	{String}	s
		 * @return	{Array}
		 */
		CryptoPrototype.createBlocksFromString = function(s) {
			return this.createBlocksFromArray( this.strToBin( s ) );
		};

		/**
		 * @method
		 * @param	{Array}	x
		 * @return	{Array}
		 */
		CryptoPrototype.createBlocksFromArray = function(x) {
			var	result =	new Array(),
				l =			x.length * 8;
			for( var i = 0; i < l ; i += 8 ) {
				result[ i >> 5 ] |= ( x[ i / 8 ] & 0xFF ) << ( i % 32 );
			}
			// append padding and length
			result[ l  >> 5 ] |= 0x80 << ( l  % 32 );
			result[ ( ( ( l  + 64 ) >>> 9 ) << 4 ) + 14 ] = l ;
			return result;
		};

		/**
		 * @param	{Number}	value
		 * @param	{String}
		 */
		CryptoPrototype.toHex = function(value) {
			var s = '';
			for ( var i = 0; i < 4; i++ ) {
				s +=	( ( value >> ( i * 8 + 4 ) ) & 0xF ).toString( 16 ) +
						( ( value >> ( i * 8 ) ) & 0xF ).toString( 16 );
			}
			return s;
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		CryptoPrototype.toString = function() {
			return '[package crypto]';
		};

		return Crypto;

	}() );

}