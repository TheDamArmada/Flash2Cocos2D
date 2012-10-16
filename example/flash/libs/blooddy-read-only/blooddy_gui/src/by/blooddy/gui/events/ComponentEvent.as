////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.events {
	
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.gui.display.component.ComponentInfo;
	
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.04.2010 15:35:54
	 */
	public class ComponentEvent extends Event {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static const COMPONENT_CONSTRUCT:String = 'componentConstruct';

		public static const COMPONENT_DESTRUCT:String = 'componentDestruct';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, component:ComponentInfo=null) {
			super( type, bubbles, cancelable );
			this.componentInfo = component;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		public var componentInfo:ComponentInfo;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new ComponentEvent( super.type, super.bubbles, super.cancelable, this.componentInfo );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'component' );
		}
		
	}
	
}