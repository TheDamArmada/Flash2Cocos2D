////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	
	import org.flexunit.Assert;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.11.2010 16:17:22
	 */
	public class Adler32Test {
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function hash():void {
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes( 'тестовая запсь для подсчёта crc' );
			Assert.assertEquals(
				by.blooddy.crypto.Adler32.hash( bytes ),
				0x216D245A
			);
		}
		
	}
	
}