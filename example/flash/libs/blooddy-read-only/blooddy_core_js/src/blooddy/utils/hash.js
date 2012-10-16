/*!
 * blooddy/utils/hash.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.Hash ) {

	blooddy.require( 'blooddy.events.EventDispatcher' );

	/**
	 * @class
	 * @namespace	blooddy.utils
	 * @extends		blooddy.events.EventDispatcher
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.Hash = ( function() {

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

			EE_A =		'added',
			EE_R =		'removed',

			_e1 =		'invalid argument "key"';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var Hash = function() {
			HashSuperPrototype.constructor.call( this );
			this._hash = new Object();
		};

		$.extend( Hash, $.events.EventDispatcher );

		var	HashPrototype =			Hash.prototype,
			HashSuperPrototype =	Hash.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Object}
		 */
		HashPrototype._hash = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}	key
		 * @param	{Object}	object
		 * @return	{Object}
		 * @throws	{Error}					invalid argument "key"
		 */
		HashPrototype.add = function(key, object) {
			if ( !key ) throw new Error( _e1 );
			// проверим наличие передоваемого объекта
			if ( object == null ) {
				this.remove( key );
			} else {
				if ( this._hash[ key ] ) {
					this.remove( key );
				}
				// добавляем
				this._hash[ key ] = object;
				if ( this.hasEventListener( EE_A ) ) {
					var	event = new EEvent( EE_A );
					event.key = key;
					event.value = object;
					this.dispatchEvent( event );
				}
			}
			return object;
		};

		/**
		 * @method
		 * @param	{String}	key
		 * @return	{Object}
		 * @throws	{Error}				invalid argument "key"
		 * @throws	{Error}				object with key absent
		 */
		HashPrototype.remove = function(key) {
			if ( !key ) throw new Error( _e1 );
			// удалим
			var	object = this._hash[ key ];
			// проверим наличие передоваемого объекта
			if ( object == null ) throw new Error( 'object with key "' + key + '" absent' );
			delete this._hash[ key ];
			// обновим
			if ( this.hasEventListener( EE_R ) ) {
				var	event = new EEvent( EE_R );
				event.key = key;
				event.value = object;
				this.dispatchEvent( event );
			}
			// вернём
			return object;
		};

		/**
		 * @method
		 * @param	{Object}	key
		 * @return	{Boolean}
		 */
		HashPrototype.has = function(key) {
			return this._hash[ key ] != null;
		};

		/**
		 * @method
		 * @param	{String}	key
		 * @return	{Object}
		 */
		HashPrototype.get = function(key) {
			return this._hash[ key ] || null;
		};

		/**
		 * @method
		 * @return	{Array}
		 */
		HashPrototype.getKeys = function() {
			var	result = 	new Array(),
				key;
			for ( key in this._hash ) {
				result.push( key );
			}
			return result;
		};

		/**
		 * @method
		 * @return	{Array}
		 */
		HashPrototype.getValues = function() {
			var	result = 	new Array(),
				key;
			for ( key in this._hash ) {
				result.push( this._hash[ key ] );
			}
			return result;
		};

		/**
		 * @method
		 * очищает хэш
		 */
		HashPrototype.clear = function() {
			var	key;
			if ( this.hasEventListener( EE_R ) ) {
				for ( key in this._hash ) {
					this.remove( key );
				}
			} else {
				for ( key in this._hash ) {
					delete this._hash[ key ];
				}
			}
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		HashPrototype.dispose = function() {
			this.clear();
			HashSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		HashPrototype.toString = function() {
			return '[Hash object]';
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
		Hash.toString = function() {
			return '[class Hash]';
		};

		return Hash;

	}() );

}