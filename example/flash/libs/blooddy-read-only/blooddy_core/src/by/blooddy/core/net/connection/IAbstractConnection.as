////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {

	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public interface IAbstractConnection extends IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * true, если соединение установленно.
		 * false, если разорванно, или ещё не установленно.
		 *
		 * @keyword					iconnection.connected, connected
		 */
		function get connected():Boolean;

	}

}