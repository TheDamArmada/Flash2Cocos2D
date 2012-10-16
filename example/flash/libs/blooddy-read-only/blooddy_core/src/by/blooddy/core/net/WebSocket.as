////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {
	
	import by.blooddy.core.utils.ByteArrayUtils;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * начали соеденяться с ервером.
	 *
	 * @eventType				flash.events.EventEvent.CONNECT
	 */
	[Event( name="open", type="flash.events.Event" )]
	
	/**
	 * Устанавилось соединение с сервером.
	 *
	 * @eventType				flash.events.EventEvent.CONNECT
	 */
	[Event( name="connect", type="flash.events.Event" )]
	
	/**
	 * Соединение разорвалось, по какой-то ошибке, или со стороны сервера.
	 *
	 * @eventType				flash.events.EventEvent.CLOSE
	 */
	[Event( name="close", type="flash.events.Event" )]
	
	/**
	 * Ошибка :)
	 *
	 * @eventType				flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	
	/**
	 * Секъюрная ошибка. Обращение запрещено со стороны сервера.
	 *
	 * @eventType				flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	
	
	/**
	 * @eventType				flash.events.DataEvent.DATA
	 */
	[Event( name="data", type="flash.events.DataEvent" )]
	
	/**
	 * @eventType				flash.events.flash.events.HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	[Event( name="httpResponseStatus", type="flash.events.HTTPStatusEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.08.2011 2:55:27
	 */
	public class WebSocket extends EventDispatcher implements ITextSocket {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _MARK:ByteArray = new ByteArray();
		_MARK.writeUTFBytes( '\r\n\r\n' );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function WebSocket(host:String=null, port:int=0.0) {
			super();
			if ( host || port ) {
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
		 */
		private const _socket:Socket = new Socket();

		/**
		 * @private
		 */
		private const _inputBuffer:ByteArray = new ByteArray();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._socket.connected;
		}

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return Protocols.WEB_SOCKET;
		}

		/**
		 * @inheritDoc
		 */
		public function get host():String {
			return this._socket.host;
		}

		/**
		 * @inheritDoc
		 */
		public function get port():int {
			return this._socket.port;
		}

		/**
		 * @inheritDoc
		 */
		public function get timeout():uint {
			return this._socket.timeout;
		}

		/**
		 * @private
		 */
		public function set timeout(value:uint):void {
			this._socket.timeout = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function send(object:*):void {
			// TODO: waiting state?
			var data:String;
			if ( typeof object == 'xml' ) {
				data = object.toXMLString();
			} else {
				data = object.toString();
			}
			this._socket.writeByte( 0x00 );
			this._socket.writeUTFBytes( data );
			this._socket.writeByte( 0xFF );
			this._socket.flush();
		}

		/**
		 * @inheritDoc
		 */
		public function connect(host:String, port:int):void {
			this._socket.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				super.dispatchEvent );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent );
			this._socket.connect( host, port );
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			this._socket.writeByte( 0xFF );
			this._socket.writeByte( 0x00 );
			this._socket.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			this._inputBuffer.length = 0;
			this._socket.removeEventListener( Event.OPEN,							super.dispatchEvent );
			this._socket.removeEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				super.dispatchEvent );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_connect_close );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_connect_socketData );
			if ( this._socket.connected ) {
				this._socket.close();
			}
		}

		/**
		 * @private
		 */
		private function throwError(e:Error=null):void {
			this.clear();
			super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, ( e ? e.message : null ), ( e ? e.errorID : 0 ) ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			this._socket.addEventListener( Event.CLOSE,					this.handler_connect_close );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,	this.handler_connect_socketData );
			this._socket.writeUTFBytes(
				'GET / HTTP/1.1\r\n' +
				'Upgrade: WebSocket\r\n' +
				'Connection: Upgrade\r\n' +
				'Host: ' + this._socket.host + '\r\n' +
				'Origin: ' + this._socket.host
			);
			this._socket.writeBytes( _MARK );
			this._socket.flush();
		}

		/**
		 * @private
		 */
		private function handler_connect_close(event:Event):void {
			this.throwError();
		}
		
		/**
		 * @private
		 */
		private function handler_connect_socketData(event:Event):void {

			this._socket.readBytes( this._inputBuffer, this._inputBuffer.length );

			var k:int = ByteArrayUtils.indexOfBytes( this._inputBuffer, _MARK );

			if ( k < 0 ) return;

			try {

				var arr:Array = this._inputBuffer.readUTFBytes( k ).split( '\r\n' );
				var s:String;
				
				if ( arr.shift() != 'HTTP/1.1 101 Web Socket Protocol Handshake' ) throw null;
				var l:uint = arr.length;
				for ( var i:uint = 0; i<l; ++i ) {
					s = arr[ i ];
					k = s.indexOf( ': ' );
					if ( k < 0 ) throw null;
					arr[ i ] = new URLRequestHeader(
						s.substring( 0, k ),
						s.substr( k + 2 )
					);
				}

				this._inputBuffer.position += 4;

				// чистим буфер
				if ( !this._inputBuffer.bytesAvailable ) {
					this._inputBuffer.length = 0;
				}

				this._socket.removeEventListener( Event.CLOSE,					this.handler_connect_close );
				this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,	this.handler_connect_socketData );
				
				if ( 'HTTP_RESPONSE_STATUS' in HTTPStatusEvent ) {
					var status:HTTPStatusEvent = new HTTPStatusEvent( HTTPStatusEvent.HTTP_RESPONSE_STATUS, false, false, 101 );
					status.responseURL = 'ws://' + host + ':' + port;
					status.responseHeaders = arr;
					super.dispatchEvent( status );
				}
				
				super.dispatchEvent( new Event( Event.CONNECT ) );
				
				if ( this._inputBuffer.bytesAvailable ) {
					this.handler_socketData( event );
				}

				this._socket.addEventListener( ProgressEvent.SOCKET_DATA,		this.handler_socketData );
				this._socket.addEventListener( Event.CLOSE,						this.handler_close );
				
			} catch ( e:* ) {
				
				this.throwError( e as Error );
				
			}
			
		}

		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			this.clear();
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_socketData(event:Event):void {

			this._socket.readBytes( this._inputBuffer, this._inputBuffer.length );

			var pos:int;
			var data:String;
			
			do {

				pos = this._inputBuffer.position;

				if ( this._inputBuffer[ pos ] == 0x00 ) {

					pos = ByteArrayUtils.indexOfByte( this._inputBuffer, 0xFF, pos + 1 );
					if ( pos >= 0 ) {
						++this._inputBuffer.position;
						data = this._inputBuffer.readUTFBytes( pos - this._inputBuffer.position );
						++this._inputBuffer.position;
						super.dispatchEvent( new DataEvent( DataEvent.DATA, false, false, data ) );
					}

				} else {

					if ( this._inputBuffer[ pos ] == 0xFF && this._inputBuffer[ pos + 1 ] == 0x00 ) {
						this._socket.close();
					} else {
						this.throwError();
					}
					return;

				}

			} while ( this._inputBuffer.bytesAvailable && pos >= 0 );
				
			// чистим буфер
			if ( !this._inputBuffer.bytesAvailable ) {
				this._inputBuffer.length = 0;
			}

		}

	}

}