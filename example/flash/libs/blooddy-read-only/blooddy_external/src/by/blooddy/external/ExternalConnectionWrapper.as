////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external {

	import by.blooddy.core.external.ExternalConnection;
	import by.blooddy.core.net.RemoterProxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.10.2009 0:19:18
	 */
	public class ExternalConnectionWrapper extends RemoterProxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor
		 */
		public function ExternalConnectionWrapper(connection:ExternalConnection) {
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
		private var _connection:ExternalConnection;
	
		public function get connection():ExternalConnection {
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
	
	}

}