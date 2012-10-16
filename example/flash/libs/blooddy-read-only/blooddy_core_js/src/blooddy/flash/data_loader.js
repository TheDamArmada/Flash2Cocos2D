/*!
 * blooddy/flash/data_loader.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.dataLoader ) {

	blooddy.require( 'blooddy.Flash.FlashProxy' );

	/**
	 * @property
	 * @final
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.FlashProxy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.dataLoader = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =		blooddy,
			Flash =	$.Flash;

		//--------------------------------------------------------------------------
		//
		//  Classes
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @class
		 * @final
		 */
		var Responder = ( function() {

			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------

			/**
			 * @private
			 * @constructor
			 */
			var	Responder =				new Function(),
				ResponderPrototype =	Responder.prototype;

			//--------------------------------------------------------------------------
			//
			//  Variables
			//
			//--------------------------------------------------------------------------

			/**
			 * @private
			 * @type	{Number}
			 */
			ResponderPrototype.id = null;

			//--------------------------------------------------------------------------
			//
			//  Properties
			//
			//--------------------------------------------------------------------------

			/**
			 * @property
			 * @type	{Function}
			 */
			ResponderPrototype.onData = null;

			/**
			 * @property
			 * @type	{Function}
			 */
			ResponderPrototype.onFail = null;

			//--------------------------------------------------------------------------
			//
			//  Class methods
			//
			//--------------------------------------------------------------------------

			/**
			 * @method
			 */
			ResponderPrototype.close = function() {
				if ( _inited ) {
					Flash.dataLoader.call( 'close', this.id );
				}
			};

			/**
			 * @method
			 * @return	{String}
			 */
			ResponderPrototype.toString = function() {
				return '[Responder id=' + this.id + ']';
			};

			return Responder;

		}() );

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	_loaders =	new Object(),
			_r20 =		/%20/g,
			_inited =	false,
			_cache =	new Array();

		//--------------------------------------------------------------------------
		//
		//  Class private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	{Object}	o
		 * @return	{String}
		 */
		var serialize = function(o) {
			switch ( typeof o ) {
				case 'string':		return o;
				case 'number':
				case 'boolean':		return o.toString();
				case 'xml':			return o.toXMLString();
				default:
					var a = new Array();
					for ( var i in o ) {
						if ( o[ i ] != null ) {
							a.push( encodeURIComponent( i ) + '=' + encodeURIComponent( o[ i ] ) );
						}
					}
					return a.join( '&' ).replace( _r20, '+' );
			}
		};

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var DataLoader = function() {
			DataLoader.superPrototype.constructor.call( this, 'data_loader' );
			this.addEventListener( 'init', this, initHandler, Number.POSITIVE_INFINITY );
			this.addEventListener( 'complete', this, completeHandler, Number.POSITIVE_INFINITY );
			this.addEventListener( 'ioError', this, errorHandler, Number.POSITIVE_INFINITY );
			this.addEventListener( 'securityError', this, errorHandler, Number.POSITIVE_INFINITY );
		};

		$.extend( DataLoader, Flash.FlashProxy );

		var	DataLoaderPrototype = DataLoader.prototype;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{blooddy.events.Event}	event
		 */
		var initHandler = function(event) {
			this.removeEventListener( 'init', this, initHandler );
			_inited = true;
			var l = _cache.length;
			while ( l-- ) {
				load.apply( this, _cache.pop() );
			}
		};

		/**
		 * @private
		 * @param	{blooddy.events.Event}	event
		 */
		var completeHandler = function(event) {
			if ( !( event.id in _loaders ) ) return;
			var	responder = _loaders[ event.id ];
			delete _loaders[ event.id ];
			if ( responder.onData ) responder.onData( event.data );
		};

		/**
		 * @private
		 * @param	{blooddy.events.Event}	event
		 */
		var errorHandler = function(event) {
			if ( !( event.id in _loaders ) ) return;
			var	responder = _loaders[ event.id ];
			delete _loaders[ event.id ];
			if ( responder.onFail ) responder.onFail( event.text );
		};

		/**
		 * @private
		 */
		var load = function(responder, uri, getContent, postContent) {
			var id = this.call(
				'load',
				uri,
				( getContent ? serialize( getContent ) : null ),
				( postContent ? serialize( postContent ) : null )
			);
			if ( !id ) throw new Error( 'something wrong' );
			_loaders[ id ] = responder;
			responder.id = id;
		};

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}	uri
		 * @param	{String}	getContent
		 * @param	{String}	postContent
		 */
		DataLoaderPrototype.load = function(uri, getContent, postContent) {
			var responder = new Responder();
			if ( _inited ) {
				load.call( this, responder, uri, getContent, postContent );
			} else {
				Array.prototype.unshift.call( arguments, responder );
				_cache.push( arguments );
			}
			return responder;
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		DataLoaderPrototype.toString = function() {
			return '[DataLoader id="' + this._id + '"]';
		};

		return DataLoader;

	}() );

}