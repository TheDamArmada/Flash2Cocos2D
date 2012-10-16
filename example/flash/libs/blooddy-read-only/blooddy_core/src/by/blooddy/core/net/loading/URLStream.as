////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					urlstream
	 */
	public class URLStream extends LoaderBase implements IDataInput {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function URLStream(request:URLRequest=null) {
			super( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stream:flash.net.URLStream;

		/**
		 * @private
		 * буфер загруженных данных
		 */
		private var _input:IDataInput;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @private
		 */
		private var _connected:Boolean = false;

		/**
		 * @copy				flash.net.URLStream#connected
		 */
		public function get connected():Boolean {
			return ( this._stream ? this._stream.connected : this._connected );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function loadBytes(bytes:ByteArray):void {
			super.loadBytes( bytes );
			this._connected = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_load override function $load(request:URLRequest):void {
			this._stream = this.create_stream();
			this._stream.load( request );
			this._input = this._stream;
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			this._input = bytes;
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			super.updateProgress( bytes.length, bytes.length );
			this.completeHandler( new Event( Event.COMPLETE ) );
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = ( this._stream || this._input );
			this._connected = false;
			this.clear_stream();
			this.clear_input();
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
			result.addEventListener( Event.OPEN,						super.dispatchEvent );
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( _HTTP_RESPONSE_STATUS ) {
				result.addEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			result.addEventListener( ProgressEvent.PROGRESS,			this.handler_stream_progress );
			result.addEventListener( Event.COMPLETE,					this.handler_stream_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_complete );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_complete );
			return result;
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
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_progress );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_stream_complete );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_complete );
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

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_stream_progress(event:ProgressEvent):void {
			super.progressHandler( event );
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			this._stream.removeEventListener( ProgressEvent.PROGRESS,	this.handler_stream_progress );
			this._stream.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
		}

		/**
		 * @private
		 */
		private function handler_stream_complete(event:Event):void {
			this._connected = false;
			var bytes:ByteArray = _BIN.takeOut( 'bytes' ) || new ByteArray();
			if ( this._stream.bytesAvailable > 0 ) {
				this._stream.readBytes( bytes );
			}
			this._input = bytes;
			this.clear_stream();
			super.completeHandler( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IDataInput
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesAvailable
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get bytesAvailable():uint {
			return this._input.bytesAvailable;
		}

		//----------------------------------
		//  endian
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get endian():String {
			return this._input.endian;
		}

		/**
		 * @private
		 */
		public function set endian(value:String):void {
			this._input.endian = value;
		}

		//----------------------------------
		//  objectEncoding
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get objectEncoding():uint {
			return this._input.objectEncoding;
		}

		/**
		 * @private
		 */
		public function set objectEncoding(value:uint):void {
			this._input.objectEncoding = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IDataInput
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function readBoolean():Boolean {
			return this._input.readBoolean();
		}

		/**
		 * @inheritDoc
		 */
		public function readByte():int {
			return this._input.readByte();
		}

		/**
		 * @inheritDoc
		 */
		public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {
			this._input.readBytes(bytes, offset, length);
		}

		/**
		 * @inheritDoc
		 */
		public function readDouble():Number {
			return this._input.readDouble();
		}

		/**
		 * @inheritDoc
		 */
		public function readFloat():Number {
			return this._input.readFloat();
		}

		/**
		 * @inheritDoc
		 */
		public function readInt():int {
			return this._input.readInt();
		}

		/**
		 * @inheritDoc
		 */
		public function readMultiByte(length:uint, charSet:String):String {
			return this._input.readMultiByte(length, charSet);
		}

		/**
		 * @inheritDoc
		 */
		public function readObject():* {
			return this._input.readObject();
		}

		/**
		 * @inheritDoc
		 */
		public function readShort():int {
			return this._input.readShort();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedByte():uint {
			return this._input.readUnsignedByte();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedInt():uint {
			return this._input.readUnsignedInt();
		}

		/**
		 * @inheritDoc
		 */
		public function readUnsignedShort():uint {
			return this._input.readUnsignedShort();
		}

		/**
		 * @inheritDoc
		 */
		public function readUTF():String {
			return this._input.readUTF();
		}

		/**
		 * @inheritDoc
		 */
		public function readUTFBytes(length:uint):String {
			return this._input.readUTFBytes(length);
		}

	}

}