////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils.memory.prng;

import by.blooddy.system.Memory;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class RC4 {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var POOL_SIZE:UInt = 0x100;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function createPool(memory:ByteArray, from:UInt, len:UInt, to:UInt):Void {
		// create start pool
		memory.position = to;
		memory.writeUTFBytes( '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f' );
		var i:UInt = to + 128;
		var j:UInt = to + 256;
		var t:UInt = 0x7F7E7D7C;
		do {
			t += 0x04040404;
			Memory.setI32( i, t );
			i += 4;
		} while ( i < j );
		// use target pool
		i = 0;
		if ( len >= POOL_SIZE ) { // optimize
			do {
				t = Memory.getByte( to + i );
				j += t + Memory.getByte( from + i/*( i % len )*/ );
				if ( j > 0xFF ) j &= 0xFF;
				Memory.setByte( to + i, Memory.getByte( to + j ) );
				Memory.setByte( to + j, t );
			} while ( ++i < POOL_SIZE );
		} else {
			do {
				t = Memory.getByte( to + i );
				j += t + Memory.getByte( from + ( i % len ) );
				if ( j > 0xFF ) j &= 0xFF;
				Memory.setByte( to + i, Memory.getByte( to + j ) );
				Memory.setByte( to + j, t );
			} while ( ++i < POOL_SIZE );
		}
	}

	public static inline function nextByte(to:UInt, _ri:UInt, _rj:UInt):UInt {
		if ( ++_ri > 0xFF ) {
			_ri &= 0xFF;
		}
		var ti:UInt = Memory.getByte( to + _ri );
		_rj += ti;
		if ( _rj > 0xFF ) {
			_rj &= 0xFF;
		}
		var tj:UInt = Memory.getByte( to + _rj );
		Memory.setByte( to + _ri, tj );
		Memory.setByte( to + _rj, ti );
		return Memory.getByte( to + ( ( ti + tj ) & 0xFF ) );
	}
	
}