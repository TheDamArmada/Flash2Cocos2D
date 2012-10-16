/*!
 * blooddy/template.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

if ( !blooddy.templater ) {

	/**
	 * @property
	 * @namespace	blooddy
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.templater = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		var	$ =			blooddy,
			browser =	$.browser,

			msie =		browser.getMSIE(),

			g_win =		$.getTop(),
			win =		window,
			doc =		win.document,

			_cache_id =		new Object(),
			_cache_uri =	new Object(),

			_rCDATA =		/^\s*<!\[CDATA\[([\S\s]*)\]\]>\s*$/,
			_rExp =			/<%([^\s]+)?\s*([\S\s]*?)\s*%>/g,
			_rQuote =		/"/g,
			_rSpaces =		/\r?\n/g,

			_local =		true,
			_logging =		$.isLogging(),

			SCRIPT_S =		'<script type="text/javascript"',
			SCRIPT_E =		'</script>';

		//--------------------------------------------------------------------------
		//
		//  Classes
		//
		//--------------------------------------------------------------------------

		var Template = ( function() {
			var	d = doc.createElement( 'div' ),
				Template = function(getText) {
					if ( getText ) this.getText = getText;
				},
				TemplatePrototype = Template.prototype;
			TemplatePrototype.getText = function(params) {
				return '';
			};
			TemplatePrototype.createText = function(params) {
				return ( this.getText ? this.getText.call( params, params ) : '' );
			};
			TemplatePrototype.createElement = function(params) {
				var result = doc.createDocumentFragment();
				if ( this.getText ) {
					d.innerHTML = this.createText( params );
					while ( d.firstChild ) result.appendChild( d.firstChild );
				}
				return result;
			};
			TemplatePrototype.toString = function() {
				return '[Template object]';
			};
			Template.toString = function() {
				return '[class Template]';
			};
			return Template;
		}() );

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		if ( !msie && g_win !== window && g_win.blooddy && g_win.blooddy !== $ ) {
			g_win.blooddy.require( 'blooddy.templater' );
			_local = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @param	{String}	str
		 * @return	{String}
		 */
		var replaceText = function(str) {
			return str.replace( _rSpaces, '\\n' ).replace( _rQuote, '\\"' );
		};

		/**
		 * @private
		 * @param	{String}						type
		 * @param	{String}						id
		 * @param	{String}						source
		 * @param	{blooddy.templater.Template}	result
		 */
		var log = function(type, id, source, result) {
			if ( !window.console ) return;
			if ( console.dir ) {
				console.groupCollapsed( 'template ' + type + '="' + id + '"' );
					console.groupCollapsed( 'source' );
					console.log( source );
					console.groupEnd();
				console.log( result );
				if ( result ) console.log( String( result.getText ) );
				console.groupEnd();
			} else {
				console.log( '==============' );
				console.log( source );
				console.log( result );
				console.log( '--------------' );
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
		var Templater =				new Function(),
			TemplaterPrototype =	Templater.prototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * Класс содержащий характеристики браузера
		 * @type	{Function}
		 */
		TemplaterPrototype.Template = Template;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @param	{String}		source
		 * @return	{blooddy.templater.Template}
		 */
		TemplaterPrototype.parseTemplate = function(source) {

			var body = '',
				a,
				l,
				i = 0,
				j,
				h = false,

				/** @param {String} js */
				append = function(js) {
					body += ( h ? '+' : ';$_+=' ) + js;
					h = true;
				},

				/** @param {String} js */
				appendJS = function(js) {
					append( '(' + js + ')' );
				},

				/** @param {String} text */
				appendText = function(text) {
					append( '"' + replaceText( text ) + '"' );
				};

			_rExp.lastIndex = 0;
			while ( a = _rExp.exec( source ) ) {
				j = _rExp.lastIndex;
				l = a[ 0 ].length;
				if ( i != j - l ) {
					appendText( source.substring( i, j - l ) );
				}
				switch ( a[ 1 ] || '' ) {

					case '=':
						appendJS( a[2] );
						break;

					case '':
						body += ( h ? ';' : '' ) + a[2];
						h = false;
						break;

					case '!':
						appendText( SCRIPT_S + '>' + a[2] + SCRIPT_E );
						break;

					case '?':
						appendText( SCRIPT_S + ' src="' );
						appendJS( a[2] );
						appendText( '">' + SCRIPT_E );
						break;

					default:
						throw new Error( 'unknown tag: ' + a[0] );
						break;

				}
				i = j;
			}
			if ( i < source.length ) {
				appendText( source.substr( i ) );
			}

			return new Template(
				new Function(
					'_$',
					'var $_="";with(blooddy.templater)with(_$||{}){try{' + body + '}catch(e){if(window.console)console.log(e)}}return $_'
				)
			);

		};

		/**
		 * @method
		 * @param	{String}	source
		 * @param	{Object}	params
		 * @return	{String}
		 */
		TemplaterPrototype.parse = function(source, params) {
			var tpl = this.parseTemplate( source );
			return ( tpl ? tpl.createText( params ) : '' );
		};

		/**
		 * @method
		 * @param	{String}		id
		 * @return	{blooddy.templater.Template}
		 */
		TemplaterPrototype.getTemplate = function(id) {
			var result = _cache_id[ id ];
			if ( result === undefined ) {
				var	e = document.getElementById( id );
				var t;
				if ( e && e.tagName.toLowerCase() == 'script' ) {
					t = ( msie ? e.text : e.textContent );
					var r = _rCDATA.exec( t );
					if ( r ) t = r[ 1 ];
					result = this.parseTemplate( t );
				}
				if ( _logging ) log( 'id', id, t, ( result || null ) );
				_cache_id[ id ] = result || null;
			}
			return result;
		};

		/**
		 * @method
		 * @param	{String}	id
		 * @param	{Object}	param
		 * @return	{String}
		 */
		TemplaterPrototype.get = function(id, param) {
			var tpl = this.getTemplate( id );
			return ( tpl ? tpl.createText( param ) : '' );
		};

		/**
		 * @method
		 * @param	{String}	uri
		 * @return	{blooddy.templater.Template}
		 */
		TemplaterPrototype.loadTemplate = function(uri) {
			var result = _cache_uri[ uri ];
			if ( result === undefined ) {
				if ( _local ) {
					var	txt = $.getFileContent( uri );
					result = ( txt ? this.parseTemplate( txt ) : null );
					if ( _logging ) log( 'uri', uri, ( txt || null ), result );
				} else {
					result = g_win.blooddy.templater.loadTemplate( uri );
					if ( result ) result = new Template( result.getText );
				}
				_cache_uri[ uri ] = result;
			}
			return result;
		};

		/**
		 * @method
		 * @param	{String}	uri
		 * @param	{Object}	param
		 * @return	{Object}
		 */
		TemplaterPrototype.load = function(uri, param) {
			var tpl = this.loadTemplate( id );
			return ( tpl ? tpl.createText( param ) : '' );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		TemplaterPrototype.toString = function() {
			return '[Templater object]';
		};

		return Templater;

	}() );

}