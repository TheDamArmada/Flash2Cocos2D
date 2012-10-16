////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image;

import flash.display.BitmapData;
import flash.geom.Point;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class ImageHelper {

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public static inline var _TRANSPARENT:UInt = 0xFF000000;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * углебленный способ проверки прозрачности. флаг прозрачности может стоять,
	 * но картинка может быть не прозрачна. немного теряем в скорости на прозрачных
	 * картинках, зато выйигрываем с установленным флагом в ~5 раз.
	 *
	 * @param	image	картинка на проверку
	 *
	 * @return			прозрачна или нет?
	 */
	public static inline function isTransparent(image:BitmapData):Bool {
		return image.transparent && (
			isPixelTransparent( image, 0,           0            ) ||
			isPixelTransparent( image, image.width, image.height ) ||
			isPixelTransparent( image, image.width, 0            ) ||
			isPixelTransparent( image, 0,           image.height ) ||
			image.clone().threshold( image, image.rect, new Point(), '!=', _TRANSPARENT, 0, _TRANSPARENT, true ) != 0
		);
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function isPixelTransparent(image:BitmapData, x:UInt, y:UInt):Bool {
		return ( image.getPixel32( x, y ) < _TRANSPARENT );
	}

}