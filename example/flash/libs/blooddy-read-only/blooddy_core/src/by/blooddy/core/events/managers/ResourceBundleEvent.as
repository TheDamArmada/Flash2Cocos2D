////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.managers {

	import by.blooddy.core.managers.resource.IResourceBundle;
	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Евент ресурс манагера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourceevent, resource, event
	 * 
	 * @see						by.blooddy.core.managers.ResourceManager
	 */
	public class ResourceBundleEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @eventType			bundleAdded
		 */
		public static const BUNDLE_ADDED:String =	'bundleAdded';

		/**
		 * @eventType			bundleRemoved
		 */
		public static const BUNDLE_REMOVED:String =	'bundleRemoved';

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
		 * @param	bundle			ПучОк.
		 */
		public function ResourceBundleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bundle:IResourceBundle=null) {
			super( type, bubbles, cancelable );
			this.bundle = bundle;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bundleName
		//----------------------------------

		/**
		 * Имя изменённого "пучка".
		 * 
		 * @keyword					resourceevent.bundlename, bundlename
		 */
		public var bundle:IResourceBundle;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new ResourceBundleEvent( super.type, super.bubbles, super.cancelable, this.bundle );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'bundle' );
		}

	}

}