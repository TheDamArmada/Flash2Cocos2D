////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.IEquable;
	import by.blooddy.core.utils.IHashable;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ResourceDefinition implements IHashable, IEquable {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _SEPERATOR:String = '#';

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public static function getHash(bundleName:String=null, resourceName:String=null):String {
			return ( bundleName || '' ) + _SEPERATOR + ( resourceName || '' );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceDefinition(bundleName:String=null, resourceName:String=null) {
			super();
			this.bundleName = bundleName;
			this.resourceName = resourceName;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var bundleName:String;
		
		public var resourceName:String;
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public function getHash():String {
			return ( this.bundleName || '' ) + _SEPERATOR + ( resourceName || '' );
		}

		public function equals(value:Object):Boolean {
			if ( this === value ) return true;
			if ( !( value is ResourceDefinition ) ) return false;
			return (
				this.bundleName == value.bundleName &&
				this.resourceName == value.resourceName
			);
		}

		public function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ( this.bundleName ? ' bundleName="' + this.bundleName + '"' : '' ) + ( this.resourceName ? ' resourceName="' + this.resourceName + '"' : '' ) + ']';
		}

	}

}