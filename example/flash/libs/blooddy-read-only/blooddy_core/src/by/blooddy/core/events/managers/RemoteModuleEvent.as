////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.managers {

	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class RemoteModuleEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const INIT:String = Event.INIT;

		public static const UNLOAD:String = Event.UNLOAD;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function RemoteModuleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, id:String=null) {
			super(type, bubbles, cancelable);
			this.id = id;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var id:String = id;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new RemoteModuleEvent(super.type, super.bubbles, super.cancelable, this.id);
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), "type", "bubbles", "cancelable", "id" );
		}

	}

}