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
class SHA1 {

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
		var bytesLength:UInt = TMP.Z0 + ( ( ( ( ( i + 64 ) >>> 9 ) << 4 ) + 15 ) << 2 ); // длинна для подсчёта в блоках

		// копируем массив
		var tmp:ByteArray = ByteArrayUtils.createByteArray( bytesLength + 4 );
		tmp.position = TMP.Z0;
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		Memory.setI32( TMP.Z0 + ( ( i >>> 5 ) << 2 ), Memory.getI32( TMP.Z0 + ( ( i >>> 5 ) << 2 ) ) | ( 0x80 << ( i % 32 ) ) );
		Memory.setBI32( bytesLength, i );

		var h0:Int = 0x67452301;
		var h1:Int = 0xEFCDAB89;
		var h2:Int = 0x98BADCFE;
		var h3:Int = 0x10325476;
		var h4:Int = 0xC3D2E1F0;

		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;
		var e:Int;

		var t:UInt;

		i = TMP.Z0;
		do {

			// 6.1.c
			a = h0;
			b = h1;
			c = h2;
			d = h3;
			e = h4;

			t = 0;

			TMP.phase( a, b, c, d, e, i, t, 16 );
			TMP.phase( a, b, c, d, e, i, t, 20 );
			TMP.phase( a, b, c, d, e, i, t, 40 );
			TMP.phase( a, b, c, d, e, i, t, 60 );
			TMP.phase( a, b, c, d, e, i, t, 80 );

			// 6.1.e
			h0 += a;
			h1 += b;
			h2 += c;
			h3 += d;
			h4 += e;

			i += 16 * 4;

		} while ( i < bytesLength );

		tmp.position = 0;
		tmp.writeUTFBytes( '0123456789abcdef' );

		Memory.setBI32( 16, h0 );
		Memory.setBI32( 20, h1 );
		Memory.setBI32( 24, h2 );
		Memory.setBI32( 28, h3 );
		Memory.setBI32( 32, h4 );

		b = 36 - 1;
		i = 16;
		do {
			a = Memory.getByte( i );
			Memory.setByte( ++b, Memory.getByte( a >>> 4 ) );
			Memory.setByte( ++b, Memory.getByte( a & 0xF ) );
		} while ( ++i < 16 + 5 * 4 );

		Memory.memory = mem;

		tmp.position = 36;
		return tmp.readUTFBytes( 5 * 8 );

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

	public static inline var Z0:UInt = 80 * 4;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function phase(a:Int, b:Int, c:Int, d:Int, e:Int, i:UInt, t:UInt, max:UInt):Void {
		var w:Int;
		do {

			if ( max <= 16 ) {
				// 6.1.a
				w =	( Memory.getByte( i + t + 0 ) << 24 ) |
					( Memory.getByte( i + t + 1 ) << 16 ) |
					( Memory.getByte( i + t + 2 ) <<  8 ) |
					  Memory.getByte( i + t + 3 )         ;
			} else {
				// 6.1.b
				w = IntUtils.rol(
						Memory.getI32( t -  3 * 4 ) ^
						Memory.getI32( t -  8 * 4 ) ^
						Memory.getI32( t - 14 * 4 ) ^
						Memory.getI32( t - 16 * 4 ) ,
						1
					);
			}
			Memory.setI32( t, w );

			// 6.1.d
			if ( max <= 20 ) {
				w += 0x5A827999 + e + ( ( a << 5 ) | ( a >>> 27 ) ) + ( ( b & c ) | ( ~b & d ) );
			} else if ( max <= 40 ) {
				w += 0x6ED9EBA1 + e + ( ( a << 5 ) | ( a >>> 27 ) ) + ( b ^ c ^ d );
			} else if ( max <= 60 ) {
				w += 0x8F1BBCDC + e + ( ( a << 5 ) | ( a >>> 27 ) ) + ( ( b & c ) | ( b & d ) | ( c & d ) );
			} else if ( max <= 80 ) {
				w += 0xCA62C1D6 + e + ( ( a << 5 ) | ( a >>> 27 ) ) + ( b ^ c ^ d );
			}

			e = d;
			d = c;
			c = ( b << 30 ) | ( b >>> 2 );
			b = a;
			a = w;

			t += 4;

		} while ( t < max * 4 );

	}

}