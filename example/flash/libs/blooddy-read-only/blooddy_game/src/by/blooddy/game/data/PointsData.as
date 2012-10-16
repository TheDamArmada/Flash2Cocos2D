////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.game.data {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.managers.process.IProgressable;
	
	import flash.events.ProgressEvent;

	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					23.08.2009 16:15:38
	 */
	public class PointsData extends Data implements IProgressable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function PointsData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * @private
		 */
		private var _progress:Number = 0;

		public function get progress():Number {
			return this._progress;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  current
		//----------------------------------

		/**
		 * @private
		 */
		private var _current:int;

		public function get current():int {
			return this._current;
		}

		/**
		 * @private
		 */
		public function set current(value:int):void {
			if ( this._current == value ) return;
			this._current = value;
			this.updateProgress();
		}

		//----------------------------------
		//  min
		//----------------------------------

		/**
		 * @private
		 */
		private var _min:int;

		public function get min():int {
			return this._min;
		}

		/**
		 * @private
		 */
		public function set min(value:int):void {
			if ( this._min == value ) return;
			this._min = value;
			this.updateProgress();
		}

		//----------------------------------
		//  max
		//----------------------------------

		/**
		 * @private
		 */
		private var _max:int;

		public function get max():int {
			return this._max;
		}

		/**
		 * @private
		 */
		public function set max(value:int):void {
			if ( this._max == value ) return;
			this._max = value;
			this.updateProgress();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'min', 'current', 'max', 'progress' );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateProgress():void {
			this._progress = ( this._current - this._min ) / ( this._max - this._min );
			if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
				super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._current, this._max ) );
			}
		}

	}

}