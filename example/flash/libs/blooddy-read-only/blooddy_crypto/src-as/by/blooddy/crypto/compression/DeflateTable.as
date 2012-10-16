////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.compression {

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getQualifiedClassName;
	
	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.11.2010 13:26:33
	 */
	public class DeflateTable {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var _fixedTable:ByteArray;
		
		/**
		 * @private
		 */
		private static var _decodeTable:ByteArray;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getDecodeTable():ByteArray {
			if ( !_decodeTable ) _decodeTable = createDecodeTable();
			var result:ByteArray = new ByteArray();
			result.writeBytes( _decodeTable );
			result.position = 0;
			return result;
		}
		
		public static function getFixedTable():ByteArray {
			if ( !_fixedTable ) _fixedTable = createFixedTable();
			var result:ByteArray = new ByteArray();
			result.writeBytes( _fixedTable );
			result.position = 0;
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
		private static function createDecodeTable():ByteArray {

			var c:uint;
			var v:Vector.<uint>;
			var result:ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;

			// LENS: Size base for length codes 257..285
			result.writeUTFBytes( '\x03\x00\x04\x00\x05\x00\x06\x00\x07\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x0d\x00\x0f\x00\x11\x00\x13\x00\x17\x00\x1b\x00\x1f\x00\x23\x00\x2b\x00\x33\x00\x3b\x00\x43\x00\x53\x00\x63\x00\x73\x00' );
			v = new <uint>[ 131, 163, 195, 227, 258 ];
			for each ( c in v ) {
				result.writeShort( c );
			}

			// LEXT: Extra bits for length codes 257..285
			result.writeUTFBytes( '\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x01\x02\x02\x02\x02\x03\x03\x03\x03\x04\x04\x04\x04\x05\x05\x05\x05\x00' );

			// DISTS: Offset base for distance codes 0..29
			result.writeUTFBytes( '\x01\x00\x02\x00\x03\x00\x04\x00\x05\x00\x07\x00\x09\x00\x0d\x00\x11\x00\x19\x00\x21\x00\x31\x00\x41\x00\x61\x00' );
			v = new <uint>[ 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577 ];
			for each ( c in v ) {
				result.writeShort( c );
			}

			// DEXT: Extra bits for distance codes 0..29
			result.writeUTFBytes( '\x00\x00\x00\x00\x01\x01\x02\x02\x03\x03\x04\x04\x05\x05\x06\x06\x07\x07\x08\x08\x09\x09\x0a\x0a\x0b\x0b\x0c\x0c\x0d\x0d' );

			return result;

		}

		/**
		 * @private
		 */
		private static function createFixedTable():ByteArray {

			var result:ByteArray = new ByteArray();
			result.length =	1408; // 4 + 16 * 4 + 288 * 4 + 4 + 16 * 4 +  30 * 4;
			result.endian = Endian.LITTLE_ENDIAN;
			
			var i:uint;
			
			// LITERAL / LENGTH TABLE
			// count
			result.position += 28; // 7 * 4;
			result.writeUnsignedInt( 24 );
			result.writeUnsignedInt( 152 );
			result.writeUnsignedInt( 112 );
			result.position += 24; // 6 * 4;
			// symbol
			for ( i=256; i<280; i++ ) result.writeUnsignedInt( i );
			for ( i=  0; i<144; i++ ) result.writeUnsignedInt( i );
			for ( i=280; i<288; i++ ) result.writeUnsignedInt( i );
			for ( i=144; i<256; i++ ) result.writeUnsignedInt( i );

			// DISTANCE TABLE
			// count
			result.position += 20; // 5 * 4;
			result.writeUnsignedInt( 30 );
			result.position += 40; // 10 * 4;
			// symbol
			for ( i=  0; i<30; i++ ) result.writeUnsignedInt( i );

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
		public function DeflateTable() {
			super();
			Error.throwError( ArgumentError, 2012, getQualifiedClassName( this ) );
		}
		
	}
	
}