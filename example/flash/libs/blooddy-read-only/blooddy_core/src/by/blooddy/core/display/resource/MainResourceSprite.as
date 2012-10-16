////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.errors.display.resource.ResourceError;
	import by.blooddy.core.events.display.resource.ResourceErrorEvent;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.resource.ResourceManagerProxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class MainResourceSprite extends ResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_rs;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MainResourceSprite() {
			super();
			super.addEventListener( ResourceEvent.REMOVED_FROM_MAIN, this.handler_removedFromMain, false, int.MIN_VALUE, true ); // !!! MIN !!!
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _manager:ResourceManagerProxy = new ResourceManagerProxy();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public final function get resourceLiveTime():uint {
			return this._manager.resourceLiveTime;
		}

		/**
		 * @private
		 */
		public final function set resourceLiveTime(value:uint):void {
			this._manager.resourceLiveTime = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_rs override function getResourceManager():ResourceManagerProxy {
			if ( super.stage ) {
				return this._manager;
			}
			return null;
		}

		$protected_rs override function getDepth():int {
			return 0;//int.MIN_VALUE;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removedFromMain(event:ResourceEvent):void {
			try {
				this._manager.clear();
			} catch ( e:ResourceError ) {
				super.dispatchEvent( new ResourceErrorEvent( ResourceErrorEvent.RESOURCE_ERROR, false, false, e.toString(), e.errorID, e.resources ) );
			}
		}

	}

}