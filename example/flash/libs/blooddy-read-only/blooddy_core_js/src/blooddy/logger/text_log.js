/*!
 * blooddy/logger/text_log.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Logger' );

if ( !blooddy.Logger.TextLog ) {

	blooddy.require( 'blooddy.Logger.Log' );

	/**
	 * @class
	 * @namespace	blooddy
	 * @extends		blooddy.Logger.Log
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Logger.TextLog = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =	blooddy;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{String}	text
		 */
		var TextLog = function(text) {
			TextLog.superPrototype.constructor.call( this );
			this.text = text;
		};

		$.extend( TextLog, $.Logger.Log );

		var TextLogPrototype = TextLog.prototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * @type	{String}
		 */
		TextLogPrototype.text = null;

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
		TextLogPrototype.toString = function() {
			return '[TextLog object]';
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
		TextLog.toString = function() {
			return '[class TextLog]';
		};

		return TextLog;

	}() );

}