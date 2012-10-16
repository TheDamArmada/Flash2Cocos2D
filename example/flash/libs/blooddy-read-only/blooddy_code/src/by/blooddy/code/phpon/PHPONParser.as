////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.phpon {
	
	import by.blooddy.code.errors.ParserError;
	
	import flash.net.getClassByAlias;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.06.2010 20:59:29
	 */
	internal final class PHPONParser {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function PHPONParser() {
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
		private const _scanner:PHPONScanner = new PHPONScanner();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function parse(value:String):* {
			this._scanner.writeSource( value );
			var result:* = this.readValue();
			//this.readFixToken( PHPONToken.EOF );
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
		private function readFixToken(kind:uint):uint {
			var tok:uint = this._scanner.readToken();
			if ( tok != kind ) {
				throw new ParserError( 'ожидается ' + kind + ' вместо ' + tok );
			}
			return tok;
		}
		
		/**
		 * @private
		 */
		private function readValue():* {
			var result:*;
			this.readFixToken( PHPONToken.IDENTIFIER );
			var length:uint;
			var semiColon:Boolean = true;
			switch ( this._scanner.tokenText ) {
				case 'd':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					result = parseFloat( this._scanner.tokenText );
					break;
				case 'i':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					result = parseInt( this._scanner.tokenText );
					break;
				case 's':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					length = parseFloat( this._scanner.tokenText );
					this.readFixToken( PHPONToken.COLON );
					result = this.readStringEntity( length );
					break;
				case 'a':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					length = parseFloat( this._scanner.tokenText );
					this.readFixToken( PHPONToken.COLON );
					result = this.readArrayEntity( length );
					semiColon = false;
					break;
				case 'O':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					length = parseFloat( this._scanner.tokenText );
					this.readFixToken( PHPONToken.COLON );
					var name:String = this.readStringEntity( length );
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					length = parseFloat( this._scanner.tokenText );
					this.readFixToken( PHPONToken.COLON );
					result = this.readObjectEntity( name, length );
					semiColon = false;
					break;
				case 'b':
					this.readFixToken( PHPONToken.COLON );
					this.readFixToken( PHPONToken.NUMBER_LITERAL );
					result = Boolean( parseInt( this._scanner.tokenText ) );
					break;
				case 'N':
					result = null;
					break;
				default:
					throw new ParserError();
					break;
			}
			var tok:uint = this._scanner.readToken();
			if ( tok != PHPONToken.SEMI_COLON ) {
				if ( semiColon && tok != PHPONToken.EOF ) {
					throw new ParserError();
				} else {
					this._scanner.retreat();
				}
			}
			return result;
		}

		/**
		 * @private
		 */
		private function readStringEntity(length:uint):String {
			this.readFixToken( PHPONToken.DOUBLE_QUOTE );
			this._scanner.readTokenAsLength( PHPONToken.STRING_LITERAL, length, true );
			var result:String = this._scanner.tokenText;
			this.readFixToken( PHPONToken.DOUBLE_QUOTE );
			return result;
		}
		
		/**
		 * @private
		 */
		private function readArrayEntity(length:uint):Array {
			this.readFixToken( PHPONToken.LEFT_BRACE );
			var result:Array = new Array();
			var key:*;
			var value:*;
			while ( length-- != 0 ) {
				key = this.readValue();
				if ( !( key is String ) && !( key is Number ) ) {
					throw new ParserError();
				}
				value = this.readValue();
				result[ key ] = value;
			}
			this.readFixToken( PHPONToken.RIGHT_BRACE );
			return result;
		}

		/**
		 * @private
		 */
		private function readObjectEntity(name:String, length:uint):Object {
			this.readFixToken( PHPONToken.LEFT_BRACE );
			var result1:Object;
			if ( name != 'stdClass' ) {
				try {
					var c:Class = getClassByAlias( name );
					result1 = new c();
				} catch ( e:Error ) {
				}
			}
			var result2:Object = new Object();
			var key:*;
			var value:*;
			while ( length-- != 0 ) {
				key = this.readValue();
				if ( !( key is String ) ) {
					throw new ParserError();
				}
				value = this.readValue();
				if ( result1 ) {
					try {
						result1[ key ] = value;
					} catch ( e:Error ) {
						result1 = null;
					}
				}
				result2[ key ] = value;
			}
			this.readFixToken( PHPONToken.RIGHT_BRACE );
			return result1 || result2;
		}
		
	}
	
}