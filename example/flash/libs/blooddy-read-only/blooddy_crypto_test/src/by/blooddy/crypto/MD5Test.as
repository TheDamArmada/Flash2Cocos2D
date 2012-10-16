////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import org.flexunit.asserts.assertEquals;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class MD5Test {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function hash_eng():void {
			assertEquals(
				MD5.hash( 'asd' ),
				'7815696ecbf1c96e6894b779456d330e'
			);
		}

		[Test]
		public function hash_rus():void {
			assertEquals(
				MD5.hash( 'фыв' ),
				'809336c0a3882d1f9865b50eaa4b6f9b'
			);
		}
		
	}

}