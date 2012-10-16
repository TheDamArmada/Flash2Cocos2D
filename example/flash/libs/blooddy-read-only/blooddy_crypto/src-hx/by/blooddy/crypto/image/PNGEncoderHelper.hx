////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.crypto.CRC32;
import by.blooddy.utils.IntUtils;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class PNGEncoderHelper {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	public static inline var NONE:UInt =	0;

	public static inline var SUB:UInt =		1;

	public static inline var UP:UInt =		2;

	public static inline var AVERAGE:UInt =	3;

	public static inline var PAETH:UInt =	4;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function writeSignature(bytes:ByteArray):Void {
		bytes.writeUnsignedInt( 0x89504e47 );
		bytes.writeUnsignedInt( 0x0D0A1A0A );
	}

	public static inline function writeChunk(bytes:ByteArray, chunk:ByteArray):Void {
		bytes.writeUnsignedInt( chunk.length - 4 );
		bytes.writeBytes( chunk, 0 );
		bytes.writeUnsignedInt( CRC32.hash( chunk ) );
	}

	public static inline function writeIHDR(bytes:ByteArray, chunk:ByteArray, width:UInt, height:UInt, bits:UInt, colors:UInt):Void {
		chunk.length = 0;
		chunk.writeUnsignedInt( 0x49484452 );
		chunk.writeUnsignedInt( width );	// width
		chunk.writeUnsignedInt( height );	// height
		chunk.writeByte( bits );			// Bit depth
		chunk.writeByte( colors );			// Colour type
		chunk.writeByte( 0x00 );			// Compression method
		chunk.writeByte( 0x00 );			// Filter method
		chunk.writeByte( 0x00 );			// Interlace method
		writeChunk( bytes, chunk );
	}

	public static inline function writeTEXT(bytes:ByteArray, chunk:ByteArray, keyword:String, text:String):Void {
		chunk.length = 0;
		chunk.writeUnsignedInt( 0x74455874 );
		chunk.writeMultiByte( keyword, 'latin-1' );
		chunk.writeByte( 0 );
		chunk.writeMultiByte( text, 'latin-1' );
		writeChunk( bytes, chunk );
	}

	public static inline function writeIEND(bytes:ByteArray, chunk:ByteArray):Void {
		chunk.length = 0;
		chunk.writeUnsignedInt( 0x49454E44 );
		writeChunk( bytes, chunk );
	}

	public static inline function paethPredictor(a:UInt, b:UInt, c:UInt):UInt {
		var p:Int = a + b - c;
		var pa:UInt = IntUtils.abs( p - a );
		var pb:UInt = IntUtils.abs( p - b );
		var pc:UInt = IntUtils.abs( p - c );
		if ( pa <= pb && pa <= pc ) {
			return a;
		} else if ( pb <= pc ) {
			return b;
		} else {
			return c;
		}
	}

}