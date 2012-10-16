////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {
	
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.net.IAbstractSocket;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	//--------------------------------------
	//  Implements events: IConnection
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
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
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.08.2011 17:10:30
	 */
	public class AbstractSocketConnection extends AbstractRemoter implements INetConnection {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AbstractSocketConnection(socket:IAbstractSocket=null) {
			if ( ( this as Object ).constructor == AbstractSocketConnection ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			if ( !socket ) {
				Error.throwError( TypeError, 2007, 'socket' );
			}
			super();
			this._socket = socket;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Сцылка на конкретное сокетное соединение.
		 */
		private var _socket:IAbstractSocket;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties: INetConnection
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  connected
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._socket.connected;
		}
		
		//----------------------------------
		//  protocol
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return this._socket.protocol;
		}
		
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
		//  connectionTimeout
		//----------------------------------
		
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
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function connect(host:String, port:int):void {
			if ( this._socket.connected ) throw new IOError();
			this._host = host;
			this._port = port;
			this._socket.addEventListener( Event.OPEN,							this.handler_open );
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			try {
				this._socket.connect( host, port );
			} catch ( e:* ) {
				this.clear();
				throw e;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( this._socket ) {
				this._socket.close();
			} else {
				Error.throwError( IOError, 2002 );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, responder:Responder=null, ...parameters):* {
			if ( !this._socket || !this._socket.connected ) throw new IllegalOperationError( 'соединение не установленно' );
			return super.$invokeCallOutputCommand( new NetCommand( commandName, NetCommand.OUTPUT, parameters ), responder );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function $clear():void {
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
			this._host = null;
			this._port = 0;
			this._socket.removeEventListener( Event.OPEN,							this.handler_open );
			this._socket.removeEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			this.$clear();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_open(event:Event):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Open: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Connect: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( /*'Error: ' + this._host + ':' + this._port + '\n' +*/ event.text, InfoLog.ERROR ) );
			}
			this.clear();
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 * Соединение закрылось.
		 */
		private function handler_close(event:Event):void {
			super.rejectResponders();
			if ( super.logging ) {
				super.logger.addLog( new InfoLog( 'Close: ' + this._host + ':' + this._port, InfoLog.INFO ) );
			}
			this.clear();
			super.dispatchEvent( event );
		}

	}

}