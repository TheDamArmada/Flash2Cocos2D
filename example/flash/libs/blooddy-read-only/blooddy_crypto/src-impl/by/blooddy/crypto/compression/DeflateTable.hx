////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.compression;

import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
extern class DeflateTable {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function getDecodeTable():ByteArray;

	public static function getFixedTable():ByteArray;

}