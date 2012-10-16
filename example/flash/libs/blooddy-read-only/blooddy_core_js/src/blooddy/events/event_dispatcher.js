/*!
 * blooddy/events/event_dispatcher.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.events.EventDispatcher ) {

	blooddy.require( 'blooddy.events.Event' );

	/**
	 * @class
	 * базовый класс для работы с событиями
	 * @namespace	blooddy.events
	 * @requires	blooddy.events.Event
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.events.EventDispatcher = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	EEvent = blooddy.events.Event,

			FUNCTION =			'function';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Object}	target		контекст событий
		 */
		var EventDispatcher = function(target) {
			this._listeners = new Object();
			this._event_target = ( target || this );
		};

		var EventDispatcherPrototype = EventDispatcher.prototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @property
		 * @type	{Object}
		 */
		EventDispatcherPrototype._listeners = null;

		/**
		 * @private
		 * @property
		 * @type	{Object}
		 */
		EventDispatcherPrototype._event_target = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * добавляет новго слушателя
		 * @param	{String}			type		тип события
		 * @param	{Object}			scope		контекст слушателя
		 * @param	{String|Function}	listener	слушатель
		 * @param	{Number}			priority	приоритет
		 */
		EventDispatcherPrototype.addEventListener = function(type, scope, listener, priority) {
			if ( !type || ( ( typeof listener != 'string' || !scope ) && typeof listener != FUNCTION ) ) return;
			if ( isNaN( priority ) ) priority = 0;
			var	arr = this._listeners[ type ];
			if ( arr ) {
				//проверить, есть ли уже такой листенер, и не дать подписаться второй раз
				var	i =		0,
					l =		arr.length,
					o,
					ot,
					index =	l;
				for ( ; i < l; i++ ) {
					o = arr[ i ];
					if ( o.s == scope && o.l === listener ) {
						if ( o.p === priority ) return; // всё и так ништяк
						ot = o;
						arr.splice( i, 1 );
						l--;
						i--;
						break;
					}
					if ( o.p < priority ) {
						index = i;
						break;
					}
				}
				if ( !ot ) {
					for ( ; i < l; i++ ) {
						o = arr[ i ];
						if ( o.s == scope && o.l === listener ) {
							if ( o.p === priority ) return; // всё и так ништяк
							ot = o;
							arr.splice( i, 1 );
							break;
						}
					}
					if ( !ot ) {
						ot = {
							s: ( scope || null ),
							l: listener
						}
					}
				} else {
					if ( index == l ) {
						for ( ; i < l; i++ ) {
							if ( o.p < priority ) {
								index = i;
								break;
							}
						}
					}
				}

				ot.p = priority;

				arr.splice( index, 0, ot );
			} else {
				this._listeners[ type ] = new Array( {
					p: priority,
					s: ( scope || null ),
					l: listener
				} );
			}
		};

		/**
		 * @method
		 * удаляет слушателя
		 * @param	{String}			type		тип события
		 * @param	{Object}			scope		контекст слушателя
		 * @param	{String|Function}	listener	слушатель
		 */
		EventDispatcherPrototype.removeEventListener = function(type, scope, listener) {
			var	arr =	this._listeners[ type ];
			if ( !arr ) return;
			var	l =		arr.length,
				i =		0,
				o;
			if ( scope ) {
				if ( listener ) {
					for ( ; i<l; i++ ) {
						o = arr[ i ];
						if ( o.s == scope && o.l == listener ) {
							arr.splice( i, 1 );
							break;
						}
					}
				} else {
					for ( ; i<l; i++ ) {
						o = arr[ i ];
						if ( o.s == scope ) {
							arr.splice( i, 1 );
							i--;
							l--;
						}
					}
				}
			} else {
				if ( typeof listener == FUNCTION ) {
					for ( ; i<l; i++ ) {
						o = arr[ i ];
						if ( !o.s && o.l === listener ) {
							arr.splice( i, 1 );
							break;
						}
					}
				}
			}
			if ( arr.length <= 0 ) delete this._listeners[ type ];
		};

		/**
		 * @method
		 * распотраняет событие
		 * @param	{blooddy.events.Event}	event	событие
		 * @return	{Boolean}						true - елси событие завершило работы, false - если было отменено
		 */
		EventDispatcherPrototype.dispatchEvent = function(event) {
			if ( !( event instanceof EEvent ) ) event = EEvent.IEvent( event );
			event.target = this._event_target;
			var	arr = this._listeners[ event.type ];
			if ( arr ) {
				var	o,
					l =	arr.length;
				if ( l > 1 ) {
					var	arrc = arr.slice(), // копируем, чтобы удаление на нас не повлияло
						e, i;
					for ( i=0; i<l; i++ ) {
						o = arrc[i];
						e = event.clone();
						if ( typeof o.l == FUNCTION ) {
							o.l.call( o.s, e );
						} else if ( o.s && typeof o.s[ o.l ] == FUNCTION ) {
							o.s[ o.l ]( e );
						} else {
							arr.splice( i, 1 );
							arrc.splice( i--, 1 );
							l--;
							continue;
						}
						// нас отменили. надо превать распостранение события
						if ( event.cancelable && e.isDefaultPrevented() ) {
							return false;
						}
						if ( e._do_stop ) {
							return true; // выход из цикла
						}
					}
					if ( arrc.length <= 0 ) delete this._listeners[ event.type ];
				} else {
					o = arr[ 0 ];
					e = event.clone();
					if ( typeof o.l == FUNCTION ) {
						o.l.call( o.s, event );
					} else if ( typeof o.s[ o.l ] == FUNCTION ) {
						o.s[ o.l ]( event );
					} else {
						delete this._listeners[ event.type ];
					}
					// нас отменили. надо превать распостранение события
					if ( event.cancelable && e.isDefaultPrevented() ) {
						return false;
					}
				}
			}
			return true;
		};

		/**
		 * @method
		 * проверяет наличие слушателя
		 * @param	{String}	type	тип события
		 * @return	{Boolean}
		 */
		EventDispatcherPrototype.hasEventListener = function(type) {
			return ( type in this._listeners );
		};

		/**
		 * @method
		 * подготавливает объект к удалению
		 */
		EventDispatcherPrototype.dispose = function() {
			this._event_target = null;
			var arr,
				i;
			for ( i in this._listeners ) {
				arr = this._listeners[ i ];
				arr.splice( 0, arr.length );
				delete this._listeners[ i ];
			}
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		EventDispatcherPrototype.toString = function() {
			return '[EventDispatcher ' +
				( this._event_target !== this ? '(' + this._event_target + ')' : 'object' ) +
			']';
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
		EventDispatcher.toString = function() {
			return '[class EventDispatcher]';
		};

		return EventDispatcher;

	}() );

}