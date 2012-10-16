////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto;

import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class SHA256 {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function hash(s:String):String {
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes( s );
		var result:String = hashBytes( bytes );
		//bytes.clear();
		return result;
	}

	public static function hashBytes(bytes:ByteArray):String {
		return SHA2Helper.hashBytes(
			bytes,
			0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
		);
	}

}