////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.tween {

	import by.blooddy.core.utils.time.getTimer;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					16.09.2011 13:48:16
	 */
	public final class Tween {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _BROADCASTER:Shape = new Shape();

		/**
		 * @private
		 */
		private static const _LIST:Vector.<Tween> = new Vector.<Tween>();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function to(target:Object, duration:uint, vars:Object, params:Object=null):Tween {
			var vvars:Vector.<Var> = new Vector.<Var>();
			for ( var n:String in vars ) {
				if ( n in target && target[ n ] is Number ) {
					vvars.push( new Var( n, target[ n ], vars[ n ] ) );
				}
			}
			vvars.fixed = true;
			return new Tween( target, duration, vvars, params );
		}

		public static function from(target:Object, duration:uint, vars:Object, params:Object=null):Tween {
			var vvars:Vector.<Var> = new Vector.<Var>();
			for ( var n:String in vars ) {
				if ( n in target && target[ n ] is Number ) {
					vvars.push( new Var( n, vars[ n ], target[ n ] ) );
				}
			}
			vvars.fixed = true;
			var result:Tween = new Tween( target, duration, vvars, params );
			result._renderFrom();
			return result;
		}

		public static function kill(target:Object):void {
			var tween:Tween;
			var list:Vector.<Tween> = _LIST;
			var i:int;
			var l:int = list.length;
			for ( i=0; i<l; ++i ) {
				tween = list[ i ];
				if ( tween._target === target ) {
					list.splice( i, 1 );
					--i;
					--l;
					tween._kill();
				}
			}
			if ( list.length <= 0 ) {
				_BROADCASTER.removeEventListener( Event.ENTER_FRAME, handler_enterFrame );
			}
		}

		public static function complete(target:Object):void {
			var tween:Tween;
			var list:Vector.<Tween> = _LIST;
			var i:int;
			var l:int = list.length;
			for ( i=0; i<l; ++i ) {
				tween = list[ i ];
				if ( tween._target === target ) {
					list.splice( i, 1 );
					--i;
					--l;
					tween._complete();
				}
			}
			if ( list.length <= 0 ) {
				_BROADCASTER.removeEventListener( Event.ENTER_FRAME, handler_enterFrame );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function easeOut(t:Number, b:Number, c:Number, d:uint):Number {
			return -1 * ( t /= d ) * ( t - 2 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function handler_enterFrame(event:Event):void {
			var time:Number = getTimer();
			var tween:Tween;
			var list:Vector.<Tween> = _LIST;
			var i:int;
			var l:int = list.length;
			var t:uint;
			for ( i=0; i<l; ++i ) {
				tween = list[ i ];
				t = time - tween._startTime;
				if ( t < tween._duration ) {
					tween._render( t );
					if ( tween._onProgress != null ) tween._onProgress();
				} else {
					list.splice( i, 1 );
					--i;
					--l;
					tween._complete();
				}
			}
			if ( list.length <= 0 ) {
				_BROADCASTER.removeEventListener( Event.ENTER_FRAME, handler_enterFrame );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Constructor
		 */
		public function Tween(target:Object, duration:uint, vars:Vector.<Var>, params:Object) {
			super();

			if ( typeof target != 'object' ) throw new ArgumentError();
			if ( isNaN( duration ) || duration <= 0 ) throw new ArgumentError();
			if ( vars.length <= 0 ) throw new ArgumentError();

			this._target = target;
			this._duration = duration;
			this._vars = vars;

			// params
			if ( params ) {
				if ( params.onProgress is Function )	this._onProgress = params.onProgress;
				if ( params.onComplete is Function )	this._onComplete = params.onComplete;
				if ( params.ease is Function )			this._ease = params.ease;
			}

			if ( _LIST.length <= 0 ) {
				_BROADCASTER.addEventListener( Event.ENTER_FRAME, handler_enterFrame );
			}
			_LIST.push( this );

		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _target:Object;

		/**
		 * @private
		 */
		private const _startTime:Number = getTimer();

		/**
		 * @private
		 */
		private var _duration:uint;

		/**
		 * @private
		 */
		private var _vars:Vector.<Var>;
		
		/**
		 * @private
		 */
		private var _ease:Function;
		
		/**
		 * @private
		 */
		private var _onProgress:Function;
		
		/**
		 * @private
		 */
		private var _onComplete:Function;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function render(time:Number):void {
			if ( time >= this._duration )	this._renderTo();
			else if ( time <= 0 )			this._renderFrom();
			else							this._render( time );
		}

		public function complete():void {
			if ( !this._target ) return;
			this._clean();
			this._complete();
		}
		
		public function kill():void {
			if ( !this._target ) return; // уже прибито
			this._clean();
			this._kill();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function _renderFrom():void {
			for each ( var v:Var in this._vars ) {
				this._target[ v.name ] = v.from;
			}
		}
		
		/**
		 * @private
		 */
		private function _render(time:uint):void {
			var ratio:Number;
			if ( this._ease == null ) {
				ratio = easeOut( time, 0, 1, this._duration );
			} else {
				ratio = this._ease( time, 0, 1, this._duration );
			}
			for each ( var v:Var in this._vars ) {
				this._target[ v.name ] = v.from + v.delta * ratio;
			}
		}

		/**
		 * @private
		 */
		private function _renderTo():void {
			for each ( var v:Var in this._vars ) {
				this._target[ v.name ] = v.to;
			}
		}

		/**
		 * @private
		 */
		private function _complete():void {
			var onComplete:Function = this._onComplete;
			this._renderTo();
			this._kill();
			if ( onComplete != null ) onComplete();
		}

		/**
		 * @private
		 */
		private function _kill():void {
			this._target = null;
			this._onComplete = null;
			this._ease = null;
		}

		/**
		 * @private
		 */
		private function _clean():void {
			var i:int = _LIST.indexOf( this );
			_LIST.splice( i, 1 );
			if ( _LIST.length <= 0 ) {
				_BROADCASTER.removeEventListener( Event.ENTER_FRAME, handler_enterFrame );
			}
		}

	}
	
}

/**
 * @private
 */
internal final class Var {

	public function Var(name:String, from:Number, to:Number) {
		super();
		this.name = name;
		this.from = from;
		this.delta = to - from;
		this.to = to;
	}

	public var name:String;

	public var from:Number;

	public var delta:Number;

	public var to:Number;

}