////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.process {

	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, когда загрузка заканчивается.
	 * 
	 * @eventType			flash.events.Event.COMPLETE
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * Ошибка.
	 * 
	 * @eventType			flash.events.ErrorEvent.ERROR
	 */
	[Event( name="error", type="flash.events.ErrorEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.04.2010 23:49:48
	 */
	public interface IProcessable extends IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  complete
		//----------------------------------

		/**
		 * закончилась ли обработка
		 */
		function get complete():Boolean;

	}

}