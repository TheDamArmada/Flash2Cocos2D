////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.math {

	import flash.utils.Endian;

	/**
	 * Всякие функи для работы с циферями.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					number, utils
	 */
	public final class NumberUtils {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Генерим случайное число.
		 * самая большая вероятность того, что число уникально это сгенерить
		 * его в зависимости от даты и прибавить рандом, если вдруг неповезёт :)
		 * 
		 * @param	date				Если передать дату, то будет взято не текущее
		 * 								время, а переданая дата (например серверное время)
		 * 
		 * @return						Псевдо случайное число.
		 */
		public static function getRND(date:Date=null):Number {
			return ( date || new Date() ).getTime() / 1000 + Math.random();
		}

		/**
		 * Rotates x left n bits
		 * 
		 * @param	x					
		 * @param	n					
		 * 
		 * @return						
		 */
		public static function rol(x:int, n:int):int {
			return ( x << n ) | ( x >>> ( 32 - n ) );
		}

		/**
		 * Rotates x right n bits
		 * 
		 * @param	x					
		 * @param	n					
		 * 
		 * @return						
		 */
		public static function ror(x:int, n:int):uint {
			n = 32 - n;
			return ( x << n ) | ( x >>> ( 32 - n ) );
		}

		/**
		 * @private
		 * String for quick lookup of a hex character based on index
		 */
		private static const hexChars:String = '0123456789abcdef';

		/**
		 * Outputs the hex value of a int, allowing the developer to specify
		 * the endinaness in the process.  Hex output is lowercase.
		 *
		 * @param	n					The int value to output as hex
		 * @param	endian				
		 * 
		 * @return						A string of length 8 corresponding to the hex representation of n ( minus the leading "0x" )
		 */
		public static function toHex(n:int, endian:String='littleEndian'):String {
			var s:String = '';

			switch ( endian ) {
				case Endian.BIG_ENDIAN:
					for ( var i:int = 0; i < 4; ++i ) {
						s +=	hexChars.charAt( ( n >> ( ( 3 - i ) * 8 + 4 ) ) & 0xF ) +
								hexChars.charAt( ( n >> ( ( 3 - i ) * 8	 ) ) & 0xF );
					}
					break;
				case Endian.LITTLE_ENDIAN:
					for ( var x:int = 0; x < 4; ++x ) {
						s +=	hexChars.charAt( ( n >> ( x * 8 + 4 ) ) & 0xF ) +
								hexChars.charAt( ( n >> ( x * 8 ) ) & 0xF );
					}
					break;
			}

			return s;
		}

		//количество знаков после запятой 
		public static function getFixedSize(value:Number):uint {
			var text:String = value.toString();
			var n:uint = text.indexOf(".") == -1 ? 0 : text.split(".")[1].length; 
			return n;
		} 

		public static function toFixed(value:Number, radix:uint=10, fractionDigits:int=0):String {
			var result:String = value.toString( radix ).toUpperCase();
			while ( result.length < -fractionDigits ) result = "0" + result;
			return result;
		}

	}

}