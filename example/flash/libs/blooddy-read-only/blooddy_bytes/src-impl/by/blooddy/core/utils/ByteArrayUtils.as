////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					2.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class ByteArrayUtils {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static native function createByteArray(length:uint=0):ByteArray;

		public static native function equals(b1:ByteArray, b2:ByteArray):Boolean;

		public static native function indexOfByte(bytes:ByteArray, value:uint, startIndex:uint=0):int;

		public static native function indexOfBytes(bytes:ByteArray, value:ByteArray, startIndex:uint=0):int;

		public static native function isUTFString(bytes:ByteArray):Boolean;

		public static native function dump(bytes:ByteArray, offset:uint=0, length:uint=0):String;

	}

}