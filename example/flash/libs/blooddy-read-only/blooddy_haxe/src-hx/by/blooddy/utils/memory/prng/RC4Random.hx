////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils.memory.prng;

import by.blooddy.system.Memory;
import by.blooddy.utils.DateUtils;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class RC4Random {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var POOL_SIZE:UInt = RC4.POOL_SIZE;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function createPool(memory:ByteArray, to:UInt):Void {
		var t:UInt = 0;
		var i:UInt = to;
		var len:UInt = i + POOL_SIZE;
		do {
			//t = untyped 0x10000 * Math.random();
			t += 256;
			Memory.setByte( i++, t >>> 8 );
			Memory.setByte( i++, t       );
		} while ( i < len );

		seed( to );

		i = to + POOL_SIZE;
		RC4.createPool( memory, to, POOL_SIZE, i );

		memory.position = to;
		memory.writeBytes( memory, i, POOL_SIZE );
	}

	public static inline function seed(to:UInt, ?x:UInt = 0):Void {
		if ( x == 0 ) {
			//x = untyped DateUtils.getTime();
			x = -374774837;
		}
		var i:UInt = to;
		Memory.setByte( i, Memory.getByte( i ) ^ (   x         & 0xFF ) );
		++i;
		Memory.setByte( i, Memory.getByte( i ) ^ ( ( x >>  8 ) & 0xFF ) );
		++i;
		Memory.setByte( i, Memory.getByte( i ) ^ ( ( x >> 16 ) & 0xFF ) );
		++i;
		Memory.setByte( i, Memory.getByte( i ) ^ ( ( x >> 24 ) & 0xFF ) );
	}

	public static inline function nextByte(to:UInt, _ri:UInt, _rj:UInt):UInt {
		return RC4.nextByte( to, _ri, _rj );
	}

}