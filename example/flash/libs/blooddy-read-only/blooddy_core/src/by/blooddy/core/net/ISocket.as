////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Появились байты для чтения.
	 * 
	 * @eventType				flash.events.ProgressEvent.SOCKET_DATA
	 */
	[Event( name="socketData", type="flash.events.ProgressEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					isocket, socket
	 */
	public interface ISocket extends IAbstractSocket, IDataInput, IDataOutput {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Очищает данные записаные в сокет.
		 * 
		 * @throws	IOError			Сокет закрыт.
		 * 
		 * @keyword					socket.flush, flush
		 */
		function flush():void

	}

}