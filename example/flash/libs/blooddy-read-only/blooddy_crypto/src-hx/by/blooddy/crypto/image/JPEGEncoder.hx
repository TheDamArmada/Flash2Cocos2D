////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import by.blooddy.system.Memory;
import flash.display.BitmapData;
import flash.Error;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class JPEGEncoder {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function encode(image:BitmapData, ?quality:UInt=60):ByteArray {

		if ( image == null ) Error.throwError( TypeError, 2007, 'image' );
		if ( quality > 100 ) Error.throwError( RangeError, 2006, 'quality' );

		var mem:ByteArray = Memory.memory;

		var width:UInt = image.width;
		var height:UInt = image.height;

		var tmp:ByteArray = new ByteArray();
		tmp.position = TMP.Z2;
		tmp.writeBytes( JPEGTable.getTable( quality ) );
		tmp.length += 680 + width * height * 3;
		// помещаем в пямять
		if ( tmp.length < Memory.MIN_SIZE ) tmp.length = Memory.MIN_SIZE;
		Memory.memory = tmp;

		// Add JPEG headers
		Memory.setI16( TMP.Z0, 0xD8FF ); // SOI
		TMP.writeAPP0( tmp, TMP.Z0 +   2 );
		TMP.writeAPP1( tmp, TMP.Z0 +  20 );
		TMP.writeDQT(  tmp, TMP.Z0 +  92 );
		TMP.writeSOF0( tmp, TMP.Z0 + 226, image.width, image.height );
		TMP.writeDHT(  tmp, TMP.Z0 + 245 );
		TMP.writeSOS(  tmp, TMP.Z0 + 665 );

		var _byteout:Int = TMP.Z0 + 679;
		var _bytepos:Int = 7;
		var _bytenew:Int = 0;

		// Encode 8x8 macroblocks
		var DCY:Int = 0;
		var DCU:Int = 0;
		var DCV:Int = 0;

		var _x:UInt;
		var _y:UInt;

		_y = 0;
		do {
			_x = 0;
			do {
				//if ( tmp.length - _byteout < 2048 ) { // у памяти есть свойство заканчиваться
				//	tmp.length += 4096;
				//}
				TMP.rgb2yuv( image, _x, _y );
				DCY = TMP.processDU( _byteout, _bytepos, _bytenew, 256 + 512 * 0, TMP.Z2 + 130, DCY, TMP.Z2 + 1218 + 416,  TMP.Z2 + 1218 + 452  );
				DCU = TMP.processDU( _byteout, _bytepos, _bytenew, 256 + 512 * 1, TMP.Z2 + 642, DCU, TMP.Z2 + 1218 + 1205, TMP.Z2 + 1218 + 1241 );
				DCV = TMP.processDU( _byteout, _bytepos, _bytenew, 256 + 512 * 2, TMP.Z2 + 642, DCV, TMP.Z2 + 1218 + 1205, TMP.Z2 + 1218 + 1241 );
				_x += 8;
			} while ( _x < width );
			_y += 8;
		} while ( _y < height );

		// Do the bit alignment of the EOI marker
		if ( _bytepos >= 0 ) {
			TMP.writeBits( _byteout, _bytepos, _bytenew, _bytepos + 1, ( 1 << ( _bytepos + 1 ) ) - 1 );
		}

		Memory.setI16( _byteout, 0xD9FF ); //EOI

		Memory.memory = mem;

		var bytes:ByteArray = new ByteArray();
		bytes.writeBytes( tmp, TMP.Z0, _byteout - TMP.Z0 + 2 );
		bytes.position = 0;

		//tmp.clear();
		
		return bytes;
	}

}

/**
 * @private
 */
private class TMP {

	//--------------------------------------------------------------------------
	//
	//  Private class variables
	//
	//--------------------------------------------------------------------------

	public static inline var Z2:UInt = 256 + 512 * 3;	// промежуточные таблицы

