/*!
 * blooddy/ajax.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.Ajax ) {

	blooddy.require( 'blooddy.utils' );

	/**
	 * @class
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.Ajax = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =			blooddy,

			win =		window,
			doc =		document,
			loc =		win.location,
			head =		doc.getElementsByTagName( 'head' )[0],

			_r20 =		/%20/g,
			_rURI =		/^(\w+:)\/\/([^\/?#]*)(\/[^?#]*)?(\?[^#]*)?(#.+)?/;

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @return	{XMLHttpRequest}
		 */
		var createXHR = ( win.XMLHttpRequest
			?	function() {
					var	result = new XMLHttpRequest();
					if ( result.overrideMimeType ) {
						result.overrideMimeType( 'text/plain' ); // fix gecko error
					}
					return result;
				}
			:	( $.browser.getMSIE() && win.ActiveXObject
					?	function() {
							try {
								return new ActiveXObject( 'Microsoft.XMLHTTP' )
							} catch ( e ) {
							}
							return null;
						}
				   :	function() {
							return null;
						}
				)
		);

		/**
		 * @param	{Object}	key
		 * @param	{Object}	value
		 * @return	{String}
		 */
		var serializePar = function(key, value) {
			return encodeURIComponent( key ) + '=' + encodeURIComponent( value );
		};

		/**
		 * @param	{Object}	o
		 * @return	{String}
		 */
		var serialize = function(o) {
			var	result =	new Array(),
				i;
			if ( o instanceof Array ) { // массив записываем без ключей
				var	a = o.slice(),
					l =	a.length;
				while ( l > 0 && a[ l-1 ] == null ) l--; // отсекаем последнии пустые элементы
				for ( i=0; i<l; i++ ) {
					result.push( a[ i ] == null ? '' : encodeURIComponent( a[ i ] ) );
				}
				for ( i in o ) {
					if ( !( i in a ) && o[ i ] != null ) {
						result.push( serializePar( i, o[ i ] ) );
					}
				}
			} else {
				for ( i in o ) {
					if ( o[ i ] != null ) {
						result.push( serializePar( i, o[ i ] ) );
					}
				}
			}
			return result.join( '&' );
		};

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Ajax = function() {
		};

		var	AjaxPrototype = Ajax.prototype;

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		AjaxPrototype._xhr = null;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}	uri
		 * @param	{Object}	content
		 * @param	{String}	method
		 * @param	{Array}		headers
		 */
		AjaxPrototype.open = function(uri, content, method, headers) {
			method = ( method ? method.toUpperCase() : 'GET' );
			var	loc2 =			uri.match( _rURI ),
				remote =		( loc2[ 1 ] != loc.protocol || loc2[ 2 ] != loc.host ),
				contentType;
			if ( remote && method != 'GET' ) throw new Error( 'cross-domain request avaible only with "GET" method' );
			if ( content != null ) {
				switch ( typeof content ) {
					case 'string':
						break;
					case 'number':
					case 'boolean':
						content = content.toString();
						break;
					case 'xml':
						content = content.toString();
						contentType = 'text/xml';
						break;
					default:
						content = serialize( content );
						contentType = 'application/x-www-form-urlencoded';
						break;
				}
			}
			if ( content && content.length > 0 ) {
				content = content.replace( _r20, '+' );
				if ( method == 'GET' ) { // ������ ���� � ������ �������
					if ( loc2[ 4 ] || loc2[ 5 ] ) {
						loc2[ 4 ] = '?' + content + ( loc2[ 4 ] && loc2[ 4 ].length > 1 ? '&' + loc2[ 4 ].substr( 1 ) : '' );
						uri = loc2[ 1 ] + '//' + loc2[ 2 ] + loc2[ 3 ] + loc2[ 4 ] + ( loc2[ 5 ] || '' );
					} else {
						uri += '?' + content;
					}
					content = null;
				} else if ( !contentType ) {
					contentType = 'text/plain';
				}
				if ( uri.length > 2048 ) {
					throw new Error( 'long URI' );
				}
			} else {
				content = null;
			}
			if ( remote ) {

				var e = doc.createElement( 'script' );
				e.setAttribute( 'src', uri );
				e.onload = function() {
					alert( this );
				}
				head.insertBefore( e, head.firstChild );

			} else {
				this._xhr = createXHR();
				this._xhr.open( method, uri, true );
				try {
					this._xhr.setRequestHeader( 'Accept', 'text/plain' );
					if ( content) {
						this._xhr.setRequestHeader( 'Content-Type', contentType );
						this._xhr.setRequestHeader( 'Content-Length', content.length );
					}
				} catch ( e ) {
				}
				this._xhr.onreadystatechange = $.utils.createDelegate( this, onReadyStateChange );
				try {
					this._xhr.send( content || null );
				} catch ( e ) {
					alert( e );
				}
			}
		};

		var onReadyStateChange = function() {
			console.dir( [ this._xhr.readyState, this._xhr.responseText ] );
		};

		/**
		 * @method
		 */
		AjaxPrototype.close = function() {
			this._xhr.abort();
		};

		/**
		 * @return	{String}
		 */
		AjaxPrototype.toString = function() {
			return '[Ajax object]';
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
		Ajax.toString = function() {
			return '[class Ajax]';
		};

		return Ajax;

	}() );

}