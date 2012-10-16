////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.utils.ByteArray;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public final class MIME {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _EXTENSION:RegExp = /[^\.\?]+(?=\?.+$|$)/;

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const FLASH:String =	'application/x-shockwave-flash';

		public static const GIF:String =	'image/gif';

		public static const JPEG:String =	'image/jpeg';

		public static const PNG:String =	'image/png';

		public static const BINARY:String =	'application/octet-stream';

		public static const ZIP:String =	'application/zip'; // application/x-zip-compressed

		public static const MP3:String =	'audio/mpeg';

		public static const HTML:String =	'text/html';

		public static const TEXT:String =	'text/plain';

		public static const RSS:String =	'text/xml+rss';

		public static const XML:String =	'text/xml';

		public static const CSS:String =	'text/css';

		public static const VARS:String =	'multipart/form-data';

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function analyseBytes(bytes:ByteArray):String {
			if (
				(
					bytes[0] == 67 ||	// C
					bytes[0] == 70		// F
				) &&
				bytes[1] == 87 &&	// W
				bytes[2] == 83		// S
			) {
				return FLASH;
			} else if (
				bytes[0] == 71 &&	// G
				bytes[1] == 73 &&	// I
				bytes[2] == 70		// F
			) {
				// TODO: проверить коректность кодеков
				return GIF;
			} else if (
				bytes[0] == 0x89 &&	// ‰
				bytes[1] == 0x50 &&	// P 
				bytes[2] == 0x4E &&	// N
				bytes[3] == 0x47	// G
			) { 
				return PNG;
			} else if (
				bytes[0] == 0xFF &&
				bytes[1] == 0xD8
			) {
				// TODO: внедрить порверку по глубже
				return JPEG;
			} else if (
				bytes[0] == 73 &&	// I
				bytes[1] == 68 &&	// D
				bytes[2] == 51		// 3
			) {
				// TODO: углубить проверку
				return MP3;
			} else if (
				bytes[0] == 0x50 &&
				bytes[1] == 0x4B &&
				bytes[2] == 0x03 &&
				bytes[3] == 0x04
			) {
				return ZIP;
			} else {
//				var l:uint = bytes.length;
//				for ( var i:uint = 0; i<l; ++i ) {
//					if ( i[i]
//				}
			}

			// TODO: bmp, video
			return null;
		}

		public static function analyseURL(url:String):String {
			if ( url ) {
				var m:Array = url.match( _EXTENSION );
				if ( m ) {
					switch ( m[ 0 ] ) {
						case 'swf':		return FLASH;
						case 'jpeg':
						case 'jpg':		return JPEG;
						case 'gif':		return GIF;
						case 'png':		return PNG;
						case 'mp3':		return MP3;
						case 'css':		return CSS;
						case 'rss':		return RSS;
						case 'xml':		return XML;
						case 'html':
						case 'htm':		return HTML;
						case 'txt':		return TEXT;
						case 'zip':		return ZIP;
					}
				}
			}
			return null;
		}

	}

}

// MP3

internal final class MP3Frame {

	public static const LAYER_1:uint = 1;
	public static const LAYER_2:uint = 2;
	public static const LAYER_3:uint = 3;

	public static const VERSION_1:uint = 1;
	public static const VERSION_2:uint = 2;

	public static const BITRATES:Array = new Array(
		0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, null,
		0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, null,
		0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, null,
		0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, null,
		0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, null,
		0, 8, 16, 24, 32, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, null
	);

	public static const FREQUENCIES:Array = new Array(
		44100, 48000, 32000,
		22050, 24000, 16000
	);

	public function MP3Frame(header:uint) {
		super();

		if ( uint( 0xFFE00000 & header ) != 0xFFE00000 ) throw new ArgumentError();

		switch ( ( 0x00180000 & header ) >> 19 ) {
			case 0:
			case 2:	this.version = VERSION_2;	break;
			case 3:	this.version = VERSION_1;	break;
		}

		switch ( ( 0x00060000 & header ) >> 17 ) {
			case 1:	this.layer = LAYER_3;		break;
			case 2:	this.layer = LAYER_2;		break;
			case 3:	this.layer = LAYER_1;		break;
		}

		var crc:Boolean = ( 0x00010000 & header ) == 0;

		this.bitrate =	BITRATES[ ( ( version - 1 ) * 3 + layer - 1 ) * 16 + ( ( 0x0000F000 & header ) >> 12 ) ];
		this.frequency = FREQUENCIES[ ( ( version - 1 ) * 3 + ( 0x00000C00 & header ) ) ];
		this.padding =	( 0x00000200 & header ) >> 9;
						//( 0x00000100 & header ) >> 8;

		this.length = 144000 * this.bitrate / this.frequency + this.padding;

	}

