////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette;

import by.blooddy.crypto.image.ImageHelper;
import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Error;
import flash.utils.ByteArray;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class MedianCutPaletteHelper {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function createTable(image:BitmapData, ?maxColors:UInt = 256):Array<Dynamic> {
		if ( image == null ) Error.throwError( TypeError, 2007, 'image' );
		if ( maxColors < 2 || maxColors > 256 ) Error.throwError( RangeError, 2006 );
		if ( ImageHelper.isTransparent( image ) ) {
			return TMP.createTable( image, maxColors, true );
		} else {
			return TMP.createTable( image, maxColors, false );
		}
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline var BLOCK:UInt = 25;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function createTable(image:BitmapData, maxColors:UInt, transparent:Bool):Array<Dynamic> {

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var len:UInt = ( width * height ) << 2;

		var z:UInt = BLOCK * maxColors;
		var colorCount:UInt = 0;
		var tmp:ByteArray = new ByteArray();
		tmp.length = z + len;
		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;

		Memory.memory = tmp;

		var c:UInt;
		var cx:UInt = ~( transparent ? image.getPixel32( 0, 0 ) : image.getPixel( 0, 0 ) );

		var t:UInt;
		var x:UInt;
		var y:UInt = 0;

		var lminA:UInt = 0xFF000000;
		var lmaxA:UInt = ( transparent ? 0x00000000 : 0xFF000000 );
		var lminR:UInt = 0x00FF0000;
		var lmaxR:UInt = 0x00000000;
		var lminG:UInt = 0x0000FF00;
		var lmaxG:UInt = 0x00000000;
		var lminB:UInt = 0x000000FF;
		var lmaxB:UInt = 0x00000000;

		var i:UInt = z;
		do {
			x = 0;
			do {

				c = ( transparent ? image.getPixel32( x, y ) : image.getPixel( x, y ) );
				if ( c == cx ) continue;
				cx = c;

				if ( transparent ) {
					t = c & 0xFF000000;
					if ( t < lminA ) lminA = t;
					if ( t > lmaxA ) lmaxA = t;
				}

				t = c & 0x00FF0000;
				if ( t < lminR ) lminR = t;
				if ( t > lmaxR ) lmaxR = t;

				t = c & 0x0000FF00;
				if ( t < lminG ) lminG = t;
				if ( t > lmaxG ) lmaxG = t;

				t = c & 0x000000FF;
				if ( t < lminB ) lminB = t;
				if ( t > lmaxB ) lmaxB = t;

				Memory.setI32( i, c );
				i += 4;

			} while ( ++x < width );
		} while ( ++y < height );

		writeBlock(
			tmp,
			lminA, lminR, lminG, lminB,
			lmaxA, lmaxR, lmaxG, lmaxB,
			z, i - z,
			colorCount++,
			transparent
		);

		z = i;

		if ( Memory.getByte( 0 ) > 0 ) {

			var z0:UInt;
			var v:UInt;
			
			var rminA:UInt = 0xFF000000;
			var rmaxA:UInt = ( transparent ? 0x00000000 : 0xFF000000 );
			var rminR:UInt;
			var rmaxR:UInt;
			var rminG:UInt;
			var rmaxG:UInt;
			var rminB:UInt;
			var rmaxB:UInt;

			var mask:UInt;
			var mid:UInt;

			var blockPos:UInt;
			
			while ( colorCount < maxColors && Memory.getByte( colorCount * BLOCK - BLOCK ) > 1 ) {

				colorCount--; // последний сплитим

				if ( transparent ) {
					lminA = 0xFF000000;
					lmaxA = 0x00000000;
					rminA = 0xFF000000;
					rmaxA = 0x00000000;
				}

				lminR = 0x00FF0000;
				lmaxR = 0x00000000;
				rminR = 0x00FF0000;
				rmaxR = 0x00000000;

				lminB = 0x000000FF;
				lmaxB = 0x00000000;
				rminB = 0x000000FF;
				rmaxB = 0x00000000;

				lminG = 0x0000FF00;
				lmaxG = 0x00000000;
				rminG = 0x0000FF00;
				rmaxG = 0x00000000;

				blockPos = colorCount * BLOCK;

				mask = Memory.getI32( blockPos + 1 );
				mid = Memory.getI32( blockPos + 5 ) & mask;
				i = Memory.getI32( blockPos + 17 );
				len = Memory.getI32( blockPos + 21 );

				z0 = z;
				z += len;
				x = z0;
				y = z;
				len += i;

				if ( z > 1024 ) tmp.length = z;

				cx = ~Memory.getI32( i );
				do {

					c = Memory.getI32( i );
					i += 4;

					if ( c == cx ) continue;
					cx = c;

					v = c & mask;
					if ( v <= mid ) {

						if ( transparent ) {
							t = c & 0xFF000000;
							if ( t < lminA ) lminA = t;
							if ( t > lmaxA ) lmaxA = t;
						}

						t = c & 0x00FF0000;
						if ( t < lminR ) lminR = t;
						if ( t > lmaxR ) lmaxR = t;

						t = c & 0x0000FF00;
						if ( t < lminG ) lminG = t;
						if ( t > lmaxG ) lmaxG = t;

						t = c & 0x000000FF;
						if ( t < lminB ) lminB = t;
						if ( t > lmaxB ) lmaxB = t;

						Memory.setI32( x, c );
						x += 4;

					} else {

						if ( transparent ) {
							t = c & 0xFF000000;
							if ( t < rminA ) rminA = t;
							if ( t > rmaxA ) rmaxA = t;
						}

						t = c & 0x00FF0000;
						if ( t < rminR ) rminR = t;
						if ( t > rmaxR ) rmaxR = t;

						t = c & 0x0000FF00;
						if ( t < rminG ) rminG = t;
						if ( t > rmaxG ) rmaxG = t;

						t = c & 0x000000FF;
						if ( t < rminB ) rminB = t;
						if ( t > rmaxB ) rmaxB = t;

						y -= 4;
						Memory.setI32( y, c );

					}
				} while ( i < len );

				writeBlock(
					tmp,
					lminA, lminR, lminG, lminB,
					lmaxA, lmaxR, lmaxG, lmaxB,
					z0, x - z0,
					colorCount++,
					transparent
				);

				writeBlock(
					tmp,
					rminA, rminR, rminG, rminB,
					rmaxA, rmaxR, rmaxG, rmaxB,
					y, z - y,
					colorCount++,
					transparent
				);

			}

		}

		y = 0;
		var hash:Array<UInt> = new Array<UInt>();
		var list:Vector<UInt> = new Vector<UInt>();
		len = colorCount * BLOCK;
		i = 0;
		do {
			t = i * BLOCK;
			list.push( Memory.getI32( t + 5 ) );
			x = Memory.getI32( t + 17 );
			z = Memory.getI32( t + 21 ) + x;
			do {
				++y;
				hash[ Memory.getI32( x ) >>> 0 ] = i;
				x += 4;
			} while ( x < z );
		} while ( ++i < colorCount );

		Memory.memory = mem;

		//tmp.clear();

		return [ list, hash ];
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function writeBlock(
		tmp:ByteArray,
		minA:UInt, minR:UInt, minG:UInt, minB:UInt,
		maxA:UInt, maxR:UInt, maxG:UInt, maxB:UInt,
		colorsPos:UInt,
		colorsLen:UInt,
		colorCount:UInt,
		transparent:Bool
	):Void {
		var midA:UInt = ( transparent ? untyped( ( untyped( maxA ) + untyped( minA ) ) / 2 ) & 0xFF000000 : 0xFF000000 );
		var midR:UInt = 0;
		var midG:UInt = 0;
		var midB:UInt = 0;
		var count:UInt = 0;
		var mid:UInt = 0;
		var mask:UInt = 0;
		if ( midA > 0 ) {
			midR = ( ( maxR + minR ) >>> 1 ) & 0xFF0000;
			midG = ( ( maxG + minG ) >>> 1 ) & 0xFF00;
			midB = ( ( maxB + minB ) >>> 1 ) & 0xFF;
			var t:UInt = maxB - minB;
			if ( t > count ) {
				count = t;
				mid = midB;
				mask = 0x000000FF;
			}
			t = ( maxG - minG ) >>> 8;
			if ( t > count ) {
				count = t;
				mid = midG;
				mask = 0x0000FF00;
			}
			t = ( maxR - minR ) >>> 16;
			if ( t > count ) {
				count = t;
				mid = midR;
				mask = 0x00FF0000;
			}
			if ( transparent ) {
				t = ( maxA - minA ) >>> 24;
				if ( t > count ) {
					count = t;
					mid = midA;
					mask = 0xFF000000;
				}
			}
		}

		var i:UInt = 0;
		var l:UInt = colorCount * BLOCK;
		while ( i < l ) {
			if ( count < Memory.getByte( i ) ) {
				tmp.position = i + BLOCK;
				tmp.writeBytes( tmp, i, l - i );
				break;
			}
			i += BLOCK;
		};
		
		Memory.setByte( i     , count );
		Memory.setI32(  i +  1, mask );
		Memory.setI32(  i +  5, midA | midR | midG | midB );
		Memory.setI32(  i +  9, minA | minR | minG | minB );
		Memory.setI32(  i + 13, maxA | maxR | maxG | maxB );
		Memory.setI32(  i + 17, colorsPos );
		Memory.setI32(  i + 21, colorsLen );
		
	}

}