////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.AbstractScanner;
	import by.blooddy.code.utils.Char;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.03.2010 23:35:53
	 */
	internal final class CSSScanner extends AbstractScanner {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CSSScanner() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function $readToken():uint {
			var t:String;

			var c:uint = this.readCharCode();
			switch ( c ) {

				case Char.EOS:			return this.makeToken( CSSToken.EOF, '\x00' );
				
				case Char.CARRIAGE_RETURN:
					if ( this.readCharCode() != Char.NEWLINE ) {
						--this._position;
					}
				case Char.NEWLINE:
				case Char.SPACE:
				case Char.TAB:
				case Char.VERTICAL_TAB:
				case Char.LS:
				case Char.PS:
				case Char.BACKSPACE:
				case Char.FORM_FEED:	return this.makeToken( CSSToken.WHITESPACE, String.fromCharCode( c ) );
					

				case Char.COLON:		return this.makeToken( CSSToken.COLON, ':' );
				case Char.LEFT_BRACE:	return this.makeToken( CSSToken.LEFT_BRACE, '{' );
				case Char.RIGHT_BRACE:	return this.makeToken( CSSToken.RIGHT_BRACE, '}' );
				case Char.LEFT_PAREN:	return this.makeToken( CSSToken.LEFT_PAREN, '(' );
				case Char.RIGHT_PAREN:	return this.makeToken( CSSToken.RIGHT_PAREN, ')' );
				case Char.LEFT_ANGLE:	return this.makeToken( CSSToken.LEFT_ANGLE, '<' );
				case Char.RIGHT_ANGLE:	return this.makeToken( CSSToken.RIGHT_ANGLE, '>' );
				case Char.HASH:			return this.makeToken( CSSToken.HASH, '#' );
				case Char.PERCENT:		return this.makeToken( CSSToken.PERCENT, '%' );
				case Char.COMMA:		return this.makeToken( CSSToken.COMMA, ',' );
				case Char.BAR:			return this.makeToken( CSSToken.BAR, '|' );
				case Char.AT:			return this.makeToken( CSSToken.AT, '@' );
				case Char.SEMI_COLON:	return this.makeToken( CSSToken.SEMI_COLON, ';' );

				case Char.SINGLE_QUOTE:
				case Char.DOUBLE_QUOTE:
					this._position--;
					t = this.readString();
					if ( t != null ) return this.makeToken( CSSToken.STRING_LITERAL, t );
					++this._position;
					break;

				case Char.SLASH:
					if ( this.readCharCode() == Char.ASTERISK ) {
						this._position -= 2;
						t = this.readBlockComment();
						if ( t != null ) return this.makeToken( CSSToken.BLOCK_COMMENT, t );
						++this._position;
					} else {
						--this._position;
					}
					break;

				default:
					if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DASH || c == Char.DOT ) {
						this._position--;
						t = this.readNumber();
						if ( t == null ) {
							this._position++;
							switch ( c ) {
								case Char.DASH:	return this.makeToken( CSSToken.DASH, '-' );
								case Char.DOT:	return this.makeToken( CSSToken.DOT, '.' );
							}
						} else {
							return this.makeToken( CSSToken.NUMBER_LITERAL, t );
						}
					} else if (
						( c >= Char.a && c <= Char.z ) ||
						( c >= Char.A && c <= Char.Z ) ||
						c == Char.DOLLAR ||
						c == Char.UNDER_SCORE ||
						c > 0x7f
					) {
						this._position--;
						return this.makeToken( CSSToken.IDENTIFIER, this.readIdentifier() );
					}
					break;

			}

			return this.makeToken( CSSToken.UNKNOWN, String.fromCharCode( c ) );

		}

	}

}