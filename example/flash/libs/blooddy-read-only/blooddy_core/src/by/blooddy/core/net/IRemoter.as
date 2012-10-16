////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.IAbstractRemoter;

	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iremoter
	 */
	public interface IRemoter extends IEventDispatcher, IAbstractRemoter {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * Тута будут вызываться функи.
		 * 
		 * @keyword					iremoter.client, client
		 */
		function get client():Object;

		/**
		 * @private
		 */
		function set client(value:Object):void;

	}

}