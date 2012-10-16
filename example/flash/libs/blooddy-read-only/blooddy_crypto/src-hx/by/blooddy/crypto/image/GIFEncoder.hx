////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.core.utils.ByteArrayUtils;
import by.blooddy.crypto.image.palette.IPalette;
import by.blooddy.crypto.image.palette.MedianCutPalette;
import by.blooddy.system.Memory;
import by.blooddy.utils.IntUtils;
import flash.display.BitmapData;
import flash.Error;
import flash.utils.ByteArray;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class GIFEncoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(image:BitmapData, ?palette:IPalette=null):ByteArray {
		if ( palette == null ) {
			palette = new MedianCutPalette( image );
		}
		return TMP.encode( image, palette );
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

	public static function encode(image:BitmapData, palette:IPalette):ByteArray {
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function writeSignature(bytes:ByteArray):Void {
		bytes.writeUTFBytes( 'GIF89a' );
	}

	/**
	 * @private
	 */
	private static inline function writeHeader(bytes:ByteArray, width:UInt, height:UInt, palette:IPalette, bgColor:UInt):Void {
		bytes.writeShort( width );
		bytes.writeShort( height );

		if ( palette == null ) {

			bytes.writeByte(
				7 << 4
			);
			bytes.writeByte( 0 );

		} else {

			bytes.writeByte(
				( 1 << 7 ) |
				( 7 << 4 ) |
				getPaletteBits( palette.getColors().length )
			);
			bytes.writeByte( palette.getIndexByColor( bgColor ) );

		}

		bytes.writeByte( 1 );
	}

	/**
	 * @private
	 */
	private static inline function writeFrame(bytes:ByteArray, chunk:ByteArray, image:BitmapData, palette:IPalette):Void {
		
	}

	/**
	 * @private
	 */
	private static inline function writePalette(bytes:ByteArray, chunk:ByteArray, palette:IPalette):Void {
		chunk.length = 1024;
		Memory.memory = chunk;

		var colors:Vector<UInt> = palette.getColors();
		var l:UInt = IntUtils.min( colors.length, 256 );

		var i:UInt = 0;
		var k:UInt = 0;
		var c:UInt;
		do {
			c = colors[ k ];
			// rgb
			Memory.setByte( i++, c >> 16 );
			Memory.setByte( i++, c >>  8 );
			Memory.setByte( i++, c       );
		} while ( k < l );
		l = getPaletteLength( l );
		if ( k < l ) {
			Memory.fill( i, l*3 );
		}
		Memory.memory = null;
		chunk.length = i;
		bytes.writeBytes( chunk );
	}

	/**
	 * @private
	 */
	private static inline function getPaletteBits(l:UInt):UInt {
		if		( l > 128 )	return 7;
		else if ( l >  64 )	return 6;
		else if ( l >  32 )	return 5;
		else if ( l >  16 )	return 4;
		else if ( l >   8 )	return 3;
		else if ( l >   4 )	return 2;
		else if ( l >   2 )	return 1;
		else				return 0;
	}

	/**
	 * @private
	 */
	private static inline function getPaletteLength(l:UInt):UInt {
		if		( l > 128 )	return 256;
		else if ( l >  64 )	return 128;
		else if ( l >  32 )	return 64;
		else if ( l >  16 )	return 32;
		else if ( l >   8 )	return 16;
		else if ( l >   4 )	return 8;
		else if ( l >   2 )	return 4;
		else				return 2;
	}

}