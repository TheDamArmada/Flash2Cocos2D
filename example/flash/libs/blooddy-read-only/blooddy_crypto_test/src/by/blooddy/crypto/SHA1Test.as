////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import org.flexunit.Assert;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class SHA1Test {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function hash_eng():void {
			Assert.assertEquals(
				SHA1.hash( 'asd' ),
				'f10e2821bbbea527ea02200352313bc059445190'
			);
		}

		[Test]
		public function hash_rus():void {
			Assert.assertEquals(
				SHA1.hash( 'фыв' ),
				'00b7df541a0bb6bb33926bda2eeb202cfd75056d'
			);
		}
		
	}

}