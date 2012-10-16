////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.version {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					version
	 */
	public class Version implements IVersion {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public static const ZERO_VERSION:IVersion = new Version( 0, 0, 0, 0 );

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public static function compare(v1:IVersion, v2:IVersion):int {
			if		( v1.majorVersion > v2.majorVersion ) return 1;
			else if	( v1.majorVersion < v2.majorVersion ) return -1;
			else if	( v1.minorVersion > v2.minorVersion ) return 1;
			else if	( v1.minorVersion < v2.minorVersion ) return -1;
			else if	( v1.buildNumber > v2.buildNumber ) return 1;
			else if	( v1.buildNumber < v2.buildNumber ) return -1;
			else if	( v1.internalBuildNumber > v2.internalBuildNumber ) return 1;
			else if	( v1.internalBuildNumber < v2.internalBuildNumber ) return -1;
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 *  
		 * @param	majorVersion
		 * @param	minorVersion
		 * @param	buildNumber
		 * @param	internalBuildNumber
		 */
		public function Version(majorVersion:uint=0, minorVersion:uint=0, buildNumber:uint=0, internalBuildNumber:uint=0) {
			super();
			this._majorVersion = majorVersion;
			this._minorVersion = minorVersion;
			this._buildNumber = buildNumber;
			this._internalBuildNumber = internalBuildNumber;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//--------------------------------------
		//  majorVersion
		//--------------------------------------

		/**
		 * @private
		 */
		private var _majorVersion:uint = 0;

		/**
		 * @inheritDoc
		 */
		public final function get majorVersion():uint {
			return this._majorVersion;
		}

		/**
		 * @private
		 */
		public function set majorVersion(value:uint):void {
			if ( this._majorVersion == value ) return;
			this._majorVersion = value;
		}

		//--------------------------------------
		//  minorVersion
		//--------------------------------------

		/**
		 * @private
		 */
		private var _minorVersion:uint = 0;

		/**
		 * @inheritDoc
		 */
		public final function get minorVersion():uint {
			return this._minorVersion;
		}

		/**
		 * @private
		 */
		public function set minorVersion(value:uint):void {
			if ( this._minorVersion == value ) return;
			this._minorVersion = value;
		}

		//--------------------------------------
		//  buildNumber
		//--------------------------------------

		/**
		 * @private
		 */
		private var _buildNumber:uint = 0;

		/**
		 * @inheritDoc
		 */
		public final function get buildNumber():uint {
			return this._buildNumber;
		}

		/**
		 * @private
		 */
		public function set buildNumber(value:uint):void {
			if ( this._buildNumber == value ) return;
			this._buildNumber = value;
		}

		//--------------------------------------
		//  internalBuildNumber
		//--------------------------------------

		/**
		 * @private
		 */
		private var _internalBuildNumber:uint = 0;

		/**
		 * @inheritDoc
		 */
		public final function get internalBuildNumber():uint {
			return this._internalBuildNumber;
		}

		/**
		 * @private
		 */
		public function set internalBuildNumber(value:uint):void {
			if ( this._internalBuildNumber == value ) return;
			this._internalBuildNumber = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function toString():String {
			return this._majorVersion + "." + this._minorVersion + "." + this._buildNumber + "." + this._internalBuildNumber;	
		}

	}

}