	public static inline var Z0:UInt = Z2 + 199817;		// начало записи для результата

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function writeAPP0(tmp:ByteArray, p:UInt):Void {
		Memory.setI16(	p     ,	0xE0FF		);	// marker
		Memory.setI16(	p +  2,	0x1000		);	// length
		Memory.setI32(	p +  4,	0x4649464A	);	// JFIF
		Memory.setByte( p +  8,	0x00		);	//
		Memory.setI16(	p +  9,	0x0101		);	// version
		Memory.setByte( p + 11,	0x00		);	// xyunits
		Memory.setI32(	p + 12,	0x01000100	);	// density
		Memory.setI16(	p + 16,	0x0000		);	// thumbn
	}

	public static inline function writeAPP1(tmp:ByteArray, p:UInt):Void {
		Memory.setI16(	p     ,	0xE1FF		);	// marker
		Memory.setI16(	p +  2,	0x4600		);	// length

		Memory.setI32(  p +  4, 0x66697845	);	// Exif
		Memory.setI16(  p +  8, 0x0000		);	//
		Memory.setI32(  p + 10, 0x002A4949	);	// TIFF Header
		Memory.setI32(  p + 14, 0x00000008	);	//

		Memory.setI16(  p + 18, 0x0001		);
		
		Memory.setI16(  p + 20, 0x0131		);	// tag
		Memory.setI16(  p + 22, 0x0002		);	// type
		Memory.setI32(  p + 24, 0x00000023	);	// count
		Memory.setI32(  p + 28, 0x0000001A	);	// value offset
		Memory.setI32(  p + 32, 0x00000000	);	//

		tmp.position = p + 36;
		tmp.writeMultiByte( 'by.blooddy.crypto.image.JPEGEncoder', 'x-ascii' ); // length=35

		Memory.setByte( p + 71, 0x00		);	// zero

	}

	public static inline function writeDQT(tmp:ByteArray, p:UInt):Void {
		Memory.setI16(	p     ,	0xDBFF		);	// marker
		Memory.setI16(	p +  2,	0x8400		);	// length

		tmp.position = p + 4;
		tmp.writeBytes( tmp, Z2, 130 );

		Memory.setByte( p +  4,	0x00		);
		Memory.setByte( p + 69,	0x01		);
	}
	
	public static inline function writeSOF0(tmp:ByteArray, p:UInt, width:UInt, height:UInt):Void {
		Memory.setI16(	p     ,	0xC0FF		);	// marker
		Memory.setI16(	p +  2,	0x1100		);	// length, truecolor YUV JPG
		Memory.setByte(	p +  4,	0x08		);	// precision
		Memory.setI16(	p +  5,					// height
			( ( ( height >> 8 ) & 0xFF )      ) |
			( ( ( height      ) & 0xFF ) << 8 )
		);
		Memory.setI16(	p +  7,					// width
			( ( ( width >> 8  ) & 0xFF )      ) |
			( ( ( width       ) & 0xFF ) << 8 )
		);
		Memory.setByte(	p +  9,	0x03		);	// nrofcomponents
		Memory.setI32(	p + 10,	0x00001101	);	// IdY, HVY, QTY
		Memory.setI32(	p + 13,	0x00011102	);	// IdU, HVU, QTU
		Memory.setI32(	p + 16,	0x00011103	);	// IdV, HVV, QTV
	}

	public static inline function writeDHT(tmp:ByteArray, p:UInt):Void {
		Memory.setI16(	p      ,	0xC4FF		);	// marker
		Memory.setI16(	p +   2,	0xA201		);	// length

		tmp.position = p + 4;
		tmp.writeBytes( tmp, Z2 + 1218, 416 );

		Memory.setByte(	p +   4,	0x00		);	// HTYDCinfo
		Memory.setByte(	p +  33,	0x10		);	// HTYACinfo
		Memory.setByte(	p + 212,	0x01		);	// HTUDCinfo
		Memory.setByte(	p + 241,	0x11		);	// HTUACinfo
	}

