////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.proxy.ProxyObject;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @copy		flash.events.EventDispatcher#deactivate
	 */
	[Event( name="activate", type="flash.events.Event" )]

	/**
	 * @copy		flash.events.EventDispatcher#activate
	 */
	[Event( name="deactivate", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					localproxysharedobject, sharedobject, proxy
	 */
	public dynamic class ProxySharedObject extends ProxyObject implements IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_px;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getLocal(name:String, path:String=null, secure:Boolean=false):ProxySharedObject {
			var so:SharedObject = SharedObject.getLocal( name, path, secure );
			var intance:ProxySharedObject = _HASH[ so ] as ProxySharedObject;
			if ( !intance ) {
				_HASH[ so ] = intance = new ProxySharedObject( so );
			}
			return intance;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ProxySharedObject(so:SharedObject) {
			super( so.data );
			this._dispatcher = new EventDispatcher( this );
			this._so = so;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _so:SharedObject;

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

		//--------------------------------------------------------------------------
		//
		//  Override protected methods: ProxyObject
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		$protected_px override function bubble(name:String, path:Vector.<String>=null, hash:Dictionary=null):void {
			var text:String;
			if ( path ) {
				path.push( name );
				path.reverse();
				text = path.join( '.' );
			} else {
				text = name;
			}
			this._dispatcher.dispatchEvent( new Event( text ) );
		}

	}

}