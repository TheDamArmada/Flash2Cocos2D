////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils.memory;

import by.blooddy.utils.Char;
import by.blooddy.system.Memory;
import flash.Error;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class MemoryScanner {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function readCharCode(_position:UInt, ?single:Bool=true):UInt {
		if ( single ) {
			return Memory.getByte( _position++ );
		} else {
			var c:UInt = Memory.getByte( _position );
			if ( c >= 0x80 ) {
				if ( ( c & 0xF8 ) == 0xF0 ) {			// 4 bytes

					c =	( ( c                             & 0x7  ) << 18 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) << 12 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				} else if ( ( c & 0xF0 ) == 0xE0 ) {	// 3 bytes

					c =	( ( c                             & 0xF  ) << 12 ) |
						( ( Memory.getByte( ++_position ) & 0x3F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				} else if ( ( c & 0xE0 ) == 0xC0 ) {	// 2 bytes

					c =	( ( c                             & 0x1F ) <<  6 ) |
						(   Memory.getByte( ++_position ) & 0x3F         ) ;

				}
			}
			++_position;
			return c;
		}
	}

	public static inline function readChar(_position:UInt, ?single:Bool=true):String {
		return String.fromCharCode( readCharCode( _position, single ) );
	}

	public static inline function readIdentifier(memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var c:UInt = readCharCode( _position );
		if (
			( c < Char.a || c > Char.z ) &&
			( c < Char.A || c > Char.Z ) &&
			c != Char.DOLLAR &&
			c != Char.UNDER_SCORE &&
			c <= 0x7f
		) {
			_position = pos;
			return null;
		} else {
			do {
				c = readCharCode( _position ); // bug?
			} while (
				( c >= Char.a && c <= Char.z ) ||
				( c >= Char.A && c <= Char.Z ) ||
				( c >= Char.ZERO && c <= Char.NINE ) ||
				c == Char.DOLLAR ||
				c == Char.UNDER_SCORE ||
				c > 0x7f
			);
			--_position;
			c = _position - pos;
			if ( c == 1 ) {
				return String.fromCharCode( Memory.getByte( pos ) );
			} else {
				memory.position = pos;
				return memory.readUTFBytes( c );
			}
		}
	}
	
	public static inline function readString(memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		var to:UInt = readCharCode( _position );
		if ( to != Char.SINGLE_QUOTE && to != Char.DOUBLE_QUOTE ) {
			--_position;
			return null;
		} else {
			var p:UInt = pos + 1;
			var result:String = '';
			var c:UInt, t:String;
			while ( ( c = readCharCode( _position ) ) != to ) {
				if ( c == Char.BACK_SLASH ) {
					c = _position - 1 - p;
					if ( c == 1 ) {
						result += String.fromCharCode( Memory.getByte( p ) );
					} else if ( c > 0 ) {
						memory.position = p;
						result += memory.readUTFBytes( c );
					}
					c = readCharCode( _position );
					if		( c == Char.n )	result += '\n';
					else if	( c == Char.r )	result += '\r';
					else if	( c == Char.t )	result += '\t';
					else if	( c == Char.v )	result += '\x0B';
					else if	( c == Char.f )	result += '\x0C';
					else if	( c == Char.b )	result += '\x08';
					else if ( c == Char.BACK_SLASH || c == to ) {
						result += String.fromCharCode( c );
					} else if ( c == Char.u ) {
						t = readFixedHex( memory, _position, 4 );
						if ( t != null ) {
							result += String.fromCharCode( untyped __global__["parseInt"]( t, 16 ) );
						} else {
							--_position;
						}
					} else if	( c == Char.x ) {
						t = readFixedHex( memory, _position, 2 );
						if ( t != null ) {
							result += String.fromCharCode( untyped __global__["parseInt"]( t, 16 ) );
						} else {
							--_position;
						}
					} else {
						--_position;
					}
					p = _position;
				} else if (
					c == Char.EOS ||
					c == Char.CARRIAGE_RETURN ||
					c == Char.NEWLINE
				) {
					// откатываемся
					_position = pos;
					break;
				}
			}
			if ( _position == pos ) {
				return null;
			} else {
				c = _position - 1 - p;
				if ( c == 1 ) {
					result += String.fromCharCode( Memory.getByte( p ) );
				} else if ( c > 0 ) {
					memory.position = p;
					result += memory.readUTFBytes( c );
				}
				return result;
			}
		}
	}

	public static inline function readNumber(memory:ByteArray, _position:UInt):String {
		var result:String = null;
		var pos:UInt = _position;
		var c:UInt = readCharCode( _position );
		var p:UInt;
		if ( c == Char.ZERO ) {
			c = readCharCode( _position );
			if ( c == Char.x || c == Char.X ) {	// hex
				p = _position;
				do {
					c = readCharCode( _position );
				} while (
					( c >= Char.ZERO && c <= Char.NINE ) ||
					( c >= Char.a && c <= Char.f ) ||
					( c >= Char.A && c <= Char.F )
				);
				if ( _position == p + 1 ) {
					_position = pos + 1;
					c = Char.ZERO;
				} else {
					--_position;
					c = _position - p;
					if ( c == 1 ) {
						result = String.fromCharCode( Memory.getByte( p ) );
					} else {
						memory.position = p;
						result = memory.readUTFBytes( c );
					}
					result = untyped __global__["parseInt"]( result, 16 );
				}
			} else {
				--_position;
				c = Char.ZERO;
			}
		}
		if ( result == null ) { // не hex
			while ( c >= Char.ZERO && c <= Char.NINE ) {
				c = readCharCode( _position );
			}
			if ( c == Char.DOT ) { // float
				do {
					c = readCharCode( _position );
				} while ( c >= Char.ZERO && c <= Char.NINE );
				if ( _position == pos + 2 ) {
					--_position;
					c = Char.DOT;
				}
			}
			if ( c == Char.e || c == Char.E ) { // exp
				var pp:UInt = _position;
				c = readCharCode( _position );
				if ( c == Char.DASH || c == Char.PLUS ) { // expsing
					c = readCharCode( _position );
				}
				p = _position;
				while ( c >= Char.ZERO && c <= Char.NINE ) {
					c = readCharCode( _position );
				}
				if ( _position == p ) {
					_position = pp;
				}
			}
			--_position;
			c = _position - pos;
			if ( c == 1 ) {
				result = String.fromCharCode( Memory.getByte( pos ) );
			} else if ( c > 0 ) {
				memory.position = pos;
				result = memory.readUTFBytes( c );
			}
		}
		return result;
	}

	public static inline function skipBlockComment(_position:UInt):Void {
		var pos:UInt = _position;
		if (
			readCharCode( _position ) != Char.SLASH ||
			readCharCode( _position ) != Char.ASTERISK
		) {
			_position = pos;
		} else {
			var c:UInt;
			do {
				c = readCharCode( _position );
				if ( c == Char.ASTERISK ) {
					if ( readCharCode( _position ) == Char.SLASH ) {
						break;
					} else {
						--_position;
					}
				} else if ( c == Char.EOS ) {
					_position = pos;
					break;
				}
			} while ( true );
		}
	}

	public static inline function readBlockComment(memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		skipBlockComment( _position );
		if ( pos == _position ) {
			return null;
		} else {
			memory.position = pos + 2;
			return memory.readUTFBytes( _position - 4 - pos );
		}
	}

	public static inline function skipLine(_position:UInt):Void {
		var c:UInt;
		do {
			c = readCharCode( _position );
		} while ( c != Char.NEWLINE && c != Char.CARRIAGE_RETURN && c != Char.EOS );
		--_position;
	}

	public static inline function readLine(memory:ByteArray, _position:UInt):String {
		var pos:UInt = _position;
		skipLine( _position );
		memory.position = pos;
		return memory.readUTFBytes( _position - pos );
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function readFixedHex(memory:ByteArray, _position:UInt, length:UInt):String {
		var c:UInt;
		var i:UInt = 0;
		do {
			c = MemoryScanner.readCharCode( _position );
			if (
				( c < Char.ZERO || c > Char.NINE ) &&
				( c < Char.a || c > Char.f ) &&
				( c < Char.A || c > Char.F )
			) {
				break;
			}
		} while ( ++i < length );
		if ( i != length ) {
			_position -= i + 1;
			return null;
		} else {
			memory.position = _position - length;
			return memory.readUTFBytes( length );
		}
	}

	///**
	 //* @private
	 //*/
	//public static inline function readTo(...to):String {
		//var pos:uint = this._position;
		//var c:uint;
		//do {
			//c = this.readCharCode();
			//switch ( c ) {
				//case Char.CARRIAGE_RETURN:
				//case Char.NEWLINE:
					//break;
			//}
			//if ( to.indexOf( c ) >= 0 ) {
				//--this._position;
				//return this._source.substring( pos, this._position );
			//}
		//} while ( c != Char.EOS );
		//this._position = pos;
		//return null;
	//}
	
}