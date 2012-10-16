/*!
 * blooddy/utils/crypto/md5.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils.crypto' );

if ( !blooddy.utils.crypto.md5 ) {

	/**
	 * @property
	 * @final
	 * составляет MD5 хэш
	 * @namespace	blooddy.utils.crypto
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.crypto.md5 = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/*
		 * Constants for MD5Transform routine.
		 */
		var	crypto =	blooddy.utils.crypto,

			S11 = 7,
			S12 = 12,
			S13 = 17,
			S14 = 22,
			S21 = 5,
			S22 = 9,
			S23 = 14,
			S24 = 20,
			S31 = 4,
			S32 = 11,
			S33 = 16,
			S34 = 23,
			S41 = 6,
			S42 = 10,
			S43 = 15,
			S44 = 21;

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/*
		 * F, G, H and I are basic MD5 functions.
		 */
		var F = function(x,y,z)	{ return ( x & y ) | ( ( ~x ) & z ) };
		var G = function(x,y,z) { return ( x & z ) | ( y & ( ~z ) ) };
		var H = function(x,y,z) { return ( x ^ y ^ z ) };
		var I = function(x,y,z) { return ( y ^ ( x | ( ~z ) ) ) };

		/*
		 * FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
		 * Rotation is separate from addition to prevent recomputation.
		 */
		var transform = function(func, a, b, c, d, x, s, t) {
			a += func( b, c, d ) + ( x >>> 0 ) + t;
			return ( a << s | a >>> 32 - s ) +  b;
		};
		var FF = function(a, b, c, d, x, s, t)	{ return transform( F, a, b, c, d, x, s, t ) };
		var GG = function(a, b, c, d, x, s, t)	{ return transform( G, a, b, c, d, x, s, t ) };
		var HH = function(a, b, c, d, x, s, t)	{ return transform( H, a, b, c, d, x, s, t ) };
		var II = function(a, b, c, d, x, s, t)	{ return transform( I, a, b, c, d, x, s, t ) };

		/**
		 * @private
		 * Performs the MD5 hash algorithm on a blocks.
		 * @param	{Array}		x
		 * @return	{String}
		 */
		var hashBlocks = function(x) {
			var len = x.length,
				i;
			// initialize the md buffers
			var a = 0x67452301,
				b = 0xEFCDAB89,
				c = 0x98BADCFE,
				d = 0x10325476,
				// variables to store previous values
				aa,
				bb,
				cc,
				dd;

			// loop over all of the blocks
			for ( i=0; i<len; i+=16 ) {
				// save previous values
				aa = a;
				bb = b;
				cc = c;
				dd = d;

				// Round 1
				a = FF( a, b, c, d, x[i+ 0], S11, 0xD76AA478 ); // 1
				d = FF( d, a, b, c, x[i+ 1], S12, 0xE8C7B756 ); // 2
				c = FF( c, d, a, b, x[i+ 2], S13, 0x242070DB ); // 3
				b = FF( b, c, d, a, x[i+ 3], S14, 0xC1BDCEEE ); // 4
				a = FF( a, b, c, d, x[i+ 4], S11, 0xF57C0FAF ); // 5
				d = FF( d, a, b, c, x[i+ 5], S12, 0x4787C62A ); // 6
				c = FF( c, d, a, b, x[i+ 6], S13, 0xA8304613 ); // 7
				b = FF( b, c, d, a, x[i+ 7], S14, 0xFD469501 ); // 8
				a = FF( a, b, c, d, x[i+ 8], S11, 0x698098D8 ); // 9
				d = FF( d, a, b, c, x[i+ 9], S12, 0x8B44F7AF ); // 10
				c = FF( c, d, a, b, x[i+10], S13, 0xFFFF5BB1 ); // 11
				b = FF( b, c, d, a, x[i+11], S14, 0x895CD7BE ); // 12
				a = FF( a, b, c, d, x[i+12], S11, 0x6B901122 ); // 13
				d = FF( d, a, b, c, x[i+13], S12, 0xFD987193 ); // 14
				c = FF( c, d, a, b, x[i+14], S13, 0xA679438E ); // 15
				b = FF( b, c, d, a, x[i+15], S14, 0x49B40821 ); // 16

				// Round 2
				a = GG( a, b, c, d, x[i+ 1], S21, 0xF61E2562 ); // 17
				d = GG( d, a, b, c, x[i+ 6], S22, 0xC040B340 ); // 18
				c = GG( c, d, a, b, x[i+11], S23, 0x265E5A51 ); // 19
				b = GG( b, c, d, a, x[i+ 0], S24, 0xE9B6C7AA ); // 20
				a = GG( a, b, c, d, x[i+ 5], S21, 0xD62F105D ); // 21
				d = GG( d, a, b, c, x[i+10], S22,  0x2441453 ); // 22
				c = GG( c, d, a, b, x[i+15], S23, 0xD8A1E681 ); // 23
				b = GG( b, c, d, a, x[i+ 4], S24, 0xE7D3FBC8 ); // 24
				a = GG( a, b, c, d, x[i+ 9], S21, 0x21E1CDE6 ); // 25
				d = GG( d, a, b, c, x[i+14], S22, 0xC33707D6 ); // 26
				c = GG( c, d, a, b, x[i+ 3], S23, 0xF4D50D87 ); // 27
				b = GG( b, c, d, a, x[i+ 8], S24, 0x455A14ED ); // 28
				a = GG( a, b, c, d, x[i+13], S21, 0xA9E3E905 ); // 29
				d = GG( d, a, b, c, x[i+ 2], S22, 0xFCEFA3F8 ); // 30
				c = GG( c, d, a, b, x[i+ 7], S23, 0x676F02D9 ); // 31
				b = GG( b, c, d, a, x[i+12], S24, 0x8D2A4C8A ); // 32

				// Round 3
				a = HH( a, b, c, d, x[i+ 5], S31, 0xFFFA3942 ); // 33
				d = HH( d, a, b, c, x[i+ 8], S32, 0x8771F681 ); // 34
				c = HH( c, d, a, b, x[i+11], S33, 0x6D9D6122 ); // 35
				b = HH( b, c, d, a, x[i+14], S34, 0xFDE5380C ); // 36
				a = HH( a, b, c, d, x[i+ 1], S31, 0xA4BEEA44 ); // 37
				d = HH( d, a, b, c, x[i+ 4], S32, 0x4BDECFA9 ); // 38
				c = HH( c, d, a, b, x[i+ 7], S33, 0xF6BB4B60 ); // 39
				b = HH( b, c, d, a, x[i+10], S34, 0xBEBFBC70 ); // 40
				a = HH( a, b, c, d, x[i+13], S31, 0x289B7EC6 ); // 41
				d = HH( d, a, b, c, x[i+ 0], S32, 0xEAA127FA ); // 42
				c = HH( c, d, a, b, x[i+ 3], S33, 0xD4EF3085 ); // 43
				b = HH( b, c, d, a, x[i+ 6], S34, 0x04881D05 ); // 44
				a = HH( a, b, c, d, x[i+ 9], S31, 0xD9D4D039 ); // 45
				d = HH( d, a, b, c, x[i+12], S32, 0xE6DB99E5 ); // 46
				c = HH( c, d, a, b, x[i+15], S33, 0x1FA27CF8 ); // 47
				b = HH( b, c, d, a, x[i+ 2], S34, 0xC4AC5665 ); // 48

				// Round 4
				a = II( a, b, c, d, x[i+ 0], S41, 0xF4292244 ); // 49
				d = II( d, a, b, c, x[i+ 7], S42, 0x432AFF97 ); // 50
				c = II( c, d, a, b, x[i+14], S43, 0xAB9423A7 ); // 51
				b = II( b, c, d, a, x[i+ 5], S44, 0xFC93A039 ); // 52
				a = II( a, b, c, d, x[i+12], S41, 0x655B59C3 ); // 53
				d = II( d, a, b, c, x[i+ 3], S42, 0x8F0CCC92 ); // 54
				c = II( c, d, a, b, x[i+10], S43, 0xFFEFF47D ); // 55
				b = II( b, c, d, a, x[i+ 1], S44, 0x85845DD1 ); // 56
				a = II( a, b, c, d, x[i+ 8], S41, 0x6FA87E4F ); // 57
				d = II( d, a, b, c, x[i+15], S42, 0xFE2CE6E0 ); // 58
				c = II( c, d, a, b, x[i+ 6], S43, 0xA3014314 ); // 59
				b = II( b, c, d, a, x[i+13], S44, 0x4E0811A1 ); // 60
				a = II( a, b, c, d, x[i+ 4], S41, 0xF7537E82 ); // 61
				d = II( d, a, b, c, x[i+11], S42, 0xBD3AF235 ); // 62
				c = II( c, d, a, b, x[i+ 2], S43, 0x2AD7D2BB ); // 63
				b = II( b, c, d, a, x[i+ 9], S44, 0xEB86D391 ); // 64

				a += aa >>> 0;
				b += bb >>> 0;
				c += cc >>> 0;
				d += dd >>> 0;
			}

			// Finish up by concatening the buffers with their hex output
			return crypto.toHex( a ) + crypto.toHex( b ) + crypto.toHex( c ) + crypto.toHex( d );
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var MD5 = new Function(),
			MD5Prototype = MD5.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}	data
		 * @return	{String}
		 */
		MD5Prototype.hashString = function(data) {
			return hashBlocks( crypto.createBlocksFromString( data ) );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		MD5Prototype.toString = function() {
			return '[MD5 object]';
		};

		return MD5;

	}() );

}