////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	[Exclude( kind="event", name="timerComplete" )]

	[Exclude( kind="property", name="currentCount" )]
	[Exclude( kind="property", name="repeatCount" )]

	[Exclude( kind="method", name="reset" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class FrameTimer extends Timer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * быстрее клонировать, чем делать new
		 */
		private static const _EVENT:TimerEvent = new TimerEvent( TimerEvent.TIMER );

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  frameRate
		//----------------------------------

		/**
		 * @private
		 */
		private static var _frameRate:Number = 1E3 / 12;

		public static function get frameRate():Number {
			return 1E3 / _frameRate;
		}

		/**
		 * @private
		 */
		public static function set frameRate(value:Number):void {
			_frameRate = 1E3 / value;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FrameTimer(delay:Number) {
			super( delay );
			this._delay = delay;
			this.updateDelay();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _count:uint = 0;

		/**
		 * @private
		 */
		private var _reset_count:uint = 1;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  delay
		//----------------------------------

		/**
		 * @private
		 */
		private var _delay:Number;

		public override function get delay():Number {
			return this._delay;
		}

		/**
		 * @private
		 */
		public override function set delay(value:Number):void {
			if ( this._delay == value ) return;
			this._delay = value;
			this.updateDelay();
		}

		//----------------------------------
		//  currentCount
		//----------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @private
		 */
		public override function get currentCount():int {
			return 0;
		}

		//----------------------------------
		//  repeatCount
		//----------------------------------

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override function set repeatCount(value:int):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//----------------------------------
		//  running
		//----------------------------------

		/**
		 * @private
		 */
		private var _running:Boolean = false;

		public override function get running():Boolean {
			return this._running;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function start():void {
			if ( this._running ) return;
			this.updateDelay();
			switch ( this._reset_count ) {
				case 0:	super.start();																			break;
				case 1:	enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );	break;
				case 2:	enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame2 );	break;
					
			}
			this._running = true;
		}

		/**
		 * @private
		 */
		public override function stop():void {
			if ( !this._running ) return;
			this._running = false;
			switch ( this._reset_count ) {
				case 0:	super.stop();																				break;
				case 1:	enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );	break;
				case 2:	enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame2 );	break;
					
			}
		}

		[Deprecated( message="метод запрещен" )]
		/**
		 * @private
		 */
		public override function reset():void {
			Error.throwError( IllegalOperationError, 1001, 'reset' );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateDelay():void {

			var value:Number = this._delay;
			if ( value < _frameRate ) value = _frameRate;

			var reset_count:uint = Math.round( value / _frameRate );
			if ( reset_count > 2 ) reset_count = 0;

			if ( this._reset_count == reset_count ) return;

			var running:Boolean = super.running;

			if ( running ) this.stop();
			this._reset_count = reset_count;
			if ( this._reset_count == 0 ) {
				super.delay = value;
			}
			if ( running ) this.start();

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			if ( !this._running ) return;
			super.dispatchEvent( _EVENT );
		}

		/**
		 * @private
		 */
		private function handler_enterFrame2(event:Event):void {
			if ( !this._running ) return;
			if ( ( ++this._count ) & 1 && this._running ) {
				super.dispatchEvent( _EVENT );
			}
		}

	}

}