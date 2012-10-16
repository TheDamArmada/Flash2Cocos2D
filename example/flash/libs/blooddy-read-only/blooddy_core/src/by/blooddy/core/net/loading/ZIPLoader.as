////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.11.2010 16:53:47
	 */
	public class ZIPLoader extends LoaderBase {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		private static const _JUNK:ByteArray = new ByteArray();

		// PKZIP record signatures
		private static const _SIG_CENTRAL_FILE_HEADER:uint =					0x02014B50;
		private static const _SIG_SPANNING_MARKER:uint =						0x30304B50;
		private static const _SIG_LOCAL_FILE_HEADER:uint =						0x04034B50;
		private static const _SIG_DIGITAL_SIGNATURE:uint =						0x05054B50;
		private static const _SIG_END_OF_CENTRAL_DIRECTORY:uint =				0x06054B50;
		private static const _SIG_ZIP64_END_OF_CENTRAL_DIRECTORY:uint =			0x06064B50;
		private static const _SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR:uint =	0x07064B50;
		private static const _SIG_DATA_DESCRIPTOR:uint =						0x08074B50;
		private static const _SIG_ARCHIVE_EXTRA_DATA:uint =						0x08064B50;
		private static const _SIG_SPANNING:uint =								0x08074B50;

		// states
		private static const _STATE_IDLE:uint =								0;
		private static const _STATE_SIGNATURE:uint =						1;
		private static const _STATE_LOCAL_FILE_HEAD:uint =					2;
		private static const _STATE_LOCAL_FILE_HEAD_EXT:uint =				3;
		private static const _STATE_LOCAL_FILE_CONTENT:uint =				4;
		private static const _STATE_LOCAL_FILE_CONTENT_DESCRIPTOR:uint =	5;
		private static const _STATE_LOCAL_FILE_CONTENT_DATA:uint =			6;
		private static const _STATE_LOCAL_FILE_UNCOMPRESS:uint =			7;

		// compression methods
		private static const _COMPRESSION_NONE:uint =				0;
		private static const _COMPRESSION_SHRUNK:uint =				1;
		private static const _COMPRESSION_REDUCED_1:uint =			2;
		private static const _COMPRESSION_REDUCED_2:uint =			3;
		private static const _COMPRESSION_REDUCED_3:uint =			4;
		private static const _COMPRESSION_REDUCED_4:uint =			5;
		private static const _COMPRESSION_IMPLODED:uint =			6;
		private static const _COMPRESSION_TOKENIZED:uint =			7;
		private static const _COMPRESSION_DEFLATED:uint =			8;
		private static const _COMPRESSION_DEFLATED_EXT:uint =		9;
		private static const _COMPRESSION_IMPLODED_PKWARE:uint =	10;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ZIPLoader(request:URLRequest=null) {
			super( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Vector.<ByteArray> = new Vector.<ByteArray>();

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private var _stream:flash.net.URLStream;

		/**
		 * @private
		 */
		private var _input:IDataInput;

		/**
		 * @private
		 */
		private var _need:uint;

		/**
		 * @private
		 */
		private var _state:uint = _STATE_IDLE;

		/**
		 * @private
		 */
		private var _fileInfo:FileInfo;

		/**
		 * @private
		 */
		private var _file:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get content():ByteArray {
			return ( this._list.length > 0 ? this._list[ 0 ] : null );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getFileByName(name:String):ByteArray {
			return this._hash[ name ];
		}

		public function getFileAt(index:uint):ByteArray {
			if ( index >= this._list.length ) return null;
			return this._list[ index ];
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * метод хак, существует для того что бы HeuristicLoader просто сделал
		 * перенаправление а не начинал загрузку заново
		 */
		$protected_load function $assign(input:ByteArray, stream:flash.net.URLStream=null, url:String=null):void {
			this.start( url );
			if ( stream ) {
				this.assign_stream( stream, true );
				this._stream = stream;
				this._input = input;
				this._input.endian = Endian.LITTLE_ENDIAN;
				this._state = _STATE_SIGNATURE;
				try {
					this._need = this.parse();
					if ( this._need <= 0 ) {
						this._stream.removeEventListener( ProgressEvent.PROGRESS, this.handler_stream_input_progress );
						this._stream.addEventListener( ProgressEvent.PROGRESS, this.handler_stream_progress );
					}
				} catch ( e:* ) {
					this.throwError( e );
				}
			} else {
				this.$loadBytes( input );
			}
		}

		$protected_load override function $load(request:URLRequest):void {
			this._state = _STATE_SIGNATURE;
			this._input =
			this._stream = this.create_stream();
			this._stream.load( request );
		}

		$protected_load override function $loadBytes(bytes:ByteArray):void {
			this._state = _STATE_SIGNATURE;
			bytes.endian = Endian.LITTLE_ENDIAN;
			this._input = bytes;
			try {
				this._need = this.parse();
				if ( this._need > 0 ) {
					throw new IOError();
				}
				this.clear();
				super.completeHandler( new Event( Event.COMPLETE ) );
			} catch ( e:* ) {
				this.throwError( e );
			}
		}

		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._stream );
			this._state = _STATE_IDLE;
			var bytes:ByteArray;
			while ( this._list.length > 0 ) {
				bytes = this._list.pop();
				bytes.clear();
			}
			for ( var name:String in this._hash ) {
				delete this._hash[ name ];
			}
			this.clear();
			return unload;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * создаёт URLStream для загрузки
		 */
		private function create_stream():flash.net.URLStream {
			var result:flash.net.URLStream = _BIN.takeOut( 'stream' ) || new flash.net.URLStream();
			this.assign_stream( result );
			return result;
		}

		/**
		 * @private
		 * создаёт URLStream для загрузки
		 */
		private function assign_stream(stream:flash.net.URLStream, useBuffer:Boolean=false):void {
			stream.endian = Endian.LITTLE_ENDIAN;
			stream.addEventListener( Event.OPEN,						super.dispatchEvent );
			stream.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( _HTTP_RESPONSE_STATUS ) {
				stream.addEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			if ( useBuffer ) {
				stream.addEventListener( ProgressEvent.PROGRESS,		this.handler_stream_input_progress );
			} else {
				stream.addEventListener( ProgressEvent.PROGRESS,		this.handler_stream_progress );
			}
			stream.addEventListener( Event.COMPLETE,					this.handler_stream_complete );
			stream.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_error );
			stream.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_error );
		}

		/**
		 * @private
		 */
		private function clear():void {
			if ( this._file ) {
				this._file.clear();
				_BIN.takeIn( 'bytes', this._file );
			}
			this._file = null;
			this._fileInfo = null;
			this.clear_stream();
			this.clear_input();
		}

		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream():void {
			if ( this._stream ) {
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				if ( _HTTP_RESPONSE_STATUS ) {
					this._stream.removeEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
				}
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_input_progress );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_progress );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_error );
				if ( this._stream.connected ) {
					this._stream.close();
				}
				_BIN.takeIn( 'stream', this._stream ); 
				this._stream = null;
			}
		}

		/**
		 * @private
		 * очищает буфер
		 */
		private function clear_input():void {
			if ( this._input ) {
				if ( this._input is ByteArray ) {
					( this._input as ByteArray ).clear();
					_BIN.takeIn( 'bytes', this._input );
				}
				this._input = null;
			}
		}

		/**
		 * @private
		 */
		private function parse():uint {
			var sig:uint;
			var bytesLeft:uint;
			//var vSrc:uint;
			var flag:uint;
			//var msdosTime:uint, msdosDate:uint;
			//var headerID:uint;
			var dataSize:uint;
			var extraBytes:ByteArray;
			var need:int;
			var pos:uint;
			var len:uint;
			var sizeCompressed:uint;
			var sizeUncompressed:uint;
			var file:Boolean;
			while ( this._state != _STATE_IDLE ) {
				switch ( this._state ) {

					case _STATE_SIGNATURE:
						if ( this._input.bytesAvailable < 4 ) return 4 - this._input.bytesAvailable;
						sig = this._input.readUnsignedInt();
						switch ( sig ) {
							case _SIG_LOCAL_FILE_HEADER:
								this._state = _STATE_LOCAL_FILE_HEAD;
								break; // continue next state
							case _SIG_CENTRAL_FILE_HEADER:
							case _SIG_END_OF_CENTRAL_DIRECTORY:
							case _SIG_SPANNING_MARKER:
							case _SIG_DIGITAL_SIGNATURE:
							case _SIG_ZIP64_END_OF_CENTRAL_DIRECTORY:
							case _SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR:
							case _SIG_DATA_DESCRIPTOR:
							case _SIG_ARCHIVE_EXTRA_DATA:
							case _SIG_SPANNING:
								this._state = _STATE_IDLE; // end
								return 0;
							default:
								throw new IOError( 'Unknown record signature: 0x' + sig.toString( 16 ) );
						}

					case _STATE_LOCAL_FILE_HEAD:
						if ( this._input.bytesAvailable < 30 ) return 30 - this._input.bytesAvailable;
						this._fileInfo = new FileInfo();
						this._input.readUnsignedShort();//vSrc = this._input.readUnsignedShort();
						//this._fileInfo.versionHost = vSrc >> 8;
						//this._fileInfo.versionNumber = Math.floor( ( vSrc & 0xFF ) / 10 ) + '.' + ( ( vSrc & 0xFF ) % 10 );
						flag = this._input.readUnsignedShort();
						//this._fileInfo.encrypted =					( flag & 0x01 ) !== 0;
						this._fileInfo.hasDataDescriptor =			( flag & 0x08 ) !== 0;
						//this._fileInfo.hasCompressedPatchedData =	( flag & 0x20 ) !== 0;
						if ( ( flag & 800 ) !== 0 ) {
							this._fileInfo.filenameEncoding = 'utf-8';
						} else {
							this._fileInfo.filenameEncoding = 'x-ascii';
						}
						this._fileInfo.compressionMethod = this._input.readUnsignedShort();
						if ( this._fileInfo.compressionMethod === _COMPRESSION_IMPLODED ) {
							//this._fileInfo.implodeDictSize = ( ( flag & 0x02 ) !== 0 ? 8192 : 4096 );
							//this._fileInfo.implodeShannonFanoTrees = ( flag & 0x04 ) !== 0 ? 3 : 2;
						} else if ( this._fileInfo.compressionMethod === _COMPRESSION_DEFLATED ) {
							//this._fileInfo.deflateSpeedOption = ( flag & 0x06 ) >> 1;
						}
						this._input.readUnsignedInt()
						//msdosTime = this._input.readUnsignedShort();
						//msdosDate = this._input.readUnsignedShort();
						//this._fileInfo.date = new Date(
						//	( ( msdosDate & 0xFE00 ) >> 9 ) + 1980,	// year
						//	( ( msdosDate & 0x01E0 ) >> 5 ) - 1,	// month
						//	    msdosDate & 0x001F,					// day
						//	  ( msdosTime & 0xF800 ) >> 11,			// hour
						//	  ( msdosTime & 0x07E0 ) >> 5,			// min
						//	    msdosTime & 0x001F,					// sec
						//	  0
						//);
						this._input.readUnsignedInt();//this._fileInfo.crc32 = this._input.readUnsignedInt();
						this._fileInfo.sizeCompressed = this._input.readUnsignedInt();
						this._fileInfo.sizeUncompressed = this._input.readUnsignedInt();
						this._fileInfo.sizeFilename = this._input.readUnsignedShort();
						this._fileInfo.sizeExtra = this._input.readUnsignedShort();
						if ( this._fileInfo.sizeFilename + this._fileInfo.sizeExtra > 0 ) {
							this._state = _STATE_LOCAL_FILE_HEAD_EXT;
						} else {
							this._state = _STATE_LOCAL_FILE_CONTENT;
							break; // jump to next state
						}

					case _STATE_LOCAL_FILE_HEAD_EXT:
						if ( this._input.bytesAvailable < this._fileInfo.sizeFilename + this._fileInfo.sizeExtra ) {
							return this._fileInfo.sizeFilename + this._fileInfo.sizeExtra - this._input.bytesAvailable;
						}
						if ( this._fileInfo.filenameEncoding == 'utf-8' ) {
							this._fileInfo.filename = this._input.readUTFBytes( this._fileInfo.sizeFilename ); // Fixes a bug in some players
						} else {
							this._fileInfo.filename = this._input.readMultiByte( this._fileInfo.sizeFilename, this._fileInfo.filenameEncoding );
						}
						bytesLeft = this._fileInfo.sizeExtra;
						while ( bytesLeft > 4 ) {
							this._input.readUnsignedShort();//headerID = this._input.readUnsignedShort();
							dataSize = this._input.readUnsignedShort();
							if ( dataSize > bytesLeft ) {
								throw new IOError( 'Parse error in file ' + this._fileInfo.filename + ': Extra field data size too big.' );
							}
							if ( !extraBytes ) extraBytes = new ByteArray();
							this._input.readBytes( extraBytes, 0, dataSize );
							//if ( headerID === 0xDADA && dataSize === 4 ) {
							//	this._fileInfo.adler32 = this._input.readUnsignedInt();
							//	this._fileInfo.hasAdler32 = true;
							//} else if ( dataSize > 0 ) {
							//	if ( !this._fileInfo.extraFields ) this._fileInfo.extraFields = new Object();
							//	extraBytes = new ByteArray();
							//	this._input.readBytes( extraBytes, 0, dataSize );
							//	this._fileInfo.extraFields[ headerID ] = extraBytes;
							//}
							bytesLeft -= dataSize + 4;
						}
						if ( bytesLeft > 0 ) {
							if ( this._input is ByteArray ) {
								( this._input as ByteArray ).position += bytesLeft;
							} else {
								this._input.readBytes( _JUNK, 0, bytesLeft );
								_JUNK.clear();
							}
						}
						this._state = _STATE_LOCAL_FILE_CONTENT;
						
					case _STATE_LOCAL_FILE_CONTENT:
						this._file = new ByteArray();
						this._file.endian = Endian.LITTLE_ENDIAN;
						if ( this._fileInfo.hasDataDescriptor ) {
							this._state = _STATE_LOCAL_FILE_CONTENT_DESCRIPTOR;
							break;	// jump to next state
						} else {
							this._state = _STATE_LOCAL_FILE_CONTENT_DATA;
						}

					case _STATE_LOCAL_FILE_CONTENT_DATA:
						if ( this._input.bytesAvailable < this._fileInfo.sizeCompressed ) {
							return this._fileInfo.sizeCompressed - this._input.bytesAvailable;
						}
						if ( this._fileInfo.sizeCompressed != 0 ) {
							this._input.readBytes( this._file, 0, this._fileInfo.sizeCompressed );
						}
						this._state = _STATE_LOCAL_FILE_UNCOMPRESS;

					case _STATE_LOCAL_FILE_UNCOMPRESS:
						try { 
							switch ( this._fileInfo.compressionMethod ) {
								case _COMPRESSION_NONE:
									break;
								case _COMPRESSION_DEFLATED:
									this._file.inflate();
									break;
								default:
									throw new IOError();
							}
							this._list.push( this._file );
							if ( this._fileInfo.filename ) {
								this._hash[ this._fileInfo.filename ] = this._file;
							}
							this._file = null;
							this._fileInfo = null;
							if ( this._list.length == 1 ) {
								if ( super.hasEventListener( Event.INIT ) ) {
									super.dispatchEvent( new Event( Event.INIT ) );
								}
							}
						} catch ( e:* ) {
							// ignore error
						}
						this._state = _STATE_SIGNATURE;
						break;
					
					case _STATE_LOCAL_FILE_CONTENT_DESCRIPTOR:
						file = true;
						need = 16 - this._file.bytesAvailable;
						do {
							if ( this._input.bytesAvailable < need ) return need;
							this._input.readBytes( this._file, pos, need );
							pos = this._file.position;
							len = pos + 16;
							for ( ; pos < len; ++pos ) {
								if ( this._file[ pos ] == 0x50 ) { // 0x08074B50
									need = pos + 16 - len;
									this._file.position = pos;
									if ( need > 0 ) {
										if ( this._input.bytesAvailable < need ) return need;
										this._input.readBytes( this._file, len, need );
										len += need;
									}
									if ( this._file.readUnsignedInt() == _SIG_DATA_DESCRIPTOR ) {
										sizeCompressed = this._input.readUnsignedInt();
										if ( sizeCompressed == this._file.length - 16 ) {
											sizeUncompressed = this._input.readUnsignedInt();
											this._file.length -= 16;
											file = false;
											break;
										}
									}
								}
							}
							this._file.position = pos;
							need = 16;
						} while ( file );
						this._fileInfo.sizeCompressed = sizeCompressed;
						this._fileInfo.sizeUncompressed = sizeUncompressed;
						this._state = _STATE_LOCAL_FILE_UNCOMPRESS;
						break;


				}
			}
			return 0;
		}

		/**
		 * @private
		 */
		private function throwError(e:*):void {
			this.clear();
			var event:ErrorEvent;
			if ( e is SecurityError ) {
				event = new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.toString() );
			} else if ( e is Error ) {
				event = new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString(), e.errorID );
			} else {
				event = new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, String( e ) );
			}
			super.completeHandler( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_stream_complete(event:Event):void {
			if ( this._state == _STATE_IDLE ) {
				this.clear();
				super.completeHandler( event );
			} else {
				this.throwError( '' );
			}
		}

		/**
		 * @private
		 */
		private function handler_stream_error(event:ErrorEvent):void {
			this.clear();
			super.completeHandler( event );
		}

		/**
		 * @private
		 */
		private function handler_stream_progress(event:ProgressEvent):void {
			try {
				this.parse();
				super.progressHandler( event );
			} catch ( e:* ) {
				this.throwError( e );
			}
		}

		/**
		 * @private
		 */
		private function handler_stream_input_progress(event:ProgressEvent):void {
			if ( this._stream.bytesAvailable >= this._need ) {
				this._stream.readBytes( this._input as ByteArray, ( this._input as ByteArray ).length, this._need );
				try {
					this.parse();
					this._stream.removeEventListener( ProgressEvent.PROGRESS, this.handler_stream_input_progress );
					this._stream.addEventListener( ProgressEvent.PROGRESS, this.handler_stream_progress );
					this._input = this._stream;
					this.parse();
					this.progressHandler( event );
				} catch ( e:* ) {
					this.throwError( e );
				}
			}
		}

	}

}

/**
 * @private
 */
internal final class FileInfo {
	
	public function FileInfo() {
		super();
	}
		
//	public var versionHost:int = 0;
//	public var versionNumber:String = '2.0';
	public var compressionMethod:int;
//	public var encrypted:Boolean = false;
//	public var implodeDictSize:int = -1;
//	public var implodeShannonFanoTrees:int = -1;
//	public var deflateSpeedOption:int = -1;
	public var hasDataDescriptor:Boolean = false;
//	public var hasCompressedPatchedData:Boolean = false;
//	public var date:Date;
//	public var adler32:uint;
//	public var hasAdler32:Boolean = false;
	public var sizeFilename:uint = 0;
	public var sizeExtra:uint = 0;
	public var filename:String;
	public var filenameEncoding:String;
//	public var extraFields:Object;
//	public var crc32:uint;
	public var sizeCompressed:uint = 0;
	public var sizeUncompressed:uint = 0;

}