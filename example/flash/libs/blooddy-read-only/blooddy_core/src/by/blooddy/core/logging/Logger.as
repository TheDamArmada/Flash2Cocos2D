////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.events.logging.LogEvent;
	import by.blooddy.core.utils.time.AutoTimer;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 */
	[Event( name="addedLog", type="by.blooddy.core.events.logging.LogEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					log, logger
	 */
	public class Logger extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 30e3 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	maxLength
		 * @param	maxTime
		 */
		public function Logger(maxLength:uint=100, maxTime:uint=5*60*1E3) {
			super();
			this._maxLength = maxLength;
			this._maxTime = maxTime; 
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as"

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _list:Vector.<Log> = new Vector.<Log>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  length
		//----------------------------------

		public function get length():uint {
			return this._list.length;
		}

		//----------------------------------
		//  maxLength
		//----------------------------------

		/**
		 * @private
		 */
		private var _maxLength:uint;

		public function get maxLength():uint {
			return this._maxLength;
		}

		/**
		 * @private
		 */
		public function set maxLength(value:uint):void {
			if ( this._maxLength == value ) return;
			var u:Boolean = ( value < this._maxLength );
			this._maxLength = value;
			if ( u ) this.updateList();
		}

		//----------------------------------
		//  maxTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _maxTime:uint;

		public function get maxTime():uint {
			return this._maxTime;
		}

		/**
		 * @private
		 */
		public function set maxTime(value:uint):void {
			if ( this._maxTime == value ) return;
			var u:Boolean = ( value < this._maxLength );
			this._maxTime = value;
			if ( u ) this.updateList();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addLog(log:Log):void {
			if ( this._list.length == 0 ) {
				_TIMER.addEventListener( TimerEvent.TIMER, this.updateList );
			}
			this._list.push( log );
			if ( super.hasEventListener( LogEvent.ADDED_LOG ) ) {
				super.dispatchEvent( new LogEvent( LogEvent.ADDED_LOG, false, false, log ) );
			}
		}

		public function getList():Vector.<Log> {
			return this._list.slice();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateList(...rest):void {
			var time:Number = getTimer() - this._maxTime;
			const l:uint = this._list.length;
			var i:uint = ( this._maxLength && l > this._maxLength ? l - this._maxLength : 0 );
			for ( i; i < l; ++i ) {
				if ( time < this._list[ i ].time ) break;
			}
			if ( i > 0 ) {
				this._list.splice( 0, i );
				if ( i == l ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.updateList );
				}
			}
		}

	}

}