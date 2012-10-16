////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.data {

	import by.blooddy.core.data.DataBaseNativeEvent;

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					databaseevent, database, data, event
	 */
	public class DataBaseEvent extends DataBaseNativeEvent {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			added
		 * 
		 * @see					by.blooddy.core.data.Data
		 */
		public static const ADDED:String = 'added';

		/**
		 * @eventType			added
		 * 
		 * @see					by.blooddy.core.data.Data
		 */
		public static const REMOVED:String = 'removed';

		/**
		 * @eventType			change
		 * 
		 * @see					by.blooddy.core.data.Data
		 * @see					by.blooddy.core.data.DataBase
		 */
		public static const CHANGE:String = Event.CHANGE;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	type		The type of the event, accessible as Event.type.
		 * @param	bubbles		Determines whether the Event object participates in
		 * 						the bubbling stage of the event flow.
		 * @param	cancelable	Determines whether the Event object can be canceled.
		 */
		public function DataBaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

	}

}