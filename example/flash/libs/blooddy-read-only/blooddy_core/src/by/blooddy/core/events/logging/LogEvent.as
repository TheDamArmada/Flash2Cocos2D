////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.logging {

	import by.blooddy.core.logging.Log;
	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Евент ошибки парсера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					logevent, log, event
	 */
	public class LogEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			addedLog
		 */
		public static const ADDED_LOG:String = 'addedLog';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function LogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, log:Log=null) {
			super( type, bubbles, cancelable );
			this.log = log;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var log:Log;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new LogEvent( super.type, super.bubbles, super.cancelable, this.log );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'log' );
		}

	}

}