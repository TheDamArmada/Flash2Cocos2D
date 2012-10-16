/*!
 * blooddy/utils/list.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.List ) {

	blooddy.require( 'blooddy.events.EventDispatcher' );

	/**
	 * @class
	 * @namespace	blooddy.utils
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.List = ( function() {

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

			EE_A =		'added',
			EE_R =		'removed',

			_e1 =		'invalid argument "object"',
			_e2 =		'invalid argument "index"';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var List = function() {
			ListSuperPrototype.constructor.call( this );
			this._list = new Array();
		};

		$.extend( List, $.events.EventDispatcher );

		var	ListPrototype =			List.prototype,
			ListSuperPrototype =	List.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Array}
		 */
		ListPrototype._list = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Number}
		 */
		ListPrototype.getLength = function() {
			return this._list.length;
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @return	{Object}
		 */
		ListPrototype.add = function(object) {
			return ListPrototype.addAt.call( this, object, this._list.length );
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @param	{Number}	index
		 * @return	{Object}
		 * @throws	{Error}				invalid argument "object"
		 * @throws	{Error}				invalid argument "index"
		 */
		ListPrototype.addAt = function(object, index) {
			// проверим наличие передоваемого объекта
			if ( !object || object === this ) throw new Error( _e1 );
			// проверим рэндж
			if ( index < 0 || index > this._list.length ) throw new Error( _e2 );
			// если есть родитель, то надо его отуда удалить
			if ( utils.indexOf( this._list, object ) >= 0 ) {
				$setIndex( this, object, index );
			} else {
				// добавляем
				this._list.splice( index, 0, object );
				if ( this.hasEventListener( EE_A ) ) {
					var	event = new EEvent( EE_A );
					event.value = object;
					event.index = index;
					this.dispatchEvent( event );
				}
			}
			// возвращаем
			return object;
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @return	{Object}
		 */
		ListPrototype.remove = function(object) {
			return ListPrototype.removeAt.call( this, this.getIndex( object ) );
		};

		/**
		 * @method
		 * @param	{Number}	index
		 * @return	{Object}
		 * @throws	{Error}				invalid argument "object"
		 */
		ListPrototype.removeAt = function(index) {
			// проверим рэндж
			if ( index < 0 || index > this._list.length ) throw new Error( _e2 );
			// удалим
			var	object = this._list.splice( index, 1 )[0];
			// обновим
			if ( this.hasEventListener( EE_R ) ) {
				var	event = new EEvent( EE_R );
				event.value = object;
				event.index = index;
				this.dispatchEvent( event );
			}
			// вернём
			return object;
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @return	{Boolean}
		 */
		ListPrototype.has = function(object) {
			return this.getIndex( object ) >= 0;
		};

		/**
		 * @method
		 * @param	{Number}	index
		 * @return	{Object}
		 * @throws	{Error}				invalid argument "index"
		 */
		ListPrototype.getAt = function(index) {
			// проверим рэндж
			if ( index < 0 || index > this._list.length ) throw new Error( _e2 );
			return this._list[ index ];
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @return	{Number}
		 * @throws	{Error}				invalid argument "object"
		 */
		ListPrototype.getIndex = function(object) {
			if ( !object ) throw new Error( _e1 );
			return utils.indexOf( this._list, object );
		};

		/**
		 * @method
		 * @param	{Object}	object
		 * @param	{Number}	index
		 * @throws	{Error}				invalid argument "child"
		 * @throws	{Error}				invalid argument "index"
		 */
		ListPrototype.setIndex = function(object, index) {
			$setIndex( this, object, index, true );
		};

		/**
		 * @private
		 */
		var $setIndex = function(scope, child, index, strict) {
			if ( strict ) {
				if ( !child ) throw new Error( 'invalid argument "child"' );
				// проверим рэндж
				if ( index < 0 || index > scope._list.length ) throw new Error( _e2 );
			}
			scope._list.splice( scope.getIndex( child ), 1 );
			scope._list.splice( index, 0, child );
		};

		/**
		 * @method
		 * @param	{Object}	object1
		 * @param	{Object}	object2
		 * @throws	{Error}				invalid argument "child"
		 */
		ListPrototype.swap = function(object1, object2) {
			$swapAt( this, object1, object2, this.getIndex( object1 ), this.getIndex( object2 ) );
		};

		/**
		 * @method
		 * @param	{Number}	index1
		 * @param	{Number}	index2
		 * @throws	{Error}				invalid argument "index"
		 */
		ListPrototype.swapAt = function(index1, index2) {
			$swapAt( this, this.getAt( index1 ), this.getAt( index2 ), index1, index2 );
		};

		/**
		 * @private
		 */
		var $swapAt = function(scope, object1, object2, index1, index2) {
			// надо сперва поставить того кто выше
			if ( index1 > index2 ) {
				$setIndex( scope, object1, index2, true );
				$setIndex( scope, object2, index1, true );
			} else {
				$setIndex( scope, object2, index1, true );
				$setIndex( scope, object1, index2, true );
			}
		};

		/**
		 * @method
		 * @return	{Array}
		 */
		ListPrototype.getValues = function() {
			return this._list.slice();
		};

		/**
		 * @method
		 * очищает список
		 */
		ListPrototype.clear = function() {
			var l = this._list.length;
			if ( this.hasEventListener( EE_R ) ) {
				while ( l-- ) ListPrototype.removeAt.call( this, l );
			} else {
				this._list.splice( 0, l );
			}
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		ListPrototype.dispose = function() {
			this.clear();
			ListSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		ListPrototype.toString = function() {
			return '[List object]';
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
		List.toString = function() {
			return '[class List]';
		};

		return List;

	}() );

}