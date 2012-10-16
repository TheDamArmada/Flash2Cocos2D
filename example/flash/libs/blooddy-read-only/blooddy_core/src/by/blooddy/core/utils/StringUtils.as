////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final class StringUtils {

		//------------------------------------------------
		//
		//  Class variables
		//
		//------------------------------------------------

		/**
		 * @private
		 */
		private static const htmlChars:Array = new Array(
			'&',	'&amp;',
			'"',	'&quot;',
			'<',	'&lt;',
			'>',	'&gt;'
		)

		//------------------------------------------------
		//
		//  Class methods
		//
		//------------------------------------------------

		public static function encodeHTML(text:String):String {
			for (var i:uint = 0; i<htmlChars.length; i+=2) {
				text = text.replace( new RegExp( htmlChars[ i ], 'g' ), htmlChars[ i+1 ] );
			}
			return text;
		}

		public static function decodeHTML(text:String):String {
			for (var i:uint = htmlChars.length-1; i<=0; i-=2 ) {
				text = text.replace( htmlChars[ i ], htmlChars[ i-1 ] );
			}
			return text;
		}

		private static const _TRIM_PATTERN:RegExp = /[^\s].*?(?=\s*$)/;

		public static function trim(text:String):String {
			var s:Array = _TRIM_PATTERN.exec( text );
			return ( s ? s[ 0 ] : '' );
		}

		public static function convertToConstName(name:String):String {
			return name.match( /\w[^A-Z]*/g ).join( '_' ).toUpperCase();
		}

		public static function convertFromConstName(name:String):String {
			var arr:Array = name.split( '_' );
			var result:String = ( arr.shift() as String ).toLowerCase();
			for each ( var word:String in arr ) {
				result += word.charAt( 0 ).toUpperCase() + word.substr( 1 ).toLowerCase();
			} 
			return result;
		}

		/**
		 * @param	flag	1 - цифры, 2 - хекс буквы, 4 - весь остальное алфавит
		 */
		public static function random(length:uint=16, flag:uint=3):String {
			var result:String = '';
			var c:uint;
			var chars:Array = new Array();
			var i:uint;
			if ( flag & 1 ) {
				for ( i=0; i<10; ++i ) {
					chars.push( i );
				}
			}
			if ( flag & 4 ) {
				for ( i=97; i<123; ++i ) {
					chars.push( String.fromCharCode( i ) );
				}
			} else {
				for ( i=97; i<103; ++i ) {
					chars.push( String.fromCharCode( i ) );
				}
			}
			while ( length-- ) {
				result += chars[ Math.round( ( chars.length - 1 ) * Math.random() )]
			}
			return result;
		}

	}

}