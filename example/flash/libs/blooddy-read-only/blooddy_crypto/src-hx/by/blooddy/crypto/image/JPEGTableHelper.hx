////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.system.Memory;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JPEGTableHelper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *	   0:	0							[1]{1}
	 *	   1:	YTable						[1]{64}
	 *	  64:	0							[1]{1}
	 *	  65:	UVTable						[1]{64}
	 *	 130:	fdtbl_Y						[8]{64}
	 *	 642:	fdtbl_UV					[8]{64}
	 * 	1154:
	 */
	public static inline function createQuantTable(quality:UInt):ByteArray {

		if ( quality > 100 ) Error.throwError( RangeError, 2006, 'quality' );
		
		var sf:UInt = ( quality <= 1
			?	5000
			:	( quality < 50
				?	Std.int( 5000 / quality )
				:	200 - ( quality << 1 )
				)
			);

		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();

		tmp.position = 130;
		// YQT
		tmp.writeUTFBytes( '\x10\x0b\x0a\x10\x18\x28\x33\x3d\x0c\x0c\x0e\x13\x1a\x3a\x3c\x37\x0e\x0d\x10\x18\x28\x39\x45\x38\x0e\x11\x16\x1d\x33\x57\x50\x3e\x12\x16\x25\x38\x44\x6d\x67\x4d\x18\x23\x37\x40\x51\x68\x71\x5c\x31\x40\x4e\x57\x67\x79\x78\x65\x48\x5c\x5f\x62\x70\x64\x67\x63' );
		// UVQT
		tmp.writeUTFBytes( '\x11\x12\x18\x2f\x63\x63\x63\x63\x12\x15\x1a\x42\x63\x63\x63\x63\x18\x1a\x38\x63\x63\x63\x63\x63\x2f\x42\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63\x63' );

		// ZigZag
		tmp.position = 1154;
		tmp.writeUTFBytes( '\x00\x01\x05\x06\x0e\x0f\x1b\x1c\x02\x04\x07\x0d\x10\x1a\x1d\x2a\x03\x08\x0c\x11\x19\x1e\x29\x2b\x09\x0b\x12\x18\x1f\x28\x2c\x35\x0a\x13\x17\x20\x27\x2d\x34\x36\x14\x16\x21\x26\x2e\x33\x37\x3c\x15\x22\x25\x2f\x32\x38\x3b\x3d\x23\x24\x30\x31\x39\x3a\x3e\x3f' );

		tmp.length += 64;

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;
		
		var i:UInt;
		var t:UInt;

		// YTable
		i = 0;
		do {
			t = Std.int( ( Memory.getByte( 130 + i ) * sf + 50 ) / 100 );
			if ( t < 1 ) t = 1;
			else if ( t > 255 ) t = 255;
			Memory.setByte( 1 + Memory.getByte( 1154 + i ), t );
		} while ( ++i < 64 );

		// UVTable
		i = 0;
		do {
			t = Std.int( ( Memory.getByte( 194 + i ) * sf + 50 ) / 100 );
			if ( t < 1 ) t = 1;
			else if ( t > 255 ) t = 255;
			Memory.setByte( 66 + Memory.getByte( 1154 + i ), t );
		} while ( ++i < 64 );

		// aasf
		Memory.setDouble( 1154 + 64 + 8 * 0, 1.000000000 );
		Memory.setDouble( 1154 + 64 + 8 * 1, 1.387039845 );
		Memory.setDouble( 1154 + 64 + 8 * 2, 1.306562965 );
		Memory.setDouble( 1154 + 64 + 8 * 3, 1.175875602 );
		Memory.setDouble( 1154 + 64 + 8 * 4, 1.000000000 );
		Memory.setDouble( 1154 + 64 + 8 * 5, 0.785694958 );
		Memory.setDouble( 1154 + 64 + 8 * 6, 0.541196100 );
		Memory.setDouble( 1154 + 64 + 8 * 7, 0.275899379 );

		// fdtbl_Y
		// fdtbl_UV
		var row:UInt;
		var col:UInt;
		var n:Float;
		i = 0;
		row = 0;
		do {
			col = 0;
			do {
				n = Memory.getDouble( 1154 + 64 + row ) * Memory.getDouble( 1154 + 64 + col ) * 8;
				Memory.setDouble( 130       + ( i << 3 ), 1.0 / ( Memory.getByte(  1 + Memory.getByte( 1154 + i ) ) * n ) );
				Memory.setDouble( 130 + 512 + ( i << 3 ), 1.0 / ( Memory.getByte( 66 + Memory.getByte( 1154 + i ) ) * n ) );
				++i;
				col += 8;
			} while ( col < 64 );
			row += 8;
		} while ( row < 64 );

		Memory.memory = mem;

		tmp.length = 1154;

		var bytes:ByteArray = new ByteArray();
		bytes.writeBytes( tmp );
		bytes.position = 0;

		//tmp.clear();

		return bytes;
	}

	/**
	 *	   0:	ZigZag						[1]{64}
	 *	  64:
	 */
	public static inline function createZigZagTable():ByteArray {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes( '\x00\x01\x05\x06\x0e\x0f\x1b\x1c\x02\x04\x07\x0d\x10\x1a\x1d\x2a\x03\x08\x0c\x11\x19\x1e\x29\x2b\x09\x0b\x12\x18\x1f\x28\x2c\x35\x0a\x13\x17\x20\x27\x2d\x34\x36\x14\x16\x21\x26\x2e\x33\x37\x3c\x15\x22\x25\x2f\x32\x38\x3b\x3d\x23\x24\x30\x31\x39\x3a\x3e\x3f' );
		bytes.position = 0;
		return bytes;
	}

	/**
	 *	   0:	0							[1]{1}
	 *	   1:	std_dc_luminance_nrcodes	[1]{16}
	 *	  17:	std_dc_luminance_values		[1]{12}
	 *	  29:	0							[1]{1}
	 *	  30:	std_ac_luminance_nrcodes	[1]{16}
	 *	  47:	std_ac_luminance_values		[1]{162}
	 *	 208:	0							[1]{1}
	 *	 209:	std_dc_chrominance_nrcodes	[1]{16}
	 *	 225:	std_dc_chrominance_values	[1]{12}
	 *	 237:	0							[1]{1}
	 *	 238:	std_ac_chrominance_nrcodes	[1]{16}
	 *	 254:	std_ac_chrominance_values	[1]{162}
	 *	 416:	YDC_HT						[1,2]{12}
	 *	 452:	YAC_HT						[1,2]{251}
	 *	1205:	UVDC_HT						[1,2]{12}
	 *	1241:	UVAC_HT						[1,2]{251}
	 *	1994:
	 */
	public static inline function createHuffmanTable():ByteArray {

		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.length = 1994;

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		var i:Int;
		var arr:Array<Int>;

		// std_dc_luminance_nrcodes
		tmp.position++;
		tmp.writeUTFBytes( '\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00'	);
		// std_dc_luminance_values
		tmp.writeUTFBytes( '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b'	);
		// std_ac_luminance_nrcodes
		tmp.position++;
		tmp.writeUTFBytes( '\x00\x02\x01\x03\x03\x02\x04\x03\x05\x05\x04\x04\x00\x00\x01\x7d'	);
		// std_ac_luminance_values
		arr = [ 0x00030201, 0x12051104, 0x06413121, 0x07615113, 0x32147122, 0x08a19181, 0xc1b14223, 0xf0d15215, 0x72623324, 0x160a0982, 0x1a191817, 0x28272625, 0x35342a29, 0x39383736, 0x4544433a, 0x49484746, 0x5554534a, 0x59585756, 0x6564635a, 0x69686766, 0x7574736a, 0x79787776, 0x8584837a, 0x89888786, 0x9493928a, 0x98979695, 0xa3a29a99, 0xa7a6a5a4, 0xb2aaa9a8, 0xb6b5b4b3, 0xbab9b8b7, 0xc5c4c3c2, 0xc9c8c7c6, 0xd4d3d2ca, 0xd8d7d6d5, 0xe2e1dad9, 0xe6e5e4e3, 0xeae9e8e7, 0xf4f3f2f1, 0xf8f7f6f5, 0x0000faf9 ];
		i = 0;
		do {
			Memory.setI32( 46 + ( i << 2 ), arr[ i ] );
		} while ( ++i < 41 );

		tmp.position = 208;
		// std_dc_chrominance_nrcodes
		tmp.position++;
		tmp.writeUTFBytes( '\x00\x03\x01\x01\x01\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00'	);
		// std_dc_chrominance_values
		tmp.writeBytes( tmp, 17, 12 );
		// std_ac_chrominance_nrcodes
		tmp.position++;
		tmp.writeUTFBytes( '\x00\x02\x01\x02\x04\x04\x03\x04\x07\x05\x04\x04\x00\x01\x02\x77'	);
		// std_ac_chrominance_values
		arr = [ 0x03020100, 0x21050411, 0x41120631, 0x71610751, 0x81322213, 0x91421408, 0x09c1b1a1, 0xf0523323, 0xd1726215, 0x3424160a, 0x17f125e1, 0x261a1918, 0x2a292827, 0x38373635, 0x44433a39, 0x48474645, 0x54534a49, 0x58575655, 0x64635a59, 0x68676665, 0x74736a69, 0x78777675, 0x83827a79, 0x87868584, 0x928a8988, 0x96959493, 0x9a999897, 0xa5a4a3a2, 0xa9a8a7a6, 0xb4b3b2aa, 0xb8b7b6b5, 0xc3c2bab9, 0xc7c6c5c4, 0xd2cac9c8, 0xd6d5d4d3, 0xdad9d8d7, 0xe5e4e3e2, 0xe9e8e7e6, 0xf4f3f2ea, 0xf8f7f6f5, 0x0000faf9 ];
		i = 0;
		do {
			Memory.setI32( 254 + ( i << 2 ), arr[ i ] );
		} while ( ++i < 41 );

		TMP.computeHuffmanTable(   0, 416 );	// YDC_HT
		TMP.computeHuffmanTable(  29, 452 );	// YAC_HT
		TMP.computeHuffmanTable( 208, 1205 );	// UVDC_HT
		TMP.computeHuffmanTable( 237, 1241 );	// UVAC_HT

		tmp.position = 0;
		Memory.memory = mem;

		return tmp;
	}

	/**
	 *	     0:	cat							[1,2]{65534}
	 *	196605:
	 */
	public static inline function createCategoryTable():ByteArray {

		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.length = 0xFFFF * 3;

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		var low:Int = 1;
		var upp:Int = 2;

		var p:UInt;
		var i:Int;
		var l:Int;
		var cat:UInt = 1;
		do {

			// Positive numbers
			i = low;
			l = upp;
			do {
				p = ( 32767 + i ) * 3;
				Memory.setByte( p, cat );
				Memory.setI16( p + 1, i );
			} while ( ++i < l );

			// Negative numbers
			i = - upp + 1;
			l = - low;
			do {
				p = ( 32767 + i ) * 3;
				Memory.setByte( p, cat );
				Memory.setI16( p + 1, upp - 1 + i );
			} while ( ++i <= l );

			low <<= 1;
			upp <<= 1;
		
		} while ( ++cat <= 15 );

		tmp.position = 0;
		Memory.memory = mem;

		return tmp;
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function computeHuffmanTable(toRead:UInt, toWrite:UInt):Void {

		var codeValue:Int = 0;
		var pos_in_table:Int = 0;

		var i:UInt;
		var j:UInt;
		var l:UInt;
		var p:UInt;

		i = 1;
		do {
	
			l = Memory.getByte( toRead + i );
			j = 1;
			while ( j <= l ) {

				p = toWrite + Memory.getByte( toRead + 17 + pos_in_table ) * 3;

				Memory.setByte( p , i );
				Memory.setI16( p + 1, codeValue );

				++pos_in_table;
				++codeValue;
				++j;

			}
	
			codeValue <<= 1;
	
		} while ( ++i <= 16 );
	}

}