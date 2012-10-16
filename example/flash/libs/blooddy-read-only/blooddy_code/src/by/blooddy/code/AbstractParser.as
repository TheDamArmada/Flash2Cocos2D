////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code {

	import by.blooddy.core.managers.process.IProcessable;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Implements events: IProcessable
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="error", type="flash.events.ErrorEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.04.2010 17:15:33
	 */
	public class AbstractParser extends EventDispatcher implements IProcessable {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * статус загрузки. ожидание
		 */
		private static const _STATE_IDLE:uint =		0;
		
		/**
		 * @private
		 * статус загрузки. пауза
		 */
		private static const _STATE_PAUSE:uint =	_STATE_IDLE		+ 1;
		
		/**
		 * @private
		 * статус загрузки. прогресс
		 */
		private static const _STATE_PROGRESS:uint =	_STATE_PAUSE	+ 1;
		
		/**
		 * @private
		 * статус загрузки. всё зашибись
		 */
		private static const _STATE_COMPLETE:uint =	_STATE_PROGRESS	+ 1;
		
		/**
		 * @private
		 * статус загрузки. ошибка
		 */
		private static const _STATE_ERROR:uint =	_STATE_COMPLETE	+ 1;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function AbstractParser() {
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
		private var _state:uint;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected final function start():void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			this._state = _STATE_PROGRESS;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_exitFrame );
		}

		protected final function activate():void {
			if ( this._state != _STATE_PAUSE ) return;
			this._state = _STATE_PROGRESS;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}
		
		protected final function deactivate():void {
			if ( this._state != _STATE_PROGRESS ) return;
			this._state = _STATE_PAUSE;
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}
		
		protected virtual function onParse():Boolean {
			throw new IllegalOperationError();
		}

		protected final function stop():void {
			this.deactivate();
			this._state = _STATE_COMPLETE;
			super.dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		protected final function throwError(e:Error):void {
			this.deactivate();
			this._state = _STATE_ERROR;
			super.dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.toString(), e.errorID ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_exitFrame(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_exitFrame );
			if ( this._state < _STATE_COMPLETE && super.hasEventListener( Event.OPEN ) ) {
				super.dispatchEvent( new Event( Event.OPEN ) );
			}
			if ( this._state == _STATE_PROGRESS ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
				this.handler_enterFrame( event );
			}
		}
		
		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			try {
				if ( this.onParse() ) {
					this.deactivate();
				}
			} catch ( e:Error ) {
				this.throwError( e );
			}
		}

	}

}