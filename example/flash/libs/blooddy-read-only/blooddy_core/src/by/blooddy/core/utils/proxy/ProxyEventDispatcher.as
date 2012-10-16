////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @copy		flash.events.EventDispatcher#activate
	 */
	[Event( name="activate", type="flash.events.Event" )]

	/**
	 * @copy		flash.events.EventDispatcher#deactivate
	 */
	[Event( name="deactivate", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxyeventdispatcher, proxy, eventdispatcher
	 */
	public dynamic class ProxyEventDispatcher extends Proxy implements IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function ProxyEventDispatcher(target:IEventDispatcher=null) {
			super();
			this._dispatcher = new EventDispatcher( target || this );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _dispatcher:EventDispatcher;

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IEventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			this._dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			this._dispatcher.removeEventListener( type, listener, useCapture );
		}

		/**
		 * @inheritDoc
		 */
		public function dispatchEvent(event:Event):Boolean {
			return this._dispatcher.dispatchEvent( event );
		}

		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean {
			return this._dispatcher.hasEventListener( type );
		}

		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean {
			return this._dispatcher.willTrigger( type );
		}

	}

}