////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.net {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.02.2010 0:00:41
	 */
	public final class URLUtils {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _BACKWARD:RegExp = /^(?:\.{1,2}\/+)+/;

		/**
		 * @private
		 */
		private static const _BACKWARDS:RegExp = /\.\.\//g;

		/**
		 * @private
		 */
		private static const _N_DYNAMIC:RegExp = /\/\[\[DYNAMIC\]\]\/.*$/;

		/**
		 * @private
		 */
		private static const _N_IMPORT:RegExp = /^(\w+:\/\/).*?\/\[\[IMPORT\]\]\//;

		/**
		 * @private
		 */
		private static const _N_DISK:RegExp = /^file:\/\/\/(\w)\|/i;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function normalizeURL(url:String):String {
			return decodeURIComponent( url ).replace( _N_DISK, 'file://$1:' ).replace( _N_DYNAMIC, '' ).replace( _N_IMPORT, '$1' );
		}

		public static function getPathURL(url:String):String {
			var loc:Location = new Location( url );
			if ( loc.path ) {
				var i:int = loc.path.lastIndexOf( '/' );
				if ( i > 0 && i < loc.path.length - 1 ) {
					loc.path = loc.path.substring( 0, i + 1 );
				}
			}
			loc.search = null;
			loc.hash = null;
			return loc.toString();
		}

		public static function createAbsoluteURL(relativeRoot:String, relativeURL:String):String {

			var urlLoc:Location = new Location( relativeURL );
			if ( urlLoc.host ) return relativeURL;

			var loc:Location = new Location( relativeRoot );
			if ( loc.search || loc.hash ) {
				throw new URIError( 'invalid root url' );
			}
			if ( !loc.path ) {
				loc.path = '/';
			} else if ( loc.path.charAt( loc.path.length - 1 ) != '/' ) {
				throw new URIError( 'invalid root url' );
			}

			if ( urlLoc.path.charAt( 0 ) == '/' ) { // урыл просится начинаться с рута
				loc.path = urlLoc.path;
			} else {
				var arr:Array = urlLoc.path.match( _BACKWARD );
				if ( arr ) {
					var slashIndex:uint = arr[ 0 ].length;
					arr = arr[ 0 ].match( _BACKWARDS );
					if ( arr ) {
						var backs:uint = arr.length;
						arr = loc.path.split( '/' );
						if ( arr.length - 2 <= backs ) {
							loc.path = '/';
						} else {
							arr.splice( arr.length - backs - 1, backs );
							loc.path = arr.join( '/' );
						}
					}
					loc.path += urlLoc.path.substr( slashIndex );
				} else {
					loc.path += urlLoc.path;
				}
			}
			loc.search = urlLoc.search;
			loc.hash = urlLoc.hash;
			return loc.toString();
		}

	}

}