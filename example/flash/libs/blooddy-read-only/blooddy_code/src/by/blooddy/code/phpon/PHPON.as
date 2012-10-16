////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.phpon {

	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	
	import flash.utils.ByteArray;
	import flash.xml.XMLDocument;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.06.2010 21:00:25
	 */
	public final class PHPON {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _parser:PHPONParser = new PHPONParser();
		
		/**
		 * @private
		 */
		private static const _FUNCTION:QName = new QName( '', 'Function' );

		/**
		 * @private
		 */
		private static const _JUNK:ByteArray = new ByteArray();
		
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
			var b:ByteArray;
			switch ( typeof value ) {
				case 'number':
					var v:Number = ( isFinite( value ) ? value : 0 );
					if ( v % 1 || v > 1e20 || v < -1e20 ) {
						return 'd:' + v.toString().toUpperCase() + ';';
					} else {
						return 'i:' + v + ';';
					}
					break;
				case 'boolean':		return 'b:' + ( value ? 1 : 0 ) + ';';
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
			return 'N;';
		}

		/**
		 * @private
		 */
		private static function encodeString(value:String):String {
			_JUNK.length = 0;
			_JUNK.writeUTFBytes( value );
			return 's:' + _JUNK.length + ':"' + value + '";';
		}

		/**
		 * @private
		 */
		private static function encodeArray(value:Object, list:Array):String {
			if ( list.indexOf( value ) >= 0 ) throw new ArgumentError();
			list.push( value );
			var result:String = '';
			var l:uint = 0;
			for ( var i:Object in value ) {
				result += encodeValue( i, list ) + encodeValue( value[ i ], list );
				l++;
			}
			list.pop();
			return 'a:' + l + ':{' + result + '}';
		}
		
		/**
		 * @private
		 */
		private static function encodeObject(value:Object, list:Array):String {
			if ( list.indexOf( value ) >= 0 ) throw new ArgumentError();
			list.push( value );
			var hash:Object = new Object();
			var result:String = '';
			var l:uint = 0;
			var info:TypeInfo = TypeInfo.getInfo( value );
			for each ( var prop:PropertyInfo in info.getProperties() ) {
				if ( prop.type == _FUNCTION ) continue;
				if ( !prop.name.uri ) {
					hash[ prop.name.toString() ] = true;
				}
				result += encodeValue( prop.name.toString(), list ) + encodeValue( value[ prop.name ], list );
				l++;
			}
			for ( var i:Object in value ) {
				if ( i in hash ) continue;
				if ( value[ i ] is Function ) continue;
				result += encodeValue( i, list ) + encodeValue( value[ i ], list );
				l++;
			}
			list.pop();
			//arr.sort();
			return 'O:8:"stdClass":' + l + ':{' + result + '}';
		}
		
	}
	
}