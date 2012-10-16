////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.net.domain;
	import by.blooddy.crypto.MD5;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.02.2010 0:00:34
	 */
	public final class UID {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function generate():String {
			var hash:String;
			do {
				hash = MD5.hash( Math.random() + '-' + domain + '-' + Math.random() + '-' + ( new Date() ).getTime() + '-' + Math.random() );
			} while ( hash in _hash );
			_hash[ hash ] = true;
			return (
				hash.substr( 0, 8 ) + '-' +
				hash.substr( 8, 4 ) + '-' +
				hash.substr( 12, 4 ) + '-' +
				hash.substr( 16, 4 ) + '-' +
				hash.substr( 20 )
			).toUpperCase();
		}

	}
	
}