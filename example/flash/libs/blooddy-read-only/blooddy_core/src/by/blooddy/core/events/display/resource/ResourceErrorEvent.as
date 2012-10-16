////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.display.resource {
	
	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 18, 2010 4:08:46 PM
	 */
	public class ResourceErrorEvent extends ErrorEvent {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const RESOURCE_ERROR:String = 'resourceError';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ResourceErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String='', id:int=0, resources:Vector.<ResourceDefinition>=null) {
			super( type, bubbles, cancelable, text, id );
			this.resources = resources;
			trace( resources.join( '\n' ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var resources:Vector.<ResourceDefinition>;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------
		
		public override function clone():Event {
			return new ResourceErrorEvent( super.type, super.bubbles, super.cancelable, super.text, super.errorID, this.resources );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'text', 'errorID', 'resources' );
		}

	}
	
}