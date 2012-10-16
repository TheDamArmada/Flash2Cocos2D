////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization;

import by.blooddy.system.Memory;
import by.blooddy.utils.Char;
import by.blooddy.utils.memory.MemoryScanner;
import flash.Error;
import flash.errors.StackOverflowError;
import flash.Lib;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;
import flash.Vector;
import flash.xml.XML;
import flash.xml.XMLDocument;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JSON {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(value:Dynamic):String {

		var set:Object = XML.settings();
		XML.setSettings( {
			ignoreComments: true,
			ignoreProcessingInstructions: false,
			ignoreWhitespace: true,
			prettyIndent: false,
			prettyPrinting: false
		} );

		// помещаем в пямять
		var tmp:ByteArray = new ByteArray();
		tmp.writeUTFBytes( '0123456789abcdef' );

		var bytes:ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;

		var cvint:Class<Vector<Int>> = untyped __as__( new Vector<Int>(), Object ).constructor;
		var cvuint:Class<Vector<UInt>> = untyped __as__( new Vector<UInt>(), Object ).constructor;
		var cvdouble:Class<Vector<Float>> = untyped __as__( new Vector<Float>(), Object ).constructor;
		var cvobject:Class<Vector<Dynamic>> = untyped __as__( new Vector<Dynamic>(), Object ).constructor;

		var writeValue:Dictionary->ByteArray->ByteArray->Dynamic->Dynamic = null;

		writeValue = function(hash:Dictionary, bytes:ByteArray, tmp:ByteArray, value:Dynamic):Dynamic {
			var t:String = untyped __typeof__( value );
			if ( t == 'number' ) {
				TMP.writeNumber( bytes, value );
			} else if ( t == 'boolean' ) {
				TMP.writeBoolean( bytes, value );
			} else {
				if ( t == 'xml' ) {
					value = value.toXMLString();
					t = 'string';
				} else if ( value && t == 'object' ) {
					if ( untyped __is__( value, XMLDocument ) ) {
						if ( value.childNodes.length > 0 ) {
							value = ( new XML( value ) ).toXMLString();
							t = 'string';
						} else {
							TMP.writeStringEmpty( bytes );
						}
					} else {

						if ( untyped __in__( value, hash ) ) {
							Error.throwError( StackOverflowError, 2024 );
						}
						hash[ value ] = true;

						var i:Int = 0;
						var l:Int;
						if (
							( untyped __is__( value, Array ) ) ||
							( untyped __is__( value, cvobject ) )
						) {

							bytes.writeByte( Char.LEFT_BRACKET );	// [
							l = untyped value.length - 1;
							while ( l >= 0 && value[ l ] == null ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								writeValue( hash, bytes, tmp, value[ 0 ] );
								while ( ++i < l ) {
									bytes.writeByte( Char.COMMA );	// ,
									writeValue( hash, bytes, tmp, value[ i ] );
								}
							}
							bytes.writeByte( Char.RIGHT_BRACKET );	// ]

						} else if (
							( untyped __is__( value, cvint ) ) ||
							( untyped __is__( value, cvuint ) )
						) {

							bytes.writeByte( Char.LEFT_BRACKET );	// [
							l = value.length;
							if ( l > 0 ) {
								TMP.writeFiniteNumber( bytes, value[ 0 ] );
								while ( ++i < l ) {
									bytes.writeByte( Char.COMMA );	// ,
									TMP.writeFiniteNumber( bytes, value[ i ] );
								}
							}
							bytes.writeByte( Char.RIGHT_BRACKET );	// ]

						} else if (
							( untyped __is__( value, cvdouble ) )
						) {

							bytes.writeByte( Char.LEFT_BRACKET );	// [
							l = untyped value.length - 1;
							while ( l >= 0 && !untyped __global__["isFinite"]( value[ l ] ) ) {
								--l;
							}
							++l;
							if ( l > 0 ) {
								TMP.writeNumber( bytes, value[ 0 ] );
								while ( ++i < l ) {
									bytes.writeByte( Char.COMMA );	// ,
									TMP.writeNumber( bytes, value[ i ] );
								}
							}
							bytes.writeByte( Char.RIGHT_BRACKET );	// ]

						} else {

							bytes.writeByte( Char.LEFT_BRACE );	// {

							var n:String;
							var f:Bool = false;
							var arr:Array<Dynamic>;
							var v:Dynamic = null;

							if ( value.constructor != Object ) {

								if ( untyped __is__( value, Dictionary ) ) {
									arr = untyped __keys__( value );
									l = arr.length;
									i = 0;
									while ( i < l ) {
										v = untyped __typeof__( arr[ i ] );
										if (
											v != 'string' &&
											v != 'number'
										) {
											Error.throwError( TypeError, 0 );
										}
										++i;
									}
								}

								var h:Bool;
								
								arr = SerializationHelper.getPropertyNames( value );
								l = arr.length;
								i = 0;
								while ( i < l ) {
									n = arr[ i ];
									try {
										v = value[ untyped n ];
										h = true;
									} catch ( e:Dynamic ) {
										h = false;
										// skip
									}
									if ( h ) {
										if ( f )	bytes.writeByte( Char.COMMA );	// ,
										else		f = true;
										TMP.writeString( bytes, tmp, n );
										bytes.writeByte( Char.COLON );	// :
										writeValue( hash, bytes, tmp, v );
									}
									++i;
								}

							}

							arr = untyped __keys__( value );
							l = arr.length;
							i = 0;
							while ( i < l ) {
								n = arr[ i ];
								v = value[ untyped n ];
								if ( !( untyped __is__( v, Function ) ) ) {
									if ( f )	bytes.writeByte( Char.COMMA );	// ,
									else		f = true;
									TMP.writeString( bytes, tmp, n );
									bytes.writeByte( Char.COLON );	// :
									writeValue( hash, bytes, tmp, v );
								}
								++i;
							}
							
							bytes.writeByte( Char.RIGHT_BRACE );	// }

						}

						untyped __delete__( hash, value );
						
					}
				}
				if ( t == 'string' ) {
					TMP.writeString( bytes, tmp, value );
				} else if ( !value ) {
					TMP.writeNull( bytes );
				}
			}

		}

		writeValue( new Dictionary(), bytes, tmp, value );

		XML.setSettings( set );

		var len:UInt = bytes.position;
		bytes.position = 0;
		return bytes.readUTFBytes( len );

	}
	
	public static function decode(value:String):Dynamic {

		if ( value == null ) Error.throwError( TypeError, 2007, 'value' );

		var result:Dynamic = untyped __global__["undefined"];

		if ( value.length > 0 ) {

			var mem:ByteArray = Memory.memory;

			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes( value );
			tmp.writeByte( 0 ); // EOF
			// помещаем в пямять
			if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
			Memory.memory = tmp;

			var _position:UInt = 0;

			var c:UInt = TMP.readNotSpaceCharCode( _position );
			if ( c != Char.EOS ) {

				var position:UInt = _position - 1;
				
				var readValue:ByteArray->UInt->Dynamic = null;

				readValue = function(memory:ByteArray, _position:UInt):Dynamic {

					var t:String;
					var pos:UInt;
					var c:UInt;
					var result:Dynamic = untyped __global__["undefined"];

					c = TMP.readNotSpaceCharCode( _position );
					if ( c == Char.SINGLE_QUOTE || c == Char.DOUBLE_QUOTE ) {	// String

						--_position;
						t = MemoryScanner.readString( memory, _position );
						if ( t != null ) {
							result = t;
						} else {
							TMP.throwError();
						}

					} else if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DOT ) {	// Number

						--_position;
						t = MemoryScanner.readNumber( memory, _position );
						if ( t != null ) {
							result = untyped __global__["parseFloat"]( t );
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.DASH ) {	// Number

						c = TMP.readNotSpaceCharCode( _position );
						if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DOT ) {
							--_position;
							t = MemoryScanner.readNumber( memory, _position );
							if ( t != null ) {
								result = -( untyped __global__["parseFloat"]( t ) );
							} else {
								TMP.throwError();
							}
						} else if ( c == Char.n ) {
							if (
								Memory.getByte( _position ) ==		  0x75 &&	// u
								Memory.getUI16( _position + 1 ) ==	0x6C6C		// ll
							) {
								_position += 3;
								result = 0;
							} else {
								TMP.throwError();
							}
						} else if ( c == Char.u ) {
							if (
								Memory.getI32( _position ) ==		0x6665646E &&	// ndef
								Memory.getI32( _position + 4 ) ==	0x64656E69		// ined
							) {
								_position += 8;
								result = untyped __global__["Number"].NaN; // -undefined
							} else {
								TMP.throwError();
							}
						} else if ( c == Char.N ) {
							if (
								Memory.getUI16( _position ) == 0x4E61	// aN
							) {
								_position += 2;
								result = untyped __global__["Number"].NaN; // -NaN
							} else {
								TMP.throwError();
							}
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.n ) {	// null

						if (
							Memory.getByte( _position ) ==		0x75 &&	// u
							Memory.getUI16( _position + 1 ) ==	0x6C6C	// ll
						) {
							_position += 3;
							result = null;
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.t ) {	// true

						if (
							Memory.getByte( _position ) ==		0x72 &&	// r
							Memory.getUI16( _position + 1 ) ==	0x6575	// ue
						) {
							_position += 3;
							result = true;
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.f ) {	// false

						if (
							Memory.getI32( _position ) ==		0x65736C61	// alse
						) {
							_position += 4;
							result = false;
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.u ) {	// undefined

						if (
							Memory.getI32( _position ) ==		0x6665646E &&	// ndef
							Memory.getI32( _position + 4 ) ==	0x64656E69		// ined
						) {
							_position += 8;
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.N ) {	// NaN

						if (
							Memory.getUI16( _position ) == 0x4E61	// aN
						) {
							_position += 2;
							result = untyped __global__["Number"].NaN; // -NaN
						} else {
							TMP.throwError();
						}

					} else if ( c == Char.LEFT_BRACE ) {
						
						var o:Object = new Object();
						var key:String = null;

						c = TMP.readNotSpaceCharCode( _position );
						if ( c != Char.RIGHT_BRACE ) {

							--_position;
							
							do {

								c = TMP.readNotSpaceCharCode( _position );
								if ( c == Char.SINGLE_QUOTE || c == Char.DOUBLE_QUOTE ) {
									--_position;
									t = MemoryScanner.readString( memory, _position );
									if ( t != null ) {
										key = t;
									} else {
										TMP.throwError();
									}
								} else if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DOT ) {
									--_position;
									t = MemoryScanner.readNumber( memory, _position );
									if ( t != null ) {
										key = untyped __global__["parseFloat"]( t ).toString();
									} else {
										TMP.throwError();
									}
								} else if (
									( c == Char.n && Memory.getByte( _position ) == 0x75 && Memory.getUI16( _position + 1 ) == 0x6C6C ) ||	// null
									( c == Char.t && Memory.getByte( _position ) == 0x72 && Memory.getUI16( _position + 1 ) == 0x6575 ) ||	// true
									( c == Char.f && Memory.getI32( _position ) == 0x65736C61 )												// false
								) {
									TMP.throwError();
								} else {
									--_position;
									t = MemoryScanner.readIdentifier( memory, _position );
									if ( t != null ) {
										key = t;
									} else {
										TMP.throwError();
									}
								}

								if ( TMP.readNotSpaceCharCode( _position ) != Char.COLON ) {
									TMP.throwError();
								}

								o[ untyped key ] = readValue( memory, _position );
								_position = position;

								c = TMP.readNotSpaceCharCode( _position );
								if ( c == Char.RIGHT_BRACE ) {	// }
									break;
								} else if ( c != Char.COMMA ) {	// ,
									TMP.throwError();
								}

							} while ( true );
						}

						result = o;

					} else if ( c == Char.LEFT_BRACKET ) {

						var arr:Array<Dynamic> = new Array<Dynamic>();
						do {

							c = TMP.readNotSpaceCharCode( _position );
							if ( c == Char.RIGHT_BRACKET ) {	// ]
								break;
							} else if ( c == Char.COMMA ) {		// ,
								arr.push( untyped __global__["undefined"] );
							} else {
								--_position;
								arr.push( readValue( memory, _position ) );
								_position = position;
								c = TMP.readNotSpaceCharCode( _position );
								if ( c == Char.RIGHT_BRACKET ) {	// ]
									break;
								} else if ( c != Char.COMMA ) {		// ,
									TMP.throwError();
								}
							}

						} while ( true );
						result = arr;


					} else {

						TMP.throwError();

					}

					position = _position;
					return result;

				}

				var h:Bool = false;
				try {
					result = readValue( tmp, position );
					_position = position;
					c = TMP.readNotSpaceCharCode( _position );
					if ( c == Char.EOS ) {
						h = true;
					}
				} catch ( e:Dynamic ) {
					// skip
					//h = false;
				}
				if ( !h ) {
					Memory.memory = mem;
					Error.throwError( SyntaxError, 1509 );
				}

			}
			
			Memory.memory = mem;

		}

		return result;
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

	public static inline function writeBoolean(bytes:ByteArray, value:Bool):Void {
		if ( value ) {
			bytes.writeInt( 0x65757274 );	// true
		} else {
			bytes.writeInt( 0x736C6166 );	// fals
			bytes.writeByte( 0x65 );		// e
		}
	}

	public static inline function writeNull(bytes:ByteArray):Void {
		bytes.writeInt( 0x6C6C756E );		// null
	}

	public static inline function writeNumber(bytes:ByteArray, value:Float):Void {
		if ( untyped __global__["isFinite"]( value ) ) {
			writeFiniteNumber( bytes, value );
		} else {
			writeNull( bytes );
		}
	}

	public static inline function writeFiniteNumber(bytes:ByteArray, value:Float):Void {
		if ( value >= 0 && value <= 9 && value % 1 == 0 ) {
			bytes.writeByte( Char.ZERO + untyped value ); // 0+
		} else {
			bytes.writeUTFBytes( untyped value.toString() );
		}
	}

	public static inline function writeStringEmpty(bytes:ByteArray):Void {
		bytes.writeShort( 0x2222 );	// ""
	}

	public static inline function writeString(bytes:ByteArray, tmp:ByteArray, value:String):Void {
		if ( value.length <= 0 ) {

			writeStringEmpty( bytes );

		} else {

			bytes.writeByte( Char.DOUBLE_QUOTE );

			tmp.position = 16;
			tmp.writeUTFBytes( value );
			var len:UInt = tmp.position;

			var i:UInt = 16;
			var j:UInt = i;
			var l:UInt;

			var c:UInt;
			do {
				c = tmp[ i ];
				if ( c < Char.SPACE || c == Char.DOUBLE_QUOTE || c == Char.SLASH || c == Char.BACK_SLASH ) {
					l = i - j;
					if ( l > 0 ) {
						bytes.writeBytes( tmp, j, l );
					}
					j = i + 1;
					if ( c == Char.NEWLINE ) {
						bytes.writeShort( 0x6E5C );	// \n
					} else if ( c == Char.CARRIAGE_RETURN ) {
						bytes.writeShort( 0x725C );	// \r
					} else if ( c == Char.TAB ) {
						bytes.writeShort( 0x745C );	// \t
					} else if ( c == Char.DOUBLE_QUOTE ) {
						bytes.writeShort( 0x225C );	// \"
					} else if ( c == Char.SLASH ) {
						bytes.writeShort( 0x2F5C );	// \/
					} else if ( c == Char.BACK_SLASH ) {
						bytes.writeShort( 0x5C5C );	// \\
					} else if ( c == Char.VERTICAL_TAB ) {
						bytes.writeShort( 0x765C );	// \v
					} else if ( c == Char.BACKSPACE ) {
						bytes.writeShort( 0x625C );	// \b
					} else if ( c == Char.FORM_FEED ) {
						bytes.writeShort( 0x665C );	// \f
					} else {
						bytes.writeInt( 0x3030755C );	// \u00
						bytes.writeByte( tmp[ c >>> 4 ] );
						bytes.writeByte( tmp[ c & 0xF ] );
					}
				}
			} while ( ++i < len );
			l = i - j;
			if ( l > 0 ) {
				bytes.writeBytes( tmp, j, l );
			}

			bytes.writeByte( Char.DOUBLE_QUOTE );	// "

		}
	}

	public static inline function readNotSpaceCharCode(_position:UInt):UInt {
		var c:UInt;
		do {
			c = MemoryScanner.readCharCode( _position );
			if (
				c != Char.CARRIAGE_RETURN &&
				c != Char.NEWLINE &&
				c != Char.SPACE &&
				c != Char.TAB &&
				c != Char.VERTICAL_TAB &&
				c != Char.BACKSPACE &&
				c != Char.FORM_FEED
			) {
				if ( c == Char.SLASH ) {
					c = MemoryScanner.readCharCode( _position );
					if ( c == Char.SLASH ) {			// //
						MemoryScanner.skipLine( _position );
						continue;
					} else if ( c == Char.ASTERISK ) {	// /*
						_position -= 2;
						c = _position;
						MemoryScanner.skipBlockComment( _position );
						if ( c != _position ) {
							continue;
						}
					}
					--_position;
					c = Char.SLASH;
				}
				break;
			}
		} while ( true );
		return c;
	}

	public static inline function throwError():Void {
		Error.throwError( Error, 0 );
	}
	
}