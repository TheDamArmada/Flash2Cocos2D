////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.math.NumberUtils;
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	//--------------------------------------
	//  Implements events: ISocket
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="connect", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="close", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]		

	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	

	/**
	 * @inheritDoc
	 */
	[Event( name="socketData", type="flash.events.ProgressEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 *                    +------------------------+
	 *                    |пришёл запрос от клиента|◄ - - - - - - - - - - - - - - - - - - - - +
	 *                    +------------------------+                                          |
	 *                                |
	 *                                |                                                       |
	 *                                ▼
	 *                   +---------------------------+                                        |
	 *               нет |есть ли открытое соединение|  да
	 *          +--------|с этим клиентом?           |--------+                               |
	 *          |        +---------------------------+        |
	 *          |                                             |                               |
	 *          ▼                                             ▼
	 * +-----------------+                          +------------------+                      |
	 * |отправляем данные|                          |закрываем открытое|
	 * |на игровой сервер|◄-------------------------|рание соединение  |                      |
	 * +-----------------+                          +------------------+
	 *          |                                                                             |
	 *          +---------------------+
	 *                                |
	 *                                ▼                                                       |
	 *                     +--------------------+                     +-----------------+
	 *                     |проверяем, есть ли  | да                  |отправляем данные|     |
	 *            +-------►|что-нить для клиента|--------------------►|на клиент        |
	 *            |        +--------------------+                     +-----------------+     |
	 *            |                  |нет                                      |
	 *            |                  |                                         |              |
	 *            |                  ▼                                         ▼
	 *            |     +--------------------------+                  +------------------+    |
	 *            | нет |держим содинение открытым.| да               |закрываем открытое|
	 *            +-----|вышел ли таймоут?         |-----------------►|рание соединение  |- - +
	 *                  +--------------------------+                  +------------------+
	 *
	 * @keyword					proxysocket, socket
	 * 
	 * @see						by.blooddy.core.net.Socket
	 */
	public class ProxySocket extends EventDispatcher implements ISocket {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * Если передать парметры то сразу начнём окнектиться.
		 *
		 * @param	host			Домен, которому будем конектиться.
		 * @param	port			Порт, которому будем конектиться.
		 *
		 * @see						#connect()
		 * @see						by.blooddy.core.net.Socket#Socket()
		 */
		public function ProxySocket(host:String=null, port:int=0.0) {
			super();
			// шаблон данных
			this._request.method = URLRequestMethod.POST;
			this._request.contentType = MIME.BINARY;
			this._request.requestHeaders = new Array(
				new URLRequestHeader( 'pragma', 'no-cache' ),
				new URLRequestHeader( 'Content-Type', MIME.BINARY )
			);
			if ( host && port ) {
				this.connect( host, port );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * сюда записываются входящие данные
		 */
		private const _input:ByteArray = new ByteArray();

		/**
		 * @private
		 * сюда записываются исходящие данные
		 */
		private const _output:ByteArray = new ByteArray();

		/**
		 * @private
		 * пул для отправки в сокет
		 */
		private const _poll:ByteArray = new ByteArray();

		/**
		 * @private
		 * Заголовок для отправки данных на сервер.
		 */
		private const _request:URLRequest = new URLRequest();

		/**
		 * @private
		 * Заголовок для отправки данных на сервер.
		 */
		private const _variables:URLVariables = new URLVariables();

		/**
		 * @private
		 */
		private const _conn1:$URLStream = new $URLStream();

		/**
		 * @private
		 */
		private const _conn2:$URLStream = new $URLStream();

		/**
		 * @private
		 * Счётчик отправленых команд.
		 */
		private var _cmdID:uint;

		/**
		 * @private
		 * Счётчик отправленых команд.
		 */
		private var _status:int;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties: ISocket
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  host
		//----------------------------------

		/**
		 * @private
		 */
		private var _host:String;

		/**
		 * @inheritDoc
		 */
		public function get host():String {
			return this._host;
		}

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * @private
		 */
		private var _port:int;

		/**
		 * @inheritDoc
		 */
		public function get port():int {
			return this._port;
		}

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @private
		 */
		private var _sesID:String;

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return Boolean( this._sesID );
		}

		//----------------------------------
		//  timeout
		//----------------------------------

		/**
		 * @private
		 */
		private var _timeoutTime:Number;

		/**
		 * @private
		 */
		private var _timeoutID:uint;

		/**
		 * @private
		 */
		private var _timeout:uint;

		/**
		 * @inheritDoc
		 */
		public function get timeout():uint {
			return this._timeout;
		}

		/**
		 * @private
		 */
		public function set timeout(value:uint):void {
			if ( this._timeout == value ) return;
			this._timeout = value;
			if ( this._timeoutID ) {
				clearTimeout( this._timeoutID );
				this._timeoutID = setTimeout( this.timeoutError, getTimer() - this._timeoutTime );
			}
		}

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return Protocols.HTTP;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: ISocket
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function connect(host:String, port:int):void {

			if ( port < 0 || port > 0xFFFF ) Error.throwError( SecurityError, 2003 );

			this._host = host;
			this._port = port;

			this._request.url = this.getURL();
			this._request.data = NumberUtils.getRND();

			this._conn1.addEventListener( Event.COMPLETE,						this.handler_connection_complete );
			this._conn1.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_connection_error );
			this._conn1.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_connection_error );

			try {
				this._conn1.load( this._request );
			} catch ( e:* ) {
				this._host = null;
				this._port = 0;
				throw e;
			}

			super.dispatchEvent( new Event( Event.OPEN ) ); // TODO: перенести на задержку

			if ( this._timeout > 0 ) {
				this._timeoutTime = getTimer();
				this._timeoutID = setTimeout( this.timeoutError, this._timeout );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( !this._sesID ) Error.throwError( IOError, 2002 );
			this.clear();
			super.dispatchEvent( new Event( Event.CLOSE ) );
		}

		/**
		 * @inheritDoc
		 */
		public function flush():void {
			if ( !this._sesID ) Error.throwError( IOError, 2002 );
			this._poll.writeBytes( this._output );	// перенесли в пул
			this._output.length = 0;				// очистили всякую то что пытались отправить
			if ( !this._conn1.connected || !this._conn2.connected ) {
				this.sendPoll();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * получения линка на урыл
		 */
		private function getURL():String {
			var url:String = 'http://' + this._host + ':' + this._port + '/proxy';
			if ( this._sesID ) {
				this._variables.id = this._cmdID;
				url += '?' + this._variables.toString();
			}
			return url;
		}

		/**
		 * @private
		 * Отсылает команду.
		 */
		private function sendPoll():void {
			++this._cmdID;
			this._request.url = this.getURL();
			if ( this._poll.length > 0 ) {
				this._request.data = this._poll;
			} else {
				this._request.data = null;
			}
			
			var conn:$URLStream;
			if ( this._conn1.connected ) {
				conn = this._conn2;
			} else {
				conn = this._conn1;
			}
			conn.load( this._request );
			//trace( conn == this._conn1 ? 1 : 2 , 'send', this._request.url );
//			if ( this._poll ) {
//				trace( ByteArrayUtils.dump( this._poll ) );
//			}
			this._poll.length = 0;
		}

		/**
		 * @private
		 */
		private function clear():void {

			this._sesID = null;

			if ( this._conn1.connected ) this._conn1.close();
			if ( this._conn2.connected ) this._conn2.close();
			
			clearTimeout( this._timeoutID );
			this._timeoutID = 0;
			
			this._cmdID = 0; // установим счётчик на ноль
			this._input.length = 0;
			this._output.length = 0;
			this._poll.length = 0;
			
			this._host = null;
			this._port = 0;
			
			this._conn1.removeEventListener( Event.COMPLETE,					this.handler_connection_complete );
			this._conn1.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_connection_error );
			this._conn1.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_connection_error );
			
			this._conn1.removeEventListener( Event.COMPLETE,					this.handler_complete );
			this._conn1.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._conn1.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._conn1.removeEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			this._conn1.removeEventListener( HTTPStatusEvent.HTTP_STATUS,		this.handler_httpStatus );
			
			this._conn2.removeEventListener( Event.COMPLETE,					this.handler_complete );
			this._conn2.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._conn2.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._conn2.removeEventListener( ProgressEvent.PROGRESS,			this.handler_progress );
			this._conn2.removeEventListener( HTTPStatusEvent.HTTP_STATUS,		this.handler_httpStatus );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connection
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_connection_complete(event:Event):void {

			// должна придти сессия. поэтому независимо от того что пришло пытаемся получить сессию
			this._sesID = this._conn1.readUTFBytes( this._conn1.bytesAvailable );

			if ( this._sesID ) { // приконектились! надо сообщить

				// запрос пришёл. удаляем обработчик. он больше не понадобится.
				this._conn1.removeEventListener( Event.COMPLETE,					this.handler_connection_complete );
				this._conn1.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_connection_error );
				this._conn1.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_connection_error );
	
				clearTimeout( this._timeoutID );
				this._timeoutID = 0;

				this._variables.ses = this._sesID;
//				trace( 'connected ' + this._sesID );
				// соединения
				this._conn1.addEventListener( Event.COMPLETE,						this.handler_complete );
				this._conn1.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._conn1.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
				this._conn1.addEventListener( ProgressEvent.PROGRESS,				this.handler_progress );
				this._conn1.addEventListener( HTTPStatusEvent.HTTP_STATUS,			this.handler_httpStatus );

				this._conn2.addEventListener( Event.COMPLETE,						this.handler_complete );
				this._conn2.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._conn2.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
				this._conn2.addEventListener( ProgressEvent.PROGRESS,				this.handler_progress );
				this._conn2.addEventListener( HTTPStatusEvent.HTTP_STATUS,			this.handler_httpStatus );

				super.dispatchEvent( new Event( Event.CONNECT ) );

				if ( this._conn1.connected ) this._conn1.close(); // всё шикарно! можно закрываться

			} else { // соединение почему-то не установилось :(

				this.clear();
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, '' ) );

			}

		}

		/**
		 * @private
		 */
		private function handler_connection_error(event:ErrorEvent):void {
			this.clear();
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function timeoutError():void {
			this.clear();
			super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, '' ) );
		}

		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			if ( this._status ) { // патч на странное поведение флэша
				//trace( ( event.target === this._conn1 ? 1 : 2 ), event.type, this._cmdID );
				if ( this._sesID ) {
					this.close();
				}
			} else {
				this.handler_complete( event );
			}
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( this._input.position == this._input.length ) {
				this._input.length = 0;
			}
			var conn:$URLStream = event.target as $URLStream;
			//if ( conn === this._conn1 ) {
				//if ( this._conn2.connected ) this._conn2.close();
			//} else {
				//if ( this._conn1.connected ) this._conn1.close();
			//}
			if ( conn.bytesAvailable > 0 ) {
//				var pos:uint = this._input.position;
				conn.readBytes( this._input, this._input.length );
//				trace( ( conn === this._conn1 ? 1 : 2 ), event, this._cmdID );
//				trace( ByteArrayUtils.dump( this._input, pos ) );
//				if ( event.bytesLoaded == 1 && event.bytesTotal == 1 && this._input[ this._input.length-1 ] == 0x20 ) {
//					this._input.length--;
//				} else {
				super.dispatchEvent( new ProgressEvent( ProgressEvent.SOCKET_DATA, false, false, this._input.bytesAvailable ) );
//				}
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			//trace( ( event.target === this._conn1 ? 1 : 2 ), 'complete' );
			var conn:$URLStream = event.target as $URLStream;
			if ( !this._conn1.connected || !this._conn2.connected ) {
				this.sendPoll();
			}
			if ( conn.connected ) conn.close();
		}

		/**
		 * @private
		 */
		private function handler_httpStatus(event:HTTPStatusEvent):void {
			this._status = event.status;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IDataInput
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _objectEncoding:uint;

		/**
		 * @inheritDoc
		 */
		public function get objectEncoding():uint {
			return this._objectEncoding;
		}

		/**
		 * @private
		 */
		public function set objectEncoding(version:uint):void {
			if ( this._objectEncoding == version ) return;
			this._output.objectEncoding =
			this._input.objectEncoding =
			this._objectEncoding = version;
		}

		/**
		 * @private
		 */
		private var _endian:String;

		/**
		 * @inheritDoc
		 */
		public function get endian():String {
			return this._endian;
		}

		/**
		 * @private
		 */
		public function set endian(type:String):void {
			if ( this._endian == type ) return;
			this._output.endian =
			this._input.endian =
			this._endian = type;
		}

		/**
		 * @inheritDoc
		 */
		public function get bytesAvailable():uint {
			return this._input.bytesAvailable;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IDataOutput
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function writeBoolean(value:Boolean):void {
			this._output.writeBoolean( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeByte(value:int):void {
			this._output.writeByte( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeShort(value:int):void {
			this._output.writeShort( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeInt(value:int):void {
			this._output.writeInt( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeUnsignedInt(value:uint):void {
			this._output.writeUnsignedInt( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeFloat(value:Number):void {
			this._output.writeFloat( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeDouble(value:Number):void {
			this._output.writeDouble( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeUTF(value:String):void {
			this._output.writeUTF( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeUTFBytes(value:String):void {
			this._output.writeUTFBytes( value );
		}

		/**
		 * @inheritDoc
		 */
		public function writeMultiByte(value:String, charSet:String):void {
			this._output.writeMultiByte( value, charSet );
		}

		/**
		 * @inheritDoc
		 */
		public function writeBytes(bytes:ByteArray, offset:uint=0, length:uint=0):void {
			this._output.writeBytes( bytes, offset, length );
		}

		/**
		 * @inheritDoc
		 */
		public function writeObject(object:*):void {
			this._output.writeObject( object );
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
		public function readUnsignedByte():uint {
			return this._input.readUnsignedByte();
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
		public function readUnsignedShort():uint {
			return this._input.readUnsignedShort();
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
		public function readUnsignedInt():uint {
			return this._input.readUnsignedInt();
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
		public function readDouble():Number {
			return this._input.readDouble();
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

		/**
		 * @inheritDoc
		 */
		public function readMultiByte(length:uint, charSet:String):String {
			return this._input.readMultiByte(length, charSet);
		}

		/**
		 * @inheritDoc
		 */
		public function readBytes(bytes:ByteArray, offset:uint=0, length:uint=0):void {
			this._input.readBytes(bytes, offset, length);
		}

		/**
		 * @inheritDoc
		 */
		public function readObject():* {
			return this._input.readObject();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.net.URLRequest;
import flash.net.URLStream;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: $URLStream
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * @author					BlooDHounD
 * @version					1.0
 * @playerversion			Flash 9
 * @langversion				3.0
 */
internal final class $URLStream extends URLStream {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function $URLStream() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _connected:Boolean = false;

	public override function get connected():Boolean {
		return this._connected;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public override function load(request:URLRequest):void {
		super.load( request );
		this._connected = true;
	}

	public override function close():void {
		this._connected = false;
		try {
			super.close();
		} catch ( e:* ) {
		}
	}

}