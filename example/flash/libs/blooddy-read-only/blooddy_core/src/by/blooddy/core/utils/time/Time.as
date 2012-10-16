////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import by.blooddy.core.events.time.TimeEvent;
	
	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="timeRelativityChange", type="by.blooddy.core.events.time.TimeEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 23:03:21
	 */
	public class Time extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Time() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  currentTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _zeroTime:Number = getTimer();

		public function get currentTime():Number {
			return getTimer() - this._zeroTime;
		}

		/**
		 * @private
		 */
		public function set currentTime(value:Number):void {
			var oldTime:Number = this.currentTime;
			this._zeroTime = getTimer() - value;
			super.dispatchEvent( new TimeEvent( TimeEvent.TIME_RELATIVITY_CHANGE, false, false, this.currentTime - oldTime ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getDelata(time:Number):Number {
			return time - this.currentTime;
		}

	}

}