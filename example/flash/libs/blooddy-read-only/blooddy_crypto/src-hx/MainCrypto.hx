////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package;

import by.blooddy.crypto.Adler32;
import by.blooddy.crypto.Base64;
import by.blooddy.crypto.compression.Deflate;
import by.blooddy.crypto.compression.LZW;
import by.blooddy.crypto.CRC32;
import by.blooddy.crypto.image.JPEGEncoder;
import by.blooddy.crypto.image.JPEGTableHelper;
import by.blooddy.crypto.image.palette.MedianCutPaletteHelper;
import by.blooddy.crypto.image.PNG24Encoder;
import by.blooddy.crypto.image.PNG8Encoder;
import by.blooddy.crypto.MD5;
import by.blooddy.crypto.serialization.JSON;
import by.blooddy.crypto.SHA1;
import by.blooddy.crypto.SHA224;
import by.blooddy.crypto.SHA256;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class MainCrypto {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	static function main() {
		SHA1;
		SHA256;
		SHA224;
		MD5;
		Base64;
		Adler32;
		CRC32;
		JPEGEncoder;
		JPEGTableHelper;
		PNG8Encoder;
		PNG24Encoder;
		MedianCutPaletteHelper;
		LZW;
		JSON;
		Deflate;
	}

}