	public static inline function writeSOS(tmp:ByteArray, p:UInt):Void {
		Memory.setI16(	p     ,	0xDAFF		);	// marker
		Memory.setI16(	p +  2,	0x0C00		);	// length
		Memory.setByte(	p +  4,	0x03		);	// nrofcomponents
		Memory.setI16(	p +  5,	0x0001		);	// IdY, HTY
		Memory.setI16(	p +  7,	0x1102		);	// IdU, HTU
		Memory.setI16(	p +  9,	0x1103		);	// IdV, HTV
		Memory.setI32(	p + 11,	0x00003f00	);	// Ss, Se, Bf
	}

	public static inline function rgb2yuv(image:BitmapData, _x:UInt, _y:UInt):Void {

		var pos:UInt = 0;

		var xm:UInt = _x + 8;
		var ym:UInt = _y + 8;

		var c:UInt;
		var r:UInt;
		var g:UInt;
		var b:UInt;

		do {
			do {

				c = image.getPixel( _x, _y );

				r =   c >>> 16         ;
				g = ( c >>   8 ) & 0xFF;
				b =   c          & 0xFF;

				Memory.setDouble( 256 + 512 * 0 + pos,   0.29900 * r + 0.58700 * g + 0.11400 * b - 0x80 ); // YDU
				Memory.setDouble( 256 + 512 * 1 + pos, - 0.16874 * r - 0.33126 * g + 0.50000 * b        ); // UDU
				Memory.setDouble( 256 + 512 * 2 + pos,   0.50000 * r - 0.41869 * g - 0.08131 * b        ); // VDU

				pos += 8;

			} while ( ++_x < xm );
			_x -= 8;
		} while ( ++_y < ym );
		_y -= 8;

	}

	public static inline function processDU(_byteout:Int, _bytepos:Int, _bytenew:Int, CDU:UInt, fdtbl:UInt, DC:Int, HTDC:UInt, HTAC:UInt):Int {
		
		fDCTQuant( CDU, fdtbl );

		var DU0:Int = Memory.getI32( 0 );
		var diff:Int = DU0 - DC;
		DC = DU0;

		var pos:UInt;

		// Encode DC
		if ( diff == 0 ) {
			writeMBits( _byteout, _bytepos, _bytenew, HTDC ); // Diff might be 0
		} else {
			pos = ( 32767 + diff ) * 3;
			writeMBits( _byteout, _bytepos, _bytenew, HTDC + Memory.getByte( Z2 + 3212 + pos ) * 3 );
			writeMBits( _byteout, _bytepos, _bytenew, Z2 + 3212 + pos );
		}

		// Encode ACs
		var end0pos:UInt = 63;
		while ( end0pos > 0 && Memory.getI32( end0pos << 2 ) == 0 ) end0pos--;

		// end0pos = first element in reverse order !=0
		if ( end0pos != 0 ) {
			var i:UInt = 1;
			var lng:Int;
			var startpos:Int;
			var nrzeroes:Int;
			var nrmarker:Int;
			while ( i <= end0pos ) {
				startpos = i;
				while ( i <= end0pos && Memory.getI32( i << 2 ) == 0 ) ++i;
				nrzeroes = i - startpos;
				if ( nrzeroes >= 16 ) {
					lng = nrzeroes >> 4;
					nrmarker = 1;
					while ( nrmarker <= lng ) {
						writeMBits( _byteout, _bytepos, _bytenew, HTAC + 0xF0 * 3 );
						++nrmarker;
					}
					nrzeroes = nrzeroes & 0xF;
				}
				pos = ( 32767 + Memory.getI32( i << 2 ) ) * 3;
				writeMBits( _byteout, _bytepos, _bytenew, HTAC + ( nrzeroes << 4 ) * 3 + Memory.getByte( Z2 + 3212 + pos ) * 3 );
				writeMBits( _byteout, _bytepos, _bytenew, Z2 + 3212 + pos );
				i++;
			}
		}
		if ( end0pos != 63 ) {
			writeMBits( _byteout, _bytepos, _bytenew, HTAC );
		}
		return DC;
	}

