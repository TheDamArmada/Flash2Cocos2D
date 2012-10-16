////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {
	
	import flash.utils.ByteArray;
	
	/**
	 * Encodes and decodes binary data using 
	 * <a herf="http://www.faqs.org/rfcs/rfc4634.html">SHA-224 (Secure Hash Algorithm)</a> algorithm.
	 * 
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.10.2010 18:00:48
	 */
	public class SHA224 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Performs SHA-224 hash algorithm on a String.
		 *
		 * @param	str		The string to hash.
		 *
		 * @return			A string containing the hash value of <code>source</code>.
		 *
		 * @keyword			sha1.hash, hash
		 */
		public static native function hash(str:String):String;
		
		/**
		 * Performs SHA-224 hash algorithm on a <code>ByteArray</code>.
		 *
		 * @param	data	The <code>ByteArray</code> data to hash.
		 *
		 * @return			A string containing the hash value of data.
		 *
		 * @keyword			sha1.hashBytes, hashBytes
		 */
		public static native function hashBytes(data:ByteArray):String;
		
	}
	
}