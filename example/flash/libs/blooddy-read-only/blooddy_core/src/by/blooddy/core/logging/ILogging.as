////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public interface ILogging {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * Логгер команд.
		 *
		 * @keyword					iconnection.logger, logger
		 */
		function get logger():Logger;

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * Логгер команд.
		 *
		 * @keyword					iconnection.logging, logging
		 */
		function get logging():Boolean;

		/**
		 * @private
		 */
		function set logging(value:Boolean):void;

	}

}