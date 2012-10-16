////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class CallerQueue {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function CallerQueue() {
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
		private const _queue:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get length():uint {
			return this._queue.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addQueue(handler:Function, ...args):void {
			this.addCallerQueue( new Caller( handler, args ) );
		}

		public function addCallerQueue(caller:Caller):void {
			if ( this._queue.push( caller ) == 1 ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame, false, int.MAX_VALUE );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			( this._queue.shift() as Caller ).call();
			if ( this._queue.length <= 0 ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame ); 
			}
		}

	}

}