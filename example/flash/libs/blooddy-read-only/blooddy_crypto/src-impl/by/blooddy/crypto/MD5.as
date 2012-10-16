////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * Encodes and decodes binary data using
	 * <a herf="http://www.faqs.org/rfcs/rfc1321.html">MD5 (Message Digest)</a> algorithm.
	 *
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class MD5 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Performs MD5 hash algorithm on a String.
		 *
		 * @param	str		The string to hash.
		 *
		 * @return			A string containing the hash value of <code>source</code>.
		 *
		 * @keyword			md5.hash, hash
		 */
		public static native function hash(str:String):String;
		
		/**
		 * Performs MD5 hash algorithm on a <code>ByteArray</code>.
		 *
		 * @param	data	The <code>ByteArray</code> data to hash.
		 *
		 * @return			A string containing the hash value of data.
		 *
		 * @keyword			md5.hashBytes, hashBytes
		 */
		public static native function hashBytes(data:ByteArray):String;

	}
	
}