/*!
 * blooddy/utils/version.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.utils' );

if ( !blooddy.utils.Version ) {

	/**
	 * @class
	 * @final
	 * вспомогательный класс работы с версиями
	 * @namespace	blooddy.utils
	 * @extends		Array
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.utils.Version = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 * @param	{Number}	major
		 * @param	{Number}	minor
		 * @param	{Number}	buildNumber
		 * @param	{Number}	internalBuildNumber
		 */
		var Version = function(major, minor, buildNumber, internalBuildNumber) {
			var	a =	arguments,
				i,
				l =	a.length;
			if ( l > 0 ) {
				if ( l > 4 ) l = 4;
				for ( i=0; i<l; i++ ) {
					this[ i ] = a[ i ] || 0;
				}
			}
		};

		blooddy.extend( Version, Array );

		var VersionPrototype = Version.prototype;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @method
		 * @return	{Number}
		 */
		VersionPrototype.getMajorVersion = function() {
			return this[ 0 ] || 0;
		};

		/**
		 * @method
		 * @return	{Number}
		 */
		VersionPrototype.getMinorVersion = function() {
			return this[ 1 ] || 0;
		};

		/**
		 * @method
		 * @return	{Number}
		 */
		VersionPrototype.getBuildNumber = function() {
			return this[ 2 ] || 0;
		};

		/**
		 * @method
		 * @return	{Number}
		 */
		VersionPrototype.getInternalBuildNumber = function() {
			return this[ 3 ] || 0;
		};

		/**
		 * @method
		 * сравнимает теущию версию с переданной
		 * @param	{blooddy.utils.Version}		v			версия для сравнения
		 * @return	{Number}					-1,0,1
		 */
		VersionPrototype.compare = function(v) {
			return Version.compare( this, v );
		};

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		VersionPrototype.toString = function() {
			var	arr =	new Array(),
				i,
				l =		this.length;
			if ( l > 4 ) l = 4;
			for ( i=0; i<l && this[i]; i++ ) {
				arr.push( this[ i ] );
			}
			return arr.join( '.' );
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @static
		 * @method
		 * сравнивает две версии
		 * @param	{blooddy.utils.Version}		v1		версия для сравнения
		 * @param	{blooddy.utils.Version}		v2		версия для сравнения
		 * @return	{Number}					-1,0,1
		 */
		Version.compare = function(v1, v2) {
			// major
			if ( !isNaN( v1[0] ) && !isNaN( v2[0] ) ) {
				if ( v1[0] > v2[0] ) return  1;
				if ( v1[0] < v2[0] ) return -1;
				// minor
				if ( !isNaN( v1[1] ) && !isNaN( v2[1] ) ) {
					if ( v1[1] > v2[1] ) return  1;
					if ( v1[1] < v2[1] ) return -1;
					// buildNumber
					if ( !isNaN( v1[2] ) && !isNaN( v2[2] ) ) {
						if ( v1[2] > v2[2] ) return  1;
						if ( v1[2] < v2[2] ) return -1;
						// internalBuildNumber
						if ( !isNaN( v1[3] ) && !isNaN( v2[3] ) ) {
							if ( v1[3] > v2[3] ) return  1;
							if ( v1[3] < v2[3] ) return -1;
						}
					}
				}
			}
			// eaual
			return 0;
		};

		/**
		 * @static
		 * @method
		 * преобразовывает строку в версию
		 * @param	{String}					value	строка для анализа
		 * @return	{blooddy.utils.Version}				получившаяся версия
		 */
		Version.parse = function(value) {
			var	arr =		value.split( /[\.,]/, 4 ),
				result =	new Version(),
				i,
				l =			arr.length,
				v;
			for ( i=0; i<l; i++ ) {
				v = parseInt( arr[ i ] );
				if ( isNaN( v ) ) break;
				result[ i ] = v;
			}
			return result;
		};

		/**
		 * @static
		 * @method
		 * @override
		 * @return	{String}
		 */
		Version.toString = function() {
			return '[class Version]';
		};

		return Version;

	}() );

}