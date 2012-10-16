/*!
 * blooddy/logger.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.Logger ) {

	blooddy.require( 'blooddy.utils.List' );

	/**
	 * @class
	 * логгер
	 * @namespace	blooddy
	 * @extends		blooddy.utils.List
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Logger = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var $ =			blooddy,
			utils =		$.utils;

		var illegalOperation = function() {
			throw new Error( 'illegal operation' );
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Number}	maxLength
		 * @param	{Number}	maxTime
		 */
		var Logger = function(maxLength, maxTime, minLength) {
			LoggerSuperPrototype.constructor.call( this );
			this._maxLength =	( isNaN( maxLength ) ? 50 : maxLength );
			this._maxTime =		( isNaN( maxTime ) ? 5*60e3 : maxTime );
			this._minLength =	( minLength || 0 );
		};

		$.extend( Logger, $.utils.List );

		var	LoggerPrototype =		Logger.prototype,
			LoggerSuperPrototype =	Logger.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._minLength = null;

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._maxLength = null;

		/**
		 * @private
		 * @type	{Number}
		 */
		LoggerPrototype._maxTime = null;

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{blooddy.Logger}	scope
		 */
		var updateList = function(scope) {
			var	time = utils.getTime(),
				log;
			while ( scope._list.length > this._minLength ) {
				log = scope._list[0];
				if ( time - log.time < scope._maxTime ) {
					break;
				}
				scope.remove( log );
			}
			while ( scope._list.length > this._maxLength ) {
				scope.remove( log );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  length
		//----------------------------------

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getLength = function() {
			return this._list.length;
		};

		//----------------------------------
		//  minLength
		//----------------------------------

		/**
		 * @method
		 * @private
		 */
		LoggerPrototype._minLength = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMinLength = function() {
			return this._minLength;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMinLength = function(value) {
			if ( this._minLength == value ) return;
			this._minLength = Math.min( value || 0, this._maxLength );
		};

		//----------------------------------
		//  maxLength
		//----------------------------------

		/**
		 * @private
		 */
		LoggerPrototype._maxLength = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMaxLength = function() {
			return this._maxLength;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMaxLength = function(value) {
			if ( this._maxLength == value ) return;
			this._maxLength = value;
			updateList( this );
		};

		//----------------------------------
		//  maxTime
		//----------------------------------

		/**
		 * @private
		 */
		LoggerPrototype._maxTime = 0;

		/**
		 * @method
		 * @return	{Number}
		 */
		LoggerPrototype.getMaxTime = function() {
			return this._maxTime;
		};

		/**
		 * @method
		 * @param	{Number}	value
		 */
		LoggerPrototype.setMaxTime = function(value) {
			if ( this._maxTime == value ) return;
			this._maxTime = value;
			updateList( this );
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @override
		 * @param	{Object}	object
		 * @return	{Object}
		 */
		LoggerPrototype.add = function(object) {
			object = LoggerSuperPrototype.add.call( this, object );
			updateList( this );
			return object;
		};

		/**
		 * @method
		 * @override
		 * @throws	{Error}		illegal operation
		 */
		LoggerPrototype.addAt = illegalOperation;

		/**
		 * @method
		 * @override
		 * @param	{Object}	object
		 * @return	{Object}
		 */
		LoggerPrototype.remove = function(object) {
			object = LoggerSuperPrototype.remove.call( this, object );
			updateList( this );
			return object;
		};

		/**
		 * @method
		 * @override
		 * @throws	{Error}		illegal operation
		 */
		LoggerPrototype.removeAt = illegalOperation;

		/**
		 * @method
		 * @override
		 * @throws	{Error}		illegal operation
		 */
		LoggerPrototype.setIndex = illegalOperation;

		/**
		 * @method
		 * @override
		 * @throws	{Error}		illegal operation
		 */
		LoggerPrototype.swap = illegalOperation;

		/**
		 * @method
		 * @override
		 * @throws	{Error}		illegal operation
		 */
		LoggerPrototype.swapAt = illegalOperation;

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		LoggerPrototype.toString = function() {
			return '[Logger object]';
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
		Logger.toString = function() {
			return '[class Logger]';
		};

		return Logger;

	}() );

}