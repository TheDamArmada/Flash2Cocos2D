////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image {

	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.06.2010 3:07:56
	 */
	public final class JPEGTable {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _quantTables:Array = new Array();

		/**
		 * @private
		 */
		private static var _jpegTable:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 *	     0:	   0:	0							[1]{1}
		 *			   1:	YTable						[1]{64}
		 *			  64:	0							[1]{1}
		 *			  65:	UVTable						[1]{64}
		 *			 130:	fdtbl_Y						[8]{64}
		 *			 642:	fdtbl_UV					[8]{64}
		 *
		 *	  1154:    0:	ZigZag						[1]{64}
		 *
		 *	  1218:    0:	0							[1]{1}
		 *			   1:	std_dc_luminance_nrcodes	[1]{16}
		 *			  17:	std_dc_luminance_values		[1]{12}
		 *			  29:	0							[1]{1}
		 *			  30:	std_ac_luminance_nrcodes	[1]{16}
		 *			  47:	std_ac_luminance_values		[1]{162}
		 *			 208:	0							[1]{1}
		 *			 209:	std_dc_chrominance_nrcodes	[1]{16}
		 *			 225:	std_dc_chrominance_values	[1]{12}
		 *			 237:	0							[1]{1}
		 *			 238:	std_ac_chrominance_nrcodes	[1]{16}
		 *			 254:	std_ac_chrominance_values	[1]{162}
		 *			 416:	YDC_HT						[1,2]{12}
		 *			 452:	YAC_HT						[1,2]{251}
		 *			1205:	UVDC_HT						[1,2]{12}
		 *			1241:	UVAC_HT						[1,2]{251}
		 *
		 *	  3212:	   0:	cat							[1,2]{65534}
		 *
		 *	199817:
		 */
		public static function getTable(quality:uint=60):ByteArray {
			if ( quality > 100 ) Error.throwError( RangeError, 2006, 'quality' );
			if ( quality < 1 ) quality = 1;
			var quantTable:ByteArray = _quantTables[ quality ];
			if ( !quantTable ) {
				quantTable = JPEGTableHelper.createQuantTable( quality );
				if ( !_jpegTable ) {
					_jpegTable = new ByteArray();
					_jpegTable.writeBytes( JPEGTableHelper.createZigZagTable() );
					_jpegTable.writeBytes( JPEGTableHelper.createHuffmanTable() );
					_jpegTable.writeBytes( JPEGTableHelper.createCategoryTable() );
				}
			}
			var result:ByteArray = new ByteArray();
			result.writeBytes( quantTable );
			result.writeBytes( _jpegTable );
			result.position = 0;
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
		public function JPEGTable() {
			super();
			Error.throwError( ArgumentError, 2012, getQualifiedClassName( this ) );
		}

	}
	
}