	public var version:uint;

	public var layer:uint;

	public var crc:uint;

	public var bitrate:uint;

	public var frequency:uint;

	public var padding:uint;

	public var length:uint;

}
/*
		private function parse_mp3():uint {
			var tmp:uint;
			this._input.endian = Endian.BIG_ENDIAN;
			this._input.position = 0;

//			var i:uint = 0;
//
//			while ( this._draft.bytesAvailable > 4 ) {
//				this._draft.position = i;
//				tmp = this._draft.readUnsignedInt();
//				if ( uint( 0xFFE00000 & tmp ) == 0xFFE00000 ) {
//					trace( this._draft.position - 4 );
//					frame = new MP3Frame( tmp );
//					i += frame.length;
//				} else {
//					++i;
//				}
//			}

			var frame:MP3Frame;
			if ( this._input.bytesAvailable < 4 ) return WAIT;
			tmp = this._input.readUnsignedInt();
			// первые 11 бит заполнены
			if ( uint( 0xFFE00000 & tmp ) == 0xFFE00000 ) { // ОПА! нашли тэг. выцепляем
				try {
					frame = new MP3Frame( tmp );
					this._input.position += frame.length;
					tmp = this._input.readUnsignedInt();
					if ( uint( 0xFFE00000 & tmp ) == 0xFFE00000 ) { 
						try {
							frame = new MP3Frame( tmp );
							return SUCCESS;
						} catch (e:Error) {
							return FAIL;
						}
					}
				} catch (e:Error) {
				} finally {

				}
			}

*/

