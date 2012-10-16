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
	 * @created					07.10.2010 20:08:51
	 */
	public class Base64Test {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		private static const _BYTES_SHORT:ByteArray = new ByteArray();
		_BYTES_SHORT.writeUTFBytes( 'short bytes!' );

		private static const _BYTES_LONG:ByteArray = new ByteArray();
		_BYTES_LONG.writeUTFBytes( 'long bytes 123 long bytes 456 long bytes 789 long bytes ds\fds afsd fsdlong bytes long bytes long bs adfasd fasd fsaf sadytes long bytes long bytes lonas dfsd saf0-9adsf-9 jmpslflksacg bytes long bytes long bytes long bytes long bytes longasdfasdfasd fsd f0f7 s0dfs98u0s7di9sf y9bu	bytes long bytes long bytes long bytes long bytes long bytes long bytes' );
		
		private static const _STRING_SHORT:String = 'c2hvcnQgYnl0ZXMh';

		private static const _STRING_LONG:String = 'bG9uZyBieXRlcyAxMjMgbG9uZyBieXRlcyA0NTYgbG9uZyBieXRlcyA3ODkgbG9uZyBieXRlcyBkcwxkcyBhZnNkIGZzZGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJzIGFkZmFzZCBmYXNkIGZzYWYgc2FkeXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uYXMgZGZzZCBzYWYwLTlhZHNmLTkgam1wc2xmbGtzYWNnIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZ2FzZGZhc2RmYXNkIGZzZCBmMGY3IHMwZGZzOTh1MHM3ZGk5c2YgeTlidQlieXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZyBieXRlcw==';

		private static const _STRING_LONG_NEWLINES:String =	'bG9uZyBieXRlcyAxMjMgbG9uZyBieXRlcyA0NTYgbG9uZyBieXRlcyA3ODkgbG9uZyBieXRlcyBk\n' +
															'cwxkcyBhZnNkIGZzZGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJzIGFkZmFzZCBmYXNkIGZz\n' +
															'YWYgc2FkeXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uYXMgZGZzZCBzYWYwLTlhZHNmLTkg\n' +
															'am1wc2xmbGtzYWNnIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJ5dGVzIGxvbmcg\n' +
															'Ynl0ZXMgbG9uZ2FzZGZhc2RmYXNkIGZzZCBmMGY3IHMwZGZzOTh1MHM3ZGk5c2YgeTlidQlieXRl\n' +
															'cyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMgbG9uZyBieXRlcyBsb25nIGJ5dGVzIGxvbmcgYnl0ZXMg\n' +
															'bG9uZyBieXRlcw==';

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		private static function equalsBytes(b1:ByteArray, b2:ByteArray):Boolean {
			var l:uint = b1.length;
			if ( l != b2.length ) return false;
			for ( var i:uint = 0; i<l; ++i ) {
				if ( b1[ i ] != b2[ i ] ) {
					return false;
				}
			}
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		[Test]
		public function encode_short():void {
			Assert.assertEquals(
				Base64.encode( _BYTES_SHORT ),
				_STRING_SHORT
			);
		}

		[Test]
		public function encode_long():void {
			Assert.assertEquals(
				Base64.encode( _BYTES_LONG ),
				_STRING_LONG
			);
		}
		
		[Test]
		public function encode_long_newlines():void {
			Assert.assertEquals(
				Base64.encode( _BYTES_LONG, true ),
				_STRING_LONG_NEWLINES
			);
		}

		[Test]
		public function decode_short():void {
			Assert.assertTrue(
				equalsBytes(
					Base64.decode( _STRING_SHORT ),
					_BYTES_SHORT
				)
			);
		}
		
		[Test]
		public function decode_long():void {
			Assert.assertTrue(
				equalsBytes(
					Base64.decode( _STRING_LONG ),
					_BYTES_LONG
				)
			);
		}
		
		[Test]
		public function decode_long_newlines():void {
			Assert.assertTrue(
				equalsBytes(
					Base64.decode( _STRING_LONG_NEWLINES ),
					_BYTES_LONG
				)
			);
		}
		
	}
	
}