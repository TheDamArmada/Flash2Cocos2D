////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	
	/**
	 * Encodes image data using
	 * <a href="http://www.w3.org/Graphics/JPEG/itu-t81.pdf">JPEG</a> compression method.
	 *
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class JPEGEncoder {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates a JPEG image from the specified <code>BitmapData</code>.
		 *
		 * @param	image		The <code>BitmapData</code> to be encoded.
		 *
		 * @param	quality		The compression level, possible values are 1 through 100 inclusive.
		 *
		 * @return 				a <code>ByteArray</code> representing the JPEG encoded image data.
		 *
		 * @throws	TypeError
		 */
		public static native function encode(image:BitmapData, quality:uint=60):ByteArray;
		
	}
	
}