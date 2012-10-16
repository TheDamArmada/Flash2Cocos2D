////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.utils.time.AutoTimer;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.TimerEvent;

	/**
	 * Сборщик всякого дерьма.
	 * Что бы не создавать дополнительные экземпляры классов, если те часто удаляются и добавляются.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					recycle, bin, recyclebin
	 */
	public class RecycleBin {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 30*1e3 );

		/**
		 * @private
		 */
		private static const _CONTAINERS:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function RecycleBin() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Varaibles
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private var _length:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function has(key:String!):Boolean {
			return ( key in this._hash && this._hash[ key ].length > 0 );
		}

		public function takeIn(key:String, resource:*, time:uint=3*60*1e3):void {
			if ( resource == null || time <= 0 ) throw new ArgumentError();
			var list:Array = this._hash[ key ];
			if ( !list ) this._hash[ key ] = list = new Array();
			time += getTimer();
			var l:uint = list.length;
			for ( var i:int=0; i < l; ++i ) {
				if ( list[ i ].time <= time ) break;
			}
			var rc:ResourceContainer = ( _CONTAINERS.length > 0 ? _CONTAINERS.pop() : new ResourceContainer() );
			rc.resource = resource;
			rc.time = time;
			list.splice( i, 0, rc );
			if ( this._length == 0 ) {
				_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
			}
			++this._length;
		}

		public function takeOut(key:String):* {
			var result:*;
			var list:Array = this._hash[ key ];
			if ( list && list.length > 0 ) {
				--this._length;
				if ( this._length == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}
				var rc:ResourceContainer = list.pop();
				result = rc.resource;
				rc.resource = null;
				_CONTAINERS.push( rc );
			}
			return result;
		}

		/**
		 */
		public function clear(pattern:*=null):void {
			var key:String;
			var rc:ResourceContainer;
			var list:Array;
			if ( pattern ) {
				for ( key in this._hash ) {
					if ( key.search( pattern ) >= 0 ) {
						list = this._hash[ key ];
						for each ( rc in list ) {
							dispose( rc.resource );
							rc.resource = null;
						}
						this._length -= list.length;
						delete this._hash[ key ];
						_CONTAINERS.push.apply( null, list );
					}
				}
				if ( this._length == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}
			} else {
				for ( key in this._hash ) {
					list = this._hash[ key ];
					for each ( rc in list ) {
						dispose( rc.resource );
						rc.resource = null;
					}
					delete this._hash[ key ];
					_CONTAINERS.push.apply( null, list );
				}
				this._length = 0;
				_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:uint = getTimer() + 1e3;
			var list:Array;
			var i:int, l:uint;
			var rc:ResourceContainer;
			for each ( list in this._hash ) {
				l = list.length;
				for ( i=0; i<l; ++i ) {
					rc = list[ i ];
					// если условие проходит, то всё что там лежит совсем не старое
					if ( rc.time > time ) break;
					dispose( rc.resource );
					rc.resource = null;
				}
				if ( i > 0 ) { // минимум один элемент на удаление
					this._length -= i;
					_CONTAINERS.push.apply( null, list.splice( 0, i ) );
				}
			}
			if ( this._length == 0 ) {
				_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
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
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class ResourceContainer {

	public function ResourceContainer() {
		super();
	}

	public var resource:*;

	public var time:Number;

}