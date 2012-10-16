////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.managers.process.IProgressProcessable;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Ошибка.
	 * 
	 * @eventType			flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	
	/**
	 * Секъюрная ошибка.
	 * 
	 * @eventType			flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					iloadable
	 */
	public interface ILoadable extends IProgressProcessable {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @copy			flash.net.URLLoader#bytesLoaded
		 */
		function get bytesLoaded():uint;

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @copy			flash.net.URLLoader#bytesTotal
		 */
		function get bytesTotal():uint;

	}

}