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
class SHA224 {

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
			0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939, 0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4
		);
	}

}