////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.core.utils.ByteArrayUtils;
import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class PNG24Encoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function encode(image:BitmapData, ?filter:Int=0):ByteArray {

		if ( image == null ) Error.throwError( TypeError, 2007, 'image' );
		if ( filter < 0 || filter > 4 ) Error.throwError( ArgumentError, 2008, 'filter' );

		var mem:ByteArray = Memory.memory;

		var transparent:Bool = ImageHelper.isTransparent( image );
		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = ( width * height ) * ( transparent ? 4 : 3 ) + height;
		var len2:UInt = len + width * 4;

		// Create output byte array
		var bytes:ByteArray = new ByteArray();
		var chunk:ByteArray = ByteArrayUtils.createByteArray( len2 );

		// PNG signature
		PNGEncoderHelper.writeSignature( bytes );

		// IHDR
		PNGEncoderHelper.writeIHDR( bytes, chunk, width, height, 0x08, ( transparent ? 0x06 : 0x02 ) );

		// IDAT
		if ( len2 < 1024 ) chunk.length = 1024;
		else chunk.length = len2;
		Memory.memory = chunk;
		if ( len < 17 ) Memory.fill( len, 17 ); // если битмапка очень маленькая, то мы случайно могли наследить
		if ( transparent )	TMP.writeIDATContent( image, filter, len, true );
		else				TMP.writeIDATContent( image, filter, len, false );
		Memory.memory = mem;
		chunk.length = len;
		chunk.compress();
		chunk.position = 4;
		chunk.writeBytes( chunk );
		chunk.position = 0;
		chunk.writeUnsignedInt( 0x49444154 );
		PNGEncoderHelper.writeChunk( bytes, chunk );

		// tEXt
		PNGEncoderHelper.writeTEXT( bytes, chunk, 'Software', 'by.blooddy.crypto.image.PNG24Encoder' );

		// IEND
		PNGEncoderHelper.writeIEND( bytes, chunk );

		//chunk.clear();

		bytes.position = 0;

		return bytes;

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

	public static inline function writeIDATContent(image:BitmapData, filter:Int, len:UInt, transparent:Bool):Void {
		var width:UInt = image.width;
		var height:UInt = image.height;

		var x:UInt, y:UInt = 0;
		var c:UInt;
		var i:UInt = 0, j:UInt;

		var r:UInt,	g:UInt, b:UInt;
		var r0:UInt, g0:UInt, b0:UInt;
		var r1:UInt, g1:UInt, b1:UInt;
		var r2:UInt, g2:UInt, b2:UInt;
		var a:UInt, a0:UInt = 0, a1:UInt, a2:UInt = 0;

		switch ( filter ) {

			case PNGEncoderHelper.NONE:
				if ( transparent && width >= 64 ) { // для широких картинок быстрее копировать целиком ряды байтов
					width <<= 2;
					var bmp:ByteArray = image.getPixels( image.rect );
					var tmp:ByteArray = Memory.memory;
					tmp.position = 0;
					x = 0;
					do {
						tmp.writeBytes( bmp, y * width, width );
						i = x + width;
						do {
							Memory.setByte( i, Memory.getByte( i - 4 ) );
							i -= 4;
						} while ( i > x );
						Memory.setByte( x, PNGEncoderHelper.NONE );
						x += width + 1;
						++tmp.position;
					} while ( ++y < height );
				} else {
					do {
						Memory.setByte( i++, PNGEncoderHelper.NONE );
						x = 0;
						do {
							c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
							Memory.setByte( i++, c >> 16 );
							Memory.setByte( i++, c >>  8 );
							Memory.setByte( i++, c       );
							if ( transparent ) {
								Memory.setByte( i++, c >> 24 );
							}
						} while ( ++x < width );
					} while ( ++y < height );
				}


			case PNGEncoderHelper.SUB:
				do {
					Memory.setByte( i++, PNGEncoderHelper.SUB );
					if ( transparent ) {
						a0 = 0;
					}
					r0 = 0;
					g0 = 0;
					b0 = 0;
					x = 0;
					do {

						b = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

						r = b >>> 16;
						Memory.setByte( i++, r - r0 );
						r0 = r;

						g = b >>>  8;
						Memory.setByte( i++, g - g0 );
						g0 = g;

						Memory.setByte( i++, b - b0 );
						b0 = b;

						if ( transparent ) {
							a = b >>> 24;
							Memory.setByte( i++, a - a0 );
							a0 = a;
						}

					} while ( ++x < width );
				} while ( ++y < height );

			
			case PNGEncoderHelper.UP:
				do {
					j = len;
					Memory.setByte( i++, PNGEncoderHelper.UP );
					x = 0;
					do {
						c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
						Memory.setByte( i++, ( c >>> 16 ) - Memory.getByte( j + 2 ) );
						Memory.setByte( i++, ( c >>>  8 ) - Memory.getByte( j + 1 ) );
						Memory.setByte( i++,   c          - Memory.getByte( j     ) );
						if ( transparent ) {
							Memory.setByte( i++, ( c >>> 24 ) - Memory.getByte( j + 3 ) );
						}
						Memory.setI32( j, c );
						j += 4;
					} while ( ++x < width );
				} while ( ++y < height );

			
			case PNGEncoderHelper.AVERAGE:
				do {
					j = len;
					Memory.setByte( i++, PNGEncoderHelper.AVERAGE );
					if ( transparent ) {
						a0 = 0;
					}
					r0 = 0;
					g0 = 0;
					b0 = 0;
					x = 0;
					do {

						c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

						r = ( transparent ? ( c >> 16 ) & 0xFF : c >>> 16 );
						Memory.setByte( i++, r - ( ( r0 + Memory.getByte( j + 2 ) ) >>> 1 ) );
						r0 = r;

						g = ( c >>  8 ) & 0xFF;
						Memory.setByte( i++, g - ( ( g0 + Memory.getByte( j + 1 ) ) >>> 1 ) );
						g0 = g;

						b = ( c       ) & 0xFF;
						Memory.setByte( i++, b - ( ( b0 + Memory.getByte( j ) ) >>> 1 ) );
						b0 = b;

						if ( transparent ) {
							a =   c >>> 24;
							Memory.setByte( i++, a - ( ( a0 + Memory.getByte( j + 3 ) ) >>> 1 ) );
							a0 = a;
						}

						Memory.setI32( j, c );
						j += 4;

						
					} while ( ++x < width );
				} while ( ++y < height );


			case PNGEncoderHelper.PAETH:
				do {

					j = len;
					Memory.setByte( i++, PNGEncoderHelper.PAETH );
					if ( transparent ) {
						a0 = 0;
						a2 = 0;
					}
					r0 = 0;
					r2 = 0;
					g0 = 0;
					g2 = 0;
					b0 = 0;
					b2 = 0;
					x = 0;
					do {

						c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );

						r = ( transparent ? ( c >> 16 ) & 0xFF : c >>> 16 );
						r1 = Memory.getByte( j + 2 );
						Memory.setByte( i++, r - PNGEncoderHelper.paethPredictor( r0, r1, r2 ) );
						r0 = r;
						r2 = r1;

						g = ( c >> 8 ) & 0xFF;
						g1 = Memory.getByte( j + 1 );
						Memory.setByte( i++, g - PNGEncoderHelper.paethPredictor( g0, g1, g2 ) );
						g0 = g;
						g2 = g1;

						b = c & 0xFF;
						b1 = Memory.getByte( j     );
						Memory.setByte( i++, b - PNGEncoderHelper.paethPredictor( b0, b1, b2 ) );
						b0 = b;
						b2 = b1;

						if ( transparent ) {
							a = c >>> 24;
							a1 = Memory.getByte( j + 3 );
							Memory.setByte( i++, a - PNGEncoderHelper.paethPredictor( a0, a1, a2 ) );
							a0 = a;
							a2 = a1;
						}

						Memory.setI32( j, c );
						j += 4;

					} while ( ++x < width );
				} while ( ++y < height );

		}

	}

}