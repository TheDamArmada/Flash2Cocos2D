/*!
 * blooddy/flash/flash_proxy.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.Flash' );

if ( !blooddy.Flash.FlashProxy ) {

	blooddy.require( 'blooddy.Flash.ExternalFlash' );

	/**
	 * @class
	 * @namespace	blooddy.Flash
	 * @extends		blooddy.Flash.ExternalFlash
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Flash.FlashProxy = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	$ =				blooddy,

			doc =			window.document,
			html =			doc.getElementsByTagName( 'html' )[0],

			ExternalFlash =	$.Flash.ExternalFlash;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{String}	name
		 */
		var FlashProxy = function(name) {

			// генерируем ID для сокета
			var id = $.createUniqID( name );
			// создаём врменную заглушку, в которую будут вставляться флэшка
			var e = doc.createElement( 'div' );
			e.setAttribute( 'id', id );
			html.insertBefore( e, html.firstChild );

			var f = ExternalFlash.embedSWF( id, $.getRoot() + 'blooddy/flash/' + name + '.swf', 1, 1, 10 );
			if ( f ) {
				f.style.position = 'absolute';
				f.style.left = '-100px';
				f.style.top = '-100px';
				FlashProxySuperPrototype.constructor.call( this, id );
			} else {
				html.removeChild( e );
			}

		};

		$.extend( FlashProxy, ExternalFlash );

		var	FlashProxyPrototype =		FlashProxy.prototype,
			FlashProxySuperPrototype =	FlashProxy.superPrototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @override
		 * подготавливает объект к удалению
		 */
		FlashProxyPrototype.dispose = function() {
			var e = this.getElement();
			FlashProxySuperPrototype.dispose.call( this );
			if ( e ) {
				var p = e.parentNode;
				if ( p ) p.removeChild( e );
			}
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		FlashProxyPrototype.toString = function() {
			return '[FlashProxy id="' + this._id + '"]';
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
		FlashProxy.toString = function() {
			return '[class FlashProxy]';
		};

		return FlashProxy;

	}() );

}