////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.events.logging.LogEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class LoggerProxy extends Logger {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function isCross(l1:LoggerProxy, l2:LoggerProxy):Boolean {
			if ( l1 === l2 ) return true;
			var l:Logger;
			for each ( l in l1._loggers ) {
				if ( l is LoggerProxy ) isCross( l as LoggerProxy, l2 );
			} 
			for each ( l in l2._loggers ) {
				if ( l is LoggerProxy ) isCross( l1, l as LoggerProxy );
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LoggerProxy(maxLength:uint=100, maxTime:uint=5*60*1E3) {
			super( maxLength, maxTime );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _loggers:Vector.<Logger> = new Vector.<Logger>();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addLogger(logger:Logger):void {
			if ( this._loggers.indexOf( logger ) >= 0 ) return;
			if ( logger is LoggerProxy && isCross( this, logger as LoggerProxy) ) throw new ArgumentError();
			this._loggers.push( logger );
			logger.addEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
		}

		public function removeLogger(logger:Logger):void {
			var i:int = this._loggers.indexOf( logger );
			if ( i < 0 ) return;
			this._loggers.splice( i, 1 );
			logger.removeEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
		}

		public function hasLogger(logger:Logger):Boolean {
			return this._loggers.indexOf( logger ) >= 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedLog(event:LogEvent):void {
			super.addLog( event.log );
		}

	}

}