	public static inline function writeBits(_byteout:Int, _bytepos:Int, _bytenew:Int, len:Int, val:Int):Void {
		while ( --len >= 0 ) {
			if ( val & ( 1 << len ) != 0 ) {
				_bytenew |= 1 << _bytepos;
			}
			_bytepos--;
			if ( _bytepos < 0 ) {
				if ( _bytenew == 0xFF ) {
					Memory.setI16( _byteout, 0x00FF );
					_byteout += 2;
				} else {
					Memory.setByte( _byteout, _bytenew );
					_byteout++;
				}
				_bytepos = 7;
				_bytenew = 0;
			}
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * DCT & quantization core
	 */
	private static inline function fDCTQuant(data:UInt, fdtbl:UInt):Void {

		var dataOff:UInt;
		var d0:Float, d1:Float, d2:Float, d3:Float, d4:Float, d5:Float, d6:Float, d7:Float;
		var tmp0:Float, tmp1:Float, tmp2:Float, tmp3:Float, tmp4:Float, tmp5:Float, tmp6:Float, tmp7:Float;
		var tmp10:Float, tmp11:Float, tmp12:Float, tmp13:Float;
		var z1:Float, z2:Float, z3:Float, z4:Float, z5:Float;
		var z11:Float, z13:Float;
		
		/* Pass 1: process rows. */
		dataOff = 0;
		do {

			d0 = Memory.getDouble( data + dataOff + 0 * 8 );
			d1 = Memory.getDouble( data + dataOff + 1 * 8 );
			d2 = Memory.getDouble( data + dataOff + 2 * 8 );
			d3 = Memory.getDouble( data + dataOff + 3 * 8 );
			d4 = Memory.getDouble( data + dataOff + 4 * 8 );
			d5 = Memory.getDouble( data + dataOff + 5 * 8 );
			d6 = Memory.getDouble( data + dataOff + 6 * 8 );
			d7 = Memory.getDouble( data + dataOff + 7 * 8 );

			tmp0 = d0 + d7;
			tmp7 = d0 - d7;
			tmp1 = d1 + d6;
			tmp6 = d1 - d6;
			tmp2 = d2 + d5;
			tmp5 = d2 - d5;
			tmp3 = d3 + d4;
			tmp4 = d3 - d4;
			
			// Even part
			// phase 2
			tmp10 = tmp0 + tmp3;
			tmp13 = tmp0 - tmp3;
			tmp11 = tmp1 + tmp2;
			tmp12 = tmp1 - tmp2;

			// phase 3
			Memory.setDouble( data + dataOff + 0 * 8, tmp10 + tmp11 );
			Memory.setDouble( data + dataOff + 4 * 8, tmp10 - tmp11 );
			
			// phase 5
			z1 = ( tmp12 + tmp13 ) * 0.707106781;	// c4
			Memory.setDouble( data + dataOff + 2 * 8, tmp13 + z1 );
			Memory.setDouble( data + dataOff + 6 * 8, tmp13 - z1 );
			
			// Odd part
			// phase 2
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			// The rotator is modified from fig 4-8 to avoid extra negations.
			z5 = ( tmp10 - tmp12 ) * 0.382683433;	// c6
			z2 = 0.541196100 * tmp10 + z5;			// c2-c6
			z4 = 1.306562965 * tmp12 + z5;			// c2+c6
			z3 = tmp11 * 0.707106781;				// c4

			//phase 5
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;

			// phase 6
			Memory.setDouble( data + dataOff + 5 * 8, z13 + z2 );
			Memory.setDouble( data + dataOff + 3 * 8, z13 - z2 );
			Memory.setDouble( data + dataOff + 1 * 8, z11 + z4 );
			Memory.setDouble( data + dataOff + 7 * 8, z11 - z4 );
			
			dataOff += 64; // advance pointer to next row
		} while ( dataOff < 512 );

		// Pass 2: process columns.
		dataOff = 0;
		do {

			d0 = Memory.getDouble( data + dataOff +  0 * 8 );
			d1 = Memory.getDouble( data + dataOff +  8 * 8 );
			d2 = Memory.getDouble( data + dataOff + 16 * 8 );
			d3 = Memory.getDouble( data + dataOff + 24 * 8 );
			d4 = Memory.getDouble( data + dataOff + 32 * 8 );
			d5 = Memory.getDouble( data + dataOff + 40 * 8 );
			d6 = Memory.getDouble( data + dataOff + 48 * 8 );
			d7 = Memory.getDouble( data + dataOff + 56 * 8 );

			tmp0 = d0 + d7;
			tmp7 = d0 - d7;
			tmp1 = d1 + d6;
			tmp6 = d1 - d6;
			tmp2 = d2 + d5;
			tmp5 = d2 - d5;
			tmp3 = d3 + d4;
			tmp4 = d3 - d4;
			
			// Even part
			// phase 2
			tmp10 = tmp0 + tmp3;
			tmp13 = tmp0 - tmp3;
			tmp11 = tmp1 + tmp2;
			tmp12 = tmp1 - tmp2;

			// phase 3
			Memory.setDouble( data + dataOff +  0 * 8, tmp10 + tmp11 );
			Memory.setDouble( data + dataOff + 32 * 8, tmp10 - tmp11 );

			// phase 5
			z1 = ( tmp12 + tmp13 ) * 0.707106781;	// c4
			Memory.setDouble( data + dataOff + 16 * 8, tmp13 + z1 );
			Memory.setDouble( data + dataOff + 48 * 8, tmp13 - z1 );

			// Odd part
			// phase 2
			tmp10 = tmp4 + tmp5;
			tmp11 = tmp5 + tmp6;
			tmp12 = tmp6 + tmp7;
			
			// The rotator is modified from fig 4-8 to avoid extra negations.
			z5 = ( tmp10 - tmp12 ) * 0.382683433;	// c6
			z2 = 0.541196100 * tmp10 + z5;			// c2-c6
			z4 = 1.306562965 * tmp12 + z5;			// c2+c6
			z3 = tmp11 * 0.707106781;				// c4

			// phase 5
			z11 = tmp7 + z3;
			z13 = tmp7 - z3;

			// phase 6
			Memory.setDouble( data + dataOff + 40 * 8, z13 + z2 );
			Memory.setDouble( data + dataOff + 24 * 8, z13 - z2 );
			Memory.setDouble( data + dataOff +  8 * 8, z11 + z4 );
			Memory.setDouble( data + dataOff + 56 * 8, z11 - z4 );
			
			dataOff += 8; // advance pointer to next column
		} while ( dataOff < 64 );

		// Quantize/descale the coefficients
		var fDCTQuant:Float;
		var i:UInt = 0;
		do {
			// Apply the quantization and scaling factor & Round to nearest integer
			fDCTQuant = Memory.getDouble( data + ( i << 3 ) ) * Memory.getDouble( fdtbl + ( i << 3 ) );
			Memory.setI32(
				Memory.getByte( Z2 + 1154 + i ) << 2, // ZigZag reorder
				Std.int( fDCTQuant + ( fDCTQuant > 0.0 ? 0.5 : - 0.5 ) )
			);
		} while ( ++i < 64 );

	}

	/**
	 * @private
	 */
	private static inline function writeMBits(_byteout:Int, _bytepos:Int, _bytenew:Int, addres:UInt):Void {
		writeBits( _byteout, _bytepos, _bytenew, Memory.getByte( addres ), Memory.getUI16( addres + 1 ));
	}

}