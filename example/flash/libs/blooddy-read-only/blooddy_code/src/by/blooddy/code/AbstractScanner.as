////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code {

	import by.blooddy.code.utils.Char;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					13.03.2010 18:56:37
	 */
	public class AbstractScanner implements IScanner {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AbstractScanner() {
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
		protected var _prevPosition:uint;

		/**
		 * @private
		 */
		protected var _nextPosition:uint;
		
		/**
		 * @private
		 */
		protected var _nextTokenKind:uint;
		
		/**
		 * @private
		 */
		protected var _nextTokenText:String;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected var _source:String;
		
		public function get source():String {
			return this._source;
		}

		/**
		 * @private
		 */
		protected var _tokenKind:uint;

		public final function get tokenKind():uint {
			return this._tokenKind;
		}
		
		/**
		 * @private
		 */
		protected var _tokenText:String;
		
		public final function get tokenText():String {
			return this._tokenText;
		}

		
		/**
		 * @private
		 */
		protected var _position:uint;
		
		public final function get position():uint {
			return this._position;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public final function writeSource(source:String):void {
			this._prevPosition = 0;
			this._position = 0;
			this._tokenText = null;
			this._source = source;
		}
		
		public final function readTokenAsLength(tok:uint, length:uint, binary:Boolean=false):uint {
			this._prevPosition = this._position;
			this._nextPosition = 0;
			length = Math.min( length, this._source.length - this._position );
			var v:String = this._source.substr( this._position, length );
			if ( binary ) {
				var bytes:ByteArray = new ByteArray();
				bytes.writeUTFBytes( v );
				bytes.position = 0;
				v = bytes.readUTFBytes( length );
			}
			this._position += v.length;
			return this.makeToken( tok, v );
		}
		
		public final function readTokenAsTo(tok:uint, ...chars):uint {
			this._prevPosition = this._position;
			this._nextPosition = 0;
			var c:uint;
			var pos:uint = this._position;
			while (
				( c = this.readCharCode() ) != Char.EOS &&
				chars.indexOf( c ) < 0
			) {};
			this._position--;
			return this.makeToken( tok, this._source.substring( pos, this._position ) );
		}
		
		public final function readTokenAsWhile(tok:uint, ...chars):uint {
			this._prevPosition = this._position;
			this._nextPosition = 0;
			var c:uint;
			var pos:uint = this._position;
			while ( chars.indexOf( this.readCharCode() ) >= 0 ) {};
			this._position--;
			return this.makeToken( tok, this._source.substring( pos, this._position ) );
		}
		
		public final function readToken():uint {
			this._prevPosition = this._position;
			if ( this._nextPosition > 0 ) {
				this._position = this._nextPosition;
				this._tokenKind = this._nextTokenKind;
				this._tokenText = this._nextTokenText;
				this._nextPosition = 0;
				return this._tokenKind;
			} else {
				return this.$readToken();
			}
		}

		public final function retreat():void {
			this._nextTokenKind = this._tokenKind;
			this._nextTokenText = this._tokenText;
			this._nextPosition = this._position;
			this._tokenKind = 0;
			this._tokenText = null;
			this._position = this._prevPosition;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected virtual function $readToken():uint {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		protected final function readCharCode():uint {
			return this._source.charCodeAt( this._position++ );
		}
		
		/**
		 * @private
		 */
		protected final function readChar():String {
			return this._source.charAt( this._position++ );
		}
		
		/**
		 * @private
		 */
		protected final function makeToken(kind:uint, text:String):uint {
			this._tokenKind = kind;
			this._tokenText = text;
			return kind;
		}
		
		/**
		 * @private
		 */
		protected final function readIdentifier():String {
			var pos:uint = this._position;
			var c:uint = this.readCharCode();
			if (
				( c < Char.a || c > Char.z ) &&
				( c < Char.A || c > Char.Z ) &&
				c != Char.DOLLAR &&
				c != Char.UNDER_SCORE &&
				c <= 0x7f
			) {
				this._position--;
				return null;
			}
			do {
				c = this.readCharCode();
			} while (
				( c >= Char.a && c <= Char.z ) ||
				( c >= Char.A && c <= Char.Z ) ||
				( c >= Char.ZERO && c <= Char.NINE ) ||
				c == Char.DOLLAR ||
				c == Char.UNDER_SCORE ||
				c > 0x7f
			);
			this._position--;
			return this._source.substring( pos, this._position );
		}
		
		/**
		 * @private
		 */
		protected final function readString():String {
			var pos:uint = this._position;
			var to:uint = this.readCharCode();
			if ( to != Char.SINGLE_QUOTE && to != Char.DOUBLE_QUOTE ) {
				this._position = pos; // откатываемся
				return null;
			}
			var p:uint = pos + 1;
			var result:String = '';
			var c:uint, t:String;
			while ( ( c = this.readCharCode() ) != to ) {
				switch ( c ) {
					case Char.BACK_SLASH:
						result += this._source.substring( p, this._position - 1 );
						switch ( c = this.readCharCode() ) {
							case Char.n:	result += '\n';	break;
							case Char.r:	result += '\r';	break;
							case Char.t:	result += '\t';	break;
							case Char.v:	result += '\v';	break;
							case Char.f:	result += '\f';	break;
							case Char.b:	result += '\b';	break;
							case Char.x:
								t = this.readFixedHex( 2 );
								if ( t )	result += String.fromCharCode( parseInt( t, 16 ) );
								else		result += 'x';
								break;
							case Char.u:
								t = this.readFixedHex( 4 );
								if ( t )	result += String.fromCharCode( parseInt( t, 16 ) );
								else		result += 'u';
								break;
							default:
								result += String.fromCharCode( c );
								break;
						}
						p = this._position;
						break;
					case Char.EOS:
					case Char.CARRIAGE_RETURN:
					case Char.NEWLINE:
						this._position = pos; // откатываемся
						return null;
				}
			}
			return result + this._source.substring( p, this._position - 1 );
		}
		
		/**
		 * @private
		 */
		protected final function readNumber():String {
			var pos:uint = this._position;
			var c:uint = this.readCharCode();
			var t:String;
			var s:String;
			if ( c == Char.DASH ) {
				s = '-';
				c = this.readCharCode();
			} else {
				s = '';
			}
			if ( c == Char.ZERO ) {

				switch ( this.readCharCode() ) {
					case Char.x:	// hex
					case Char.X:
						t = this.readHex();
						if ( t != null ) return s + parseInt( t, 16 );
						break;
					case Char.DOT:	// float
						t = this.readDec();
						if ( t != null ) return s + '.' + t + ( this.readExp() || '' );
						break;
					default:		// oct
						this._position--;
				}

			} else if ( c == Char.DOT ) {

				t = this.readDec();
				if ( t != null ) return s + '.' + t + ( this.readExp() || '' );

			}

			this._position--;
			t = this.readDec();

			if ( t != null ) {
				s += t;
				if ( this.readCharCode() == Char.DOT ) {
					t = this.readDec();
					if ( t != null ) s += '.' + t;
				} else {
					this._position--;
				}
				return s + ( this.readExp() || '' );
			}

			this._position = pos;
			return null;
		}
		
		/**
		 * @private
		 */
		private function readDec():String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
			} while (
				c >= Char.ZERO && c <= Char.NINE
			);
			this._position--;
			if ( this._position == pos ) return null;
			return this._source.substring( pos, this._position );
		}

		/**
		 * @private
		 */
		private function readExp():String {
			var c:uint = this.readCharCode();
			if ( c == Char.e || c == Char.E ) {
				var prefix:String;
				c = this.readCharCode();
				if ( c == Char.DASH ) {
					prefix = '-';
				} else {
					prefix = '';
					if ( c != Char.PLUS ) {
						this._position--;
					}
				}
				var t:String = this.readDec();
				if ( t != null ) return 'e' + prefix + t;
			}
			this._position--;
			return null;
		}

		/**
		 * @private
		 */
		private function readHex():String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
			} while (
				( c >= Char.ZERO && c <= Char.NINE ) ||
				( c >= Char.a && c <= Char.f ) ||
				( c >= Char.A && c <= Char.F )
			);
			this._position--;
			if ( this._position == pos ) return null;
			return this._source.substring( pos, this._position );
		}
		
		/**
		 * @private
		 */
		private function readFixedHex(length:uint=0):String {
			var c:uint;
			for ( var i:uint = 0; i<length; ++i ) {
				c = this.readCharCode();
				if (
					( c < Char.ZERO || c > Char.NINE ) &&
					( c < Char.a || c > Char.f ) &&
					( c < Char.A || c > Char.F )
				) {
					this._position -= i;
					return null;
				}
			}
			return this._source.substring( this._position - length, this._position );
		}
		
		/**
		 * @private
		 */
		protected final function readTo(...to):String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
				switch ( c ) {
					case Char.CARRIAGE_RETURN:
					case Char.NEWLINE:
						break;
				}
				if ( to.indexOf( c ) >= 0 ) {
					this._position--;
					return this._source.substring( pos, this._position );
				}
			} while ( c != Char.EOS );
			this._position = pos;
			return null;
		}
		
		/**
		 * @private
		 */
		protected final function readLine():String {
			var pos:uint = this._position;
			var c:uint;
			do {
				c = this.readCharCode();
			} while ( c != Char.NEWLINE && c != Char.CARRIAGE_RETURN && c != Char.EOS );
			this._position--;
			return this._source.substring( pos, this._position );
		}
		
		/**
		 * @private
		 */
		protected final function readBlockComment():String {
			var pos:uint = this._position;
			if (
				this.readCharCode() != Char.SLASH ||
				this.readCharCode() != Char.ASTERISK
			) {
				this._position = pos;
				return null;
			}
			do {
				switch ( this.readCharCode() ) {
					case Char.ASTERISK:
						if ( this.readCharCode() == Char.SLASH ) {
							return this._source.substring( pos + 2, this._position - 2 );
						} else {
							this._position--;
						}
						break;
					case Char.CARRIAGE_RETURN:
					case Char.NEWLINE:
						break;
					case Char.EOS:
						this._position = pos;
						return null;
				}
			} while ( true );
			this._position = pos;
			return null;
		}
		
	}
	
}