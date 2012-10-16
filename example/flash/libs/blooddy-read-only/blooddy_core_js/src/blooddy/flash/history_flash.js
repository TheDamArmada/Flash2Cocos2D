/*!
 * blooddy/flash/history_flash.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.HistoryFlash ) {

	blooddy.require( 'blooddy.Flash.ExternalFlash' );
	blooddy.require( 'blooddy.utils.history' );

	/**
	 * @class
	 * класс работает с историей страницы и передаёт информацию флэшке
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.ExternalFlash
	 * @requires	blooddy.utils.history
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.HistoryFlash = ( function() {

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
			ExternalFlash =	Flash.ExternalFlash,
			history =		$.utils.history,

			_flashs =		new Object();

		//-------------------------------------------------------------------------
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
		var HistoryFlash = function(id) {
			if ( _flashs[ id ] ) throw new Error( 'object already created' );
			_flashs[ id ] = this;
			HistoryFlashSuperPrototype.constructor.call( this, id );
			if ( this.isInitialized() ) {
				initHandler.call( this );
			} else {
				this.addEventListener( 'init', this, initHandler );
			}
		};

		$.extend( HistoryFlash, ExternalFlash );

		var	HistoryFlashPrototype =			HistoryFlash.prototype,
			HistoryFlashSuperPrototype =	HistoryFlash.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Event handlres
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var initHandler = function() {
			history.addEventListener( 'change', this, changeHandler );
			var href = history.getHREF();
			if ( href ) {
				changeHandler.call( this );
			}
		};

		/**
		 * @private
		 */
		var changeHandler = function() {
			this.dispatchEvent.call( this, new $.events.Event( 'historyChange' ) );
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @see		blooddy.utils.history#isAvailable()
		 * @return	{Boolean}
		 */
		HistoryFlashPrototype.isHistoryAvailable = function() {
			return history.isAvailable();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#back()
		 */
		HistoryFlashPrototype.back = function() {
			history.back();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#forward()
		 */
		HistoryFlashPrototype.forward = function() {
			history.forward();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#go()
		 * @param	{Number}
		 */
		HistoryFlashPrototype.go = function(delta) {
			history.go( delta );
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#up()
		 */
		HistoryFlashPrototype.up = function() {
			history.up();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#getHREF()
		 * @return	{String}
		 */
		HistoryFlashPrototype.getHREF = function() {
			return history.getHREF();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#setHREF()
		 * @param	{String}	value
		 */
		HistoryFlashPrototype.setHREF = function(value) {
			history.setHREF( value );
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#getTitle()
		 * @return	{String}
		 */
		HistoryFlashPrototype.getTitle = function() {
			return history.getTitle();
		};

		/**
		 * @method
		 * @see		blooddy.utils.history#setTitle()
		 * @param	{String}
		 */
		HistoryFlashPrototype.setTitle = function(value) {
			history.setTitle( value );
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		HistoryFlashPrototype.dispose = function() {
			history.removeEventListener( 'change', this );
			if ( _flashs[ this._id ] === this ) {
				delete _flashs[ this._id ];
			}
			HistoryFlashSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		HistoryFlashPrototype.toString = function() {
			return '[HistoryFlash id="' + this._id + '"]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * Вставляет флэшку в HTML и генерирует контроллер
		 * @param	{String}						id			ID флэшки
		 * @param	{String}						uri			путь к флэшке
		 * @param	{Number}						width		ширина флэшки
		 * @param	{Number}						height		высота флэшки
		 * @param	{blooddy.utils.Version}			version		минимальная версияплэйера
		 * @param	{Object}						flashvars	переменные лэфшки
		 * @param	{Object}						parameters	параметры флэшки
		 * @param	{Object}						attributes	атрибуты флэшки
		 * @return	{blooddy.Flash.HistoryFlash}				контроллер Flash-объекта
		 */
		HistoryFlash.createFlash = function(id, uri, width, height, version, flashvars, parameters, attributes) {
			if ( ExternalFlash.embedSWF( id, uri, width, height, version, flashvars, parameters, attributes ) ) {
				return HistoryFlash.getFlash( id );
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
		HistoryFlash.hasFlash = function(id) {
			return Boolean( _flashs[ id ] );
		};

		/**
		 * @static
		 * @method
		 * возвращает существующий конроллер, или создаёт новый
		 * @param	{String}						id	ID флэшки
		 * @return	{blooddy.Flash.HistoryFlash}		контроллер Flash-объекта
		 * @throws	{Error}								object already created as "blooddy.Flash"
		 */
		HistoryFlash.getFlash = function(id) {
			var flash = _flashs[ id ];
			if ( !flash ) {
				if ( Flash.hasFlash( id ) ) throw new Error( 'object already created as "blooddy.Flash"' );
				flash = new HistoryFlash( id );
			}
			return flash;
		};

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		HistoryFlash.toString = function() {
			return '[class HistoryFlash]';
		};

		return HistoryFlash;

	}() );

}