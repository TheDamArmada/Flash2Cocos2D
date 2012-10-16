/*!
 * blooddy/utils/timer.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.Timer ) {

	blooddy.require( 'blooddy.events.EventDispatcher' );

	/**
	 * @class
	 * @namespace	blooddy.utils
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.Timer = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	$ =			blooddy,
			EEvent =	$.events.Event,
			utils =		$.utils,
			MMath =		Math,

			msie =		$.browser.getMSIE();


		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Number}	delay
		 */
		var Timer = function(delay, repeatCount) {
			TimerSuperPrototype.constructor.call( this );
			this._delay = MMath.max( 1, delay || 0 );
			this._repeatCount = MMath.max( 0, repeatCount || 0 );
		};

		$.extend( Timer, $.events.EventDispatcher );

		var	TimerPrototype =		Timer.prototype,
			TimerSuperPrototype =	Timer.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Number}
		 */
		TimerPrototype._delayID = NaN;

		/**
		 * @private
		 * @type	{Number}
		 */
		TimerPrototype._id = NaN;

		/**
		 * @private
		 * @type	{Number}
		 */
		TimerPrototype._time = 0;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  running
		//----------------------------------

		/**
		 * @method
		 * The timer's current state; true if the timer is running,
		 * otherwise false.
		 * @return	{Boolean}
		 */
		TimerPrototype.isRunning = function() {
			return !isNaN( this._id );
		};

		//----------------------------------
		//  delay
		//----------------------------------

		/**
		 * @private
		 */
		TimerPrototype._delay = 1;

		/**
		 * @method
		 * The delay, in milliseconds, between timer events.
		 * @return	{Number}
		 */
		TimerPrototype.getDelay = function() {
			return this._delay;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		TimerPrototype.setDelay = function(value) {
			if ( this._delay == value ) return;
			value = MMath.max( 1, value || 0 );
			if ( this._delay == value ) return;
			this._delay = value;
			if ( !isNaN( this._id ) ) {
				this.stop();
				var d = ( this._delay - ( utils.getTime() - this._time ) % this._delay ) % this._delay;
				if ( msie ) {
					var t = this;
					this._delayID = setTimeout( function() { delayUpdate( t ) }, d );
				} else {
					this._delayID = setTimeout( delayUpdate, d, this );
				}
			}
		};

		//----------------------------------
		//  repeatCount
		//----------------------------------

		/**
		 * @private
		 */
		TimerPrototype._repeatCount = 0;

		/**
		 * @method
		 * The total number of times the timer is set to run.
		 * @return	{Number}
		 */
		TimerPrototype.getRepeatCount = function() {
			return this._repeatCount;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		TimerPrototype.setRepeatCount = function(value) {
			this._repeatCount = MMath.max( 0, value || 0 );
		};

		//----------------------------------
		//  currentCount
		//----------------------------------

		/**
		 * @private
		 */
		TimerPrototype._currentCount = 0;

		/**
		 * @method
		 * The total number of times the timer has fired since it
		 * started at zero.
		 * @return	{Number}
		 */
		TimerPrototype.getCurrentCount = function() {
			return this._currentCount;
		};

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var delayUpdate = function(scope) {
			clearTimeout( scope._delayID );
			scope._delayID = NaN;
			scope.start();
			interval( scope );
		};

		/**
		 * @private
		 */
		var interval = function(scope) {
			scope._time = utils.getTime();
			scope._currentCount++;
			scope.dispatchEvent( new EEvent( 'timer' ) );
			if ( scope._repeatCount && scope._currentCount >= scope._repeatCount ) {
				scope.stop();
				scope.dispatchEvent( new EEvent( 'timer_complete' ) );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * Starts the timer, if it is not already running.
		 */
		TimerPrototype.start = function() {
			if ( !isNaN( this._id ) ) return;
			if ( msie ) {
				var t = this;
				this._id = setInterval( function() { interval( t ) }, this._delay );
			} else {
				this._id = setInterval( interval, this._delay, this );
			}
		};

		/**
		 * @method
		 * Stops the timer.
		 */
		TimerPrototype.stop = function() {
			if ( isNaN( this._id ) ) return;
			clearInterval( this._id );
			this._id = NaN;
			if ( !isNaN( this._delayID ) ) {
				clearTimeout( this._delayID );
				this._delayID = NaN;
			}
		};

		/**
		 * @method
		 * Stops the timer, if it is running, and sets the currentCount
		 * property back to 0, like the reset button of a stopwatch.
		 */
		TimerPrototype.reset = function() {
			this.stop();
			this._currentCount = 0;
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		TimerPrototype.dispose = function() {
			this.stop();
			TimerSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		TimerPrototype.toString = function() {
			return '[Timer object]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		Timer.toString = function() {
			return '[class Timer]';
		};

		return Timer;

	}() );

}