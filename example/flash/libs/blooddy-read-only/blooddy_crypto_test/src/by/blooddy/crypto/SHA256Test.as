////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import org.flexunit.Assert;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.10.2010 21:54:52
	 */
	public class SHA256Test {
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function hash_eng():void {
			Assert.assertEquals(
				SHA256.hash( 'asd' ),
				'688787d8ff144c502c7f5cffaafe2cc588d86079f9de88304c26b0cb99ce91c6'
			);
		}
		
		[Test]
		public function hash_rus():void {
			Assert.assertEquals(
				SHA256.hash( 'фыв' ),
				'6ce2b11b62f74576177a63f621be551a946ca1a6f857f44efcbd92a940cbb123'
			);
		}
		
	}
	
}