////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import by.blooddy.system.Memory;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Adler32 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(bytes:ByteArray):UInt {

		var len:UInt = bytes.length;
		if ( len > 0 ) {

			var mem:ByteArray = Memory.memory;

			if ( len < Memory.MIN_SIZE ) {

				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( bytes );
				tmp.length = Memory.MIN_SIZE;
				Memory.memory = tmp;

			} else {

				Memory.memory = bytes;

			}

			var i:UInt = 0;
			var a:UInt = 1;
			var b:UInt = 0;
			var tlen:UInt;
			do {
				tlen = i + TMP.TLEN;
				if ( tlen > len ) tlen = len;
				do {
					a += Memory.getByte( i );
					b += a;
				} while ( ++i < tlen );
				a %= TMP.BASE;
				b %= TMP.BASE;
			} while ( i < len );

			Memory.memory = mem;

			return ( b << 16 ) | a;

		} else {
			
			return 1;
			
		}

	}

}

/**
 * @private
 */
private class TMP {

	/**
	 * The largest prime smaller than 65536.
	 */
	public static inline var BASE:UInt = 65521;

	/**
	 * TLEN is the largest n such that 255n(n+1)/2 + (n+1)(BASE-1) <= 2^32-1
	 */
	public static inline var TLEN:UInt = 5552;

}