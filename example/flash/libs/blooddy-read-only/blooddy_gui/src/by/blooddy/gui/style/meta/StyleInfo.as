////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style.meta {

	import by.blooddy.code.css.definition.values.NumberValue;
	import by.blooddy.core.meta.AbstractInfo;
	import by.blooddy.core.meta.MemberInfo;
	import by.blooddy.core.meta.PropertyInfo;
	import by.blooddy.core.meta.TypeInfo;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.gui.style.StyleType;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.05.2010 0:21:43
	 */
	public class StyleInfo extends AbstractInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function getInfo(o:Object):StyleInfo {
			var c:Class = ClassUtils.getClass( o );
			if ( !c ) return null;
			var result:StyleInfo = _HASH[ c ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ c ] = result = new StyleInfo();
				result.parseType( TypeInfo.getInfo( c ) );
			}
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;
		
		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function StyleInfo() {
			super();
			if ( !_privateCall ) throw new IllegalOperationError();
			_privateCall = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _name:QName;

		/**
		 * @private
		 */
		private const _styles:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getStyle(name:String):AbstractStyle {
			return this._styles[ name ];
		}

		public override function toXML(local:Boolean=false):XML {

			var xml:XML = <styles name={ this._name } />;
			var x:XML;
			var s:AbstractStyle;
			var n:String;
			
			if ( local ) {

				for ( n in this._styles ) {
					
					s = this._styles[ n ];
					if ( !s || s._owner !== this ) continue;
					x = s.toXML( true );
					x.@name = n;
					xml.appendChild( x );
					
				}
			
			} else {

				for ( n in this._styles ) {
				
					s = this._styles[ n ];
					if ( !s ) continue;
					x = s.toXML( false );
					x.@name = n;
					if ( s._owner !== this ) {
						x.@declaredBy = s._owner._name;
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
		private function parseType(type:TypeInfo):void {

			this._name = type.name;

			var n:String;
			var hash:Object;

			var parent:StyleInfo;
			if ( type.parent ) {
				parent = getInfo( type.parent.target );
				hash = parent._styles;
				for ( n in hash ) {
					this._styles[ n ] = hash[ n ];
				}
			}

			var list:XMLList;
			var xml:XML;
			var m:MemberInfo;
			var a:AbstractStyle;
			var s:SimpleStyle;
			var c:CollectionStyle;
			var name:String;
			var q:QName;
			
			// обрабатываем свойства
			var metaT:XMLList = type.getMetadata( true );
			var metaP:XMLList;
			var arg:XMLList;

			// выкидываем все exclude
			for each ( xml in metaT.( @name == 'Exclude' ) ) {
				arg = xml.arg;
				if ( arg.( @key == 'kind' && ( n = @value, n == 'property' || n == 'style' ) ).length() > 0 ) {
					// ставим именно null, так как Exclude может быть прописан у класса предка
					n = arg.( @key == 'name' ).@value;
					if ( n ) this._styles[ n ] = null;
				}
			}

			var t:Class;
			
			for each ( var prop:PropertyInfo in type.getProperties( true ) ) {
				q = prop.name;

				if ( q.uri ) continue;
				name = prop.name.toString();
				if ( name in this._styles ) continue; // exclude

				metaP = prop.getMetadata();
				if ( metaP.length() > 0 ) metaP = null;

				t = null;

				if ( metaP ) {

					// если указать хоть какой-нить environment, то он явно не для нажего gui
					list = metaP.( @name == 'Inspectable' );
					if ( list.length() > 0 ) {
						arg = list[ 0 ].arg;
						if ( arg.length() > 0 ) {
							if ( arg.( @key == 'environment' && @value != '' ).length() > 0 ) {
								this._styles[ name ] = null;
								continue;
							}
						} else {
							arg = null;
						}
					} else {
						arg = null;
					}

					// указан кастомный тип
					list = metaP.( @name == 'StyleType' );
					if ( list.length() > 0 ) {
						list = list[ 0 ].arg.( @key == '' );
						if ( list.length() > 0 ) {
							t = StyleType.getValueByType( list[ 0 ].@value );
						}
					}

					if ( !t && arg ) { // посмотрим в Inspectable поле type
						list = arg.( @key == 'type' );
						if ( list.length() > 0 ) {
							n = list[ 0 ].@value;
							if ( n == 'Font Name' ) n = 'string'; // исключение
							t = StyleType.getValueByType( n );
						}
					}
					
				}

				if ( !t ) { // тип не указан
					t = StyleType.getClassByQName( prop.type );
				}

				if ( t ) {

					s = new SimpleStyle();
					s._owner = this;
					s.type = t;
					
					if ( metaP && t === NumberValue ) { // нумбер полей может быть указанно PercentProxy
						list = metaP.( @name == 'PercentProxy' );
						if ( list.length() > 0 ) {
							list = list[ 0 ].arg.( @key == '' );
							if ( list.length() > 0 ) {
								n = list[ 0 ].@value;
								// проверям что там number
								if ( n in this._styles && this._styles[ n ] is SimpleStyle ) {
									t = this._styles[ n ].type;
								} else {
									prop = type.getMember( n ) as PropertyInfo;
									if ( prop ) {
										t = StyleType.getClassByQName( prop.type );
									}
								}
								if ( t === NumberValue ) {
									s.proxy = n;
									this._styles[ n ] = null;
								}
							}
						}
					}

					this._styles[ name ] = s;

				}

			}

			// создаём комплексные стили
			for each ( xml in metaT.( @name == 'ProxyStyle' ) ) {
				arg = xml.arg;
				list = arg.( @key == 'name' );
				if ( list.length() > 0 ) {
					name = list[ 0 ].@value;
					if ( !name || name in this._styles ) continue;

					if ( !type.hasMember( n ) ) { // нельзя перекрывать свойства стилями

						list = arg.( @key == '' ).@value;
						if ( list.length() > 0 ) {

							c = new CollectionStyle();
							c._owner = this;
							for each ( xml in list ) {
								c.styles.push( xml );
							}
							if ( c.styles.length > 0 ) {
								this._styles[ name ] = c;
							}

						}

					}
				}
			}

		}

	}
	
}