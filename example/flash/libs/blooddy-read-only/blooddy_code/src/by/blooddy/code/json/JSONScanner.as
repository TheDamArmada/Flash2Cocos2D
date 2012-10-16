////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.json {
	
	import by.blooddy.code.AbstractScanner;
	import by.blooddy.code.errors.ParserError;
	import by.blooddy.code.utils.Char;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.03.2010 14:33:15
	 */
	internal final class JSONScanner extends AbstractScanner {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function JSONScanner() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected override function $readToken():uint {
			var t:String;
			
			do {
				var c:uint = this.readCharCode();
				switch ( c ) {
					
					case Char.CARRIAGE_RETURN:
					case Char.NEWLINE:
					case Char.SPACE:
					case Char.TAB:
					case Char.VERTICAL_TAB:
					case Char.LS:
					case Char.PS:
					case Char.BACKSPACE:
					case Char.FORM_FEED:
						break;

					case Char.EOS:				return this.makeToken( JSONToken.EOF, '\x00' );
					case Char.COLON:			return this.makeToken( JSONToken.COLON, ':' );
					case Char.LEFT_BRACE:		return this.makeToken( JSONToken.LEFT_BRACE, '{' );
					case Char.RIGHT_BRACE:		return this.makeToken( JSONToken.RIGHT_BRACE, '}' );
					case Char.LEFT_BRACKET:		return this.makeToken( JSONToken.LEFT_BRACKET, '[' );
					case Char.RIGHT_BRACKET:	return this.makeToken( JSONToken.RIGHT_BRACKET, ']' );
					case Char.COMMA:			return this.makeToken( JSONToken.COMMA, ',' );

					case Char.SINGLE_QUOTE:
					case Char.DOUBLE_QUOTE:
						this._position--;
						t = this.readString();
						if ( t != null ) {
							return this.makeToken( JSONToken.STRING_LITERAL, t );
						} else {
							return this.makeToken( JSONToken.UNKNOWN, String.fromCharCode( c ) );
						}
						break;

					case Char.SLASH:
						switch ( this.readCharCode() ) {
							case Char.SLASH:
								return this.makeToken( JSONToken.LINE_COMMENT, this.readLine() );
							case Char.ASTERISK:
								this._position -= 2;
								t = this.readBlockComment();
								if ( t != null ) return this.makeToken( JSONToken.BLOCK_COMMENT, t );
								this._position += 2;
							default:
								--this._position;
						}
						return this.makeToken( JSONToken.UNKNOWN, '/' );

					default:
						if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DASH || c == Char.DOT ) {
							--this._position;
							t = this.readNumber();
							if ( t != null ) return this.makeToken( JSONToken.NUMBER_LITERAL, t );
							++this._position;
						} else if ( c == Char.n && this._source.substr( this._position, 3 ) == 'ull' ) {
							this._position += 3;
							return this.makeToken( JSONToken.NULL, 'null' );
						} else if ( c == Char.t && this._source.substr( this._position, 3 ) == 'rue' ) {
							this._position += 3;
							return this.makeToken( JSONToken.TRUE, 'true' );
						} else if ( c == Char.f && this._source.substr( this._position, 4 ) == 'alse' ) {
							this._position += 4;
							return this.makeToken( JSONToken.FALSE, 'false' );
						} else if ( c == Char.u && this._source.substr( this._position, 8 ) == 'ndefined' ) {
							this._position += 8;
							return this.makeToken( JSONToken.UNDEFINED, 'undefined' );
						} else if ( c == Char.N && this._source.substr( this._position, 2 ) == 'aN' ) {
							this._position += 2;
							return this.makeToken( JSONToken.NAN, 'NaN' );
						} else if (
							( c >= Char.a && c <= Char.z ) ||
							( c >= Char.A && c <= Char.Z ) ||
							c == Char.DOLLAR ||
							c == Char.UNDER_SCORE ||
							c > 0x7f
						) {
							this._position--;
							return this.makeToken( JSONToken.IDENTIFIER, this.readIdentifier() );
						}
						return this.makeToken( JSONToken.UNKNOWN, String.fromCharCode( c ) );
				}
			} while ( true );
			throw new ParserError();
			
		}
		
	}
	
}