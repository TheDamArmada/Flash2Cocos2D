////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.compression;

import by.blooddy.system.Memory;
import by.blooddy.utils.IntUtils;
import flash.Error;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Deflate {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function compress(bytes:ByteArray):ByteArray {
		var result:ByteArray = new ByteArray();
		result.writeBytes( bytes );
		result.compress();
		result.position = 2;
		result.readBytes( result, 0, result.length - 6 ); // remove 2-byte header and last 4-byte addler32 checksum
		result.length -= 6;
		result.position = 0;
		return result;
	}

	public static function decompress(bytes:ByteArray):ByteArray {
		var T:Float = Lib.getTimer();
		var mem:ByteArray = Memory.memory;

		var tmp:ByteArray = new ByteArray();
		tmp.writeBytes( DeflateTable.getDecodeTable() );
		tmp.writeBytes( bytes );

		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		var _tmpLen:UInt = tmp.length;
		
		var inStart:UInt = 177;
		var _inPos:UInt = inStart;
		var _inLen:UInt = inStart + bytes.length;

		var outStart:UInt = _inLen;

		var _tblLensPos:UInt = outStart;
		var _tblDistPos:UInt = 0;
		var tblLen:UInt;

		var tmpStart:UInt = 0;
		var _tmpPos:UInt;

		var _bitbuf:Int = 0;
		var _bitcnt:Int = 0;

		var fixedTable:ByteArray = null;

		var last:Int;
		var type:Int;

		var symbol:UInt;
		var len:UInt = 0;
		var dist:UInt;
		var d:Int;

		do { // process blocks until last block or error

			last = TMP.bits( _inPos, _inLen, _bitbuf, _bitcnt, 1 ); // one if last block
			type = TMP.bits( _inPos, _inLen, _bitbuf, _bitcnt, 2 ); // block type 0..3

			if ( type >= 3 ) {
				Error.throwError( RangeError, 0 );
				//throw new Error('invalid block type (type == 3)', -1);
			} else if ( type >= 1 ) { // compressed block

				// create table
				if ( type == 1 ) {
					if ( fixedTable == null ) fixedTable = DeflateTable.getFixedTable();
					tmp.position = _tblLensPos;
					tmp.writeBytes( fixedTable );
					if ( tmp.position >= _tmpLen ) {
						tmp.length =
						_tmpLen = tmp.length;
					}
					_tblDistPos = _tblLensPos + 1216;
					tmpStart = tmp.position;
				} else {
					tmpStart = TMP.createDynamicTable( tmp, _tmpLen, _inPos, _inLen, _bitbuf, _bitcnt, _tblLensPos, _tblDistPos );
				}
				_tmpPos = tmpStart;
				tblLen = tmpStart - _tblLensPos;

				// decode data until end-of-block code
				// decode literals and length/distance pairs
				do {
					symbol = TMP.decode( _inPos, _inLen, _bitbuf, _bitcnt, _tblLensPos );
					if ( symbol < 256 ) {	// literal: symbol is the byte
						TMP.updateBytesSize( tmp, _tmpLen, _tmpPos );
						Memory.setByte( _tmpPos++, symbol );
					} else if ( symbol > 256 ) {	// length
						// get and compute length
						symbol -= 257;
						if ( symbol >= 29 ) {
							Error.throwError( RangeError, 0 );
							//throw new Error("invalid literal/length or distance code in fixed or dynamic block", -9);
						}
						len = Memory.getUI16( TMP.LENS + ( symbol << 1 ) ) + TMP.bits( _inPos, _inLen, _bitbuf, _bitcnt, Memory.getByte( TMP.LEXT + symbol ) );	// length for copy
						// get and check distance
						symbol = TMP.decode( _inPos, _inLen, _bitbuf, _bitcnt, _tblDistPos );
						dist = Memory.getUI16( TMP.DISTS + ( symbol << 1 ) ) + TMP.bits( _inPos, _inLen, _bitbuf, _bitcnt, Memory.getByte( TMP.DEXT + symbol ) );	// distance for copy
						if ( dist > _tblLensPos - outStart + _tmpPos - tmpStart ) {
							Error.throwError( RangeError, 0 );
							//throw new Error("distance is too far back in fixed or dynamic block", -10);
						}
						// copy length bytes from distance bytes back
						d = dist - _tmpPos + tmpStart;
						if ( d > 0 ) {
							d = IntUtils.min( d, len );
							TMP.shiftBytes( tmp, _tmpLen, _tmpPos, tblLen + dist, d );
							_tmpPos += d;
							len -= d;
						}
						if ( len > 0 ) {
							TMP.shiftBytes( tmp, _tmpLen, _tmpPos, dist, len );
							_tmpPos += len;
						}
					}
				} while ( symbol != 256 ); // end of block symbol

				// move tmp to out
				len = _tmpPos - tmpStart;

			} else {

				// uncompressed block
				// discard leftover bits from current byte (assumes s->bitcnt < 8)
				_bitbuf = 0;
				_bitcnt = 0;
				// get length and check against its one's complement
				if ( _inPos + 4 > _inLen ) {
					Error.throwError( RangeError, 0 );
					//throw new Error('available inflate data did not terminate', 2);
				}
				len = Memory.getUI16( _inPos ); // length of stored block
				_inPos += 2;
				if ( // TODO: optimize to getUI16
					Memory.getByte( _inPos++ ) !=         (   ~len        & 0xFF ) ||
					Memory.getByte( _inPos++ ) != untyped ( ( ~len >> 8 ) & 0xFF )
				) {
					Error.throwError( RangeError, 0 );
					//throw new Error("stored block length did not match one's complement", -2);
				}
				if ( _inPos + len > _inLen ) {
					Error.throwError( RangeError, 0 );
					//throw new Error('available inflate data did not terminate', 2);
				}

				tmpStart = _inPos;
				_inPos += len;

			}

			TMP.copyBytes( tmp, _tmpLen, tmpStart, _tblLensPos, len );
			_tblLensPos += len;

		} while ( last == 0 );

		Memory.memory = mem;
		
		var result:ByteArray = new ByteArray();
		result.writeBytes( tmp, outStart, _tblLensPos - outStart );
		result.position = 0;

		return result;
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

	public static inline var LENS:UInt =	0;
	public static inline var LEXT:UInt =	58;
	public static inline var DISTS:UInt =	87;
	public static inline var DEXT:UInt =	147;

	private static inline var MAXBITS:UInt =	15;						// maximum bits in a code
	private static inline var MAXLCODES:UInt =	286;					// maximum number of literal/length codes
	private static inline var MAXDCODES:UInt =	30;						// maximum number of distance codes

	public static inline var MAXBITSLEN:UInt =	( MAXBITS + 1 ) << 2;

	private static inline var Z1:UInt =	MAXBITS + 19;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function updateBytesSize(tmp:ByteArray, _tmpLen:UInt, pos:UInt):Void {
		if ( _tmpLen - pos < 2048 ) {
			_tmpLen += 4096;
			tmp.length = _tmpLen;
		}
	}

	public static inline function copyBytes(tmp:ByteArray, _tmpLen, from:UInt, to:UInt, len:UInt):Void {
		if ( len <= 4 ) {
			updateBytesSize( tmp, _tmpLen, to + len );
			if ( len == 1 ) {
				Memory.setByte( to, Memory.getByte( from ) );
			} else if ( len == 2 ) {
				Memory.setI16( to, Memory.getUI16( from ) );
			} else if ( len == 3 ) {
				Memory.setByte( to, Memory.getByte( from ) );
				Memory.setI16( to + 1, Memory.getUI16( from + 1 ) );
			} else {
				Memory.setI32( to, Memory.getI32( from ) );
			}
		} else {
			tmp.position = from;
			tmp.readBytes( tmp, to, len );
			if ( tmp.length >= _tmpLen ) {
				tmp.length =
				_tmpLen = tmp.length;
			}
		}
	}

	public static inline function shiftBytes(tmp:ByteArray, _tmpLen, to:UInt, dist:UInt, len:UInt):Void {
		if ( dist >= len ) {
			copyBytes( tmp, _tmpLen, to - dist, to, len );
		} else {
			var len2:UInt = len + to;
			updateBytesSize( tmp, _tmpLen, len2 );
			do {
				Memory.setByte( to, Memory.getByte( to - dist ) );
			} while ( ++to < len2 );
		}
	}

	public static inline function bits(_inPos:UInt, _inLen:UInt, _bitbuf:Int, _bitcnt:Int, need:UInt):Int {
		// bit accumulator (can use up to 20 bits)
		// load at least need bits into val
		var val:Int = _bitbuf;
		while ( _bitcnt < need ) {
			if ( _inPos >= _inLen ) {
				Error.throwError( RangeError, 2 );
				//throw new Error('available inflate data did not terminate', 2);
			}
			val |= Memory.getByte( _inPos++ ) << _bitcnt; // load eight bits
			_bitcnt += 8;
		}
		// drop need bits and update buffer, always zero to seven bits left
		_bitbuf = val >> need;
		_bitcnt -= need;
		// return need bits, zeroing the bits above that
		return val & ( ( 1 << need ) - 1 );
	}

	public static inline function decode(_inPos:UInt, _inLen:UInt, _bitbuf:Int, _bitcnt:Int, tpos:UInt, ?check:Bool=true):Int {
		var result:Int = -1; // ran out of codes
		var code:Int = 0; // len bits being decoded
		var first:Int = 0; // first code of length len
		var index:Int = 0; // index of first code of length len in symbol table
		var count:Int;
		var i:UInt = tpos + 4; // current number of bits in code
		var len:UInt = i + MAXBITSLEN;
		do {
			code |= bits( _inPos, _inLen, _bitbuf, _bitcnt, 1 ); // get next bit
			count = Memory.getI32( i ); // number of codes of length len
			// if length len, return symbol
			if ( code < first + count ) {
				result = Memory.getI32( tpos + MAXBITSLEN + ( ( index + code - first ) << 2 ) );
				break;
			}
			index += count; // else update for next length
			first += count;
			first <<= 1;
			code <<= 1;
			i += 4;
		} while ( i < len );
		if ( check && result < 0 ) {
			Error.throwError( RangeError, 0 );
		}
		return result;
	}

	public static inline function createDynamicTable(tmp:ByteArray, _tmpLen:UInt, _inPos:UInt, _inLen:UInt, _bitbuf:Int, _bitcnt:Int, _tblLensPos:UInt, _tblDistPos:UInt):UInt {

		// get number of lengths in each table, check lengths
		var nlen:Int = bits( _inPos, _inLen, _bitbuf, _bitcnt, 5 ) + 257;
		if ( nlen > MAXLCODES ) {
			Error.throwError( RangeError, -3 );
		}
		var ndist:Int = bits( _inPos, _inLen, _bitbuf, _bitcnt, 5 ) + 1;
		if ( ndist > MAXDCODES ) {
			Error.throwError( RangeError, -3 );
			//throw new Error( "dynamic block code description: too many length or distance codes", -3 );
		}

		// permutation of code length codes
		tmp.position = _tblLensPos;
		tmp.writeUTFBytes( '\x40\x44\x48\x00\x20\x1c\x24\x18\x28\x14\x2c\x10\x30\x0c\x34\x08\x38\x04\x3c' ); // order
		if ( tmp.position >= _tmpLen ) {
			tmp.length =
			_tmpLen = tmp.length;
		}

		var i:UInt;
		var s:UInt;

		// read code length code lengths (really), missing lengths are zero
		// descriptor code lengths
		s = _tblLensPos + 19;
		updateBytesSize( tmp, _tmpLen, s + ( 19 << 2 ) );
		Memory.fill2( s, ( 19 << 2 ) );
		i = _tblLensPos;
		var ncode:Int = _tblLensPos + bits( _inPos, _inLen, _bitbuf, _bitcnt, 4 ) + 4; // number of lengths in descriptor
		do {
			Memory.setI32(
				s + Memory.getByte( i ),
				bits( _inPos, _inLen, _bitbuf, _bitcnt, 3 )
			);
		} while ( ++i < ncode );

		// build huffman table for code lengths codes (use lencode temporarily)
		var tpos:UInt = s + ( 19 << 2 );
		var tlen:UInt = construct( tmp, _tmpLen, s, tpos, 19, false );

		// read length / literal and distance code length tables
		var symbol:Int;	// decoded value
		var length:Int;	// last length to repeat
		i = tlen;
		var len:UInt = i + ( ( nlen + ndist ) << 2 );
		while ( i < len ) {
			symbol = decode( _inPos, _inLen, _bitbuf, _bitcnt, tpos, false );
			if ( symbol < 16 ) { // length in 0..15
				updateBytesSize( tmp, _tmpLen, i );
				Memory.setI32( i, symbol );
				i += 4;
			} else { // repeat instruction
				length = 0; // assume repeating zeros
				if ( symbol == 16 ) { // repeat last length 3..6 times
					if ( i == 0 ) {
						Error.throwError( RangeError, -5 );
						//throw new Error("dynamic block code description: repeat lengths with no first length", -5);
					}
					length = Memory.getI32( i - 4 ); // last length
					symbol = 3 + bits( _inPos, _inLen, _bitbuf, _bitcnt, 2 );
				} else if ( symbol == 17 ) {
					symbol = 3 + bits( _inPos, _inLen, _bitbuf, _bitcnt, 3 ); // repeat zero 3..10 times
				} else {
					symbol = 11 + bits( _inPos, _inLen, _bitbuf, _bitcnt, 7 ); // == 18, repeat zero 11..138 times
				}
				if ( i + ( symbol << 2 ) > len ) {
					Error.throwError( RangeError, -6 );
					//throw new Error("dynamic block code description: repeat more than specified lengths", -6);
				}
				s = i + ( symbol << 2 );
				updateBytesSize( tmp, _tmpLen, s );
				while ( i < s ) {
					Memory.setI32( i, length ); // repeat last or zero symbol times
					i += 4;
				}
			}
		}
		// build huffman table for literal/length codes
		_tblDistPos = construct( tmp, _tmpLen, tlen, i, nlen );
		// build huffman table for distance codes
		len = construct( tmp, _tmpLen, tlen + ( nlen << 2 ), _tblDistPos, ndist );

		tmp.position = i;
		tmp.readBytes( tmp, _tblLensPos, len - i );

		// correct offset
		_tblDistPos += _tblLensPos - i;
		len += _tblLensPos - i;

		return len;

	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function construct(tmp:ByteArray, _tmpLen:UInt, lens:UInt, out:UInt, n:UInt, ?check:Bool=true):UInt {
		// count number of codes of each length
		var s:UInt = out + MAXBITSLEN;
		var o:UInt = s + ( n << 2 );
		Memory.fill( out, o + MAXBITSLEN );
		// assumes lengths are within bounds
		var k:UInt;
		var i:UInt = lens;
		var len:Int = i + ( n << 2 );
		updateBytesSize( tmp, _tmpLen, len );
		do {
			k = out + ( Memory.getI32( i ) << 2 );
			Memory.setI32(
				k,
				Memory.getI32( k ) + 1
			);
			i += 4;
		} while ( i < len );

		// no codes! complete, but decode() will fail
		if ( Memory.getI32( out ) != n ) {

			// check for an over-subscribed or incomplete set of lengths
			var left:Int = 1; // one possible code of zero length
			i = out + 4;
			do {
				left <<= 1; // one more bit, double codes left
				left -= Memory.getI32( i ); // deduct count from possible codes
				if ( left < 0 ) {
					// over-subscribed--return negative
					Error.throwError( RangeError, 0 );
				}
				i += 4;
			} while ( i < s ); // left > 0 means incomplete

			// only allow incomplete codes if just one code
			if ( check && ( left > 0 && n - Memory.getI32( out ) != 1 ) ) {
				Error.throwError( RangeError, -7 );
				//throw new Error("dynamic block code description: invalid literal/length code lengths", -7);
			}

			// generate offsets into symbol table for each length for sorting
			updateBytesSize( tmp, _tmpLen, o + MAXBITSLEN + 4 );
			i = 4;
			do {
				Memory.setI32(
					o + i + 4,
					Memory.getI32( o + i ) + Memory.getI32( out + i )
				);
				i += 4;
			} while ( i < MAXBITSLEN );
			// put symbols in table sorted by length, by symbol order within each length
			var c:UInt;
			i = 0;
			len = -1;
			do {
				k = Memory.getI32( lens + ( i << 2 ) );
				if ( k != 0 ) {
					k = o + ( k << 2 );
					updateBytesSize( tmp, _tmpLen, k );
					c = Memory.getI32( k );
					if ( len < c ) len = c;
					Memory.setI32( s + ( c << 2 ), i );
					Memory.setI32( k, c + 1 );
				};
			} while ( ++i < n );
			// put length
			len = ( len + 1 ) << 2;

		} else {

			len = 0;

		}
		return out + MAXBITSLEN + len;
	}

}