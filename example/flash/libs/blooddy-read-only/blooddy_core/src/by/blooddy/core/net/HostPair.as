////////////////////////////////////////////////////////////////////////////////
//
//  © 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.02.2011 14:37:05
	 */
	public class HostPair {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function HostPair(host:String!, port:int=843) {
			super();
			this._host = host;
			this._port = port;
		}

		//--------------------------------------------------------------------------
		//
		//  Prooperties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _host:String;

		public function get host():String {
			return this._host;
		}

		/**
		 * @private
		 */
		private var _port:int;

		public function get port():int {
			return this._port;
		}

		//--------------------------------------------------------------------------
		//
		//  Prooperties
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			return this.host + ':' + this.port;
		}
		
	}
	
}