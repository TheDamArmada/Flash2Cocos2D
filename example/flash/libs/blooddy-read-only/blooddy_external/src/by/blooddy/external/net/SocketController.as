////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.net {

	import by.blooddy.core.events.net.SerializeErrorEvent;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.net.connection.SocketConnection;
	import by.blooddy.core.net.connection.filters.ISocketFilter;
	import by.blooddy.external.ExternalConnectionController;
	import by.blooddy.external.ExternalConnectionWrapper;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					13.09.2009 23:50:40
	 */
	public class SocketController extends ExternalConnectionController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SocketController(container:DisplayObjectContainer, filter:ISocketFilter, sharedObject:ProxySharedObject=null) {
			super( container, sharedObject || ProxySharedObject.getLocal( 'socket' ) );
			this._filter = filter;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _filter:ISocketFilter;
		
		/**
		 * @private
		 */
		private var _socket:SocketConnection;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function construct():void {
			this._socket = new SocketConnection();
			this._socket.logging = false;
			this._socket.filter = this._filter;
			this._socket.client = new ExternalConnectionWrapper( super.externalConnection );
			this._socket.addEventListener( Event.OPEN,								super.externalConnection.dispatchEvent );
			this._socket.addEventListener( Event.CONNECT,							super.externalConnection.dispatchEvent );
			this._socket.addEventListener( Event.CLOSE,								super.externalConnection.dispatchEvent );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,					super.externalConnection.dispatchEvent );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,		super.externalConnection.dispatchEvent );
			this._socket.addEventListener( AsyncErrorEvent.ASYNC_ERROR,				super.externalConnection.dispatchEvent );
			this._socket.addEventListener( SerializeErrorEvent.SERIALIZE_ERROR,		super.externalConnection.dispatchEvent );
			var socketWrapper:SocketConnectionWrapper = new SocketConnectionWrapper( this._socket );
			socketWrapper.addEventListener( AsyncErrorEvent.ASYNC_ERROR,			super.externalConnection.dispatchEvent );
			super.externalConnection.client = socketWrapper;
		}

		protected override function destruct():void {
			var socketWrapper:SocketConnectionWrapper = super.externalConnection.client as SocketConnectionWrapper;
			socketWrapper.removeEventListener( AsyncErrorEvent.ASYNC_ERROR,			super.externalConnection.dispatchEvent );
			super.externalConnection.client = null;
			this._socket.removeEventListener( SerializeErrorEvent.SERIALIZE_ERROR,	super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( AsyncErrorEvent.ASYNC_ERROR,			super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( Event.CLOSE,							super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( Event.CONNECT,						super.externalConnection.dispatchEvent );
			this._socket.removeEventListener( Event.OPEN,							super.externalConnection.dispatchEvent );
			this._socket.filter = null;
			this._socket.client = null;
			if ( this._socket.connected ) {
				this._socket.close();
			}
			this._socket = null;
		}

	}

}