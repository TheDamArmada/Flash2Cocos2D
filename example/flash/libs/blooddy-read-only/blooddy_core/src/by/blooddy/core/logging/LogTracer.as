////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.events.logging.LogEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 18, 2010 4:34:48 PM
	 */
	public final class LogTracer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function addLogger(logger:Logger):void {
			logger.addEventListener( LogEvent.ADDED_LOG, handler_addedLog );
		}

		public static function removeLogger(logger:Logger):void {
			logger.removeEventListener( LogEvent.ADDED_LOG, handler_addedLog );
		}

		//--------------------------------------------------------------------------
		//
		//  Class event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function handler_addedLog(event:LogEvent):void {
			trace( event.log );
		}

	}

}