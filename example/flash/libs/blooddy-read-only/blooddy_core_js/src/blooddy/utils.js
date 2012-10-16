/*!
 * blooddy/utils.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.utils ) {

	/**
	 * @package
	 * @final
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	browser =	blooddy.browser,
			msie =		browser.getMSIE(),
			webKit =	browser.getWebKit(),
			gecko =		browser.getGecko(),

			win =		window,
			doc =		document,
			doce = 		doc.documentElement;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Utils = new Function(),
			UtilsPrototype = Utils.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{Object}	scope
		 * @param	{Function}	func
		 * @return	{Function}
		 */
		UtilsPrototype.createDelegate = function(scope, func) {
			return function() {
				func.apply( scope, arguments );
			};
		};

		/**
		 * @method
		 * @param	{Object}	scope
		 * @param	{Function}	func
		 * @return	{Function}
		 */
		UtilsPrototype.createDeferredDelegate = ( msie
			?	function(scope, func, onError) {
					return function() {
						var a = arguments;
						setTimeout(
							( onError
								?	function() {
										try {
											func.apply( scope, a );
										} catch ( e ) {
											onError.call( scope, e );
										}
									}
								:	function() {
										func.apply( scope, a );
									}
							),
							1
						);
					};
				}
			:	function(scope, func, onError) {
					var delegate = ( onError
						?	function(args) {
								try {
									func.apply( scope, args );
								} catch ( e ) {
									onError.call( scope, e );
								}
							}
						:	function(args) {
								func.apply( scope, args );
							}
					);
					return function() {
						setTimeout( delegate, 1, arguments );
					};
				}
		);

		/**
		 * @method
		 * @param	{Object}	scope
		 * @param	{Function}	func
		 */
		UtilsPrototype.deferredCall = function(scope, func) {
			var	args =	Array.prototype.slice.call( arguments, 2 );
			if ( args.length <= 0 && !scope ) {
				setTimeout( func, 1 );
			} else if ( msie ) {
				setTimeout(
					function() {
						func.apply( scope, args );
					},
					1
				);
			} else {
				args.unshift(
					( scope ? this.createDelegate( scope, func ) : func ),
					1
				);
				setTimeout.apply( window, args );
			}
		};

		/**
		 * @method
		 * @return	{Number}
		 */
		UtilsPrototype.getTime = function() {
			return ( new Date() ).getTime();
		};

		/**
		 * @method
		 * @param	{String}	value
		 * @return	{String}
		 */
		UtilsPrototype.encodeHTML = function(value) {
			var	result =	'',
				l =			value.length,
				i,
				j =			0,
				r;
			for ( i=0; i<l; i++ ) {
				switch ( value.charAt( i ) ) {
					case '&':	r = '&amp;';	break;
					case '<':	r = '&lt;';		break;
					case '>':	r = '&gt;';		break;
					case '"':	r = '&quot;';	break;
					//case '\'':	r = '&#39;';	break;
				}
				if ( r ) {
					if ( j != i ) result += value.substring( j, i );
					result += r;
					j = i + 1;
					r = null;
				}
			}
			result += value.substr( j );
			return result;
		};

		/**
		 * @method
		 * @param	{String}	value
		 * @return	{String}
		 */
		UtilsPrototype.decodeHTML = function(value) {
			var result =	'',
				l =			value.length,
				i,
				j =			0,
				c,
				r;
			for ( i=0; i<l; i++ ) {
				switch ( value.charAt( i ) ) {
					case '&':
						switch ( value.charAt( i + 1 ) ) {
							case 'q': if ( value.substr( i + 2, 4 ) == 'uot;' )	{ r = '"'; c = 6; } break;
							case 'g': if ( value.substr( i + 2, 2 ) == 't;' )	{ r = '>'; c = 4; } break;
							case 'l': if ( value.substr( i + 2, 2 ) == 't;' )	{ r = '<'; c = 4; } break;
							case 'a': if ( value.substr( i + 2, 3 ) == 'mp;' )	{ r = '&'; c = 5; } break;
						}
						break;

				}
				if ( r ) {
					if ( j != i ) result += value.substring( j, i );
					result += r;
					j = i + c;
					r = null;
				}
			}
			result += value.substr( j );
			return result;
		};

		/**
		 * @method
		 * @param	{Array}		arr
		 * @param	{Object}	o
		 * @return	{Number}
		 */
		UtilsPrototype.indexOf = ( msie
			?	function(arr, o) {
					var l = arr.length,
						i;
					for ( i=0; i<l; i++ ) {
						if ( arr[ i ] === o ) return i;
					}
					return -1;
				}
			:	function(arr, o) {
					return arr.indexOf( o );
				}
		);

		/**
		 * @method
		 * @param	{Array}		arr
		 * @param	{Object}	o
		 * @return	{Number}
		 */
		UtilsPrototype.lastIndexOf = ( msie
			?	function(arr, o) {
					var i = arr.length - 1;
					for ( i; i>=0; i-- ) {
						if ( arr[ i ] === o ) return i;
					}
					return -1;
				}
			:	function(arr, o) {
					return arr.indexOf( o );
				}
		);

		/**
		 * @param {Element} e
		 * @param {Object} e
		 */
		UtilsPrototype.localToGlobal = function(e, p) {
			do {
				p.x += e.offsetLeft;
				p.y += e.offsetTop;
			} while ( e = e.offsetParent );
		};

		/**
		 * @param {Element} e
		 * @param {Object} e
		 */
		UtilsPrototype.globalToLocal = function(e, p) {
			do {
				p.x -= e.offsetLeft;
				p.y -= e.offsetTop;
			} while ( e = e.offsetParent );
		};

		/**
		 * @return {Object}
		 */
		UtilsPrototype.getPageBounds = ( msie
			?	function() {
					return {
						left:	doce.scrollLeft,
						right:	doce.scrollLeft + doce.clientWidth,
						top:	doce.scrollTop,
						bottom:	doce.scrollTop + doce.clientHeight
					};
				}
			:	function() {
					return {
						left:	win.pageXOffset,
						right:	win.pageXOffset + win.innerWidth,
						top:	win.pageYOffset,
						bottom:	win.pageYOffset + win.innerHeight
					};
				}
		);

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		UtilsPrototype.toString = function() {
			return '[package utils]';
		};

		return Utils;

	}() );

}