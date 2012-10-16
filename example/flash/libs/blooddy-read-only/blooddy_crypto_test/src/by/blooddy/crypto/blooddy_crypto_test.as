////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import by.blooddy.crypto.serialization.JSONTest;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class blooddy_crypto_test {

		public var base64:Base64Test;
		public var adler32:Adler32Test;
		public var crc32:CRC32Test;
		public var md5:MD5Test;
		public var sha1:SHA1Test;
		public var sha256:SHA256Test;
		public var sha224:SHA224Test;
		public var json:JSONTest;

	}

}