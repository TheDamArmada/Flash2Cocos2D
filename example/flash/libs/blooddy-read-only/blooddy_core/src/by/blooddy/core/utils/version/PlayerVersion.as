////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.version {

	import flash.system.Capabilities;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					version
	 */
	public final class PlayerVersion implements IVersion {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		private static function init():void {
			var arr:Array = Capabilities.version.match( /^\w+\s(\d+),(\d+),(\d+),(\d+)$/ );
			_majorVersion  = parseInt( arr[1] );
			_minorVersion  = parseInt( arr[2] );
			_buildNumber  = parseInt( arr[3] );
			_internalBuildNumber  = parseInt( arr[4] );
		}
		init();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _majorVersion:uint;

		/**
		 * @private
		 */
		private static var _minorVersion:uint;

		/**
		 * @private
		 */
		private static var _buildNumber:uint;

		/**
		 * @private
		 */
		private static var _internalBuildNumber:uint;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function PlayerVersion() {
			super();
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
		 * @inheritDoc
		 */
		public function get majorVersion():uint {
			return _majorVersion;
		}

		//--------------------------------------
		//  minorVersion
		//--------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get minorVersion():uint {
			return _minorVersion;
		}

		//--------------------------------------
		//  buildNumber
		//--------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get buildNumber():uint {
			return _buildNumber;
		}

		//--------------------------------------
		//  internalBuildNumber
		//--------------------------------------

		/**
		 * @inheritDoc
		 */
		public function get internalBuildNumber():uint {
			return _internalBuildNumber;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function toString():String {
			return _majorVersion + '.' + _minorVersion + '.' + _buildNumber + '.' + _internalBuildNumber;	
		}

	}

}