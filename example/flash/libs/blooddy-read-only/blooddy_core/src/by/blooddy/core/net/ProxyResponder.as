package by.blooddy.core.net {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.09.2011 16:50:34
	 */
	public class ProxyResponder extends Responder {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ProxyResponder(responder:Responder!, result:Function=null, status:Function=null) {
			super(
				( result !== null && responder.result !== null ? this.$result : ( responder.result || result ) ),
				( status !== null && responder.status !== null ? this.$status : ( responder.status || status ) ),
				responder.timeout
			);
			this._responder = responder;
			this._result = result;
			this._status = status;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _responder:Responder;

		/**
		 * @private
		 */
		private var _result:Function;

		/**
		 * @private
		 */
		private var _status:Function;
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $result(...args):void {
			if ( this._result != null ) {
				this._result.apply( null, args );
			}
			if ( this._responder.result != null ) {
				this._responder.result.apply( null, args );
			}
		}

		/**
		 * @private
		 */
		private function $status(...args):void {
			var arr:Array = args;
			if ( this._status != null ) {
				if ( args.length < this._status.length ) {
					args = arr.slice();
					args.length = this._status.length;
				}
				this._status.apply( null, args );
			}
			if ( this._responder.status != null ) {
				if ( args.length < this._responder.status.length ) {
					args.length = this._responder.status.length;
				}
				this._responder.status.apply( null, args );
			}
		}
		
	}
	
}