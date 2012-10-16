////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.09.2010 16:16:44
	 */
	public class RDFDescriber {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		private static const ns_rdf:Namespace = new Namespace( 'rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' );

		private static const ns_as3:Namespace = new Namespace( 'as3', AS3 + '#' );

		private static const ns_dc:Namespace = new Namespace( 'dc', 'http://purl.org/dc/elements/1.1/' );

		private static const ns_rdfs:Namespace = new Namespace( 'rdfs', 'http://www.w3.org/2000/01/rdf-schema' );

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function describeType(o:Object):XML {
			return getType( TypeInfo.getInfo( o ) );
		}

		public static function describeTypeLinks(...args):XML {
			var list:Vector.<TypeInfo> = new Vector.<TypeInfo>();
			var hash:Dictionary = new Dictionary();
			for each ( var o:Object in args ) {
				updateLinks( hash, list, TypeInfo.getInfo( o ) );
			}

			var result:XML = <RDF />;
			result.setNamespace( ns_rdf );
			result.addNamespace( ns_dc );
			result.addNamespace( ns_as3 );

			var desc:XML;
			var x:XML;
			var seq:XML;
			var li:XML;

			for each ( var info:TypeInfo in list ) {
				// пробегаемся по списку и строим RDF
				desc = <Description />;
				desc.setNamespace( ns_rdf );
				desc.@ns_rdf::about = '#' + encodeURI( info.name.toString() );

				// title
				x = <title />;
				x.setNamespace( ns_dc );
				x.appendChild( info.name.toString() );
				desc.appendChild( x );

				// links
				x = <links />;
				x.setNamespace( ns_as3 );

				seq = <Bag />;
				seq.setNamespace( ns_rdf );

				list = hash[ info ];
				for each ( info in list ) {
					li = <li />;
					li.setNamespace( ns_rdf );
					li.@ns_rdf::resource = '#' + encodeURI( info.name.toString() );
					seq.appendChild( li );
				}

				x.appendChild( seq );

				desc.appendChild( x );

				result.appendChild( desc );

			}

			return result;
		}

		public static function describeTypeDependes(...args):XML {
			var list:Vector.<TypeInfo> = new Vector.<TypeInfo>();
			var hash:Dictionary = new Dictionary();
			for each ( var o:Object in args ) {
				updateDependes( hash, list, TypeInfo.getInfo( o ) );
			}

			var result:XML = <RDF />;
			result.setNamespace( ns_rdf );
			result.addNamespace( ns_rdfs );
			result.addNamespace( ns_dc );
			result.addNamespace( ns_as3 );

			for each ( var info:TypeInfo in list ) {
				result.appendChild( getType( info ) );
			}

			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function updateLinks(hash:Dictionary, list:Vector.<TypeInfo>, info:TypeInfo):void {

			var hash2:Dictionary = new Dictionary();
			var list2:Vector.<TypeInfo> = new Vector.<TypeInfo>();

			hash[ info ] = list2;
			list.push( info );

			var t:ITypedInfo;

			var names:Vector.<QName>;
			// interfaces
			names = info.getInterfaces( true );
			// superClass
			if ( info.parent ) {
				names.push( info.parent.name );
			}
			// properties
			for each ( t in info.getProperties( true ) ) {
				names.push( t.type );
			}
			// methods
			for each ( var m:MethodInfo in info.getMethods( true ) ) {
				names.push( m.returnType );
				for each ( t in m.getParameters() ) {
					names.push( t.type );
				}
			}
			// constructor
			for each ( t in info.constructor.getParameters() ) {
				names.push( t.type );
			}

			// вызываем апдэйтилку
			for each ( var n:QName in names ) {
				info = TypeInfo.getInfoByName( n );
				if ( !info || info in hash2 ) continue;
				hash2[ info ] = true;
				list2.push( info );
				if ( !info || info in hash ) continue;
				updateLinks( hash, list, TypeInfo.getInfoByName( n ) );
			}
		}

		/**
		 * @private
		 */
		private static function updateDependes(hash:Dictionary, list:Vector.<TypeInfo>, info:TypeInfo):void {

			list.push( info );
			hash[ info ] = true;

			var names:Vector.<QName> = new Vector.<QName>();

			var t:ITypedInfo;

			// superClasses
			names = names.concat( info.getSuperclasses() );
			// interfaces
			names = names.concat( info.getInterfaces( true ) );
			// properties
			for each ( t in info.getProperties( true ) ) {
				names.push( t.type );
			}
			// methods
			for each ( var m:MethodInfo in info.getMethods( true ) ) {
				names.push( m.returnType );
				for each ( t in m.getParameters() ) {
					names.push( t.type );
				}
			}
			// constructor
			for each ( t in info.constructor.getParameters() ) {
				names.push( t.type );
			}

			// вызываем апдэйтилку
			for each ( var n:QName in names ) {
				info = TypeInfo.getInfoByName( n );
				if ( !info || info in hash ) continue;
				updateDependes( hash, list, info );
			}
		}

		/**
		 * @private
		 */
		private static function getType(info:TypeInfo):XML {
			var xml:XML = getDefinition( info );
			xml.addNamespace( ns_rdfs );
			xml.addNamespace( ns_dc );
			xml.addNamespace( ns_as3 );

			xml.@ns_rdf::about = '#' + encodeURI( info.name.toString() );

			var resource:XML;
			var seq:XML;
			var x:XML;
			var members:Vector.<MemberInfo>;
			var types:Vector.<QName>
			var i:uint, l:uint;

			// type
			x = <type>type</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );

			// source
			if ( info.source ) {
				x = <source />;
				x.appendChild( info.source );
				x.setNamespace( ns_dc );
				xml.appendChild( x );
			}

			// superClasses
			types = info.getSuperclasses();
			l = types.length;
			if ( l > 0 ) {
				resource = <extendsClass />
				resource.setNamespace( ns_as3 );

				seq = <Seq />
				seq.setNamespace( ns_rdf );

				for ( i=0; i<l; ++i ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( types[ i ].toString() );

					seq.appendChild( x );
				}

				resource.appendChild( seq );

				xml.appendChild( resource );
			}

			// interfaces
			types = info.getInterfaces( true );
			l = types.length;
			if ( l > 0 ) {
				resource = <implementsInterface />
				resource.setNamespace( ns_as3 );

				seq = <Bag />
				seq.setNamespace( ns_rdf );

				for ( i=0; i<l; ++i ) {
					x = <li />
					x.setNamespace( ns_rdf );
					x.@ns_rdf::resource = '#' + encodeURI( types[ i ].toString() );

					seq.appendChild( x );
				}

				resource.appendChild( seq );

				xml.appendChild( resource );
			}

			// constructor
			resource = getConstructor( info.constructor );
			if ( resource.hasComplexContent() ) {
				xml.appendChild( resource );
			}

			// members
			members = info.getMembers( true );
			if ( members.length > 0 ) {
				resource = <members />
				resource.setNamespace( ns_as3 );
				resource.@ns_rdf::parseType = 'Collection';
				for each ( var m:MemberInfo in members ) {
					switch ( true ) {
						case m is PropertyInfo:	x = getProperty( m as PropertyInfo );	break;
						case m is MethodInfo:	x = getMethod( m as MethodInfo );		break;
						default:				x = null;								break;
					}
					if ( x ) {
						resource.appendChild( x );
					}
				}
				xml.appendChild( resource );
			}

			return xml;
		}

		/**
		 * @private
		 */
		private static function getConstructor(info:ConstructorInfo):XML {
			var xml:XML = <constructor />;
			xml.setNamespace( ns_as3 );
			xml.@ns_rdf::parseType = 'Resource';
			xml.setChildren( getFunction( info ) );
			return xml;
		}

		/**
		 * @private
		 */
		private static function getProperty(info:PropertyInfo):XML {
			var xml:XML = getMember( info );
			var x:XML;
			// type
			x = <type>property</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );
			// type
			x = <type />;
			x.setNamespace( ns_as3 );
			x.@ns_rdf::resource = '#' + encodeURI( info.type.toString() );
			xml.appendChild( x );
			// access
			var a:int = info.access;
			var access:String = '';
			if ( a & PropertyInfo.ACCESS_READ )		access += 'read';
			if ( a & PropertyInfo.ACCESS_WRITE )	access += 'write';
			if ( ( a & PropertyInfo.ACCESS_READ_WRITE ) != PropertyInfo.ACCESS_READ_WRITE ) access += 'only';
			if ( access ) {
				x = <access />;
				x.setNamespace( ns_as3 );
				//x.@ns_rdf::datatype = 'http://www.w3.org/2001/XMLSchema#string';
				x.appendChild( access );
				xml.appendChild( x );
			}	
			return xml;
		}

		/**
		 * @private
		 */
		private static function getMethod(info:MethodInfo):XML {
			var xml:XML = getDefinition( info );
			var x:XML;
			// type
			x = <type>method</type>;
			x.setNamespace( ns_dc );
			xml.appendChild( x );
			// returnType
			x = <returnType />;
			x.setNamespace( ns_as3 );
			x.@ns_rdf::resource = '#' + encodeURI( info.returnType.toString() );
			xml.appendChild( x );
			xml.setChildren( getFunction( info ) );
			return xml;
		}

		/**
		 * @private
		 */
		private static function getMember(info:MemberInfo):XML {
			var xml:XML = getDefinition( info );
			// about
			xml.@ns_rdf::about = '#' + encodeURI( info.owner.name + '-' + info.name );
			// define
			var x:XML = <isDefinedBy />;
			x.setNamespace( ns_rdfs );
			x.@ns_rdf::resource = '#' + encodeURI( info.owner.name.toString() );
			xml.appendChild( x );
			return xml;
		}

		/**
		 * @private
		 */
		private static function getDefinition(info:DefinitionInfo):XML {
			var xml:XML = <Description />;
			xml.setNamespace( ns_rdf );
			var x:XML;
			// title
			x = <title />;
			x.setNamespace( ns_dc );
			x.appendChild( info.name.toString() );
			xml.appendChild( x );
			// metadata
			var meta:XMLList = info.getMetadata( true );
			if ( meta.length() > 0 ) {
				x = <metadata />;
				x.setNamespace( ns_as3 );
				x.@ns_rdf::parseType = 'Literal';
				x.setChildren( meta );
				xml.appendChild( x );
			}

			return xml;
		}

		/**
		 * @private
		 */
		private static function getFunction(info:IFunctionInfo):XMLList {
			var list:XMLList = new XMLList();
			var x:XML;
			var seq:XML = <Seq />;
			var params:Vector.<ParameterInfo> = info.getParameters();
			var l:uint = params.length;
			for ( var i:uint = 0; i<l; ++i ) {
				seq.appendChild( getParameter( params[ i ] ) );
			}
			if ( seq.hasComplexContent() ) {
				seq.setNamespace( ns_rdf );
				x = <parameters />;
				x.setNamespace( ns_as3 );
				x.appendChild( seq );
				list += x;
			}
			return list;
		}

		/**
		 * @private
		 */
		private static function getParameter(info:ParameterInfo):XML {
			var xml:XML = <li />;
			xml.setNamespace( ns_rdf );
			xml.@ns_rdf::parseType = 'Resource';
			var x:XML;
			// type
			x = <type />;
			x.setNamespace( ns_as3 );
			x.@ns_rdf::resource = '#' + encodeURI( info.type.toString() );
			xml.appendChild( x );
			// optional
			x = <optional />;
			x.appendChild( info.optional );
			x.setNamespace( ns_as3 );
			//x.@ns_rdf::datatype = 'http://www.w3.org/2001/XMLSchema#boolean';
			xml.appendChild( x );
			return xml;
		}

	}

}