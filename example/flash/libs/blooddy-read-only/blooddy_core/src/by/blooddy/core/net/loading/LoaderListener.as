////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.events.net.loading.LoaderListenerEvent;
	import by.blooddy.core.managers.process.IProcessable;
	import by.blooddy.core.managers.process.ProgressDispatcher;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="loaderEnabled", type="by.blooddy.core.events.net.loading.LoaderListenerEvent" )]
	[Event( name="loaderDisabled", type="by.blooddy.core.events.net.loading.LoaderListenerEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class LoaderListener extends ProgressDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LoaderListener(target:IEventDispatcher=null) {
			super();
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE, true );
			if ( target ) this.target = target;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _target:IEventDispatcher;

		public function get target():IEventDispatcher {
			return this._target;
		}

		/**
		 * @private
		 */
		public function set target(value:IEventDispatcher):void {
			if ( this._target === value ) return;
			if ( this._target ) {
				this._target.removeEventListener( LoaderEvent.LOADER_INIT, this.handler_loaderInit );
				super.clear();
			}
			this._target = value;
			if ( this._target ) {
				this._target.addEventListener( LoaderEvent.LOADER_INIT, this.handler_loaderInit, false, int.MAX_VALUE, true );
			}
		}
		
		/**
		 * @private
		 */
		private var _running:Boolean = false;

		public function get running():Boolean {
			return this._running;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		[Deprecated( message="метод запрещен" )]
		/**
		 * @private
		 */
		public override function clear():void {
			Error.throwError( IllegalOperationError, 1001, 'clear' );
		}

		[Deprecated( message="метод запрещен" )]
		/**
		 * @private
		 */
		public override function addProcess(process:IProcessable):void {
			Error.throwError( IllegalOperationError, 1001, 'addProcess' );
		}

		[Deprecated( message="метод запрещен" )]
		/**
		 * @private
		 */
		public override function removeProcess(process:IProcessable):void {
			Error.throwError( IllegalOperationError, 1001, 'removeProcess' );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_loaderInit(event:LoaderEvent):void {
			var complete:Boolean = super.complete;
			super.addProcess( event.loader );
			if ( complete && !super.complete ) {
				this._running = true;
				super.dispatchEvent( new LoaderListenerEvent( LoaderListenerEvent.LOADER_ENABLED, false, false ) );
			}
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._running = false;
			super.dispatchEvent( new LoaderListenerEvent( LoaderListenerEvent.LOADER_DISABLED, false, false ) );
		}

	}

}