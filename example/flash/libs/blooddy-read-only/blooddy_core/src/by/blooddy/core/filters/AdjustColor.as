////////////////////////////////////////////////////////////////////////////////
//
//  © 2008 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.filters {

	import by.blooddy.core.utils.MathUtils;

	import flash.filters.ColorMatrixFilter;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class AdjustColor {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * constant for contrast calculations
		 */
		private static const _DELTA_INDEX:Vector.<Number> = new <Number>[
			0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
			0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
			0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
			0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 
			0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
			1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
			1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25, 
			2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
			4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
			7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8, 
			10.0
		];

		/**
		 * @private
		 * identity matrix constant
		 */
		private static const _IDENTITY_MATRIX:Array = new Array(
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0,
			0,	0,	0,	0,	1
		);

		/**
		 * @private
		 */
		private static const _LUM_R:Number = 0.212671;

		/**
		 * @private
		 */
		private static const _LUM_G:Number = 0.715160;

		/**
		 * @private
		 */
		private static const _LUM_B:Number = 0.072169;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public static function getFilter(hue:Number=0, saturation:Number=0, brightness:Number=0, contrast:Number=0, color32:uint=0x00000000):ColorMatrixFilter {
			var m:Array = _IDENTITY_MATRIX.slice();
			var value:Number, x:Number;
			if ( hue ) {

				while ( hue > Math.PI )		hue -= Math.PI * 2;
				while ( hue < -Math.PI )	hue += Math.PI * 2;

				if ( hue ) {
					const cos:Number = Math.cos( hue );
					const sin:Number = Math.sin( hue );
					m = multiplyMatrix(
						m,
						new Array(
							_LUM_R + cos * ( 1 - _LUM_R ) + sin * ( - _LUM_R ),		_LUM_G + cos * (   - _LUM_G ) + sin * ( - _LUM_G ),	_LUM_B + cos * (   - _LUM_B ) + sin * ( 1 - _LUM_B ),	0,		0,
							_LUM_R + cos * (   - _LUM_R ) + sin * ( 0.143 ),		_LUM_G + cos * ( 1 - _LUM_G ) + sin * (   0.140 ),	_LUM_B + cos * (   - _LUM_B ) + sin * ( - 0.283 ),		0,		0,
							_LUM_R + cos * (   - _LUM_R ) + sin * ( _LUM_R - 1 ),	_LUM_G + cos * (   - _LUM_G ) + sin * (   _LUM_G ),	_LUM_B + cos * ( 1 - _LUM_B ) + sin * (  _LUM_B ),		0,		0,
							0,													0,												0,													1,		0,
							0,													0,												0,													0,		1
						)
					);
				}

			}

			if ( saturation ) {

				saturation = MathUtils.validateRange( saturation, -1, 1 );

				x = 1 + ( saturation > 0 ? 3 : 1 ) * saturation;

				const lumR:Number = 0.3086 * ( 1 - x );
				const lumG:Number = 0.6094 * ( 1 - x );
				const lumB:Number = 0.0820 * ( 1 - x );

				m = multiplyMatrix(
					m,
					new Array(
						lumR + x,	lumG,		lumB,		0,	0,
						lumR,		lumG + x,	lumB,		0,	0,
						lumR,		lumG,		lumB + x,	0,	0,
						0,			0,			0,			1,	0,
						0,			0,			0,			0,	1
					)
				);
			}

			if ( brightness ) {
				brightness = MathUtils.validateRange( brightness, -1, 1 );
				value = brightness * 100;
				m = multiplyMatrix(
					m,
					new Array(
						1,	0,	0,	0,	value,
						0,	1,	0,	0,	value,
						0,	0,	1,	0,	value,
						0,	0,	0,	1,	0,
						0,	0,	0,	0,	1
					)
				);
			}

			if ( contrast ) {
				contrast = MathUtils.validateRange( contrast, -1, 1 );
				if ( contrast > 0 ) {
					value = contrast * 100;
					x = value % 1;
					value = int( value );
					if ( x ) {
						x = _DELTA_INDEX[ value ] * ( 1 - x ) + _DELTA_INDEX[ value+1 ] * x; // use linear interpolation for more granularity.
					} else {
						x = _DELTA_INDEX[ value ];
					}
				} else {
					x = contrast;
				}
				x = 127 + x * 127;
				m = multiplyMatrix(
					m,
					new Array(
						x / 127,	0,			0,			0,		( 127 - x ) / 2,
						0,			x / 127,	0,			0,		( 127 - x ) / 2,
						0,			0,			x / 127,	0,		( 127 - x ) / 2,
						0,			0,			0,			1,		0,
						0,			0,			0,			0,		1
					)
				);
			}

			if ( color32 > 0x00FFFFFF ) {

				const a:Number = ( ( color32 >> 24 ) & 0xFF ) / 0xFF;
				const r:Number = ( ( color32 >> 16 ) & 0xFF ) / 0xFF;
				const g:Number = ( ( color32 >> 8  ) & 0xFF ) / 0xFF;
				const b:Number = ( ( color32       ) & 0xFF ) / 0xFF;

				const inv_a:Number = 1 - a;

  				m = multiplyMatrix(
					new Array(
						a * r * _LUM_R + inv_a,		a * r * _LUM_G,				a * r * _LUM_B,				0,		0,
						a * g * _LUM_R,				a * g * _LUM_G + inv_a,		a * g * _LUM_B,				0,		0,
						a * b * _LUM_R,				a * b * _LUM_G,				a * b * _LUM_B + inv_a,		0,		0,
						0,							0,							0,							1,		0,
						0,							0,							0,							0,		1
					),
					m
				);
			}

			return new ColorMatrixFilter( m.slice( 0, 20 ) );

		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * multiplies one matrix against another
		 */
		private static function multiplyMatrix(m1:Array, m2:Array):Array {
			var tmp:Array;
			var i:uint, j:uint, k:uint, value:Number;
			var result:Array = new Array();
			for ( i=0; i<5; ++i ) {
				tmp = m1.slice( i * 5, ( i + 1 ) * 5 );
				for ( j=0; j<5; ++j ) {
					value = 0;
					for ( k=0; k<5; ++k ) {
						value += m2[ j + k * 5 ] * tmp[ k ];
					}
					result[ j + i * 5 ] = value;
				}
			}
			return result;
		}

	}

}