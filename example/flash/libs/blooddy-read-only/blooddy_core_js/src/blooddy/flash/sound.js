/*!
 * blooddy/flash/sound.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.sound ) {

	/**
	 * @property
	 * @final
	 * экзэмпляр класса Sound.
	 * умеет проигрывать звуки при помощи флэша
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.FlashProxy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.sound = new ( function() {

		// short cuts
		var	$ =	blooddy;

		blooddy.require( 'blooddy.Flash.FlashProxy' );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var Sound = function() {
			Sound.superPrototype.constructor.call( this, 'sound' );
		};

		$.extend( Sound, $.Flash.FlashProxy );

		var	SoundPrototype = Sound.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}	uri
		 */
		SoundPrototype.load = function(uri) {
			this.call( 'load', uri );
		};

		/**
		 * @method
		 * @param	{String}	uri
		 * @param	{Number}	startTime
		 * @param	{Number}	loops
		 * @param	{Object}	transform
		 * @param	{Boolean}	afterLoad
		 * @return	{Number}	id
		 */
		SoundPrototype.loadAndPlay = function(uri, startTime, loops, transform, afterLoad) {
			return this.call( 'loadAndPlay', uri, startTime, loops, transform, afterLoad );
		};

		/**
		 * @method
		 * @param	{String}	uri
		 * @param	{Number}	startTime
		 * @param	{Number}	loops
		 * @param	{Object}	transform
		 * @return	{Number}	id
		 */
		SoundPrototype.play = function(uri, startTime, loops, transform) {
			return this.call( 'play', uri, startTime, loops, transform );
		};

		/**
		 * @method
		 * @param	{Number}	id
		 */
		SoundPrototype.stop = function(id) {
			this.call( 'stop', id );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		SoundPrototype.toString = function() {
			return '[Sound id="' + this._id + '"]';
		};

		return Sound;

	}() );

}