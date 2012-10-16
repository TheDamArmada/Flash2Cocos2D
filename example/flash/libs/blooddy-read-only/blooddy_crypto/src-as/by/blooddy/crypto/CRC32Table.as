////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto {

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.10.2010 20:06:26
	 */
	public final class CRC32Table {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _table:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getTable():ByteArray {
			if ( !_table ) _table = createTable();
			var result:ByteArray = new ByteArray();
			result.writeBytes( _table );
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function createTable():ByteArray {
			var result:ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;

			var c:uint;
			var j:uint;
			var i:uint;
			for ( i=0; i<256; ++i ) {
				c = i;
				for ( j=0; j<8; ++j ) {
					if ( c & 1 == 1 ) {
						c = 0xEDB88320 ^ ( c >>> 1 );
					} else {
						c >>>= 1;
					}
				}
				result.writeUnsignedInt( c );
			}

			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function CRC32Table() {
			super();
			Error.throwError( ArgumentError, 2012, getQualifiedClassName( this ) );
		}

	}

}