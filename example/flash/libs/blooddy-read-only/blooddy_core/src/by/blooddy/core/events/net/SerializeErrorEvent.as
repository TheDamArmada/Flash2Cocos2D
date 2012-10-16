////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.net {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class SerializeErrorEvent extends AsyncErrorEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const SERIALIZE_ERROR:String = 'serializeError';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function SerializeErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String=null, error:Error=null, data:*=null) {
			super( type, bubbles, cancelable, text, error );
			this.data = data;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var data:*;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new SerializeErrorEvent( super.type, super.bubbles, super.cancelable, super.text, super.error, this.data );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'text', 'errorID', 'error', 'data' );
		}

	}

}