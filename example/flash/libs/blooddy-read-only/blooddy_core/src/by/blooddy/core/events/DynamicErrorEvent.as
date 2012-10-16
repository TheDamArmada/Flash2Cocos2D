////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {
	
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.02.2010 18:04:33
	 */
	public dynamic class DynamicErrorEvent extends ErrorEvent {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function DynamicErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String='', id:int=0) {
			super( type, bubbles, cancelable, text, id );
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
			var event:DynamicErrorEvent = new DynamicErrorEvent( super.type, super.bubbles, super.cancelable, super.text, super.errorID );
			for ( var i:String in this ) {
				event[i] = this[i];
			}
			return event;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			var arr:Array = new Array( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'text', 'errorID' );
			for ( var i:String in this ) {
				arr.push( i );
			}
			return super.formatToString.apply( this, arr );
		}
		
	}
	
}