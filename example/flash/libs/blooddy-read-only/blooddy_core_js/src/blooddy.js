/*!
 * blooddy.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) {

	/**
	 * @package
	 * @final
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	var blooddy = new ( function() {

		//--------------------------------------------------------------------------
		//
		//  Classes
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @class
		 * @final
		 * Класс содержащий характеристики браузера
		 * @memberOf	blooddy
		 */
		var browser = new ( function() {

			//--------------------------------------------------------------------------
			//
			//  Class variables
			//
			//--------------------------------------------------------------------------

			/**
			 * @private
			 */
			var	_u = navigator.userAgent,

				_msie =		0,
				_opera =	0,
				_gecko =	0,
				_webkit =	0,

				m = _u.match( /AppleWebKit\/([\.\d]*)/ );

			if ( m ) {
				if ( m[1] )	_webkit = parseFloat( m[1] );
				else		_webkit = 1;
			} else if ( ( /KHTML/ ).test( _u ) ) {
				_webkit = 1;
			} else {
				m = _u.match( /Opera[\s\/]([^\s]*)/ );
				if ( m ) {
					if ( m[1] )	_opera = parseFloat( m[1] );
					else		_opera = 1;
				} else {
					m = _u.match( /MSIE\s([^;]*)/ );
					if ( m ) {
						if ( m[1] )	_msie = parseFloat( m[1] );
						else		_msie = 1;
					} else {
						m = _u.match( /Gecko\/([^\s]*)/ );
						if ( m ) {
							m = _u.match( /rv:([\.\d]*)/ );
							if ( m && m[1] )	_gecko = parseFloat( m[1] );
							else				_gecko = 1;
						}
					}
				}
			}

			//--------------------------------------------------------------------------
			//
			//  Constructor
			//
			//--------------------------------------------------------------------------

			/**
			 * @private
			 * @constructor
			 */
			var	Browser = new Function(),
				BrowserPrototype = Browser.prototype;

			//--------------------------------------------------------------------------
			//
			//  Methods
			//
			//--------------------------------------------------------------------------

			/**
			 * @method
			 * получает версию Gecko ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			BrowserPrototype.getGecko = function() {
				return _gecko;
			};

			/**
			 * @method
			 * получает версию AppleWebKit ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			BrowserPrototype.getWebKit = function() {
				return _webkit;
			};

			/**
			 * @method
			 * получает версию Internet Explorer ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			BrowserPrototype.getMSIE = function() {
				return _msie;
			};

			/**
			 * @method
			 * получает версию Opera ( 0 - если не используется )
			 * @return	{Number}	версия
			 */
			BrowserPrototype.getOpera = function() {
				return _opera;
			};

			/**
			 * @method
			 * @return	{String}
			 */
			BrowserPrototype.toString = function() {
				return '[Browser ' +
					' gecko=' +		_gecko +
					' webkit=' +	_webkit +
					' opera=' +		_opera +
					' msie=' +		_msie +
				']';
			};

			return Browser;

		}() );

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		var	win =			window,
			g_win =			win,
			t_win,
			doc =			win.document,
			loc =			win.location,
			t_loc,

			MMath =			Math,

			msie =			browser.getMSIE(),

			_FILENAME =		'blooddy.js',
			_NOTATION =		/([^^\/])([A-Z])/g,

			_incluedes =	new Object(),
			_files =		new Object(),
			_requires =		new Object(),

			_xhr,
			_root,
			_logging =		( win.location.protocol == 'file:' || /(;|^)\s*\$bl=1\s*(;|$)/.test( doc.cookie.toString() ) );

		//--------------------------------------------------------------------------
		//
		//  Static
		//
		//--------------------------------------------------------------------------

		// выдёргиваем максимально глобальное окно
		try {
			while ( ( t_win = g_win.parent ) && t_win !== g_win ) {
				t_loc = t_win.location;
				if ( t_loc.protocol == loc.protocol && t_loc.hostname == loc.hostname ) {
					g_win = t_win;
				} else {
					break;
				}
			}
		} catch ( e ) {
		}

		// инитиализируем request
		if ( msie && win.ActiveXObject ) {
			try {
				_xhr = new ActiveXObject( 'Microsoft.XMLHTTP' )
			} catch ( e ) {
			}
		}
		if ( !_xhr && win.XMLHttpRequest ) {
			_xhr = new XMLHttpRequest();
			if ( _xhr.overrideMimeType ) {
				_xhr.overrideMimeType( 'text/javascript' ); // fix gecko error
			}
		}

		_incluedes[ _FILENAME ] = true;

		// инитиализируем root
		if ( browser.getGecko() ) {
			try {
				_root = ( new Error() ).stack.split( '\n', 2 )[1].match( new RegExp( '@(.+?)' + _FILENAME + ':\\d+' ) )[1];
			} catch ( e ) {
			}
		}
		if ( !_root ) {
			var	scripts = doc.getElementsByTagName( 'script' ),
				i,
				l = scripts.length,
				s,
				index;
			for ( i=l-1; i>=0; i-- ) { // скорее всего мы последний добавленный скрипт
				s = scripts[ i ].src;
				if ( s ) {
					index = s.lastIndexOf( _FILENAME );
					if ( index == s.length - _FILENAME.length ) { // мы себя нашли
						_root = s.substring( 0, index );
						break;
					}
				}
			}
		}
		if ( !_root ) _root = 'js/';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * @constructor
		 */
		var Blooddy = new Function(),
			BlooddyPrototype = Blooddy.prototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * Класс содержащий характеристики браузера
		 * @type	{Object}
		 */
		BlooddyPrototype.browser = browser;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Boolean}
		 */
		BlooddyPrototype.isLogging = function() {
			return _logging;
		};

		/**
		 * @method
		 * @param	{Boolean}	value
		 */
		BlooddyPrototype.setLogging = function(value) {
			doc.cookie = '$bl=' + ( value ? '1; path=/' : '; expires=' + ( new Date( 0 ) ) );
			return _logging = Number( value ) > 0;
		};

		/**
		 * @method
		 * @return	{window}
		 */
		BlooddyPrototype.getTop = function() {
			return g_win;
		};

		/**
		 * @method
		 * наследует один класс от другого
		 * @param	{Function}	Child	класс-ребёнок
		 * @param	{Function}	Parent	класс-родитель
		 */
		BlooddyPrototype.extend = function(Child, Parent) {
			var Proxy = new Function();
			Proxy.prototype = Parent.prototype;
			Child.prototype = new Proxy();
			Child.prototype.constructor = Child;
			Child.superPrototype = Parent.prototype;
		};

		/**
		 * @method
		 * исполняет код вглобальной области видимости
		 * @param	{String}	source	код
		 * @return	{Object}
		 */
		BlooddyPrototype.eval = function(source) {
			//return ( new Function( source ) ).call( win );
			if ( msie ) {
				return win.execScript( source );
			} else {
				return win.eval( source ); // FIXME: выдаёт ошибки в gecko
			}
			/*
			// альтернативный вариант не внушающий доверия
			var	script = document.createElement( 'script' );
			script.type = 'text/javascript';
			script.innerHTML = source;
			document.getElementsByTagName( 'head' )[ 0 ].appendChild( script );
			*/
		};

		/**
		 * @method
		 * синхронно получает содержание файла
		 * @param	{String}	uri		путь к файлу
		 * @return	{String}			содержание файла, или null
		 */
		BlooddyPrototype.getFileContent = function(uri) {
			var	result = _files[ uri ];
			if ( result === undefined ) {
				if ( g_win !== win && g_win.blooddy && g_win.blooddy !== this ) {
					result = g_win.blooddy.getFileContent( uri );
				} else {
					if ( _xhr ) {
						try {
							_xhr.open( 'GET', uri, false );
							_xhr.send( null );
							result = _xhr.responseText || null;
						} catch ( e ) {
						}
					}
				}
				_files[ uri ] = result || null;
			}
			return result;
		};

		/**
		 * @method
		 * синхронно импортирует файл
		 * @param	{String}	uri		путь к файлу
		 * @throws	{Error}				uri not found
		 */
		BlooddyPrototype.include = function(uri) {
			if ( _incluedes[ uri ] ) return; // рание был добавлен
			_incluedes[ uri ] = true;
			var	content = this.getFileContent( uri );
			if ( typeof content != 'string' ) {
				throw new Error( uri + ' not fount.' );
			}
			this.eval( content );
		};

		/**
		 * @method
		 * проверяет наличие объекта.
		 * при его отсутвии пытается его загрузить.
		 * @param	{String}	name	имя класса
		 * @throws	{Error}				object not initialized
		 */
		BlooddyPrototype.require = function(name) {
			var asset = _requires[ name ];
			if ( asset === undefined ) {
				var	arr =	name.split( '.' ),
					o =		win,
					n,
					nn =	'',
					s,
					i,
					l = arr.length;
				asset = true;
				for ( i=0; i<l; i++ ) {
					n = arr[ i ];
					nn = arr.slice( 0, i + 1 ).join( '.' );
					if ( nn in _requires ) {
						asset = _requires[ nn ];
					} else {
						if ( asset ) {
							if ( !( n in o ) ) {
								s = arr.slice( 0, i + 1 ).join( '/' ).replace( _NOTATION, '$1_$2' ).toLowerCase() + '.js';
								this.include( _root + s );
								if ( !( n in o ) ) {
									asset = false;
								}
							}
						}
						_requires[ nn ] = asset;
					}
					if ( asset ) {
						o = o[ n ];
					}
				}
			}
			if ( !asset ) throw new Error( name + ' non initialized.' );
		};

		/**
		 * @method
		 * @param	{String}	name
		 * @return	{Object}
		 */
		BlooddyPrototype.createAbstractInstance = function(name) {
			var InstanceClass = new Function();
			InstanceClass.prototype.toString = function() {
				return '[package ' + name + ']';
			};
			return new InstanceClass();
		};

		/**
		 * @method
		 * @param	{String}	prefix
		 * @return	{String}
		 */
		BlooddyPrototype.createUniqID = function(prefix) {
			var id;
			do {
				id = prefix + '_' + MMath.round( ( new Date() ).getTime() * MMath.random() );
			} while ( doc.getElementById( id ) );
			return id;
		};

		/**
		 * @method
		 * @return	{String}
		 */
		BlooddyPrototype.getRoot = function() {
			return _root;
		};

		/**
		 * @method
		 * @return	{String}
		 */
		BlooddyPrototype.toString = function() {
			return '[package blooddy]';
		};

		return Blooddy;

	}() );

}