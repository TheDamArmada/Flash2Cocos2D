////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Динамический эвент, для создания всяких разных мелких евентов
	 * с различными свойствами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					dynamicevent, event, dynamic
	 */
	public dynamic class DynamicEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	type			The event type; indicates the action that caused the event.
		 * @param	bubbles			Specifies whether the event can bubble up the display list hierarchy.
		 * @param	cancelable		Specifies whether the behavior associated with the event can be prevented.
		 * @param	properties		Сюда запихиваем объект с нужными для нас свойствами.
		 */
		public function DynamicEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super( type, bubbles, cancelable );
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			var event:DynamicEvent = new DynamicEvent( super.type, super.bubbles, super.cancelable );
			for ( var i:String in this ) {
				event[i] = this[i];
			}
			return event;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			var arr:Array = new Array( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable' );
			for ( var i:String in this ) {
				arr.push( i );
			}
			return super.formatToString.apply( this, arr );
		}

	}

}