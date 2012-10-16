/*!
 * blooddy/flash/socket.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.Socket ) {

	blooddy.require( 'blooddy.Flash.FlashProxy' );

	/**
	 * @class
	 * умеет устанавливать постоянное соединение по бинарному сокету.
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.FlashProxy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.Socket = ( function() {

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
		 * @throws	{Error}				failed to create a flash object
		 */
		var Socket = function() {
			SocketSuperPrototype.constructor.call( this, 'socket' );

			if ( !this.getElement() ) {
				throw new Error( 'failed to create a flash object' );
			}

			// пописываемся на собтия
			this.addEventListener( 'connect', this, connectHandler, Number.POSITIVE_INFINITY );
			this.addEventListener( 'close', this, closeHandler, Number.POSITIVE_INFINITY );

		};

		$.extend( Socket, $.Flash.FlashProxy );

		var	SocketPrototype =		Socket.prototype,
			SocketSuperPrototype =	Socket.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * установилось соединение с сервером
		 * @param	{blooddy.events.Event}	event
		 */
		var connectHandler = function(event) {
			this._connected = true;
		};

		/**
		 * @private
		 * сервер закрыл соединение
		 * @param	{blooddy.events.Event}	event
		 */
		var closeHandler = function(event) {
			this._connected = false;
		};

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @type	{Boolean}
		 */
		SocketPrototype._connected = false;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		SocketPrototype.isConnected = function() {
			return this._connected;
		};

		/**
		 * @method
		 * @override
		 * вызывает произвольный метод у флэшки
		 * @param	{String}	methodName		имя метода
		 * @return								результат работы метода
		 * @throws	{Error}						connection absent
		 */
		SocketPrototype.call = function(methodName) {
			if ( !this._connected )  throw new Error( 'connection absent' );
			return SocketSuperPrototype.call.apply( this, arguments );
		};

		/**
		 * @method
		 * @param	{String}	host
		 * @param	{Number}	port
		 * @param	{Boolean}	proxy
		 */
		SocketPrototype.connect = function(host, port, proxy) {
			if ( this.isInitialized() ) {
				SocketSuperPrototype.call.call( this, 'connect', host, port, proxy );
			} else {
				this.addEventListener(
					'init',
					this,
					function() {
						this.removeEventListener( 'init', this, arguments.callee );
						SocketSuperPrototype.call.call( this, 'connect', host, port, proxy );
					},
					Number.POSITIVE_INFINITY
				);
			}
		};

		/**
		 */
		SocketPrototype.close = function() {
			if ( this._connected ) {
				this._connected = false;
				SocketSuperPrototype.call.call( this, 'close' );
			}
		};

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		SocketPrototype.dispose = function() {
			if ( this._connected ) this.close();
			SocketSuperPrototype.dispose.call( this );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		SocketPrototype.toString = function() {
			return '[Socket id="' + this._id + '"]';
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * @return	{String}
		 */
		Socket.toString = function() {
			return '[class Socket]';
		};

		return Socket;

	}() );

}