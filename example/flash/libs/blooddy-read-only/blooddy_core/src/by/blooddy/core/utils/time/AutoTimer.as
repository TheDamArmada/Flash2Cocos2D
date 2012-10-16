////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="event", name="timerComplete" )]

	[Exclude( kind="property", name="delay" )]
	[Exclude( kind="property", name="currentCount" )]
	[Exclude( kind="property", name="repeatCount" )]

	[Exclude( kind="method", name="start" )]
	[Exclude( kind="method", name="stop" )]
	[Exclude( kind="method", name="reset" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class AutoTimer extends Timer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function AutoTimer(delay:Number) {
			super( delay );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override function set delay(value:Number):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @private
		 */
		public override function get currentCount():int {
			return 0;
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override function set repeatCount(value:int):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		[Deprecated( message="метод запрещён. включается автоматически.", replacement="addEventListener" )]
		/**
		 * @private
		 */
		public override function start():void {
			Error.throwError( IllegalOperationError, 1001, 'start' );
		}

		[Deprecated( message="метод запрещён. выключается автоматически.", replacement="removeEventListener" )]
		/**
		 * @private
		 */
		public override function stop():void {
			Error.throwError( IllegalOperationError, 1001, 'stop' );
		}

		[Deprecated( message="метод не использщуется" )]
		/**
		 * @private
		 */
		public override function reset():void {
			Error.throwError( IllegalOperationError, 1001, 'reset' );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			super.addEventListener( type, listener, useCapture, priority, useWeakReference );
			if ( type == TimerEvent.TIMER ) {
				if ( !super.running ) {
					super.start();
				}
			}
		}

		/**
		 * @private
		 */
		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			super.removeEventListener( type, listener, useCapture );
			if ( type == TimerEvent.TIMER ) {
				if ( super.running && !super.hasEventListener( type ) ) {
					super.stop();
				}
			}
		}

	}

}