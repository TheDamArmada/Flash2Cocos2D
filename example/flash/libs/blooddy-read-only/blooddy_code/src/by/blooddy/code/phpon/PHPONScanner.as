////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.phpon {
	
	import by.blooddy.code.AbstractScanner;
	import by.blooddy.code.utils.Char;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.06.2010 20:59:10
	 */
	internal final class PHPONScanner extends AbstractScanner {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function PHPONScanner() {
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
					
					case Char.EOS:				return this.makeToken( PHPONToken.EOF, '\x00' );
					case Char.COLON:			return this.makeToken( PHPONToken.COLON, ':' );
					case Char.SEMI_COLON:		return this.makeToken( PHPONToken.SEMI_COLON, ';' );
					case Char.LEFT_BRACE:		return this.makeToken( PHPONToken.LEFT_BRACE, '{' );
					case Char.RIGHT_BRACE:		return this.makeToken( PHPONToken.RIGHT_BRACE, '}' );
					case Char.DOUBLE_QUOTE:		return this.makeToken( PHPONToken.DOUBLE_QUOTE, '"' );
					
					default:
						if ( ( c >= Char.ZERO && c <= Char.NINE ) || c == Char.DASH || c == Char.DOT ) {
							this._position--;
							t = this.readNumber();
							if ( t != null ) return this.makeToken( PHPONToken.NUMBER_LITERAL, t );
						} else if (
							( c >= Char.a && c <= Char.z ) ||
							( c >= Char.A && c <= Char.Z ) ||
							c == Char.DOLLAR ||
							c == Char.UNDER_SCORE ||
							c > 0x7f
						) {
							this._position--;
							return this.makeToken( PHPONToken.IDENTIFIER, this.readIdentifier() );
						}
						return this.makeToken( PHPONToken.UNKNOWN, String.fromCharCode( c ) );
				}
			} while ( true );
			throw new ParserError();
			
		}
		
	}
	
}