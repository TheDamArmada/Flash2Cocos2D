////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils;

import by.blooddy.system.Memory;
import by.blooddy.utils.IntUtils;
import flash.Error;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class ByteArrayUtils {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function createByteArray(length:UInt):ByteArray {
		var result:ByteArray = new ByteArray();
		result.length = length;
		return result;
	}

	public static inline function equals(b1:ByteArray, b2:ByteArray):Bool {
		var l:UInt = b1.length;
		var result:Bool = true;
		if ( l == b2.length ) {
			var mem:ByteArray = Memory.memory;
			var tmp:ByteArray = new ByteArray();
			tmp.writeBytes( b1 );
			tmp.writeBytes( b2 );
			if ( l + l < Memory.MIN_SIZE ) {
				tmp.length = Memory.MIN_SIZE;
			}
			Memory.memory = tmp;
			var e:UInt = l - ( l & 3 );
			var i:UInt = 0;
			do {
				if ( Memory.getI32( i ) != Memory.getI32( l + i ) ) {
					result = false;
					break;
				}
				i += 4;
			} while ( i < e );
			if ( result ) {
				while ( i < l ) {
					if ( Memory.getByte( i ) != Memory.getByte( l + i ) ) {
						result = false;
						break;
					}
					++i;
				}
			}
			Memory.memory = mem;
		} else {
			result = false;
		}
		return result;
	}

	public static inline function indexOfByte(bytes:ByteArray, value:UInt, ?startIndex:UInt=0):Int {
		if ( value > 0xFF ) {
			Error.throwError( RangeError, 0 );
		}
		var l:UInt = bytes.length;
		var result:Int = -1;
		if ( l - startIndex > 0 ) {
			var mem:ByteArray = Memory.memory;
			if ( l < Memory.MIN_SIZE ) {
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( bytes );
				tmp.length = Memory.MIN_SIZE;
				Memory.memory = tmp;
			} else {
				Memory.memory = bytes;
			}
			var i:UInt = startIndex;
			do {
				if ( Memory.getByte( i ) == value ) {
					result = i;
					break;
				}
			} while ( ++i < l );
			Memory.memory = mem;
		}
		return result;
	}

	public static inline function indexOfBytes(bytes:ByteArray, value:ByteArray, ?startIndex:UInt = 0):Int {
		var result:Int = -1;
		var m:UInt = value.length;
		var n:UInt = bytes.length;
		if ( m > 0 && startIndex < n ) {
			if ( m == 1 ) {
				result = indexOfByte( bytes, value[ 0 ], startIndex );
			} else {
				var mem:ByteArray = Memory.memory;
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( value );
				tmp.writeBytes( bytes );
				if ( tmp.length < Memory.MIN_SIZE ) {
					tmp.length = Memory.MIN_SIZE;
				}
				Memory.memory = tmp;
				var l:UInt = n + 1;
				var i:UInt = m + startIndex;
				var j:UInt;
				var byte:UInt = Memory.getByte( 0 );
				do {
					if ( Memory.getByte( i ) == byte ) {
						j = 1;
						do {
							if ( Memory.getByte( i + j ) != Memory.getByte( j ) ) break;
						} while ( ++j < m );
						if ( j == m ) {
							result = i - j;
							break;
						}
					}
				} while ( ++i < l );
				Memory.memory = mem;
			}
		}
		return result;
	}

	public static inline function isUTFString(bytes:ByteArray):Bool {
		var l:UInt = bytes.length;
		var result:Bool = true;
		if ( l > 0 ) {
			var mem:ByteArray = Memory.memory;
			if ( l < Memory.MIN_SIZE ) {
				var tmp:ByteArray = new ByteArray();
				tmp.writeBytes( bytes );
				tmp.length = Memory.MIN_SIZE;
				Memory.memory = tmp;
			} else {
				Memory.memory = bytes;
			}
			var c:UInt;
			var i:UInt = (
				Memory.getByte( 0 ) == 0xEF &&
				Memory.getByte( 1 ) == 0xBB &&
				Memory.getByte( 2 ) == 0xBF
				?	3
				:	0
			);
			do {
				c = Memory.getByte( i );
				if (
					c == 0x00 ||
					c >= 0xF5 ||
					c == 0xC0 ||
					c == 0xC1
				) {
					result = false;
					break;
				}
			} while ( ++i < l );
			Memory.memory = mem;
		}
		return result;
	}

	public static function dump(bytes:ByteArray, offset:UInt=0, length:UInt=0):String {

		var mem:ByteArray = Memory.memory;

		offset = IntUtils.min( offset, bytes.length );
		if ( offset >= bytes.length ) return '';
		length = (
			length == 0
			?	bytes.length - offset
			:	IntUtils.min( length, bytes.length - offset )
		);

		var rest:UInt = length & 15;

		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( '0123456789ABCDEF' );
		tmp.writeBytes( bytes, offset, length );
		tmp.length += ( ( length >> 4 ) + ( rest == 0 ? 0 : 1 ) ) * 80;
		length += 16;
		if ( tmp.length < Memory.MIN_SIZE ) {
			tmp.length = Memory.MIN_SIZE;
		}
		Memory.memory = tmp;
		
		var i:UInt = 16;
		var j:UInt = length;

		var k:UInt;
		var v:UInt;
		var len:UInt;
		var len2:UInt;

		do {

			Memory.fill2( j, 80, 0x20 );

			v = i - 16;
			
			if ( v < TMP.MASK1 ) Memory.setI32( j,     0x30303030 );
			if ( v < TMP.MASK2 ) Memory.setI32( j + 4, 0x30303030 );

			j += 8;
			if ( v > 0 ) {

				k = j;
				do {
					Memory.setByte( --k, Memory.getByte( v & 0xF ) );
					v >>>= 4;
				} while ( v > 0 );
			}

			Memory.setI16( j, 0x203A );
			j += 2;

			k = j + 50;

			Memory.setByte( k++, 0x7C );

			len2 = i + 8;
			len = IntUtils.min( len2, length );
			while ( i < len ) {
				v = Memory.getByte( i++ );
				Memory.setByte( j++, Memory.getByte( v >> 4 ) );
				Memory.setByte( j++, Memory.getByte( v & 0xF ) );
				Memory.setByte( j++, 0x20 );
				Memory.setByte( k++, v < 32 || v > 126 ? 0x2E : v );
			}
			while ( i < len2 ) {
				i++;
				Memory.setI16( j, 0x2020 );
				j += 2;
				Memory.setByte( j++, 0x20 );
				Memory.setByte( k++, 0x20 );
			}
			Memory.setByte( j++, 0x20 );
			len2 = i + 8;
			len = IntUtils.min( len2, length );
			while ( i < len ) {
				v = Memory.getByte( i++ );
				Memory.setByte( j++, Memory.getByte( v >> 4 ) );
				Memory.setByte( j++, Memory.getByte( v & 0xF ) );
				Memory.setByte( j++, 0x20 );
				Memory.setByte( k++, v < 32 || v > 126 ? 0x2E : v );
			}
			while ( i < len2 ) {
				i++;
				Memory.setI16( j, 0x2020 );
				j += 2;
				Memory.setByte( j++, 0x20 );
				Memory.setByte( k++, 0x20 );
			}
			Memory.setByte( j++, 0x20 );

			Memory.setByte( k++, 0x7C );
			
			j += 18;
			Memory.setByte( j++, 0x0A );
			
		} while ( i < length );

		Memory.memory = mem;
		
		tmp.position = length;

		return tmp.readUTFBytes( j - length - 1 );

	}

}

private class TMP {

	public static inline var MASK1:UInt = 0xFFFFFFFF;
	public static inline var MASK2:UInt = 0x0000FFFF;

}