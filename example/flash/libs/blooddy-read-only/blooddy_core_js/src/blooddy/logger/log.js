/*!
 * blooddy/logger/log.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Logger' );

if ( !blooddy.Logger.Log ) {

	/**
	 * @class
	 * лог
	 * @namespace	blooddy.Logger
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Logger.Log = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var Log = function() {
			this.time = blooddy.utils.getTime();
		};

		var LogPrototype = Log.prototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * @type	{Number}
		 */
		LogPrototype.time = 0;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		LogPrototype.toString = function() {
			return '[Log object]';
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
		Log.toString = function() {
			return '[class Log]';
		};

		return Log;

	}() );

}