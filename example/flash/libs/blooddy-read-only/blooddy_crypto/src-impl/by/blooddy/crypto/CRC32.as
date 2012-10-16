////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * Generates a <a href="http://www.mathpages.com/home/kmath458.htm">CRC hash
	 * (Cyclic Redundancy Check)</a>.
	 *
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class CRC32 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Generates a polinominal code checksum represented as unsigned integer.
		 *
		 * @param	bytes	The data to be hashed.
		 *
		 * @return			The resluting checksum.
		 */
		public static native function hash(bytes:ByteArray):uint;
		
	}
	
}