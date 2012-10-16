////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import by.blooddy.crypto.image.palette.IPalette;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * Encodes image data using 8 bits of color information per pixel.
	 *
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class PNG8Encoder {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates a PNG-encoded byte sequence from the specified <code>BitmapData</code>
		 *
		 * @param	image			The <code>BitmapData</code> of the image you wish to encode.
		 *
		 * @param	palette			The color patette to use.
		 * 							If <code>null</code> given, the
		 * 							<code>by.blooddy.crypto.image.palette.MedianCutPalette</code>
		 * 							will be used.
		 *
		 * @param	filter			The encoding algorithm you wish to apply while encoding.
		 * 							Use the constants provided in
		 * 							<code>by.blooddy.crypto.image.PNGFilter</code> class.
		 *
		 * @return					The sequence of bytes containing the encoded image.
		 *
		 * @throws	TypeError		
		 * @throws	ArgumentError	No such filter.
		 *
		 * @see 					by.blooddy.crypto.image.palette.IPalette
		 * @see 					by.blooddy.crypto.image.palette.MedianCutPalette
		 * @see 					by.blooddy.crypto.image.PNGFilter
		 */
		public static native function encode(image:BitmapData,
			palette:IPalette=null, filter:uint=0):ByteArray;
		
	}
	
}