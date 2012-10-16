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
class SHA2Helper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function hashBytes(bytes:ByteArray, h0:Int, h1:Int, h2:Int, h3:Int, h4:Int, h5:Int, h6:Int, h7:Int):String {

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

		var k:Array<Int> = [ 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 ];
		i = 0;
		do {
			Memory.setI32( TMP.Z1 + ( i << 2 ), k[ i ] );
		} while ( ++i < 64 );

		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;
		var e:Int;
		var f:Int;
		var g:Int;
		var h:Int;

		var t:UInt;

		i = TMP.Z0;
		do {

			a = h0;
			b = h1;
			c = h2;
			d = h3;
			e = h4;
			f = h5;
			g = h6;
			h = h7;

			t = 0;

			TMP.phase( a, b, c, d, e, f, g, h, i, t, 16 );
			TMP.phase( a, b, c, d, e, f, g, h, i, t, 64 );

			//Add this chunk's hash to result so far:
			h0 += a;
			h1 += b;
			h2 += c;
			h3 += d;
			h4 += e;
			h5 += f;
			h6 += g;
			h7 += h;

			i += 16 * 4;

		} while ( i < bytesLength );

		tmp.position = 0;
		tmp.writeUTFBytes( '0123456789abcdef' );

		Memory.setBI32( 16, h0 );
		Memory.setBI32( 20, h1 );
		Memory.setBI32( 24, h2 );
		Memory.setBI32( 28, h3 );
		Memory.setBI32( 32, h4 );
		Memory.setBI32( 36, h5 );
		Memory.setBI32( 40, h6 );
		Memory.setBI32( 44, h7 );

		b = 48 - 1;
		i = 16;
		do {
			a = Memory.getByte( i );
			Memory.setByte( ++b, Memory.getByte( a >>> 4 ) );
			Memory.setByte( ++b, Memory.getByte( a & 0xF ) );
		} while ( ++i < 16 + 8 * 4 );

		Memory.memory = mem;

		tmp.position = 48;
		return tmp.readUTFBytes( 8 * 8 );

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

	public static inline var Z1:UInt = 64 * 4;
	public static inline var Z0:UInt = Z1 * 2;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function phase(a:Int, b:Int, c:Int, d:Int, e:Int, f:Int, g:Int, h:Int, i:UInt, t:UInt, max:UInt):Void {

		var w2:Int;
		var w15:Int;
		var w:Int;
		var T2:Int;
		var T1:Int;
		do {

			if ( max <= 16 ) {
				w =	( Memory.getByte( i + t + 0 ) << 24 ) |
					( Memory.getByte( i + t + 1 ) << 16 ) |
					( Memory.getByte( i + t + 2 ) <<  8 ) |
					  Memory.getByte( i + t + 3 )         ;
			} else {
				w2 =  Memory.getI32( t -  2 * 4 );
				w15 = Memory.getI32( t - 15 * 4 );
				w =	( IntUtils.ror( w2, 17 ) ^ IntUtils.ror( w2, 19 ) ^ ( w2 >>> 10 ) ) +
					Memory.getI32( t -  7 * 4 ) +
					( IntUtils.ror( w15, 7 ) ^ IntUtils.ror( w15, 18 ) ^ ( w15 >>> 3 ) ) +
					Memory.getI32( t - 16 * 4 );
			}
			Memory.setI32( t, w );

			T1 =	h +
					( IntUtils.ror( e, 6 ) ^ IntUtils.ror( e, 11 ) ^ IntUtils.ror( e, 25 ) ) +
					( ( e & f ) ^ ( ( ~e ) & g ) ) +
					Memory.getI32( Z1 + t ) +
					w;
			T2 =	( IntUtils.ror( a, 2 ) ^ IntUtils.ror( a, 13 ) ^ IntUtils.ror( a, 22 ) ) +
					( ( a & b ) ^ ( a & c ) ^ ( b & c ) );

			h = g;
			g = f;
			f = e;
			e = d + T1;
			d = c;
			c = b;
			b = a;
			a = T1 + T2;

			t += 4;
			
		} while ( t < max * 4 );
	}

}