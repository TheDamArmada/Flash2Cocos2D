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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="data", type="flash.events.DataEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.08.2011 17:39:14
	 */
	public class TextSocket extends EventDispatcher implements ITextSocket {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function TextSocket(host:String=null, port:int=0.0) {
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
			return Protocols.SOCKET;
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
			this._socket.writeUTFBytes( data );
			this._socket.writeByte( 0x00 );
			this._socket.flush();
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect(host:String, port:int):void {
			this._socket.addEventListener( Event.OPEN,							super.dispatchEvent );
			this._socket.addEventListener( Event.CONNECT,						super.dispatchEvent );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				super.dispatchEvent );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			this._socket.connect( host, port );
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
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
			this._socket.removeEventListener( Event.CONNECT,						super.dispatchEvent );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				super.dispatchEvent );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			if ( this._socket.connected ) {
				this._socket.close();
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
		private function handler_close(event:Event):void {
			this.clear();
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_socketData(event:Event):void {
			
			this._socket.readBytes( this._inputBuffer, this._inputBuffer.length );
			
			var pos:int = this._inputBuffer.position;
			var data:String;
			
			do {
				
				pos = ByteArrayUtils.indexOfByte( this._inputBuffer, 0x00, pos );
				if ( pos >= 0 ) {
					data = this._inputBuffer.readUTFBytes( pos - this._inputBuffer.position );
					if ( data ) { // сообщение может быть пустым
						super.dispatchEvent( new DataEvent( DataEvent.DATA, false, false, data ) );
					}
				}
					
			} while ( this._inputBuffer.bytesAvailable && pos >= 0 );

			// чистим буфер
			if ( !this._inputBuffer.bytesAvailable ) {
				this._inputBuffer.length = 0;
			}
			
		}
		
	}
	
}