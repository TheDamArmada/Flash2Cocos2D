/*!
 * blooddy/events/event.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.events' );

if ( !blooddy.events.Event ) {

	/**
	 * @class
	 * класс осбытия
	 * @namespace	blooddy.events
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events.Event = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{String}	type			тип события
		 * @param	{Boolean}	cancelable		отменяемо ли соыбтие?
		 */
		var EEvent = function(type, cancelable) {
			this.type = type;
			this.cancelable = cancelable;
		};

		var EEventPrototype = EEvent.prototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Boolean}
		 */
		EEventPrototype._do_cancel = false;


		/**
		 * @private
		 * @type	{Boolean}
		 */
		EEventPrototype._do_stop = false;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * тип события
		 * @type	{String}
		 */
		EEventPrototype.type = null;

		/**
		 * @property
		 * вызыватель события :)
		 * @type	{blooddy.events.EventDispatcher}
		 */
		EEventPrototype.target = null;

		/**
		 * @property
		 * отменяемо ли?
		 * @type	{Boolean}
		 */
		EEventPrototype.cancelable = false;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * клонирует событие.
		 * @return	{blooddy.events.Event}	новое событие
		 */
		EEventPrototype.clone = function() {
			var	c = this.constructor || EEvent,
				event = new c(),
				key;
			for ( key in this ) {
				event[ key ] = this[ key ];
			}
			return event;
		};

		/**
		 * @method
		 * останавливает распостранение.
		 */
		EEventPrototype.stopPropagation = function() {
			this._do_stop = true;
		};

		/**
		 * @method
		 * отменяет событие
		 */
		EEventPrototype.preventDefault = function() {
			if ( this.cancelable ) {
				this._do_cancel = true;
			}
		};

		/**
		 * @method
		 * событие было отменено
		 * @return	{Boolean}
		 */
		EEventPrototype.isDefaultPrevented = function() {
			return this._do_cancel;
		};

		/**
		 * @method
		 * @override
		 * приводит к строковому виду
		 * @return	{String}
		 */
		EEventPrototype.toString = function() {
			var	arr = new Array(),
				i,
				s,
				arr2 = new Array();
			for ( i in this ) arr.push( i );
			for ( i in arr ) {
				if ( typeof this[ arr[ i ] ] == 'function' ) continue;
				s = ( typeof this[ arr[ i ] ] == 'string' );
				arr2.push( arr[ i ] + '=' + ( s ? '"' : '' ) + this[ arr[ i ] ] + ( s ? '"' : '' ) );
			}
			return '[Event ' + arr2.join( ' ' ) + ']';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * конвертирует объект в Event.
		 * @param		object		объект, который надо сконвертировать
		 * @param		{blooddy.events.Event}
		 */
		EEvent.IEvent = function(object) {
			if ( !object || !object.type ) return null;
			else if ( object instanceof EEvent ) return object;
			var	result = new EEvent( object.type, object.cancelable ),
				key;
			for ( key in object ) {
				if ( key in EEventPrototype ) continue;
				result[ key ] = object[ key ];
			}
			return result;
		};

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		EEvent.toString = function() {
			return '[class Event]';
		};

		return EEvent;

	}() );

}