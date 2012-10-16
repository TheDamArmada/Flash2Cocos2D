////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.04.2010 12:29:05
	 */
	public final class ObjectUtils {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _FUNCTION:QName = new QName( '', 'Function' );

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function toString(o:Object):String {
			return encodeValue( o, new Dictionary() );
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function encodeValue(value:*, list:Dictionary):String {
			switch ( typeof value ) {
				case 'number':		return ( isFinite( value ) ? value : 'null' );
				case 'boolean':		return value;
				case 'xml':			value = value.toXMLString();
				case 'string':		return '"' + encodeString( value ) + '"';
				case 'object':
					if ( value is XMLDocument ) return '"' + encodeString( ( value as XMLDocument ).toString() ) + '"';
					else if (
						value is Array ||
						value is Vector.<*> ||
						value is Vector.<uint> ||
						value is Vector.<int> ||
						value is Vector.<Number>
					) {
						return encodeArray( value, list );
					} else if ( value is Object ) {
						return encodeObject( value, list );
					}
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
			var c:String;
			var j:uint = 0;
			for ( var i:uint = 0; i<l; ++i ) {
				switch ( c = value.charAt( i ) ) {
					case '\r':	s = '\\r';	break;
					case '\n':	s = '\\n';	break;
					case '\t':	s = '\\t';	break;
					case '\v':	s = '\\v';	break;
					case '\b':	s = '\\b';	break;
					case '\f':	s = '\\f';	break;
					case '\\':	s = '\\\\';	break;
					case '"':	s = '\\"';	break;
					default:
						if ( c < '\x20' ) {
							s = c.charCodeAt( 0 ).toString( 16 );
							if ( s.length < 2 ) s = '0' + s;
							s = '\\x' + s;
						}
				}
				if ( s ) {
					result += value.substring( j, i ) + s;
					j = i + 1;
					s = null;
				}
			}
			result += value.substr( j );
			return result;
		}

		/**
		 * @private
		 */
		private static function encodeArray(value:Object, list:Dictionary):String {
			if ( value in list ) return '[link]';
			list[ value ] = true;
			var arr:Array = new Array();
			var l:int = value.length - 1;
			while ( l > 0 && value[ l ] == null ) {
				l--;
			}
			++l;
			for ( var i:uint = 0; i<l; ++i ) {
				arr.push( encodeValue( value[ i ], list ) );
			}
			delete list[ value ];
			return '[' + arr.join( ',' ) + ']';
		}

		/**
		 * @private
		 */
		private static function encodeObject(value:Object, list:Dictionary):String {
			if ( value in list ) return '[link]';
			list[ value ] = true;
			var hash:Object = new Object();
			var arr:Array = new Array();
			var info:TypeInfo = TypeInfo.getInfo( value );
			for each ( var prop:PropertyInfo in info.getProperties() ) {
				if ( prop.type == _FUNCTION ) continue;
				if ( !prop.name.uri ) {
					hash[ prop.name.toString() ] = true;
				}
				arr.push( prop.name + ':' + encodeValue( value[ prop.name ], list ) );
			}
			for ( var i:Object in value ) {
				if ( i in hash ) continue;
				hash[ i ] = true;
				if ( value[ i ] is Function ) continue;
				arr.push( i + ':' + encodeValue( value[ i ], list ) );
			}
			delete list[ value ];
			arr.sort();
			return '{' + arr.join( ',' ) + '}';
		}

	}

}
