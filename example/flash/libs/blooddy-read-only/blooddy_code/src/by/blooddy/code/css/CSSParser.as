////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.css.definition.CSSMedia;
	import by.blooddy.code.css.definition.CSSRule;
	import by.blooddy.code.css.definition.selectors.AttributeSelector;
	import by.blooddy.code.css.definition.selectors.CSSSelector;
	import by.blooddy.code.css.definition.selectors.ChildSelector;
	import by.blooddy.code.css.definition.selectors.ClassSelector;
	import by.blooddy.code.css.definition.selectors.DescendantSelector;
	import by.blooddy.code.css.definition.selectors.IDSelector;
	import by.blooddy.code.css.definition.selectors.PseudoSelector;
	import by.blooddy.code.css.definition.selectors.TagSelector;
	import by.blooddy.code.css.definition.values.ArrayValue;
	import by.blooddy.code.css.definition.values.BooleanValue;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.CollectionValue;
	import by.blooddy.code.css.definition.values.ColorValue;
	import by.blooddy.code.css.definition.values.ComplexValue;
	import by.blooddy.code.css.definition.values.IdentifierValue;
	import by.blooddy.code.css.definition.values.NumberValue;
	import by.blooddy.code.css.definition.values.PercentValue;
	import by.blooddy.code.css.definition.values.StringValue;
	import by.blooddy.code.css.definition.values.URLValue;
	import by.blooddy.code.errors.ParserError;
	import by.blooddy.code.net.AbstractLoadableParser;
	import by.blooddy.code.utils.Char;
	import by.blooddy.core.managers.process.IProcessable;
	import by.blooddy.core.utils.StringUtils;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.system.Capabilities;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:17:10 PM
	 */
	public final class CSSParser extends AbstractLoadableParser {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _ENY:RegExp = /./g;

		/**
		 * @private
		 */
		private static const _IN:Number = Capabilities.screenDPI;
		
		/**
		 * @private
		 */
		private static const _CM:Number = _IN / 2.54;
		
		/**
		 * @private
		 */
		private static const _MM:Number = _CM / 1e3;
		
		/**
		 * @private
		 */
		private static const _PT:Number = _IN / 72;
		
		/**
		 * @private
		 */
		private static const _PC:Number = _PT * 6;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function CSSParser() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _manager:CSSManager;
		
		/**
		 * @private
		 */
		private const _scanner:CSSScanner = new CSSScanner();

		/**
		 * @private
		 */
		private const _assets:Vector.<ImportAsset> = new Vector.<ImportAsset>();

		/**
		 * @private
		 */
		private const _nss:Object = new Object();
		
		/**
		 * @private
		 */
		private var _ns:String = '';
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _content:Vector.<CSSMedia>;

		public function get content():Vector.<CSSMedia> {
			return ( this._content ? this._content.slice() : null );
		}

		/**
		 * @private
		 */
		private var _errors:Vector.<Error>;

		public function get errors():Vector.<Error> {
			return this._errors;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(value:String, manager:CSSManager=null):void {
			super.start();
			
			this._manager = manager || CSSManager.getManager();
			// сбрасываем значения
			this._content = null;
			this._errors = new Vector.<Error>();

			this._scanner.writeSource( value );
			
		}

		protected override function onParse():Boolean {

			this._content = new Vector.<CSSMedia>();
			
			var tok:uint;

			var selectors:Vector.<CSSSelector>;
			var names:Vector.<String>;
			var rules:Vector.<CSSRule>;
			var declarations:Object;

			var s:CSSSelector;
			var v:CSSValue;
			var n:String;
			var ns:String;
			var i:int;

			var loader:IProcessable;
			var asset:ImportAsset;

			do {
				try { // top-level обработка

					tok = this.readToken();
					switch ( tok ) {

						case CSSToken.AT:
							tok = this.readFixToken( CSSToken.IDENTIFIER, false );
							switch ( this._scanner.tokenText.toLowerCase() ) {
								case 'namespace':
									tok = this.readToken();
									n = null;
									if ( tok == CSSToken.IDENTIFIER ) {
										if ( this._scanner.tokenText == 'url' ) {
											if ( this._scanner.readToken() == CSSToken.LEFT_PAREN ) {
												this._scanner.retreat();
											} else {
												this._scanner.retreat();
												n = this._scanner.tokenText;
											}
										} else {
											n = this._scanner.tokenText;
										}
										tok = this.readToken();
									}
									if ( tok == CSSToken.STRING_LITERAL ) {
										ns = this._scanner.tokenText;
									} else if ( tok == CSSToken.IDENTIFIER && this._scanner.tokenText == 'url' ) {
										ns = this.readURLEntity();
									} else {
										throw new ParserError( 'ожидались url ли индификатор' );
									}
									this.readFixToken( CSSToken.SEMI_COLON );
									if ( n ) {
										this._nss[ n ] = ns;
									} else {
										this._ns = ns;
									}
									break;
								case 'import':
									if ( rules ) {
										this._content.push( new CSSMedia( rules ) );
										rules = null;
									}
									asset = new ImportAsset();
									// url
									tok = this.readToken();
									if ( tok == CSSToken.STRING_LITERAL ) {
										asset.url = this._scanner.tokenText;
									} else if ( tok == CSSToken.IDENTIFIER && this._scanner.tokenText == 'url' ) {
										asset.url = this.readURLEntity();
									} else {
										throw new ParserError( 'не найдено определение url' );
									}
									// media
									tok = this.readToken();
									if ( tok == CSSToken.IDENTIFIER ) {
										this._scanner.retreat();
										asset.names = this.readMediaNames(); // result media
									} else {
										this._scanner.retreat();
									}
									this.readFixToken( CSSToken.SEMI_COLON );
									asset.index = this._content.length;
									if ( asset.url ) {
										if ( !this._manager.hasDefinition( asset.url ) ) {
											super.addLoader(
												this._manager.loadDefinition( asset.url )
											);
										}
										this._assets.push( asset );
									} else {
										throw new IOError();
									}
									break;
								case 'media':
									if ( rules ) {
										this._content.push( new CSSMedia( rules ) );
										rules = null;
									}
									names = this.readMediaNames();
									rules = this.readMediaEntity();
									i = names.indexOf( 'all' );
									if ( i >= 0 ) {
										this._content.push( new CSSMedia( rules, 'all' ) );
									} else {
										for each ( n in names ) {
											this._content.push( new CSSMedia( rules, n ) );
										}
									}
									rules = null;
									break;
								default:
									throw new ParserError( 'неизвестный типа injection' );
							}
							break;

						// начало селектора
						case CSSToken.HASH:
						case CSSToken.DOT:
						case CSSToken.IDENTIFIER:
						case CSSToken.COLON:
						case CSSToken.BAR:
							this._scanner.retreat();
							selectors = this.readSelectors();
							declarations = this.readDeclarations();
							for each ( v in declarations ) { // это проверка на существовани элементов
								if ( !rules ) rules = new Vector.<CSSRule>();
								for each ( s in selectors ) {
									rules.push( new CSSRule( s, declarations ) );
								}
								break;
							}
							break;
						
						case CSSToken.EOF:
							break;

						default:
							throw new ParserError( 'не известный тип токена' );

					}

				} catch ( e:Error ) {
					this._errors.push( e );
				}
			} while ( tok != CSSToken.EOF );

			if ( rules ) {
				this._content.push( new CSSMedia( rules ) );
			}

			if ( super.loaded ) {
				this.onLoad();
			}
			return true;
		}

		protected override function onLoad():void {

			var media:CSSMedia;
			var n:String;
			var arr:Array;
			var asset:ImportAsset;

			while ( this._assets.length ) {
				asset = this._assets.pop();
				arr = new Array();
				for each ( media in this._manager.getDefinition( asset.url ) ) {
					if ( !media.name && asset.names && asset.names.length > 0 ) {
						if ( asset.names.indexOf( 'all' ) >= 0 ) {
							arr.push( new CSSMedia( media.rules, 'all' ) );
						} else {
							for each ( n in asset.names ) {
								arr.push( new CSSMedia( media.rules, n ) );
							}
						}
					} else {
						arr.push( media );
					}
				}
				if ( arr.length > 0 ) {
					arr.unshift( asset.index, 0 );
					this._content.splice.apply( this._content, arr );
				}
			}

			this._manager = null;
			
			if ( this._content && this._content.length >= 0 ) {
				var l:uint = this._content.length - 1;
				var m:CSSMedia;
				var m1:CSSMedia;
				while ( l-- ) {
					m = this._content[ l ];
					m1 = this._content[ l + 1 ];
					if ( m.name == m1.name ) {
						this._content.splice(
							l,
							2,
							new CSSMedia(
								m.rules.concat( m1.rules ),
								m.name
							)
						);
					}
				}
				super.stop();
			} else {
				this._content = null;
				this.throwError( new IOError() );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function readToken(ignoreWhite:Boolean=true, ignoreComments:Boolean=true):uint {
			var tok:uint;
			do {
				tok = this._scanner.readToken();
			} while (
				( ignoreWhite && tok == CSSToken.WHITESPACE ) ||
				( ignoreComments && tok == CSSToken.BLOCK_COMMENT )
			);
			return tok;
		}

		/**
		 * @private
		 */
		private function readFixToken(kind:uint, ignoreWhite:Boolean=true, ignoreComments:Boolean=true):uint {
			var tok:uint = this.readToken( ignoreWhite, ignoreComments );
			if ( tok != kind ) throw new ParserError( 'ожидался токен "' + kind + '" вместо "' + tok + '"' );
			return tok;
		}

		/**
		 * @private
		 */
		private function readMediaNames():Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			var tok:uint;
			do {
				tok = this.readFixToken( CSSToken.IDENTIFIER );
				result.push( this._scanner.tokenText.toLowerCase() ); // result media
				tok = this.readToken();
			} while ( tok == CSSToken.COMMA );
			this._scanner.retreat();
			return result;
		}

		/**
		 * @private
		 */
		private function readMediaEntity():Vector.<CSSRule> {
			this.readFixToken( CSSToken.LEFT_BRACE );

			var result:Vector.<CSSRule> = new Vector.<CSSRule>();

			var tok:uint;
			var selectors:Vector.<CSSSelector>;
			var declarations:Object;
			var s:CSSSelector;
			var v:CSSValue;

			do {
				try {
					
					tok = this.readToken();
					switch ( tok ) {
						
						// начало селектора
						case CSSToken.HASH:
						case CSSToken.DOT:
						case CSSToken.IDENTIFIER:
						case CSSToken.COLON:
						case CSSToken.BAR:
							this._scanner.retreat();
							selectors = this.readSelectors();
							declarations = this.readDeclarations();
							for each ( v in declarations ) {
								for each ( s in selectors ) {
									result.push(
										new CSSRule( s, declarations )
									);
								}
								break;
							}
							break;
						
						case CSSToken.RIGHT_BRACE:
							break;

						default:
							throw new ParserError( 'не известный тип токена' );
							
					}
					
				} catch ( e:Error ) {
					this._errors.push( e );
				}
			} while ( tok != CSSToken.RIGHT_BRACE );
			return result;
		}

		/**
		 * @private
		 */
		private function readSelectors():Vector.<CSSSelector> {
			var result:Vector.<CSSSelector> = new Vector.<CSSSelector>();
			do {
				result.push( this.readSelector( new CSSSelector() ) );
			} while ( this.readToken() == CSSToken.COMMA );
			this._scanner.retreat();
			return result;
		}
		
		/**
		 * @private
		 */
		private function readSelector(child:CSSSelector):CSSSelector {
			child.selector = this.readAttributeSelector();
			switch ( this._scanner.readToken() ) {
				case CSSToken.LEFT_BRACE:
				case CSSToken.COMMA:
					this._scanner.retreat();
					return child;
				case CSSToken.RIGHT_ANGLE:
					return this.readSelector( new ChildSelector( child ) );
				case CSSToken.WHITESPACE:
					switch ( this.readToken() ) {
						case CSSToken.LEFT_BRACE:
						case CSSToken.COMMA:
							this._scanner.retreat();
							return child;
						case CSSToken.RIGHT_ANGLE:
							return this.readSelector( new ChildSelector( child ) );
					}
					this._scanner.retreat();
					return this.readSelector( new DescendantSelector( child ) );
			}
			throw new ParserError( 'неизвестный тип селектора' );
		}

		/**
		 * @private
		 */
		private function readAttributeSelector():AttributeSelector {
			switch ( this.readToken() ) {
				case CSSToken.IDENTIFIER:
					var n:String = this._scanner.tokenText;
					if ( this._scanner.readToken() == CSSToken.BAR ) {
						if ( !( n in this._nss ) ) {
							throw new ParserError( 'неведомый namespace' );
						}
						n = this._nss[ n ];
						this.readFixToken( CSSToken.IDENTIFIER, false, false );
					} else {
						this._scanner.retreat();
						n = this._ns;
					}
					return this.readSelectorAfterTag( new TagSelector( ( new QName( n, this._scanner.tokenText ) ) ) );
				case CSSToken.BAR:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return this.readSelectorAfterTag( new TagSelector( new QName( this._scanner.tokenText ) ) );
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new IDSelector( this._scanner.tokenText, this.readSelectorAfterID() );
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new PseudoSelector( this._scanner.tokenText );
			}
			return null;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterTag(tag:TagSelector):AttributeSelector {
			switch ( this._scanner.readToken() ) {
				case CSSToken.HASH:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					var result:IDSelector = new IDSelector( this._scanner.tokenText, tag );
					tag.selector = this.readSelectorAfterID();
					return result;
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					tag.selector = new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
					break;
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					tag.selector = new PseudoSelector( this._scanner.tokenText );
					break;
				default:
					this._scanner.retreat();
					break;
			}
			return tag;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterID():AttributeSelector {
			switch ( this._scanner.readToken() ) {
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new ClassSelector( this._scanner.tokenText, this.readSelectorAfterClass() );
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					return new PseudoSelector( this._scanner.tokenText );
				default:
					this._scanner.retreat();
					break;
			}
			return null;
		}

		/**
		 * @private
		 */
		private function readSelectorAfterClass():AttributeSelector {
			var result:AttributeSelector;
			switch ( this._scanner.readToken() ) {
				case CSSToken.DOT:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					result = new ClassSelector( this._scanner.tokenText );
					result.selector = this.readSelectorAfterClass();
					break;
				case CSSToken.COLON:
					this.readFixToken( CSSToken.IDENTIFIER, false, false );
					result = new PseudoSelector( this._scanner.tokenText );
					break;
				default:
					this._scanner.retreat();
					break;
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readDeclarations():Object {
			this.readFixToken( CSSToken.LEFT_BRACE );
			var result:Object = new Object();
			var name:String;
			while ( this.readToken() != CSSToken.RIGHT_BRACE ) {
				this._scanner.retreat();
				try {
					name = this.readDeclarationName();
					this.readFixToken( CSSToken.COLON );
					result[ name ] = this.readDeclarationValue();
				} catch ( e:Error ) { // пропускаем дкларацию
					this._errors.push( e );
					if ( this._scanner.tokenKind != CSSToken.RIGHT_BRACE && this._scanner.tokenKind != CSSToken.SEMI_COLON ) {
						this._scanner.readTokenAsTo( CSSToken.UNKNOWN, Char.SEMI_COLON, Char.RIGHT_BRACE, Char.NEWLINE, Char.CARRIAGE_RETURN );
						if ( this._scanner.readToken() != Char.SEMI_COLON ) {
							this._scanner.retreat();
						}
					}
				}
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readDeclarationName():String {
			var result:String = '';
			var t:String;
			var u:Boolean = false;
			var tok:uint = this.readToken();
			do {
				switch ( tok ) {
					case CSSToken.DASH:
						if ( u ) throw new ParserError( 'двойной "-"' );
						u = true;
						break;
					case CSSToken.IDENTIFIER:
						t = this._scanner.tokenText.toLowerCase();
						result += ( u ? t.charAt( 0 ).toUpperCase() + t.substr( 1 ) : t );
						u = false;
						break;
					default:
						this._scanner.retreat();
						return result;
				}
			} while ( tok = this._scanner.readToken() );
			return result;
		}

		/**
		 * @private
		 */
		private function readDeclarationValue():CSSValue {
			var result:Vector.<CSSValue> = new Vector.<CSSValue>();
			do {

				switch ( this.readToken() ) {

					case CSSToken.RIGHT_BRACE:
						this._scanner.retreat();
					case CSSToken.SEMI_COLON:
						if ( result.length == 0 ) {
							throw new ParserError( 'нету значений для определения' );
						} else if ( result.length == 1 ) {
							return result[ 0 ];
						}
						return new CollectionValue( result );

					default:
						this._scanner.retreat();
						result.push( this.readValue() );
						break;

				}

			} while ( true );
			throw new ParserError();
		}

		/**
		 * @private
		 */
		private function readValue(complexAvailable:Boolean=true):CSSValue {
				
			switch ( this.readToken() ) {
				
				case CSSToken.STRING_LITERAL:
					return new StringValue( this._scanner.tokenText );
				
				case CSSToken.NUMBER_LITERAL:
					var v:Number = parseFloat( this._scanner.tokenText );
					switch ( this._scanner.readToken() ) {
						case CSSToken.PERCENT:
							return new PercentValue( v );
						case CSSToken.IDENTIFIER:
							switch ( this._scanner.tokenText.toLowerCase() ) {
								case 'px':				break;
								case 'in':	v *= _IN;	break;
								case 'cm':	v *= _CM;	break;
								case 'mm':	v *= _MM;	break;
								case 'pt':	v *= _PT;	break;
								case 'pc':	v *= _PC;	break;
								default:	throw new ParserError( 'единицы "' + this._scanner.tokenText + '" не поддерживаются' );
							}
							break;
						default:
							this._scanner.retreat();
							break;
					}
					return new NumberValue( v );

				case CSSToken.HASH:
					this._scanner.retreat();
					return new ColorValue( this.readColor() );
				
				case CSSToken.IDENTIFIER:
					var t:String = this._scanner.tokenText.toLowerCase();
					switch ( t ) {
						case 'true':	return new BooleanValue( true );
						case 'false':	return new BooleanValue( false );
						default:
							if ( this._scanner.readToken() == CSSToken.LEFT_PAREN ) {
								this._scanner.retreat();
								switch ( t ) {
									case 'url':		return new URLValue( this.readURLEntity() );
									case 'rgb':		return new ColorValue( this.readRGBEntity() );
									case 'rgba':	return new ColorValue( this.readRGBAEntity() );
									case 'hsl':
									case 'hsla':	throw new ParserError( 'TODO' );
									default:
										if ( complexAvailable ) {
											return new ComplexValue( t, this.readComplexEntity() );
										} else {
											throw new ParserError( 'ComplexValue не поддерживается' );
										}
									
								}
							} else {
								this._scanner.retreat();
								return new IdentifierValue( t );
							}
					}

				case CSSToken.LEFT_BRACKET:
					this._scanner.retreat();
					return new ArrayValue( this.readArray() );
			}
			
			throw new ParserError( 'неизвестный тип значения' );
		}
		
		/**
		 * @private
		 */
		private function readComplexEntity():Vector.<CSSValue> {
			var result:Vector.<CSSValue> = new Vector.<CSSValue>();
			this.readFixToken( CSSToken.LEFT_PAREN, false, false );
			do {
				
				switch ( this.readToken( true, false ) ) {
					
					case CSSToken.RIGHT_PAREN:
						return result;

					default:
						this._scanner.retreat();
						result.push( this.readValue( false ) );
						switch ( this.readToken( true, false ) ) {
							case CSSToken.COMMA:
								break;
							case CSSToken.RIGHT_PAREN:
								return result;
							default:
								throw new ParserError( 'ожидалось либо запятая либо скобка' );
						}
						break;
					
				}
				
			} while ( true );
			throw new ParserError();
		}
		
		/**
		 * @private
		 */
		private function readArray():Array {
			var result:Array = new Array();
			this.readFixToken( CSSToken.LEFT_BRACKET, true, false );
			do {
				
				switch ( this.readToken( true, false ) ) {
					
					case CSSToken.RIGHT_BRACKET:
						return result;
						
					default:
						this._scanner.retreat();
						result.push( this.readValue( false ) );
						switch ( this.readToken( true, false ) ) {
							case CSSToken.COMMA:
								break;
							case CSSToken.RIGHT_BRACKET:
								return result;
							default:
								throw new ParserError( 'ожидалось либо запятая либо скобка' );
						}
						break;
					
				}
				
			} while ( true );
			throw new ParserError();
		}
		
		/**
		 * @private
		 */
		private function readColor():uint {
			this.readFixToken( CSSToken.HASH );
			this._scanner.readTokenAsWhile( CSSToken.STRING_LITERAL,
				Char.ZERO, Char.ONE, Char.TWO, Char.THREE, Char.FOUR, Char.FIVE, Char.SIX, Char.SEVEN, Char.EIGHT, Char.NINE,
				Char.a, Char.b, Char.c, Char.d, Char.e, Char.f,
				Char.A, Char.B, Char.C, Char.D, Char.E, Char.F
			);
			var t:String = this._scanner.tokenText;
			switch ( t.length ) {
				case 3:
				case 4:
					t = t.replace( _ENY, '$&$&' );
				case 6:
				case 8:
					break;
				default:
					throw new ParserError( 'кривой цвет' );
			}
			return parseInt( t, 16 ) | ( t.length <= 6 ? 0xFF000000 : 0 );
		}

		/**
		 * @private
		 */
		private function readURLEntity():String {
			var result:String;
			this.readFixToken( CSSToken.LEFT_PAREN, false, false );
			var tok:uint = this.readToken( true, false );
			if ( tok == CSSToken.STRING_LITERAL ) {
				result = this._scanner.tokenText;
			} else {
				this._scanner.retreat();
				this._scanner.readTokenAsTo( CSSToken.STRING_LITERAL, Char.RIGHT_PAREN );
				result = this._scanner.tokenText;
			}
			this.readFixToken( CSSToken.RIGHT_PAREN, true, false );
			return StringUtils.trim( result );
		}

		/**
		 * @private
		 */
		private function readRGBEntity():uint {
			var arr:Array = this.readColorArr( 0xFF, 0xFF, 0xFF );
			return	0xFF000000 |
					( Math.round( arr[ 0 ] ) << 16 ) |
					( Math.round( arr[ 1 ] ) << 8 ) |
					  Math.round( arr[ 2 ] );
		}

		/**
		 * @private
		 */
		private function readRGBAEntity():uint {
			var arr:Array = this.readColorArr( 0xFF, 0xFF, 0xFF, 1 );
			return	( ( arr[ 3 ] * 255 ) << 24 ) |
					( Math.round( arr[ 0 ] ) << 16 ) |
					( Math.round( arr[ 1 ] ) << 8 ) |
					  Math.round( arr[ 2 ] );
		}

		/**
		 * @private
		 */
		private function readColorArr(...values):Array {
			this.readFixToken( CSSToken.LEFT_PAREN, false, false );
			const l:uint = values.length;
			var result:Array = new Array();
			var v:Number;
			var d:Number;
			do {
				d = values[ result.length ];
				switch ( this.readToken( true, false ) ) {
					case CSSToken.NUMBER_LITERAL:
						v = parseFloat( this._scanner.tokenText );
						if ( this._scanner.readToken() == CSSToken.PERCENT ) {
							v = v / 100 * d;
						} else {
							this._scanner.retreat();
						}
						result.push( Math.min( Math.max( 0, v ), d ) );
						switch ( this.readToken( true, false ) ) {
							case CSSToken.COMMA:
								break;
							case CSSToken.RIGHT_PAREN:
								if ( result.length < l ) {
									result.push.apply(
										result,
										values.slice( result.length )
									);
								}
								break;
							default:
								throw new ParserError( 'ожидалось либо запятая, либо скобка' );
						}
						break;
					case CSSToken.COMMA:
						result.push( d );
						break;
					case CSSToken.RIGHT_PAREN:
						result.push.apply(
							result,
							values.slice( result.length )
						);
						break;
					default:
						throw new ParserError( 'хз что пришло' );
				}
			} while ( result.length < l );
			return result;
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ImportAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ImportAsset {

	public function ImportAsset() {
		super();
	}

	public var url:String;

	public var names:Vector.<String>;

	public var index:uint;

}