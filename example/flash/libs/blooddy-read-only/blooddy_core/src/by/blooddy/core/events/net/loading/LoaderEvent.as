////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.net.loading {

	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.ClassUtils;

	import flash.events.Event;

	/**
	 * Евент лоадера.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class LoaderEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const LOADER_INIT:String =		'loaderInit';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function LoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, loader:ILoadable=null) {
			super( type, bubbles, cancelable );
			this.loader = loader;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var loader:ILoadable;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new LoaderEvent( super.type, super.bubbles, super.cancelable, this.loader );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'loader' );
		}

	}

}