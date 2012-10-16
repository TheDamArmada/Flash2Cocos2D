////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.state {
	
	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * @eventType			by.blooddy.gui.events.StateEvent.STATE_CHANGE
	 */
	[Event( name="stateChange", type="by.blooddy.gui.events.StateEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					22.05.2010 2:03:44
	 */
	public interface IStatable extends IEventDispatcher {

		function get state():String;

	}
	
}