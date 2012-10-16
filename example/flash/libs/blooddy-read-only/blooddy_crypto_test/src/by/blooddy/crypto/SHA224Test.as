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
	 * @created					12.10.2010 21:58:26
	 */
	public class SHA224Test {
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function hash_eng():void {
			Assert.assertEquals(
				SHA224.hash( 'asd' ),
				'cda1d665441ef8120c3d3e82610e74ab0d3b043763784676654d8ef1b364690c'
			);
		}
		
		[Test]
		public function hash_rus():void {
			Assert.assertEquals(
				SHA224.hash( 'фыв' ),
				'974f3e857dc28d67dc8ed73795860089588361cbf81a8898628c432931f243b3'
			);
		}
		
	}
	
}