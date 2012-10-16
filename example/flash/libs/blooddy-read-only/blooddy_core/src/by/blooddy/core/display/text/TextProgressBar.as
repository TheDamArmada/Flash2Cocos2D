package by.blooddy.core.display.text {

	import by.blooddy.core.display.IProgressBar;
	import by.blooddy.core.managers.process.IProgressable;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.01.2012 15:00:51
	 */
	public class TextProgressBar extends BaseTextField implements IProgressBar {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function TextProgressBar() {
			super();
			super.addEventListener( Event.ADDED_TO_STAGE, this.render, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.clear, false, int.MAX_VALUE, true );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  progressDispatcher
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _progressDispatcher:IProgressable;
		
		public function get progressDispatcher():IProgressable {
			return this._progressDispatcher;
		}
		
		/**
		 * @private
		 */
		public function set progressDispatcher(value:IProgressable):void {
			if ( this._progressDispatcher === value ) return;
			if ( this._progressDispatcher ) {
				this._progressDispatcher.removeEventListener( ProgressEvent.PROGRESS, this.handler_progress );
			}
			this._progressDispatcher = value;
			if ( this._progressDispatcher ) {
				this._progressDispatcher.addEventListener( ProgressEvent.PROGRESS, this.handler_progress );
				this._progress = this._progressDispatcher.progress;
			} else {
				this._progress = 0;
			}
			this.render();
		}
		
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
		
		/**
		 * @private
		 */
		public function set progress(value:Number):void {
			if ( this._progressDispatcher || this._progress == value ) return;
			value = Math.min( Math.max( 0, value ), 1 );
			if ( this._progress == value ) return;
			this._progress = value;
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
			this.setText( Math.round( this._progress * 100 ) + '%' );
			return true;
		}
		
		protected function clear(event:Event=null):Boolean {
			this.setText( '' );
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this._progress = Math.min( Math.max( 0, this._progressDispatcher.progress ), 1 );
			this.render( event );
		}
		
	}
	
}