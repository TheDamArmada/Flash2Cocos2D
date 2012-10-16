////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType				flash.events.DataEvent.DATA
	 */
	[Event( name="data", type="flash.events.DataEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.08.2011 2:52:26
	 */
	public interface ITextSocket extends IAbstractSocket {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		function send(object:*):void

	}

}