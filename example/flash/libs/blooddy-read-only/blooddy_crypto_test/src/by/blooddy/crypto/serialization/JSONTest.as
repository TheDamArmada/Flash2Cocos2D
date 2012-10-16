////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {

	import flash.xml.XMLDocument;
	
	import org.flexunit.Assert;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class JSONTest {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function equalsObjects(o1:Object, o2:Object):Boolean {
			
			if ( o1 == o2 ) return true;
			
			if ( !o1 || !o2 ) return false;
			if ( o1.constructor !== o2.constructor ) return false;
			
			if ( o1 is Array ) {
				if ( o1.length != o2.length ) return false;
			}
			
			var i:Object;
			for ( i in o1 ) {
				if ( !( i in o2 ) ) return false;
				else if ( o1[ i ] != o2[ i ] ) {
					switch ( typeof o1[ i ] ) {
						case 'object':
							if ( !equalsObjects( o1[ i ], o2[ i ] ) ) {
								return false;
							}
							break;
						case 'number':
							if ( isFinite( o1[ i ] ) || isFinite( o2[ i ] ) ) {
								return false;
							}
							break;
					}
				}
			}
			
			for ( i in o2 ) {
				if ( !( i in o2 ) ) return false;
			}
			
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Test( expects="TypeError" )]
		public function decode_value_null():void {
			JSON.decode( null );
		}
		
		[Test]
		public function decode_value_empty():void {
			Assert.assertTrue(
				JSON.decode( '' ) === undefined
			);
		}
		
		[Test]
		public function decode_undefined():void {
			// assertStrictlyEquals not work with undefined
			Assert.assertTrue(
				JSON.decode( 'undefined' ) === undefined
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_identifier():void {
			JSON.decode( 'identifier' );
		}
		
		[Test]
		public function decode_true():void {
			Assert.assertTrue(
				JSON.decode( 'true' )
			);
		}
		
		[Test]
		public function decode_false():void {
			Assert.assertFalse(
				JSON.decode( 'false' )
			);
		}
		
		[Test]
		public function decode_null():void {
			Assert.assertNull(
				JSON.decode( 'null' )
			);
		}
		
		[Test]
		public function decode_string():void {
			Assert.assertEquals(
				JSON.decode( '"string"' ),
				'string'
			);
			Assert.assertEquals(
				JSON.decode( "'string'" ),
				'string'
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_string_noclose():void {
			JSON.decode( '"string' );
		}
		
		[Test]
		public function decode_string_escape():void {
			Assert.assertEquals(
				JSON.decode( '"\\x33\\u0044\\t\\n\\b\\r\\t\\v\\f\\\\\\""' ),
				'\x33\u0044\t\n\b\r\t\v\f\\\"'
			);
		}
		
		[Test]
		public function decode_string_nonescape():void {
			Assert.assertEquals(
				JSON.decode( '"\\x3\\u044\\5"' ),
				'\x3\u044\5'
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_sring_newline():void {
			JSON.decode( '"firs\nsecond"' );
		}
		
		[Test]
		public function decode_number_zero():void {
			Assert.assertEquals(
				JSON.decode( '0' ),
				0
			);
		}
		
		[Test]
		public function decode_number_firstzero():void {
			Assert.assertEquals(
				JSON.decode( '01' ),
				01
			);
			Assert.assertEquals(
				JSON.decode( '002' ),
				002
			);
		}
		
		[Test]
		public function decode_number_positive():void {
			Assert.assertEquals(
				JSON.decode( '123' ),
				123
			);
		}
		
		[Test]
		public function decode_number_float():void {
			Assert.assertEquals(
				JSON.decode( '1.123' ),
				1.123
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonfloat():void {
			JSON.decode( '1.' );
		}
		
		[Test]
		public function decode_number_float_witoutLeadZero():void {
			Assert.assertEquals(
				JSON.decode( '.123' ),
				.123
			);
		}
		
		public function decode_number_exp():void {
			Assert.assertEquals(
				JSON.decode( '1E3' ),
				1e3
			);
			Assert.assertEquals(
				JSON.decode( '1e-3' ),
				1e-3
			);
			Assert.assertEquals(
				JSON.decode( '1e+3' ),
				1e+3
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonexp():void {
			JSON.decode( '1E' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_floatexp():void {
			JSON.decode( '1E1.2' );
		}
		
		[Test]
		public function decode_number_hex():void {
			Assert.assertEquals(
				JSON.decode( '0xFF' ),
				0xFF
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonhex():void {
			JSON.decode( '0x' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_number_nonhex2():void {
			JSON.decode( '0xZ' );
		}
		
		[Test]
		public function decode_number_NaN():void {
			Assert.assertTrue(
				isNaN( JSON.decode( 'NaN' ) )
			);
		}
		
		[Test]
		public function decode_dash_number():void {
			Assert.assertEquals(
				JSON.decode( '-  \n 5' ),
				-5
			);
		}
		
		[Test]
		public function decode_dash_undefined():void {
			Assert.assertTrue(
				isNaN( JSON.decode( '-undefined' ) )
			);
		}
		
		[Test]
		public function decode_dash_null():void {
			Assert.assertEquals(
				JSON.decode( '-null' ),
				-null
			);
		}
		
		[Test]
		public function decode_dash_NaN():void {
			Assert.assertTrue(
				isNaN( JSON.decode( '-NaN' ) )
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_dash_false():void {
			JSON.decode( '-false' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_dash_true():void {
			JSON.decode( '-true' );
		}
		
		[Test]
		public function decode_object_empty():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '{}' ),
					{}
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_leadComma():void {
			JSON.decode( '{,}' );
		}
		
		[Test]
		public function decode_object_key_string():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '{"key":"value"}' ),
					{"key":"value"}
				)
			);
		}
		
		[Test]
		public function decode_object_key_nonstring():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '{key1:"value1",5:"value2"}' ),
					{key1:"value1",5:"value2"}
				)
			);
		}
		
		[Test]
		public function decode_object_key_undefined_NaN():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '{undefined:1,NaN:2}' ),
					{undefined:1,NaN:2}
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_null():void {
			JSON.decode( '{null:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_false():void {
			JSON.decode( '{false:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_key_true():void {
			JSON.decode( '{true:1}' );
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_object_noclose():void {
			JSON.decode( '{key1:"value1"' );
		}
		
		[Test]
		public function decode_array_empty():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '[]' ),
					[]
				)
			);
		}
		
		[Test]
		public function decode_array_trailComma():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '[,,,]' ),
					[,,,]
				)
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_array_withIdentifier():void {
			JSON.decode( '[identifier]' );
		}
		
		[Test]
		public function decode_comment_line():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '5// comment' ),
					5// comment
				)
			);
		}
		
		[Test]
		public function decode_comment_multiline():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '[1/* line1\nline2*/,2]' ),
					[1/* line1\nline2*/,2]
				)
			);
		}
		
		[Test]
		public function decode_comment_only():void {
			Assert.assertTrue(
				JSON.decode( '// comment' ) === undefined
			);
		}
		
		[Test( expects="SyntaxError" )]
		public function decode_multilineComments_noclose():void {
			JSON.decode( '1/* comment' );
		}
		
		[Test]
		public function decode_object_all():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( '{key1: {"key2" /*comment\r222\n*/: null},// comment\n   3 : [undefined,true,false,\n-   .5e3,"string",				NaN]}' ),
					{ key1: { "key2" : null }, 3 : [ undefined, true, false, -.5e3, "string", NaN ] }
				)
			);
		}
		
		[Test]
		public function encode_null():void {
			Assert.assertEquals(
				JSON.encode( null ),
				'null'
			);
		}
		
		[Test]
		public function encode_undefined():void {
			Assert.assertEquals(
				JSON.encode( undefined ),
				'null'
			);
		}
		
		[Test]
		public function encode_notFinite():void {
			Assert.assertEquals(
				JSON.encode( NaN ),
				'null'
			);
			Assert.assertEquals(
				JSON.encode( Number.NEGATIVE_INFINITY ),
				'null'
			);
			Assert.assertEquals(
				JSON.encode( Number.POSITIVE_INFINITY ),
				'null'
			);
		}
		
		[Test]
		public function encode_number_positive():void {
			Assert.assertEquals(
				JSON.encode( 5 ),
				'5'
			);
		}
		
		[Test]
		public function encode_number_negative():void {
			Assert.assertEquals(
				JSON.encode( -5 ),
				'-5'
			);
		}
		
		[Test]
		public function encode_false():void {
			Assert.assertEquals(
				JSON.encode( false ),
				'false'
			);
		}
		
		[Test]
		public function encode_true():void {
			Assert.assertEquals(
				JSON.encode( true ),
				'true'
			);
		}
		
		[Test]
		public function encode_string():void {
			Assert.assertEquals(
				JSON.encode( 'asd' ),
				'"asd"'
			);
		}
		
		[Test]
		public function encode_string_enpty():void {
			Assert.assertEquals(
				JSON.encode( '' ),
				'""'
			);
		}
		
		[Test]
		public function encode_string_escape():void {
			Assert.assertEquals(
				JSON.encode( '\x33\u0044\t\n\b\r\t\v\f\\"' ),
				'"\x33\u0044\\t\\n\\b\\r\\t\\v\\f\\\\\\""'
			);
		}
		
		[Test]
		public function encode_string_nonescape():void {
			Assert.assertEquals(
				JSON.encode( '\x3\u044\5' ),
				'"\x3\u044\5"'
			);
		}
		
		[Test]
		public function encode_xml():void {
			Assert.assertEquals(
				JSON.encode( <xml field="098"><node field="123" /></xml> ),
				'"<xml field=\\"098\\"><node field=\\"123\\"\\/><\\/xml>"'
			);
		}
		
		[Test]
		public function encode_xmlDocument():void {
			Assert.assertEquals(
				JSON.encode( new XMLDocument( '<xml field="098">\n         <node            field = "123" />\n\r\t</xml>' ) ),
				'"<xml field=\\"098\\"><node field=\\"123\\"\\/><\\/xml>"'
			);
		}
		
		[Test]
		public function encode_xml_empty():void {
			Assert.assertEquals(
				JSON.encode( new XML() ),
				'""'
			);
		}
		
		[Test]
		public function encode_xmlDocument_empty():void {
			Assert.assertEquals(
				JSON.encode( new XMLDocument() ),
				'""'
			);
		}
		
		[Test]
		public function encode_array_empty():void {
			Assert.assertEquals(
				JSON.encode( [] ),
				'[]'
			);
		}
		
		[Test]
		public function encode_array_trailComma():void {
			Assert.assertEquals(
				JSON.encode( [5,,,] ),
				'[5]'
			);
			Assert.assertEquals(
				JSON.encode( new Array( 100 ) ),
				'[]'
			);
		}
		
		[Test]
		public function encode_array_leadComma():void {
			Assert.assertEquals(
				JSON.encode( [,,5] ),
				'[null,null,5]'
			);
		}
		
		[Test]
		public function encode_vector_empty():void {
			Assert.assertEquals(
				JSON.encode( new <*>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <SimpleClass>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <uint>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <int>[] ),
				'[]'
			);
			Assert.assertEquals(
				JSON.encode( new <Number>[] ),
				'[]'
			);
		}
		
		[Test]
		public function encode_vector_int():void {
			Assert.assertEquals(
				JSON.encode( new <uint>[1,5,6] ),
				'[1,5,6]'
			);
			Assert.assertEquals(
				JSON.encode( new <int>[1,-5,6] ),
				'[1,-5,6]'
			);
		}
		
		[Test]
		public function encode_vector_number():void {
			Assert.assertEquals(
				JSON.encode( new <Number>[1.555,0.5e-1,6,NaN] ),
				'[1.555,0.05,6]'
			);
		}
		
		[Test]
		public function encode_vector_object():void {
			Assert.assertEquals(
				JSON.encode( new <*>[{},5,null] ),
				'[{},5]'
			);
		}
		
		[Test]
		public function encode_object_empty():void {
			Assert.assertEquals(
				JSON.encode( {} ),
				'{}'
			);
		}
		
		[Test]
		public function encode_object_key_string():void {
			Assert.assertEquals(
				JSON.encode( { "string key": "value" } ),
				'{"string key":"value"}'
			);
		}
		
		[Test]
		public function encode_object_key_nonstring():void {
			Assert.assertEquals(
				JSON.encode( { key: "value", 5:true } ),
				'{"5":true,"key":"value"}'
			);
		}
		
		[Test]
		public function encode_object_key_undefined_NaN():void {
			Assert.assertEquals(
				JSON.encode( {undefined:1,NaN:2} ),
				'{"NaN":2,"undefined":1}'
			);
		}
		
		[Test( order=1 )]
		public function encode_object_class():void {
			Assert.assertTrue(
				equalsObjects(
					JSON.decode( JSON.encode( new SimpleClass() ) ),
					JSON.decode( '{"accessor":4,"variable":1,"constant":2,"getter":3,"dynamicProperty":0}' )
				)
			);
		}
		
		[Test( expects="flash.errors.StackOverflowError" )]
		public function encode_object_recursion():void {
			var o:SimpleClass = new SimpleClass();
			o.arr = [ o ];
			JSON.encode( o );
		}
		
	}

}