////////////////////////////////////////////////////////////////////////////////
//
//  © 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {
	
	import by.blooddy.core.net.connection.IAbstractConnection;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
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
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					03.02.2011 20:42:58
	 */
	public class SocketConnector extends EventDispatcher implements IAbstractConnection {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function SocketConnector(socket:IAbstractSocket=null) {
			super();
			if ( socket ) this.socket = socket;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _hosts:Vector.<HostPair>;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get connected():Boolean {
			return ( this._socket ? this._socket.connected : false );
		}

		/**
		 * @private
		 */
		private var _socket:IAbstractSocket;

		public function get socket():IAbstractSocket {
			return this._socket;
		}

		/**
		 * @private
		 */
		public function set socket(value:IAbstractSocket):void {
			if ( this._socket === value ) return;
			if ( value && this._hosts ) throw new IllegalOperationError();
			this._hosts = null;
			if ( this._socket ) {
				this._socket.removeEventListener( Event.CONNECT,						this.handler_connect );
				this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
				this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
			}
			this._socket = value;
			if ( this._socket ) {
				this._socket.addEventListener( Event.CONNECT,						this.handler_connect, false, int.MAX_VALUE );
				this._socket.addEventListener( Event.CLOSE,							this.handler_close, false, int.MAX_VALUE );
				this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error, false, int.MAX_VALUE );
				this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error, false, int.MAX_VALUE );
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function connect(pair:HostPair, ...hosts):void {
			if ( !pair ) throw new ArgumentError();
			if ( !this._socket ) throw new IllegalOperationError();
			if ( this._socket.connected ) throw new IllegalOperationError();
			if ( this._hosts ) throw new IllegalOperationError();
			this._hosts = Vector.<HostPair>( hosts );
			this._hosts.unshift( pair );
			this._connectToNext();
			super.dispatchEvent( new Event( Event.OPEN ) );
		}

		public function close():void {
			if ( !this._socket ) throw new IllegalOperationError();
			if ( !this._socket.connected ) throw new IllegalOperationError();
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
		private function _connectToNext():void {
			var pair:HostPair = this._hosts.shift();
			this._socket.connect( pair.host, pair.port );
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
			this._hosts = null;
			super.dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			super.dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:Event):void {
			if ( this._hosts.length > 0 ) {
				this._connectToNext();
			} else {
				this._hosts = null;
				super.dispatchEvent( event );
			}
		}
		
	}
	
}