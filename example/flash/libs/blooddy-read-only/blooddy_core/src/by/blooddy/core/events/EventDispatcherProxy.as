////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="method", name="dispatchEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class EventDispatcherProxy implements IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function EventDispatcherProxy() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _dispatchers:Vector.<IEventDispatcher> = new Vector.<IEventDispatcher>();

		/**
		 * @private
		 */
		private const _listeners:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IEventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {

			var listeners_type:Vector.<Dictionary> = this._listeners[ type ] as Vector.<Dictionary>;
			if ( !listeners_type ) this._listeners[ type ] = listeners_type = new Vector.<Dictionary>( 2, true );

			var listeners_capture:Dictionary = listeners_type[ useCapture ? 1 : 0 ];
			if ( !listeners_capture ) listeners_type[ useCapture ? 1 : 0 ] = listeners_capture = new Dictionary(); // BUG: должен стоять useWeakReference, но почему-то методы удаляются сразу, если их не использовать никто в коде кроме этого места. в общем не учитывается ссылка на контекст метода.

			var listener_props:EventListenerProperties = listeners_capture[ listener ];
			var update:Boolean = false;
			if ( !listener_props ) {
				update = true;
				listeners_capture[ listener ] = listener_props = new EventListenerProperties();
			}
			if (
				listener_props.priority != priority ||
				listener_props.useWeakReference != useWeakReference
			) {
				update = true;
				listener_props.priority = priority;
				listener_props.useWeakReference = useWeakReference;
			}

			// обновим подписчиков
			if ( update ) {
				for each ( var dispatcher:IEventDispatcher in this._dispatchers ) {
					dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			var listeners_type:Vector.<Dictionary> = this._listeners[ type ] as Vector.<Dictionary>;
			if ( listeners_type ) {
				var listeners_capture:Dictionary = listeners_type[ useCapture ? 1 : 0 ];
				if ( listeners_capture ) {
					delete listeners_capture[ listener ];
				}
			}
			// обновим подписчиков
			for each ( var dispatcher:IEventDispatcher in this._dispatchers ) {
				dispatcher.removeEventListener( type, listener, useCapture );
			}
		}

		[Deprecated( message="метод не используется" )]
		/**
		 * 
		 */
		public function dispatchEvent(event:Event):Boolean {
			return true;
		}

		/**
		 * @inheritDoc
		 */
		public function hasEventListener(type:String):Boolean {
			for each ( var dispatcher:IEventDispatcher in this._dispatchers ) {
				if ( dispatcher.hasEventListener( type ) ) return true;
			}
			return false;
		}

		/**
		 * @inheritDoc
		 */
		public function willTrigger(type:String):Boolean {
			for each ( var dispatcher:IEventDispatcher in this._dispatchers ) {
				if ( dispatcher.willTrigger( type ) ) return true;
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addEventDispatcher(dispatcher:IEventDispatcher):void {
			if ( this._dispatchers.indexOf( dispatcher ) >= 0 ) return;
			this._dispatchers.push( dispatcher );

			var type:String;
			var listener:Function;
			var useCapture_i:uint;
			var useCapture:Boolean;

			var listeners_type:Vector.<Dictionary>;
			var listeners_capture:Dictionary;
			var listener_props:EventListenerProperties;

			var o:Object;

			for ( type in this._listeners ) {
				listeners_type = this._listeners[ type ] as Vector.<Dictionary>;
				for ( useCapture_i = 0; useCapture_i <= 1; ++useCapture_i ) {
					useCapture = Boolean( useCapture_i )
					listeners_capture = listeners_type[ useCapture_i ];
					for ( o in listeners_capture ) {
						listener = o as Function;
						listener_props = listeners_capture[ o ] as EventListenerProperties;
						dispatcher.addEventListener( type, listener, useCapture, listener_props.priority, listener_props.useWeakReference );
					}
				}
			}

		}

		public function removeEventDispatcher(dispatcher:IEventDispatcher):void {
			var i:int = this._dispatchers.indexOf( dispatcher );
			if ( i < 0 ) return;
			this._dispatchers.splice( i, 1 );

			var type:String;
			var useCapture_i:uint;
			var useCapture:Boolean;

			var listeners_type:Vector.<Dictionary>;
			var listeners_capture:Dictionary;

			var o:Object;

			for ( type in this._listeners ) {
				listeners_type = this._listeners[ type ] as Vector.<Dictionary>;
				for ( useCapture_i = 0; useCapture_i <= 1; ++useCapture_i ) {
					useCapture = Boolean( useCapture_i )
					listeners_capture = listeners_type[ useCapture_i ];
					for ( o in listeners_capture ) {
						dispatcher.removeEventListener( type, o as Function, useCapture );
					}
				}
			}

		}

		public function hasEventDispatcher(dispatcher:IEventDispatcher):Boolean {
			return this._dispatchers.indexOf( dispatcher ) >= 0;
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventListenerProperties
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class EventListenerProperties {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function EventListenerProperties() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var priority:int = 0;

	public var useWeakReference:Boolean = false;

}