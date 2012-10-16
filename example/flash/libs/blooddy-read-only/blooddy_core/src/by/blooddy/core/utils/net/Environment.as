////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.net {

	import flash.external.ExternalInterface;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.09.2010 16:52:08
	 */
	public class Environment {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const MSIE:String =		'Microsoft Internet Explorer';

		public static const FIREFOX:String =	'Firefox';

		public static const CHROME:String =		'Chrome';

		public static const SAFARI:String =		'Safari';

		public static const OPERA:String =		'Opera';

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _browserName:String;

		public static function get browserName():String {
			return _browserName;
		}

		/**
		 * @private
		 */
		private static var _browserVersion:String;

		public static function get browserVersion():String {
			return _browserVersion;
		}

		//--------------------------------------------------------------------------
		//
		//  Private class methids
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function init():void {
			if ( ExternalInterface.available ) {

				var o:Object;
				try {
					o = ExternalInterface.call(
						'function(){' +
							'try{' +
								'var w=window,n=w.navigator;' +
								'return{' +
									'an:n.appName,' +
									'av:n.appVersion,' +
									'ua:n.userAgent,' +
									'op:(w.opera?w.opera.version():0)' +
								'}' +
							'}catch(e){' +
							'}' +
						'}'
					);
				} catch ( e:* ) {
				}

				if ( o ) {

					var m:Array;

					if ( o.op ) {

						_browserName = OPERA;
						_browserVersion = o.op;

					} else if ( ( m = o.ua.match( /(Chrome|Firefox)\/([\d\.]+)/ ) ) ) {

						_browserName = m[ 1 ];
						_browserVersion = m[ 2 ];

					} else if ( ( m = o.ua.match( /(Safari|Opera)/ ) ) ) {

						_browserName = m[ 1 ];
						m = o.ua.match( /Version\/([\d\.]+)/ );
						if ( m ) _browserVersion = m[ 1 ];

					} else if ( ( m = o.ua.match( /MSIE ([\d\.]+)/ ) ) ) {

						_browserName = MSIE;
						_browserVersion = m[ 1 ];

					} else {

						_browserName = o.an;
						m = o.av.match( /([\d\.]+)/ );
						if ( m ) _browserVersion = m[ 1 ];

					}

				}
			}
		}
		init();

	}

}