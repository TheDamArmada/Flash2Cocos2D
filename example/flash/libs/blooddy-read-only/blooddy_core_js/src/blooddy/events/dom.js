/*!
 * blooddy/events/dom.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.events' );

if ( !blooddy.events.dom ) {

	/**
	 * @package
	 * @final
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events.dom = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	msie =	blooddy.browser.getMSIE();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Dom = new Function(),
			DomPrototype = Dom.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{HTMLElement}	target
		 * @param	{String}		type
		 * @param	{Function}		func
		 */
		DomPrototype.addEventListener = ( msie
			?	function(target, type, func) {
					target.attachEvent( 'on' + type, func );
				}
			:	function(target, type, func) {
					if ( type == 'mousewheel' ) type = 'DOMMouseScroll';
					target.addEventListener( type, func, false );
				}
		);

		/**
		 * @method
		 * @param	{HTMLElement}	target
		 * @param	{String}		type
		 * @param	{Function}		func
		 */
		DomPrototype.removeEventListener = ( msie
			?	function(target, type, func) {
					target.detachEvent( 'on' + type, func );
				}
			:	function(target, type, func) {
					if ( type == 'mousewheel' ) type = 'DOMMouseScroll';
					target.removeEventListener( type, func, false );
				}
		);

		/**
		 * @method
		 * @return	{String}
		 */
		DomPrototype.toString = function() {
			return '[Dom object]';
		};

		return Dom;

	}() );

}