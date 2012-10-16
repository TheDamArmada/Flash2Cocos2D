////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.net.Responder;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class Responder extends flash.net.Responder {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const DEFAULT_RESPONDER:by.blooddy.core.net.Responder = new by.blooddy.core.net.Responder(
			function(...rest):* {
			},
			function(...rest):* {
				trace( 'DEFAULT_RESPONDER_ERROR:', rest );
			}
		);

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function Responder(result:Function!, status:Function=null, timeout:uint=0) {
			super( result, status );
			this._result = result;
			this._status = status;
			this._timeout = timeout;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _result:Function;

		public function get result():Function {
			return this._result;
		}

		/**
		 * @private
		 */
		private var _status:Function;

		public function get status():Function {
			return this._status;
		}

		/**
		 * @private
		 */
		private var _timeout:uint;

		public function get timeout():uint {
			return this._timeout;
		}

	}

}