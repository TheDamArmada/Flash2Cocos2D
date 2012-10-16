////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import avmplus.HIDE_OBJECT;
	import avmplus.INCLUDE_ACCESSORS;
	import avmplus.INCLUDE_BASES;
	import avmplus.INCLUDE_CONSTRUCTOR;
	import avmplus.INCLUDE_INTERFACES;
	import avmplus.INCLUDE_METADATA;
	import avmplus.INCLUDE_METHODS;
	import avmplus.INCLUDE_TRAITS;
	import avmplus.INCLUDE_VARIABLES;
	import avmplus.USE_ITRAITS;
	import avmplus._describeType;
	
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.display.BitmapData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.03.2010 23:44:05
	 */
	public final class TypeInfo extends DefinitionInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _FLAGS:uint = INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
		
		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;
		
		/**
		 * @private
		 */
		private static const _EMPTY_HASH:Object = new Object();
		
		/**
		 * @private
		 */
		private static const _EMPTY_LIST_QNAME:Vector.<QName> = new Vector.<QName>( 0, true );
		
		/**
		 * @private
		 */
		private static const _EMPTY_LIST_PROPERTIES:Vector.<PropertyInfo> = new Vector.<PropertyInfo>( 0, true );
		
		/**
		 * @private
		 */
		private static const _EMPTY_LIST_METHODS:Vector.<MethodInfo> = new Vector.<MethodInfo>( 0, true );
		
		/**
		 * @private
		 */
		private static const _EMPTY_LIST_MEMBERS:Vector.<MemberInfo> = new Vector.<MemberInfo>( 0, true );
		
		/**
		 * @private
		 */
		private static const _EMPTY_CONSTRUCTOR:ConstructorInfo = new ConstructorInfo();
		_EMPTY_CONSTRUCTOR.parse( {} );
		
		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );
		_HASH[ Object ] = getObjectInfo();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getInfo(o:Object):TypeInfo {
			var c:Class = ClassUtils.getClass( o );
			if ( !c ) return null;
			var result:TypeInfo = _HASH[ c ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ c ] = result = new TypeInfo();
				result.parseClass( c );
			}
			return result;
		}

		public static function getInfoByName(o:*):TypeInfo {
			var c:Class = ClassAlias.getClass( o );
			if ( c ) return getInfo( c );
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * специальное исключение для Object, из-за ебанутости FP
		 */
		private static function getObjectInfo():TypeInfo {

			var t:Object = _describeType( Object, _FLAGS & ~HIDE_OBJECT ).traits;

			_privateCall = true;
			var result:TypeInfo = new TypeInfo();

			result._targetPrototype = Object.prototype;
			result._target = Object;

			result._name = new QName( getQualifiedClassName( Object ) );

			result._constructor = _EMPTY_CONSTRUCTOR;

			result._metadata =
			result._metadata_local = _EMPTY_METADATA;

			result._hash_superclasses = _EMPTY_HASH;
			result._list_superclasses = _EMPTY_LIST_QNAME;
			result._hash_interfaces = _EMPTY_HASH;
			result._list_interfaces = _EMPTY_LIST_QNAME;
			result._list_interfaces_local = _EMPTY_LIST_QNAME;
			result._hash_types = _EMPTY_HASH;
			result._list_types = _EMPTY_LIST_QNAME;

			// methods
			var n:String;
			var uri:String;
			var localName:String;
			var o:Object;

			var hash:Object = new Object();
			var list_p:Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
			var list_m:Vector.<MethodInfo> = new Vector.<MethodInfo>();
			var m:MemberInfo;

			// properties
			
			// variable & constant
			for each ( o in t.variables ) {
				// имя свойства
				uri = o.uri || '';
				localName = o.name;
				if ( uri )	n = uri + '::' + localName;
				else		n = localName;
				m = new PropertyInfo();
				m.parse( o );
				m._owner = result;
				m._name = new QName( uri, localName );
				list_p.push( m as PropertyInfo );
				hash[ n ] = m;
			}
			
			// accessor
			for each ( o in t.accessors ) {
				// имя свойства
				uri = o.uri || '';
				localName = o.name;
				if ( uri )	n = uri + '::' + localName;
				else		n = localName;
				m = new PropertyInfo();
				m.parse( o );
				m._owner = result;
				m._name = new QName( uri, localName );
				list_p.push( m as PropertyInfo );
				hash[ n ] = m;
			}
			
			if ( list_p.length > 0 ) {
				list_p.fixed = true;
				result._list_properties_local = list_p;
				result._list_properties = list_p;
			} else {
				result._list_properties_local = _EMPTY_LIST_PROPERTIES;
				result._list_properties = _EMPTY_LIST_PROPERTIES;
			}
			
			// methods
			for each ( o in t.methods ) {
				// имя свойства
				uri = o.uri || '';
				localName = o.name;
				if ( uri )	n = uri + '::' + localName;
				else		n = localName;
				m = new MethodInfo();
				m.parse( o );
				m._owner = result;
				m._name = new QName( uri, localName );
				list_m.push( m as MethodInfo ); // добавляем в списки только наших
				hash[ n ] = m;
			}
			
			if ( list_m.length > 0 ) {
				list_m.fixed = true;
				result._list_methods_local = list_m;
				result._list_methods = list_m;
			} else {
				result._list_methods_local = _EMPTY_LIST_METHODS;
				result._list_methods = _EMPTY_LIST_METHODS;
			}
			
			result._list_members =
			result._list_members_local = Vector.<MemberInfo>( list_p ).concat( Vector.<MemberInfo>( list_m ) );

			result._hash_members = hash;

			return result;

		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function TypeInfo() {
			if ( !_privateCall ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			_privateCall = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  types
		//----------------------------------

		/**
		 * @private
		 */
		private var _hash_types:Object;

		/**
		 * @private
		 */
		private var _list_types:Vector.<QName>;

		//----------------------------------
		//  superclasses
		//----------------------------------

		/**
		 * @private
		 */
		private var _hash_superclasses:Object;

		/**
		 * @private
		 */
		private var _list_superclasses:Vector.<QName>;

		//----------------------------------
		//  interfaces
		//----------------------------------

		/**
		 * @private
		 */
		private var _hash_interfaces:Object;

		/**
		 * @private
		 */
		private var _list_interfaces:Vector.<QName>;

		/**
		 * @private
		 */
		private var _list_interfaces_local:Vector.<QName>;

		//----------------------------------
		//  members
		//----------------------------------

		/**
		 * @private
		 */
		private var _hash_members:Object;

		/**
		 * @private
		 */
		private var _list_members:Vector.<MemberInfo>;

		/**
		 * @private
		 */
		private var _list_members_local:Vector.<MemberInfo>;

		//----------------------------------
		//  properties
		//----------------------------------

		/**
		 * @private
		 */
		private var _list_properties:Vector.<PropertyInfo>;

		/**
		 * @private
		 */
		private var _list_properties_local:Vector.<PropertyInfo>;

		//----------------------------------
		//  methods
		//----------------------------------

		/**
		 * @private
		 */
		private var _list_methods:Vector.<MethodInfo>;

		/**
		 * @private
		 */
		private var _list_methods_local:Vector.<MethodInfo>;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _targetPrototype:Object;

		/**
		 * @private
		 */
		private var _target:Class;

		public function get target():Class {
			return this._target;
		}

		public function get parent():TypeInfo {
			return this._parent as TypeInfo;
		}

		/**
		 * @private
		 */
		private var _constructor:ConstructorInfo;

		public function get constructor():ConstructorInfo {
			return this._constructor;
		}

		/**
		 * @private
		 */
		private var _source:String;

		public function get source():String {
			return this._source;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  types
		//----------------------------------

		public function hasType(o:*):Boolean {
			if ( o is Class ) {
				return this._targetPrototype instanceof o;
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
					n = o.toString();
				} else if ( o is String ) {
					n = o;
					// нормализуем
					if ( n.lastIndexOf( '::' ) < 0 ) {
						var i:int = n.lastIndexOf( '.' );
						if ( i > 0 ) {
							n = n.substr( 0, i ) + '::' + n.substr( i + 1 );
						}
					}
				} else {
					throw new ArgumentError();
				}
				return n in this._hash_types;
			}
		}

		public function getTypes():Vector.<QName> {
			return this._list_types.slice();
		}

		//----------------------------------
		//  superclasses
		//----------------------------------

		public function hasSuperclass(o:*):Boolean {
			if ( o is Class ) {
				return o.prototype.isPrototypeOf( this._targetPrototype );
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
					n = o.toString();
				} else if ( o is String ) {
					n = o;
					// нормализуем
					if ( n.lastIndexOf( '::' ) < 0 ) {
						var i:int = n.lastIndexOf( '.' );
						if ( i > 0 ) {
							n = n.substr( 0, i ) + '::' + n.substr( i + 1 );
						}
					}
				} else {
					throw new ArgumentError();
				}
				return n in this._hash_superclasses;
			}
		}

		public function getSuperclasses():Vector.<QName> {
			return this._list_superclasses.slice();
		}

		//----------------------------------
		//  interfaces
		//----------------------------------

		public function hasInterface(o:*):Boolean {
			if ( o is Class ) {
				return o.prototype.isPrototypeOf( this._targetPrototype );
			} else if ( o is TypeInfo ) {
				return ( o as TypeInfo )._targetPrototype.isPrototypeOf( this._targetPrototype );
			} else {
				var n:String;
				if ( o is QName ) {
					n = o.toString();
				} else if ( o is String ) {
					n = o;
					// нормализуем
					if ( n.lastIndexOf( '::' ) < 0 ) {
						var i:int = n.lastIndexOf( '.' );
						if ( i > 0 ) {
							n = n.substr( 0, i ) + '::' + n.substr( i + 1 );
						}
					}
				} else {
					throw new ArgumentError();
				}
				return n in this._hash_interfaces;
			}
		}

		public function getInterfaces(local:Boolean=false):Vector.<QName> {
			if ( local ) {
				return this._list_interfaces_local.slice();
			} else {
				return this._list_interfaces.slice();
			}
		}

		//----------------------------------
		//  members
		//----------------------------------

		public function hasMember(name:*):Boolean {
			return String( name ) in this._hash_members;
		}

		public function getMembers(local:Boolean=false):Vector.<MemberInfo> {
			if ( local ) {
				return this._list_members_local.slice();
			} else {
				return this._list_members.slice();
			}
		}

		public function getMember(name:*):MemberInfo {
			if ( !name ) throw new ArgumentError();
			return this._hash_members[ String( name ) ];
		}

		//----------------------------------
		//  properties
		//----------------------------------

		public function getProperties(local:Boolean=false):Vector.<PropertyInfo> {
			if ( local ) {
				return this._list_properties_local.slice();
			} else {
				return this._list_properties.slice();
			}
		}

		//----------------------------------
		//  methods
		//----------------------------------

		public function getMethods(local:Boolean=false):Vector.<MethodInfo> {
			if ( local ) {
				return this._list_methods_local.slice();
			} else {
				return this._list_methods.slice();
			}
		}

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = super.toXML( local );

			xml.setLocalName( 'type' );
			xml.@name = this._name;

			// superClass
			if ( this._parent ) {
				xml.@base = this._parent.name;
			}

			var x:XML;
			var q:QName;

			if ( local ) {

				// interfaces
				for each ( q in this._list_interfaces_local ) {
					x = <implementsInterface />;
					x.@type = q;
					xml.appendChild( x );
				}

			} else {

				// extends
				for each ( q in this._list_superclasses ) {
					x = <extendsClass />;
					x.@type = q;
					xml.appendChild( x );
				}

				// interfaces
				for each ( q in this._list_interfaces ) {
					x = <implementsInterface />;
					x.@type = q;
					xml.appendChild( x );
				}

			}

			// constructor
			x = this._constructor.toXML();
			if ( x.hasComplexContent() ) {
				xml.appendChild( x );
			}

			var m:MemberInfo;
			if ( local ) {

				for each ( m in this._list_members_local ) {
					xml.appendChild( m.toXML() );
				}

			} else {

				for each ( m in this._list_members ) {
					x = m.toXML();
					if ( m._owner !== this ) {
						x.@declaredBy = m._owner.name;
					}
					xml.appendChild( x );
				}

			}

			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function parseClass(c:Class):void {
			this._target = c;
			this._targetPrototype = c.prototype;
			this.parse( _describeType( c, _FLAGS ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function parse(t:Object):void {

			// весь код написанный в этом методе очень запутанный
			// сложные конструкции используются с целью сэкономить память
			// и исключиь дополнительную обработку

			// name
			this._name = ClassUtils.parseClassQName( t.name ); // выдёргиваем имя

			t = t.traits;

			var n:String;
			var q:QName;
			var i:int;
			var o:Object;

			// parent
			var hash:Object = new Object();
			var parent:TypeInfo;

			// superclasses
			// собираем суперклассы
			if ( t.bases && t.bases.length > 0 ) {

				this._list_superclasses = new Vector.<QName>();
				this._hash_superclasses = new Object();

				for each ( n in t.bases ) {
					this._hash_superclasses[ n ] = true;
					this._list_superclasses.push( ClassUtils.parseClassQName( n ) );
					hash[ n ] = true;
					// надо найти нашего папу
					if ( !parent ) {
						parent = getInfoByName( n );
					}
				}
				
				this._parent = parent;

				this._list_superclasses.fixed = true;

			} else {

				this._list_superclasses = _EMPTY_LIST_QNAME;
				this._hash_superclasses = _EMPTY_HASH;

			}

			// interfaces
			// собираем список интерфейсов на основании списка нашего папы
			var hash_interfaces:Object;
			var list_interfaces:Vector.<QName>;
			if ( t.interfaces && t.interfaces.length > 0 ) {
				
				hash_interfaces = new Object();
				list_interfaces = new Vector.<QName>();

				if ( parent ) {

					for each ( n in t.interfaces ) {
						if ( !( n in parent._hash_interfaces ) ) { // добавляем только "наши" интерфейсы
							list_interfaces.push( ClassUtils.parseClassQName( n ) );
						}
						hash_interfaces[ n ] = true;
						hash[ n ] = true;
					}
					list_interfaces.fixed = true;
					
					if ( parent._list_interfaces === _EMPTY_LIST_QNAME ) {
						this._list_interfaces =		list_interfaces;
					} else {
						this._list_interfaces =		list_interfaces.concat( parent._list_interfaces );
						this._list_interfaces.fixed =	true;
					}
					this._hash_interfaces =			hash_interfaces;
					this._list_interfaces_local =	list_interfaces;
					
				} else {
					
					for each ( n in t.interfaces ) {
						list_interfaces.push( ClassUtils.parseClassQName( n ) );
						hash_interfaces[ n ] = true;
						hash[ n ] = true;
					}
					list_interfaces.fixed = true;
					
					this._list_interfaces =			list_interfaces;
					this._hash_interfaces =			hash_interfaces;
					this._list_interfaces_local =	list_interfaces;
						
				}
				
			} else {

				list_interfaces =				_EMPTY_LIST_QNAME;
				this._list_interfaces =			_EMPTY_LIST_QNAME;
				this._hash_interfaces =			_EMPTY_HASH;
				this._list_interfaces_local =	_EMPTY_LIST_QNAME;

			}
			
			// types
			if ( this._list_interfaces === _EMPTY_LIST_QNAME ) {

				this._list_types = this._list_superclasses;
				this._hash_types = this._hash_superclasses;

			} else if ( this._list_superclasses === _EMPTY_LIST_QNAME ) {

				this._list_types = this._list_interfaces;
				this._hash_types = this._hash_interfaces;

			} else {

				this._list_types = this._list_interfaces.concat( this._list_superclasses );
				this._list_types.fixed = true;
				this._hash_types = hash;

			}

			// metadata
			// запускаем дефолтный парсер
			super.parse( t );

			// members
			// надо распарсить всех наших многочленов

			var uri:String;
			var localName:String;

			var p:PropertyInfo;		// локальное свойство
			var pp:PropertyInfo;	// родительское свойство
			var list_p:Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
			var list_pp:Vector.<PropertyInfo>;

			var m:MethodInfo;	// метод
			var mm:MethodInfo;	// родительский метод
			var list_m:Vector.<MethodInfo> = new Vector.<MethodInfo>();
			var list_mm:Vector.<MethodInfo>;

			var info:TypeInfo;

			var hash_p:Object;

			// соберём свойства описанные в XML
			if ( parent ) { // для классов

				// constructor
				if ( t.constructor ) {
					this._constructor = new ConstructorInfo();
					this._constructor.parse( t.constructor );
				} else {
					this._constructor = _EMPTY_CONSTRUCTOR;
				}

				hash_p = parent._hash_members;
				hash = new Object();

				// соберём ссылки на локальную имплементацию
				var impl:Object;
				if ( list_interfaces.length > 1 ) {
					impl = new Object();
					for each ( q in list_interfaces ) {
						info = getInfoByName( q );
						if ( info ) {
							o = info._hash_members;
							for ( n in o ) {
								impl[ n ] = o[ n ];
							}
						}
					}
				} else if ( list_interfaces.length > 0 ) {
					info = getInfoByName( this._list_interfaces_local[ 0 ] );
					impl = ( info ? info._hash_members : _EMPTY_HASH );
				} else {
					impl = _EMPTY_HASH;
				}

				// properties

				// variable & constant
				for each ( o in t.variables ) {
					// имя свойства
					uri = o.uri || '';
					localName = o.name;
					if ( uri )	n = uri + '::' + localName;
					else		n = localName;
					// ищем свойство у родителя
					if ( n in hash_p ) {
						p = hash_p[ n ] as PropertyInfo;
					} else {
						p = new PropertyInfo();
						p.parse( o );
						p._owner = this;
						p._name = new QName( uri, localName );
						list_p.push( p );
					}
					hash[ n ] = p;
				}

				// accessor
				for each ( o in t.accessors ) {
					// имя свойства
					uri = o.uri || '';
					localName = o.name;
					if ( uri )	n = uri + '::' + localName;
					else		n = localName;
					// ищем свойство у родителя
					pp = ( n in hash_p ? hash_p[ n ] as PropertyInfo : null );
					if ( o.declaredBy == name ) { // это свойство объявленно/переопределнно у нас
						p = new PropertyInfo();
						p._parent = pp || impl[ n ] as PropertyInfo;
						p.parse( o );
						// если наше свойство не отличается от ролительского
						// то используем родительское свойство
						if ( pp && pp._metadata === p._metadata && pp.access == p.access ) {
							p = pp; // переиспользуем: нечего создавать лишние связи
						} else {
							p._owner = this;
							p._name = new QName( uri, localName );
							list_p.push( p );
							if ( pp ) { // что бы не было дублей надо подчистят список родителя
								if ( !list_pp ) list_pp = parent._list_properties.slice();
								i = list_pp.indexOf( pp );
								list_pp.splice( i, 1 );
							}
						}
					} else {
						p = pp;
					}
					hash[ n ] = p;
				}

				if ( list_p.length > 0 ) {

					list_p.fixed = true;
					this._list_properties_local = list_p;
					if ( !list_pp ) list_pp = parent._list_properties;
					else list_pp.fixed = true;
					if ( list_pp.length > 0 ) {
						this._list_properties = list_p.concat( list_pp );
						this._list_properties.fixed = true;
					} else {
						this._list_properties = list_p;
					}

				} else {

					this._list_properties_local = _EMPTY_LIST_PROPERTIES;
					this._list_properties = parent._list_properties;

				}

				// methods
				for each ( o in t.methods ) {
					// имя свойства
					uri = o.uri || '';
					localName = o.name;
					if ( uri )	n = uri + '::' + localName;
					else		n = localName;
					// ищем метод у родителя
					mm = ( n in hash_p ? hash_p[ n ] as MethodInfo : null );
					if ( o.declaredBy == name ) { // метод объявлен у нас
						m = new MethodInfo();
						m._parent = mm || impl[ n ] as MethodInfo;
						m.parse( o );
						if ( mm && mm._metadata === m._metadata ) { // метод ничем не отличается от родительского
							m = mm;
						} else {
							m._owner = this;
							m._name = new QName( uri, localName );
							list_m.push( m ); // добавляем в списки только наших
							if ( mm ) { // что бы не было дублей надо подчистят список родителя
								if ( !list_mm ) list_mm = parent._list_methods.slice();
								i = list_mm.indexOf( mm );
								list_mm.splice( i, 1 );
							}
						}
					} else {
						m = mm;
					}
					hash[ n ] = m;
				}

				if ( list_m.length > 0 ) {

					list_m.fixed = true;
					this._list_methods_local = list_m;
					if ( !list_mm ) list_mm = parent._list_methods;
					else list_mm.fixed = true;
					if ( list_mm.length > 0 ) {
						this._list_methods = list_m.concat( list_mm );
						this._list_methods.fixed = true;
					} else {
						this._list_methods = list_m;
					}

				} else {

					this._list_methods_local = _EMPTY_LIST_METHODS;
					this._list_methods = parent._list_methods;

				}

			} else { // для интерфейсов

				// constructor
				this._constructor = _EMPTY_CONSTRUCTOR;

				hash = new Object();

				// соберём ссылки на локальную имплементацию
				if ( list_interfaces.length > 1 ) {

					list_pp = new Vector.<PropertyInfo>();
					list_mm = new Vector.<MethodInfo>();
					for each ( q in list_interfaces ) {
						info = getInfoByName( q );
						if ( info ) {
							o = info._hash_members;
							for ( n in o ) {
								hash[ n ] = o[ n ];
							}
							if ( info._list_properties.length > 0 ) {
								list_pp = list_pp.concat( info._list_properties );
							}
							if ( info._list_methods.length > 0 ) {
								list_mm = list_mm.concat( info._list_methods );
							}
						}
					}

				} else if ( list_interfaces.length > 0 ) {

					info = getInfoByName( this._list_interfaces_local[ 0 ] );
					if ( info ) {
						o = info._hash_members;
						for ( n in o ) {
							hash[ n ] = o[ n ];
						}
						if ( info._list_properties.length > 0 ) {
							list_pp = info._list_properties.slice();
						}
						if ( info._list_methods.length > 0 ) {
							list_mm = info._list_methods.slice();
						}
					}

				}

				// properties
				// variable & constant у интерфейсов отсутсвуют. у Object тоже
				// accessor
				for each ( o in t.accessor ) {
					// имя свойства
					n = o.name;
					p = new PropertyInfo();
					p.parse( o );
					p._owner = this;
					p._name = new QName( n );
					list_p.push( p );
					hash[ n ] = p;
				}

				if ( list_p.length > 0 ) {

					list_p.fixed = true;
					this._list_properties_local = list_p;
					if ( list_pp && list_pp.length > 0 ) {
						this._list_properties = list_p.concat( list_pp );
						this._list_properties.fixed = true;
					} else {
						this._list_properties = list_p;
					}

				} else {

					this._list_properties_local = _EMPTY_LIST_PROPERTIES;
					if ( list_pp && list_pp.length > 0 ) {
						list_pp.fixed = true;
						this._list_properties = list_pp;
					} else {
						this._list_properties = _EMPTY_LIST_PROPERTIES;
					}

				}

				// methods
				for each ( o in t.method ) {
					// имя свойства
					n = o.name;
					m = new MethodInfo();
					m.parse( o );
					m._owner = this;
					m._name = new QName( n );
					list_m.push( m );
					hash[ n ] = m;
				}

				if ( list_m.length > 0 ) {

					this._list_methods_local = list_m;
					if ( list_mm && list_mm.length > 0 ) {
						this._list_methods = list_m.concat( list_mm );
					} else {
						this._list_methods = list_m;
					}

				} else {

					this._list_methods_local = _EMPTY_LIST_METHODS;
					if ( list_mm && list_mm.length > 0 ) {
						this._list_methods = list_mm;
					} else {
						this._list_methods = _EMPTY_LIST_METHODS;
					}

				}

			}

			// members
			if ( list_p.length > 0 && list_m.length > 0 ) {

				this._list_members_local = Vector.<MemberInfo>( list_p ).concat( Vector.<MemberInfo>( list_m ) );
				this._hash_members = hash;

			} else if ( list_p.length > 0 ) {

				this._list_members_local = Vector.<MemberInfo>( list_p );
				this._hash_members = hash;

			} else if ( list_m.length > 0 ) {

				this._list_members_local = Vector.<MemberInfo>( list_m );
				this._hash_members = hash;

			} else {

				this._list_members_local = _EMPTY_LIST_MEMBERS;
				if ( parent ) {
					this._list_members = parent._list_members;
					this._hash_members = hash_p;
				} else {
					this._list_members = _EMPTY_LIST_MEMBERS;
					this._hash_members = _EMPTY_HASH;
				}

			}

			if ( !this._list_members ) {

				if ( ( list_pp && list_pp.length > 0 ) || ( list_mm && list_mm.length > 0 ) ) {

					this._list_members = this._list_members_local.slice();

					if ( !list_pp && parent ) list_pp = parent._list_properties;
					if ( list_pp && list_pp.length > 0 ) {
						this._list_members = this._list_members.concat( Vector.<MemberInfo>( list_pp ) );
					}

					if ( !list_mm && parent ) list_mm = parent._list_methods;
					if ( list_mm && list_mm.length > 0 ) {
						this._list_members = this._list_members.concat( Vector.<MemberInfo>( list_mm ) );
					}

				} else if ( parent && parent._list_members.length > 0 ) {

					this._list_members = this._list_members_local.concat( parent._list_members );

				} else {

					this._list_members = this._list_members_local;

				}
			}

			// бывают случаи, когда мемберы из родителя не попадают в описательную XML
			if ( parent ) {
				if ( this._hash_members === hash ) {
					for ( n in hash_p ) {
						if ( !( n in hash ) ) {
							hash[ n ] = hash_p[ n ];
						}
					}
				}
			}

//			if ( Capabilities.isDebugger ) {
//				// source
//				var list:XML = xml.metadata.( @name == '__go_to_definition_help' );
//				if ( list.length() > 0 ) {
//					list = list[ 0 ].arg.( @key == 'file' );
//					if ( list.length() > 0 ) {
//						this._source = list[ 0 ].@value.toString();
//					}
//				}
//			}

		}

	}

}