//////////////////////////////////////////////////////////////////////////////////
////
////  (C) 2009 BlooDHounD
////
//////////////////////////////////////////////////////////////////////////////////
//
//package by.blooddy.core.net {
//
//	import flash.utils.ByteArray;
//
//	/**
//	 * @author					BlooDHounD
//	 * @version					1.0
//	 * @playerversion			Flash 10
//	 * @langversion				3.0
//	 */
//	public final class MIME {
//
//		//--------------------------------------------------------------------------
//		//
//		//  Class variables
//		//
//		//--------------------------------------------------------------------------
//
//		/**
//		 * @private
//		 */
//		private static const _PROTO:Object = createMIME( 'application/octet-stream' );
//
//		/**
//		 * @private
//		 */
//		private static const _HASH:Object = new Object();
//		_HASH[ _PROTO ] = _PROTO;
//
//		/**
//		 * @private
//		 */
//		private static const _EXTENSION:RegExp = /[^\.\?]+(?=\?.+$|$)/;
//
//		//--------------------------------------------------------------------------
//		//
//		//  Class constants
//		//
//		//--------------------------------------------------------------------------
//
//		public static const BINARY:* =	_PROTO;
//
//		public static const FLASH:* =	getMIME( 'application/x-shockwave-flash' );
//
//		public static const GIF:* =		getMIME( 'image/gif' );
//
//		public static const JPEG:* =	getMIME( 'image/jpeg' );
//
//		public static const PNG:* =		getMIME( 'image/png' );
//
//		public static const ZIP:* =		getMIME( 'application/zip' );
//
//		public static const MP3:* =		getMIME( 'audio/mpeg' );
//
//		public static const TEXT:* =	getMIME( 'text/plain' );
//
//		public static const XML:* =		getMIME( 'text/xml', TEXT );
//
//		public static const HTML:* =	getMIME( 'text/html', TEXT );
//
//		public static const RSS:* =		getMIME( 'text/xml+rss', XML );
//
//		public static const CSS:* =		getMIME( 'text/css', TEXT );
//
//		public static const VARS:* =	getMIME( 'multipart/form-data', TEXT );
//
//		//--------------------------------------------------------------------------
//		//
//		//  Class methods
//		//
//		//--------------------------------------------------------------------------
//
//		public static function isPrototypeOf(type:*, subtype:*):Boolean {
//			if ( type is String ) {
//				type = getMIME( type );
//			} else if ( !_PROTO.isPrototypeOf( type ) ) {
//				throw Error.throwError( TypeError, 1034, type, _PROTO );
//			}
//
//			if ( subtype is String ) {
//				subtype = getMIME( subtype );
//			} else if ( !_PROTO.isPrototypeOf( subtype ) ) {
//				throw Error.throwError( TypeError, 1034, subtype, _PROTO );
//			}
//
//			return type.isPrototypeOf( subtype );
//		}
//
//		public static function getMIME(type:*, parent:*=null):* {
//			if ( !type ) throw new ArgumentError();
//			if ( parent ) {
//				if ( parent is String ) {
//					parent = getMIME( parent );
//				} else if ( !_PROTO.isPrototypeOf( parent ) ) {
//					throw Error.throwError( TypeError, 1034, parent, _PROTO );
//				}
//			}
//			var result:*;
//			if ( type is String ) {
//				result = _HASH[ type ];
//				if ( !result ) {
//					_HASH[ type ] = result = createMIME( type, parent || _PROTO );
//				} 
//			} else if ( !_PROTO.isPrototypeOf( type ) ) {
//				throw Error.throwError( TypeError, 1034, type, _PROTO );
//			}
//			if ( parent && !parent.isPrototypeOf( result ) ) {
//				throw Error.throwError( TypeError, 1034, result, parent );
//			}
//			return result;
//		}
//
//		public static function analyseBytes(bytes:ByteArray):* {
//			if			( bytes[0] == 67 ) { // C
//				if			( bytes[1] == 87 ) { // W
//					if			( bytes[2] == 83 ) { // S
//						// CWS // swf
//						return FLASH;
//					}
//				}
//			} else if	( bytes[0] == 70 ) { // F
//				if			( bytes[1] == 87 ) { // W
//					if			( bytes[2] == 83 ) { // S
//						// FWS // swf
//						return FLASH;
//					}
//				}
//			} else if	( bytes[0] == 71 ) { // G
//				if			( bytes[1] == 73 ) { // I
//					if			( bytes[2] == 70 ) { // F
//						// TODO: проверить коректность кодеков
//						// GIF // gif
//						return GIF;
//					}
//				}
//			} else if	( bytes[0] == 0x89 ) { // 89 50 4E 47
//				if			( bytes[1] == 0x50 ) { // P 
//					if			( bytes[2] == 0x4E ) { // N
//						if			( bytes[3] == 0x47 ) { // G
//							// ‰PNG // png
//							return PNG;
//						}
//					}
//				}
//			} else if	( bytes[0] == 0xFF ) {
//				if			( bytes[1] == 0xD8 ) {
//					// TODO: внедрить порверку по глубже
//					// jpg
//					return JPEG;
//				}
//			} else if	( bytes[0] == 73 ) { // I
//				if			( bytes[1] == 68 ) { // D
//					if			( bytes[2] == 51 ) { // 3
//						// TODO: углубить проверку
//						// ID3 // mp3
//						return MP3;
//					}
//				}
//			} else {
//				//				var l:uint = bytes.length;
//				//				for ( var i:uint = 0; i<l; ++i ) {
//				//					if ( i[i]
//				//				}
//			}
//
//			// TODO: bmp, video
//			return null;
//		}
//
//		public static function analyseURL(url:String):* {
//			if ( url ) {
//				var m:Array = url.match( _EXTENSION );
//				if ( m ) {
//					switch ( m[ 0 ] ) {
//						case 'swf':		return FLASH;
//						case 'jpeg':
//						case 'jpg':		return JPEG;
//						case 'gif':		return GIF;
//						case 'png':		return PNG;
//						case 'mp3':		return MP3;
//						case 'css':		return CSS;
//						case 'rss':		return RSS;
//						case 'rdf':
//						case 'xml':		return XML;
//						case 'html':
//						case 'htm':		return HTML;
//						case 'txt':		return TEXT;
//					}
//				}
//			}
//			return null;
//		}
//
//		//--------------------------------------------------------------------------
//		//
//		//  Private class methods
//		//
//		//--------------------------------------------------------------------------
//
//		/**
//		 * @private
//		 */
//		private static function createMIME(type:String, parent:Object=null):Object {
//			var C:Function = new Function();
//			if ( parent ) {
//				var P:Function = new Function();
//				P.prototype = parent;
//				C.prototype = new P();
//			}
//			C.prototype.name = type;
//			C.prototype.valueOf =
//				C.prototype.toString = function():String {
//					return type;
//				}
//			return new C();
//		}
//
//
//	}
//
//}