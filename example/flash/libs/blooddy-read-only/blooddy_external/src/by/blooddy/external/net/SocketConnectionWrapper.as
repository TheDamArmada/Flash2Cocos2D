////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.net {

	import by.blooddy.core.net.Protocols;
	import by.blooddy.core.net.RemoterProxy;
	import by.blooddy.core.net.connection.SocketConnection;
	import by.blooddy.core.net.connection.filters.ISocketFilter;
	
	import flash.events.AsyncErrorEvent;
	import flash.utils.setTimeout;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * какая-то ошибка при исполнении.
	 */
	[Event( name="asyncError", type="flash.events.AsyncErrorEvent" )]	
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.10.2009 0:21:32
	 */
	public class SocketConnectionWrapper extends RemoterProxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 */
		public function SocketConnectionWrapper(connection:SocketConnection) {
			super( connection );
			this._connection = connection;
		}
	
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
	
		//----------------------------------
		//  connection
		//----------------------------------
	
		/**
		 * @private
		 */
		private var _connection:SocketConnection;
	
		public function get connection():SocketConnection {
			return this._connection;
		}
	
		//----------------------------------
		//  connected
		//----------------------------------
	
		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._connection.connected;
		}
	
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getFilterHash():String {
			var filter:ISocketFilter = this._connection.filter;
			return ( filter ? filter.getHash() : null );
		}
		
		public function connect(host:String, port:int):void {
			setTimeout( this._call, 1, this._connect, host, port );
		}

		public function close():void {
			setTimeout( this._call, 1, this._connection.close );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function call(methodName:String, args:Array):* {
			setTimeout( this._call, 1, super.call, methodName, args );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function _connect(host:String, port:int):void {
			this._connection.connect( host, port );
		}
		
		/**
		 * @private
		 */
		private function _call(func:Function, ...args):* {
			try {
				func.apply( null, args );
			} catch ( e:* ) {
				super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, String( e ), e as Error ) );
			}
		}
		
	}

}