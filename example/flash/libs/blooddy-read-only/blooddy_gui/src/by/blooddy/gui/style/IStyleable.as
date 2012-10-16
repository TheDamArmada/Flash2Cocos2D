////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style {

	import flash.events.IEventDispatcher;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * @eventType			by.blooddy.gui.events.StyleEvent.STYLE_CHANGE
	 */
	[Event( name="STYLE_CHANGE", type="by.blooddy.gui.events.StyleEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					22.05.2010 1:26:03
	 */
	public interface IStyleable extends IEventDispatcher {
		
		function get styleClass():String;

	}
	
}