////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.xml {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					xml
	 */
	public final class XMLUtils {

		public static function parseToString(xml:XML):String {
			if ( !xml )	return null;
			return xml.toString() || null;
		}

		public static function parseToDate(xml:XML):Date {
			if ( !xml ) return new Date();
			return new Date( Date.parse( xml.toString() ) );
		}

		public static function parseToInt(xml:XML):int {
			if ( !xml ) return 0;
			return parseInt( xml.toString() );
		}

		public static function parseToBoolean(xml:XML):Boolean {
			if ( !xml ) return false;
			return parseBoolean( xml.toString() );
		}

		public static function parseListToString(list:XMLList):String {
			return parseToString( list.length() > 0 ? list[0] : null );
		}

		public static function parseListToDate(list:XMLList):Date {
			return parseToDate( list.length() > 0 ? list[0] : null );
		}

		public static function parseListToInt(list:XMLList):int {
			return parseToInt( list.length() > 0 ? list[0] : null );
		}

		public static function parseListToBoolean(list:XMLList):Boolean {
			return parseToBoolean( list.length() > 0 ? list[0] : null );
		}

	}

}