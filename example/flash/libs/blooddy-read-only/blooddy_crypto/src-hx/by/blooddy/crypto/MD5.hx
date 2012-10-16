////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.core.utils.ByteArrayUtils;
import by.blooddy.system.Memory;
import by.blooddy.utils.IntUtils;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class MD5 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(s:String):String {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes( s );
		var result:String = hashBytes( bytes );
		//bytes.clear();
		return result;
	}

	public static function hashBytes(bytes:ByteArray):String {

		var mem:ByteArray = Memory.memory;

		var i:UInt = bytes.length << 3;
		var bytesLength:UInt = ( ( ( ( i + 64 ) >>> 9 ) << 4 ) + 15 ) << 2; // длинна для подсчёта в блоках

		// копируем массив
		var tmp:ByteArray = ByteArrayUtils.createByteArray( bytesLength + 4 );
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		Memory.setI32( ( i >>> 5 ) << 2, Memory.getI32( ( i >>> 5 ) << 2 ) | ( 0x80 << ( i % 32 ) ) );
		Memory.setI32( bytesLength - 4, i );

		var a:Int =   1732584193;
		var b:Int = -  271733879;
		var c:Int = - 1732584194;
		var d:Int =    271733878;

		var aa:Int = a;
		var bb:Int = b;
		var cc:Int = c;
		var dd:Int = d;

		i = 0;

		do {

			aa = a;
			bb = b;
			cc = c;
			dd = d;

			a = TMP.FF( a, b, c, d, Memory.getI32( i +  0 * 4 ), TMP.S11, -  680876936 );
			d = TMP.FF( d, a, b, c, Memory.getI32( i +  1 * 4 ), TMP.S12, -  389564586 );
			c = TMP.FF( c, d, a, b, Memory.getI32( i +  2 * 4 ), TMP.S13,    606105819 );
			b = TMP.FF( b, c, d, a, Memory.getI32( i +  3 * 4 ), TMP.S14, - 1044525330 );
			a = TMP.FF( a, b, c, d, Memory.getI32( i +  4 * 4 ), TMP.S11, -  176418897 );
			d = TMP.FF( d, a, b, c, Memory.getI32( i +  5 * 4 ), TMP.S12,   1200080426 );
			c = TMP.FF( c, d, a, b, Memory.getI32( i +  6 * 4 ), TMP.S13, - 1473231341 );
			b = TMP.FF( b, c, d, a, Memory.getI32( i +  7 * 4 ), TMP.S14, -   45705983 );
			a = TMP.FF( a, b, c, d, Memory.getI32( i +  8 * 4 ), TMP.S11,   1770035416 );
			d = TMP.FF( d, a, b, c, Memory.getI32( i +  9 * 4 ), TMP.S12, - 1958414417 );
			c = TMP.FF( c, d, a, b, Memory.getI32( i + 10 * 4 ), TMP.S13, -      42063 );
			b = TMP.FF( b, c, d, a, Memory.getI32( i + 11 * 4 ), TMP.S14, - 1990404162 );
			a = TMP.FF( a, b, c, d, Memory.getI32( i + 12 * 4 ), TMP.S11,   1804603682 );
			d = TMP.FF( d, a, b, c, Memory.getI32( i + 13 * 4 ), TMP.S12, -   40341101 );
			c = TMP.FF( c, d, a, b, Memory.getI32( i + 14 * 4 ), TMP.S13, - 1502002290 );
			b = TMP.FF( b, c, d, a, Memory.getI32( i + 15 * 4 ), TMP.S14,   1236535329 );
			a = TMP.GG( a, b, c, d, Memory.getI32( i +  1 * 4 ), TMP.S21, -  165796510 );
			d = TMP.GG( d, a, b, c, Memory.getI32( i +  6 * 4 ), TMP.S22, - 1069501632 );
			c = TMP.GG( c, d, a, b, Memory.getI32( i + 11 * 4 ), TMP.S23,    643717713 );
			b = TMP.GG( b, c, d, a, Memory.getI32( i +  0 * 4 ), TMP.S24, -  373897302 );
			a = TMP.GG( a, b, c, d, Memory.getI32( i +  5 * 4 ), TMP.S21, -  701558691 );
			d = TMP.GG( d, a, b, c, Memory.getI32( i + 10 * 4 ), TMP.S22,     38016083 );
			c = TMP.GG( c, d, a, b, Memory.getI32( i + 15 * 4 ), TMP.S23, -  660478335 );
			b = TMP.GG( b, c, d, a, Memory.getI32( i +  4 * 4 ), TMP.S24, -  405537848 );
			a = TMP.GG( a, b, c, d, Memory.getI32( i +  9 * 4 ), TMP.S21,    568446438 );
			d = TMP.GG( d, a, b, c, Memory.getI32( i + 14 * 4 ), TMP.S22, - 1019803690 );
			c = TMP.GG( c, d, a, b, Memory.getI32( i +  3 * 4 ), TMP.S23, -  187363961 );
			b = TMP.GG( b, c, d, a, Memory.getI32( i +  8 * 4 ), TMP.S24,   1163531501 );
			a = TMP.GG( a, b, c, d, Memory.getI32( i + 13 * 4 ), TMP.S21, - 1444681467 );
			d = TMP.GG( d, a, b, c, Memory.getI32( i +  2 * 4 ), TMP.S22, -   51403784 );
			c = TMP.GG( c, d, a, b, Memory.getI32( i +  7 * 4 ), TMP.S23,   1735328473 );
			b = TMP.GG( b, c, d, a, Memory.getI32( i + 12 * 4 ), TMP.S24, - 1926607734 );
			a = TMP.HH( a, b, c, d, Memory.getI32( i +  5 * 4 ), TMP.S31, -     378558 );
			d = TMP.HH( d, a, b, c, Memory.getI32( i +  8 * 4 ), TMP.S32, - 2022574463 );
			c = TMP.HH( c, d, a, b, Memory.getI32( i + 11 * 4 ), TMP.S33,   1839030562 );
			b = TMP.HH( b, c, d, a, Memory.getI32( i + 14 * 4 ), TMP.S34, -   35309556 );
			a = TMP.HH( a, b, c, d, Memory.getI32( i +  1 * 4 ), TMP.S31, - 1530992060 );
			d = TMP.HH( d, a, b, c, Memory.getI32( i +  4 * 4 ), TMP.S32,   1272893353 );
			c = TMP.HH( c, d, a, b, Memory.getI32( i +  7 * 4 ), TMP.S33, -  155497632 );
			b = TMP.HH( b, c, d, a, Memory.getI32( i + 10 * 4 ), TMP.S34, - 1094730640 );
			a = TMP.HH( a, b, c, d, Memory.getI32( i + 13 * 4 ), TMP.S31,    681279174 );
			d = TMP.HH( d, a, b, c, Memory.getI32( i +  0 * 4 ), TMP.S32, -  358537222 );
			c = TMP.HH( c, d, a, b, Memory.getI32( i +  3 * 4 ), TMP.S33, -  722521979 );
			b = TMP.HH( b, c, d, a, Memory.getI32( i +  6 * 4 ), TMP.S34,     76029189 );
			a = TMP.HH( a, b, c, d, Memory.getI32( i +  9 * 4 ), TMP.S31, -  640364487 );
			d = TMP.HH( d, a, b, c, Memory.getI32( i + 12 * 4 ), TMP.S32, -  421815835 );
			c = TMP.HH( c, d, a, b, Memory.getI32( i + 15 * 4 ), TMP.S33,    530742520 );
			b = TMP.HH( b, c, d, a, Memory.getI32( i +  2 * 4 ), TMP.S34, -  995338651 );
			a = TMP.II( a, b, c, d, Memory.getI32( i +  0 * 4 ), TMP.S41, -  198630844 );
			d = TMP.II( d, a, b, c, Memory.getI32( i +  7 * 4 ), TMP.S42,   1126891415 );
			c = TMP.II( c, d, a, b, Memory.getI32( i + 14 * 4 ), TMP.S43, - 1416354905 );
			b = TMP.II( b, c, d, a, Memory.getI32( i +  5 * 4 ), TMP.S44, -   57434055 );
			a = TMP.II( a, b, c, d, Memory.getI32( i + 12 * 4 ), TMP.S41,   1700485571 );
			d = TMP.II( d, a, b, c, Memory.getI32( i +  3 * 4 ), TMP.S42, - 1894986606 );
			c = TMP.II( c, d, a, b, Memory.getI32( i + 10 * 4 ), TMP.S43, -    1051523 );
			b = TMP.II( b, c, d, a, Memory.getI32( i +  1 * 4 ), TMP.S44, - 2054922799 );
			a = TMP.II( a, b, c, d, Memory.getI32( i +  8 * 4 ), TMP.S41,   1873313359 );
			d = TMP.II( d, a, b, c, Memory.getI32( i + 15 * 4 ), TMP.S42, -   30611744 );
			c = TMP.II( c, d, a, b, Memory.getI32( i +  6 * 4 ), TMP.S43, - 1560198380 );
			b = TMP.II( b, c, d, a, Memory.getI32( i + 13 * 4 ), TMP.S44,   1309151649 );
			a = TMP.II( a, b, c, d, Memory.getI32( i +  4 * 4 ), TMP.S41, -  145523070 );
			d = TMP.II( d, a, b, c, Memory.getI32( i + 11 * 4 ), TMP.S42, - 1120210379 );
			c = TMP.II( c, d, a, b, Memory.getI32( i +  2 * 4 ), TMP.S43,    718787259 );
			b = TMP.II( b, c, d, a, Memory.getI32( i +  9 * 4 ), TMP.S44, -  343485551 );

			a += aa;
			b += bb;
			c += cc;
			d += dd;

			i += 64;

		} while ( i < bytesLength );

		tmp.position = 0;
		tmp.writeUTFBytes( '0123456789abcdef' );
		
		Memory.setI32( 16, a );
		Memory.setI32( 20, b );
		Memory.setI32( 24, c );
		Memory.setI32( 28, d );

		b = 32 - 1;
		i = 16;
		do {
			a = Memory.getByte( i );
			Memory.setByte( ++b, Memory.getByte( a >>> 4 ) );
			Memory.setByte( ++b, Memory.getByte( a & 0xF ) );
		} while ( ++i < 16 + 4 * 4 );

		Memory.memory = mem;

		tmp.position = 32;
		return tmp.readUTFBytes( 32 );

	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var S11:UInt =  7;
	public static inline var S12:UInt = 12;
	public static inline var S13:UInt = 17;
	public static inline var S14:UInt = 22;
	public static inline var S21:UInt =  5;
	public static inline var S22:UInt =  9;
	public static inline var S23:UInt = 14;
	public static inline var S24:UInt = 20;
	public static inline var S31:UInt =  4;
	public static inline var S32:UInt = 11;
	public static inline var S33:UInt = 16;
	public static inline var S34:UInt = 23;
	public static inline var S41:UInt =  6;
	public static inline var S42:UInt = 10;
	public static inline var S43:UInt = 15;
	public static inline var S44:UInt = 21;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * transformations for round 1
	 */
	public static inline function FF(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( ( b & c ) | ( ( ~b ) & d ) ) + x + t;
		return IntUtils.rol( a, s ) +  b;
	}

	/**
	 * transformations for round 2
	 */
	public static inline function GG(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( ( b & d ) | ( c & ( ~d ) ) ) + x + t;
		return IntUtils.rol( a, s ) +  b;
	}

	/**
	 * transformations for round 3
	 */
	public static inline function HH(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( b ^ c ^ d ) + x + t;
		return IntUtils.rol( a, s ) +  b;
	}

	/**
	 * transformations for round 4
	 */
	public static inline function II(a:Int, b:Int, c:Int, d:Int, x:Int, s:Int, t:Int):Int {
		a += ( c ^ ( b | ( ~d ) ) ) + x + t;
		return IntUtils.rol( a, s ) +  b;
	}

}