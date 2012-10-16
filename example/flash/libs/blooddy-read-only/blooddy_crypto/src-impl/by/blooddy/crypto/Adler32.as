////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class Adler32 {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static native function hash(bytes:ByteArray):uint;

	}
	
}