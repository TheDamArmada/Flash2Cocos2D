package by.blooddy.core.display.text {

	import by.blooddy.core.utils.DateUtils;
	import by.blooddy.core.utils.time.AutoTimer;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.01.2012 15:59:50
	 */
	public class Clock extends BaseTextField {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 1e3 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Clock() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var formater:Function;

		//----------------------------------
		//  progressDispatcher
		//----------------------------------

		/**
		 * @private
		 */
		private var _realTime:Number;

		/**
		 * @private
		 */
		private var _time:Number;

		public function get time():Number {
			return this._realTime - getTimer();
		}
		
		/**
		 * @private
		 */
		public function set time(value:Number):void {
			if ( this.time === value ) return;
			this._time = value;
			this._realTime = getTimer() + value;
			this.render();
		}
		
		//----------------------------------
		//  progress
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _reverse:Boolean = true;
		
		public function get reverse():Boolean {
			return this._reverse;
		}
		
		/**
		 * @private
		 */
		public function set reverse(value:Boolean):void {
			if ( this._reverse == value ) return;
			this._reverse = value;
			this.render();
		}
		
		//----------------------------------
		//  text
		//----------------------------------
		
		public override function set text(value:String):void {
			Error.throwError( IllegalOperationError, 2071 );
		}
		
		//----------------------------------
		//  htmlText
		//----------------------------------
		
		public override function set htmlText(value:String):void {
			Error.throwError( IllegalOperationError, 2071 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected final function setText(value:String):void {
			super.text = value;
		}
		
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;
			_TIMER.addEventListener( TimerEvent.TIMER, this.updateTimer );
			this.updateTimer();
			return true;
		}
		
		protected function clear(event:Event=null):Boolean {
			_TIMER.removeEventListener( TimerEvent.TIMER, this.updateTimer );
			this.setText( '' );
			return true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function updateTimer(...rest):void {
			var d:Number = this._realTime - getTimer();
			if ( d < 0 ) {
				this.clear();
			} else {
				var formater:Function = this.formater || DateUtils.timeToString;
				this.setText( formater( this._reverse ? d : this._time - d ) );
			}
		}
		
	}
	
}