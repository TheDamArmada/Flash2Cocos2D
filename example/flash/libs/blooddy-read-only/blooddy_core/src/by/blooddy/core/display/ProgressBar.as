////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.managers.process.IProgressable;
	import by.blooddy.core.utils.css.ColorUtils;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class ProgressBar extends BaseShape implements IProgressBar {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ProgressBar() {
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
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		private var _width:Number = 40;

		public override function get width():Number {
			return this._width;
		}

		/**
		 * @private
		 */
		public override function set width(value:Number):void {
			if ( this._width == value ) return;
			this._width = value;
			this.render();
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		private var _height:Number = 2;

		public override function get height():Number {
			return this._height;
		}

		/**
		 * @private
		 */
		public override function set height(value:Number):void {
			if ( this._height == value ) return;
			this._height = value;
			this.render();
		}

		//----------------------------------
		//  borderColor32
		//----------------------------------

		/**
		 * @private
		 */
		private var _borderColor32:Object;

		public function get borderColor32():Object {
			return this._borderColor32;
		}

		/**
		 * @private
		 */
		public function set borderColor32(value:Object):void {
			if ( this._borderColor32 == value ) return;
			this._borderColor32 = value;
			this.render();
		}

		//----------------------------------
		//  bgColor32
		//----------------------------------

		/**
		 * @private
		 */
		private var _bgColor32:Object;

		public function get bgColor32():Object {
			return this._bgColor32;
		}

		/**
		 * @private
		 */
		public function set bgColor32(value:Object):void {
			if ( this._bgColor32 == value ) return;
			this._bgColor32 = value;
			this.render();
		}

		//----------------------------------
		//  indicatorColor32
		//----------------------------------

		/**
		 * @private
		 */
		private var _indicatorColor32:Object;

		public function get indicatorColor32():Object {
			return this._indicatorColor32;
		}

		/**
		 * @private
		 */
		public function set indicatorColor32(value:Object):void {
			if ( this._indicatorColor32 == value ) return;
			this._indicatorColor32 = value;
			this.render();
		}

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
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;

			super.graphics.clear();

			if ( this._width <= 0 || this._height <= 0 ) return false;

			var g:Graphics = super.graphics;
			
			var alpha:Number;
			var color:uint;
			
			color =	(	this._bgColor32 is Number ?
						this._bgColor32 as Number :
						(	this._bgColor32 is Array ?
							ColorUtils.getGradientColor( this._progress, this._bgColor32 as Array ) :
							parseInt( this._bgColor32 as String )
						)
					);
			alpha = ( ( color >>> 24 ) & 0xFF ) / 0xFF;
			if ( alpha > 0.05 ) {
				color = color & 0xFFFFFF;
				g.beginFill( color, alpha );
				g.drawRect( 0, 0, this._width, this._height );
				g.endFill();
			}

			if ( this._progress > 0 ) {
				g.lineStyle();
				color =	(	this._indicatorColor32 is Number ?
							this._indicatorColor32 as Number :
							(	this._indicatorColor32 is Array ?
								ColorUtils.getGradientColor( this._progress, this._indicatorColor32 as Array ) :
								parseInt( this._indicatorColor32 as String )
							)
						);
				alpha = ( ( color >>> 24 ) & 0xFF ) / 0xFF;
				color = color & 0xFFFFFF;
				g.beginFill( color, alpha );
				g.drawRect( 0, 0, this._width * this._progress, this._height );
				g.endFill();
				// 3D суко!
//				super.graphics.lineStyle( 1, 0, 0.70, true );
//				super.graphics.moveTo( 0, this._height - 1 );
//				super.graphics.lineTo( this._width * this._progress, this._height - 1 );
//				super.graphics.lineStyle( 1, 0, 0.40, true );
//				super.graphics.moveTo( 0, 1 );
//				super.graphics.lineTo( this._width * this._progress, 1 );
			}

			color =	(	this._borderColor32 is Number ?
						this._borderColor32 as Number :
						(	this._borderColor32 is Array ?
							ColorUtils.getGradientColor( this._progress, this._borderColor32 as Array ) :
							parseInt( this._borderColor32 as String )
						)
					);
			alpha = ( ( color >>> 24 ) & 0xFF ) / 0xFF;
			if ( alpha > 0.05 ) {
				color = color & 0xFFFFFF;
				g.lineStyle( 1, color, alpha );
				g.drawRect( -0.5, -0.5, this._width + 1, this._height + 1 );
			}

			return true;
		}

		protected function clear(event:Event=null):Boolean {
			super.graphics.clear();
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