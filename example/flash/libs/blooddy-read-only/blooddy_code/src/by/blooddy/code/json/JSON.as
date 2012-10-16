////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.json {

	import by.blooddy.code.utils.Char;
	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	
	import flash.xml.XMLDocument;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.03.2010 19:48:48
	 */
	public final class JSON {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _parser:JSONParser = new JSONParser();

		/**
		 * @private
		 */
		private static const _FUNCTION:QName = new QName( '', 'Function' );
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function decode(value:String):* {
			return _parser.parse( value );
		}

		public static function encode(value:*):String {
			return encodeValue( value, new Array() );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function encodeValue(value:*, list:Array):String {
			switch ( typeof value ) {
				case 'number':		return ( isFinite( value ) ? value : 'null' );
				case 'boolean':		return value;
				case 'xml':			value = value.toXMLString();
				case 'string':		return encodeString( value );
				case 'object':
					if ( value is XMLDocument ) return encodeString( ( value as XMLDocument ).toString() );
					else if (
						value is Array ||
						value is Vector.<*> ||
						value is Vector.<uint> ||
						value is Vector.<int> ||
						value is Vector.<Number>
					)	return encodeArray( value, list );
					else if ( value is Object ) return encodeObject( value, list );
					break;
			}
			return 'null';
		}
		
		/**
		 * @private
		 */
		private static function encodeString(value:String):String {
			var result:String = '';
			var l:uint = value.length;
			var s:String;
			var c:uint;
			var j:uint = 0;
			for ( var i:uint = 0; i<l; ++i ) {
				switch ( c = value.charCodeAt( i ) ) {
					case Char.CARRIAGE_RETURN:	s = '\\r';	break;
					case Char.NEWLINE:			s = '\\n';	break;
					case Char.TAB:				s = '\\t';	break;
					case Char.VERTICAL_TAB:		s = '\\v';	break;
					case Char.BACKSPACE:		s = '\\b';	break;
					case Char.FORM_FEED:		s = '\\f';	break;
					case Char.BACK_SLASH:		s = '\\\\';	break;
					case Char.DOUBLE_QUOTE:		s = '\\"';	break;
					default:
						if ( c < 32 ) {
							s = '\\x' + ( c < 16 ? '0' : '' ) + c.toString( 16 );
						}
						break;
				}
				if ( s ) {
					result += value.substring( j, i ) + s;
					j = i + 1;
					s = null;
				}
			}
			result += value.substr( j );
			return '"' + result + '"';
		}

		/**
		 * @private
		 */
		private static function encodeArray(value:Object, list:Array):String {
			if ( list.indexOf( value ) >= 0 ) throw new ArgumentError();
			list.push( value );
			var arr:Array = new Array();
			var l:int = value.length - 1;
			while ( l > 0 && value[ l ] == null ) {
				l--;
			}
			++l;
			for ( var i:uint = 0; i<l; ++i ) {
				arr.push( encodeValue( value[ i ], list ) );
			}
			list.pop();
			return '[' + arr.join( ',' ) + ']';
		}

		/**
		 * @private
		 */
		private static function encodeObject(value:Object, list:Array):String {
			if ( list.indexOf( value ) >= 0 ) throw new ArgumentError();
			list.push( value );
			var hash:Object = new Object();
			var arr:Array = new Array();
			var info:TypeInfo = TypeInfo.getInfo( value );
			for each ( var prop:PropertyInfo in info.getProperties() ) {
				if ( prop.type == _FUNCTION ) continue;
				if ( !prop.name.uri ) {
					hash[ prop.type.toString() ] = true;
				}
				arr.push( '"' + prop.name + '":' + encodeValue( value[ prop.name ], list ) );
			}
			for ( var i:Object in value ) {
				if ( i in hash ) continue;
				if ( value[ i ] is Function ) continue;
				arr.push( '"' + i + '":' + encodeValue( value[ i ], list ) );
			}
			list.pop();
			//arr.sort();
			return '{' + arr.join( ',' ) + '}';
		}

	}

}