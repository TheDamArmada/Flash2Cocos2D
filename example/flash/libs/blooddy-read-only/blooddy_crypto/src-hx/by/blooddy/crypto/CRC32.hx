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
class CRC32 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(bytes:ByteArray):UInt {

		var len:UInt = bytes.length;
		if ( len > 0 ) {

			len += 1024;
			
			var mem:ByteArray = Memory.memory;

			var tmp:ByteArray = CRC32Table.getTable();
			tmp.position = 1024;
			tmp.writeBytes( bytes );

			// помещаем в пямять
			if ( len < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
			Memory.memory = tmp;
			
			var c:UInt = 0xFFFFFFFF;
			var i:UInt = 1024;
			do {
				c = Memory.getI32( ( ( c ^ Memory.getByte( i ) & 0xFF ) << 2 ) ) ^ ( c >>> 8 );
			} while ( ++i < len );

			Memory.memory = mem;

			//tmp.clear();

			return c ^ 0xFFFFFFFF;

		} else {
			
			return 0;
			
		}

	}

}