////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.json {

	import by.blooddy.code.errors.ParserError;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:17:10 PM
	 */
	internal final class JSONParser {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function JSONParser() {
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
		private const _scanner:JSONScanner = new JSONScanner();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function parse(value:String):* {
			this._scanner.writeSource( value );
			var result:* = this.readValue();
			this.readFixToken( JSONToken.EOF );
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function readToken():uint {
			var tok:uint;
			do {
				tok = this._scanner.readToken();
			} while ( tok == JSONToken.LINE_COMMENT || tok == JSONToken.BLOCK_COMMENT );
			return tok;
		}

		/**
		 * @private
		 */
		private function readFixToken(kind:uint):uint {
			var tok:uint = this.readToken();
			if ( tok != kind ) {
				throw new ParserError( 'ожидается ' + kind + ' вместо ' + tok );
			}
			return tok;
		}

		/**
		 * @private
		 */
		private function readValue():* {
			var tok:uint = this.readToken();
			switch ( tok ) {

				case JSONToken.STRING_LITERAL:
					return this._scanner.tokenText;

				case JSONToken.NUMBER_LITERAL:
					var n:Number = parseFloat( this._scanner.tokenText );
					if ( n % 1 == 0 && n > int.MIN_VALUE ) {
						if ( n < int.MAX_VALUE ) {
							return int( n );
						} else if ( n < uint.MAX_VALUE ) {
							return uint( n );
						}
					}
					return n;

				case JSONToken.NULL:		return null;
				case JSONToken.TRUE:		return true;
				case JSONToken.FALSE:		return false;
				case JSONToken.UNDEFINED:	return undefined;
				case JSONToken.NAN:			return Number.NaN;

				case JSONToken.LEFT_BRACE:		// {
					var o:Object = new Object();
					var key:String;
					tok = this.readToken();
					if ( tok == JSONToken.RIGHT_BRACE ) return o;
					else this._scanner.retreat();
					do {

						tok = this.readToken();
						switch ( tok ) {
							case JSONToken.STRING_LITERAL:
							case JSONToken.IDENTIFIER:		key = this._scanner.tokenText;							break;
							case JSONToken.NUMBER_LITERAL:	key = parseFloat( this._scanner.tokenText ).toString();	break;
							default:						throw new ParserError( 'ожидался ключ объекта, а не ' + tok );
						}

						this.readFixToken( JSONToken.COLON );

						o[ key ] = this.readValue();

						tok = this.readToken();
						switch ( tok ) {
							case JSONToken.COMMA:		break;		// ,
							case JSONToken.RIGHT_BRACE:	return o;	// }
							default:					throw new ParserError( 'ожидалась запятая либо завершение объекта, а не ' + tok );
						}

					} while ( true );
					break;

				case JSONToken.LEFT_BRACKET:	// [
					var arr:Array = new Array();
					do {

						tok = this.readToken();
						switch ( tok ) {
							case JSONToken.RIGHT_BRACKET:	return arr;						// ]
							case JSONToken.COMMA:			arr.push( undefined );	break;	// ,
							default:
								this._scanner.retreat();
								arr.push( this.readValue() );
								tok = this.readToken();
								switch ( tok ) {
									case JSONToken.RIGHT_BRACKET:	return arr;	// ]
									case JSONToken.COMMA:			break;		// ,
									default:						throw new ParserError( 'ожидалась запятая либо завершение массива, а не ' + tok );
								}
						}

					} while ( true );
					break;

			}
			throw new ParserError();
		}

	}

}