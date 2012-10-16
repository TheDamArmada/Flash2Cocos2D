package by.blooddy.gui.events {
	
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.01.2011 15:15:27
	 */
	public class ComponentErrorEvent extends ErrorEvent {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static const COMPONENT_ERROR:String = 'componentError';
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ComponentErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String='', id:int=0) {
			super( type, bubbles, cancelable, text, id );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public override function clone():Event {
			return new ComponentErrorEvent( super.type, super.bubbles, super.cancelable, super.text, super.errorID );
		}
		
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'text', 'errorID' );
		}
		
	}
	
}