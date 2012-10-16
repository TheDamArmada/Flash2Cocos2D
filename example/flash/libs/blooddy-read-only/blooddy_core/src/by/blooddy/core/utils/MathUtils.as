////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final /*abstract*/ class MathUtils {

		public static function convertRadix(value:String, inRadix:uint=10, outRadix:uint=10):String {
			if ( inRadix < 2 || inRadix > 36 ) {
				throw new RangeError( "Error #1003: The radix argument must be between 2 and 36; got " + inRadix + "." );
			}
			if ( outRadix < 2 || outRadix > 36 ) {
				throw new RangeError( "Error #1003: The radix argument must be between 2 and 36; got " + outRadix + "." );
			}

			if ( inRadix == outRadix ) return value;

			var hash:Array = new Array();
			var l:uint = value.length;

			var i:int;
			var c:Number;
			var hl:uint, pos:uint;
			var v:uint, rest:uint;
			for ( i = 0; i < l; ++i ) {
				c = parseInt( value.charAt( i ), inRadix );
				if ( isNaN( c ) ) throw new ArgumentError();
				v = c;
				rest = 0;
				pos = 0;
				hl = hash.length;
				do {
					rest += uint( hash[ pos ] ) * inRadix;
					v += rest % outRadix;
					hash[ pos ] = v % outRadix;
					rest =	rest / outRadix;
					v =		v / outRadix;
					pos += 1;
				} while ( pos <= hl || rest || v );
			}

			var result:String = "";
			i = hash.length;
			while ( i-- && hash[ i ] == 0 ) {};
			++i;
			while ( i-- ) {
				result += hash[ i ].toString( outRadix );
			}
			return result;
		}

		public static function disintegrate(value:uint):Array {
			var result:Array = new Array();
			for ( var i:uint = 1; i<=value; i<<=1 ) {
				if ( value & i ) {
					result.push( i );
				}
			}
			return result;
		}

		public static function validateRange(value:Number, min:Number, max:Number):Number {
			if ( value < min ) value = min;
			else if ( value > max ) value = max;
			return value;
		}

	}

}