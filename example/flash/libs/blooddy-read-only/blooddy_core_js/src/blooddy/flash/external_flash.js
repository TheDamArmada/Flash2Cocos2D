/*!
 * blooddy/flash/external_flash.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.ExternalFlash ) {

	blooddy.require( 'blooddy.events.dom' );

	/**
	 * @class
	 * класс, который умеет общаться с флэш объектами
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.ExternalFlash = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	$ =				blooddy,
			Flash =			$.Flash,
			events =		$.events,
			utils =			$.utils,
			EEvent =		events.Event,

			ObjectPrototype =	Object.prototype,
			ArrayPrototype =	Array.prototype,

			gecko =			$.browser.getGecko(),

			OBJECT =				'object',
			FUNCTION =				'function',
			DISPATCH_EVENT =		'dispatchEvent',
			DISPATCH_ERROR_EVENT =	'dispatchErrorEvent',
			ASYNC_ERROR =			'asyncError',

			_logging =		$.isLogging(),

			_flashs =		new Object(),
			_min_version =	new utils.Version( 8 );

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		var log = function(io, id, methodName, args) {
			if ( gecko && console.dir ) {
				console.groupCollapsed( io + '::' + id + ' %d(%d)', methodName, ( args.length ) );
				console.dir( args );
				console.groupEnd();
			} else {
				console.log( '==============' );
				console.log( io + '::' + id + ' ' + methodName + '(' + ( args.length ) + ')' );
				console.log( args );
				console.log( '--------------' );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 * @param	{String}	id		ID флэшки
		 * @throws	{Error}				object already created
		 */
		var ExternalFlash = function(id) {
			if ( _flashs[ id ] ) throw new Error( 'object already created' );
			_flashs[ id ] = this;
			ExternalFlashSuperPrototype.constructor.call( this, id );

			this.addEventListener( 'init', this, initHandler );

			var app = this;
			events.dom.addEventListener(
				window,
				'unload',
				function() {
					callDispose.call( app, 'dispose' );
				}
			);

		};

		$.extend( ExternalFlash, Flash );

		var	ExternalFlashPrototype =		ExternalFlash.prototype,
			ExternalFlashSuperPrototype =	ExternalFlash.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * @type	{Boolean}
		 */
		ExternalFlashPrototype._inited = false;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var initHandler = function() {
			this.removeEventListener( 'init', this, initHandler );
			this._inited = true;
		};

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var callDispose = function() {
			ExternalFlashPrototype.call.call( this, 'dispose' );
		};

		/**
		 * @private
		 */
		var dispatchEvent = ExternalFlashSuperPrototype.dispatchEvent;

		/**
		 * @private
		 * @param	{blooddy.events.Event}	event
		 * @return	{Boolean}
		 */
		var _dispatchEvent = function(event) {
			var result;
			try {
				result = dispatchEvent.call( this, event );
			} catch ( e ) {
				event = new EEvent( ASYNC_ERROR );
				event.text = e.toString();
				event.error = e;
				dispatchEvent.call( this, event );
			} finally {
				return ( result == null || result );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Boolean}
		 */
		ExternalFlashPrototype.isInitialized = function() {
			if ( !this._inited ) return false;
			var e = this.getElement();
			return ( e && typeof e.__flash__call == FUNCTION );
		};

		/**
		 * @method
		 * вызывает произвольный метод у флэшки
		 * @param	{String}	methodName		имя метода
		 * @return								результат работы метода
		 */
		ExternalFlashPrototype.call = function(methodName) {
			var	e =	this.getElement();
			if ( !e || typeof e.__flash__call != FUNCTION ) return undefined;
			var	args =	ArrayPrototype.slice.call( arguments );

			if ( _logging && window.console ) {
				log( 'output', this._id, methodName, args.slice( 1 ) );
			}

			args.unshift( this._id );
			return e.__flash__call.apply( e, args );
		};

		/**
		 * @method
		 * @override
		 * диспатчит событие у флэшки
		 * @param	{blooddy.events.Event}	event	событие
		 * @return	{Boolean}						true - елси событие завершило работы, false - если было отменено
		 */
		ExternalFlashPrototype.dispatchEvent = function(event) {
			var	o =		new Object(),
				key;
			for ( key in event ) {
				if ( key in EEvent.prototype ) continue;
				o[ key ] = o[ key ];
			}
			return this.call( DISPATCH_EVENT, event.type, event.cancelable, o );
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		ExternalFlashPrototype.dispose = function() {
			callDispose.call( this );
			if ( _flashs[ this._id ] === this ) {
				delete _flashs[ this._id ];
			}
			ExternalFlashSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		ExternalFlashPrototype.toString = function() {
			return '[ExternalFlash id="' + this._id + '"]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * метод, который ловит вызовы флэшек и распределяет по контроллерам.
		 * @param	{String}	id				ID флэшки
		 * @param	{String}	commandName		имя метода
		 * @return	{Object}					результат работы метода
		 */
		ExternalFlash.__flash__call = function(id, commandName) {

			var	flash =	_flashs[ id ];

			if ( !flash ) {
				throw new Error( '' );
			}

			var	a =		arguments,
				event;

			if ( _logging && window.console ) {
				log( ' input', id, commandName, ArrayPrototype.slice.call( a, 2 ) );
			}

			switch ( commandName ) {

				case DISPATCH_EVENT:
				case DISPATCH_ERROR_EVENT:
					if ( a[ 4 ] ) {
						event = a[ 4 ];
						event.type = a[ 2 ];
						event.cancelable = a[ 3 ];
					} else {
						event = new EEvent( a[ 2 ], a[ 3 ] );
					}
					if ( !flash.hasEventListener( a[ 2 ] ) ) {
						if ( commandName == DISPATCH_ERROR_EVENT ) {
							try {
								throw new Error( 'unhandled errorEvent: ' + EEvent.IEvent( event ) );
							} finally {
								return true;
							}
						}
						return true;
					} else {
						if ( a[ 3 ] ) { // синхронное событие
							return _dispatchEvent.call( flash, event );
						} else { // асинхронное событие
							utils.deferredCall( flash, _dispatchEvent, event );
							return true;
						}
					}

				default:
					try {

						if ( typeof flash[ commandName ] != FUNCTION ) {
							throw new Error( 'DefinitionError: method ' + commandName + ' not found' );
						} else {
							return flash[ commandName ].apply(
								flash,
								ArrayPrototype.slice.call( a, 2 )
							);
						}

					} catch ( e ) {
						event = new EEvent( ASYNC_ERROR );
						event.text = e.toString();
						event.error = e;
						dispatchEvent.call( flash, event );
					}

			}

			return undefined;
		};

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML, автоматически прописывая ей некоторые парметры.
		 * @param	{String}				id			ID флэшки
		 * @param	{String}				uri			путь к флэшке
		 * @param	{Number}				width		ширина флэшки
		 * @param	{Number}				height		высота флэшки
		 * @param	{blooddy.utils.Version}	version		минимальная версияплэйера
		 * @param	{Object}				flashvars	переменные лэфшки
		 * @param	{Object}				parameters	параметры флэшки
		 * @param	{Object}				attributes	атрибуты флэшки
		 * @return	{HTMLElement}						Flash-объект
		 */
		ExternalFlash.embedSWF = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			var	key,
				value,
				params =	new Object(),
				fv =		new Object();

			if ( _min_version.compare( Flash.getPlayerVersion() ) >= 0 ) {
				return null;
			}

			if ( parameters && typeof parameters == OBJECT ) {
				for ( key in parameters ) {
					value = parameters[ key ];
					if ( key in ObjectPrototype ) continue;
					switch ( key.toLowerCase() ) {
						case 'flashvars':
						case 'movie':				value = null;	break;
					}
					if ( value == null ) continue;
					params[ key ] = value;
				}
			}
			params.swLiveConnect = true;
			params.allowScriptAccess = 'always';

			if ( flashvars && typeof flashvars == OBJECT ) {
				for ( key in flashvars ) {
					value = flashvars[ key ];
					if ( key in ObjectPrototype ) continue;
					if ( !value ) continue;
					fv[ key ] = value;
				}
			}
			fv.externalID = id;

			return Flash.embedSWF( id, uri, width, height, version, fv, params, attributes );
		};

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML и генерирует контроллер
		 * @param	{String}				id			ID флэшки
		 * @param	{String}				uri			путь к флэшке
		 * @param	{Number}				width		ширина флэшки
		 * @param	{Number}				height		высота флэшки
		 * @param	{blooddy.utils.Version}	version		минимальная версияплэйера
		 * @param	{Object}				flashvars	переменные лэфшки
		 * @param	{Object}				parameters	параметры флэшки
		 * @param	{Object}				attributes	атрибуты флэшки
		 * @return	{blooddy.Flash}						контроллер Flash-объекта
		 */
		ExternalFlash.createFlash = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( ExternalFlash.embedSWF( id, uri, width, height, version, flashvars, parameters, attributes ) ) {
				return ExternalFlash.getFlash( id );
			}
			return null;
		};

		/**
		 * @static
		 * @method
		 * проверяет существование конроллера
		 * @param	{String}	id			ID флэшки
		 * @return	{Boolean}
		 */
		ExternalFlash.hasFlash = function(id) {
			return Boolean( _flashs[ id ] );
		};

		/**
		 * @static
		 * @method
		 * возвращает существующий конроллер, или создаёт новый
		 * @param	{String}						id	ID флэшки
		 * @return	{blooddy.Flash.ExternalFlash}		контроллер Flash-объекта
		 * @throws	{Error}								object already created as "blooddy.Flash"
		 */
		ExternalFlash.getFlash = function(id) {
			var	flash = _flashs[ id ];
			if ( !flash ) {
				if ( Flash.hasFlash( id ) ) throw new Error( 'object already created as "blooddy.Flash"' );
				flash = new ExternalFlash( id );
			}
			return flash;
		};

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		ExternalFlash.toString = function() {
			return '[class ExternalFlash]';
		};

		return ExternalFlash;

	}() );

	/**
	 * @method
	 * @final
	 * глобальный метод, который ловит вызовы флэшек и распределяет по контроллерам.
	 * @param	{String}	id				ID флэшки
	 * @param	{String}	commandName		имя метода
	 * @return	{Object}					результат работы метода
	 */
	var __flash__call = blooddy.Flash.ExternalFlash.__flash__call;

}