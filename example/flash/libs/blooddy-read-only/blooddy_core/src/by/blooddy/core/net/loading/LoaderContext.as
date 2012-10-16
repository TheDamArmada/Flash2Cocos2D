////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import flash.system.ApplicationDomain;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.02.2010 22:00:04
	 */
	public class LoaderContext {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LoaderContext(applicationDomain:ApplicationDomain=null, ignoreSecurity:Boolean=false, checkPolicyFile:Boolean=false) {
			super();
			this.applicationDomain = applicationDomain;
			this.ignoreSecurityDomain = ignoreSecurity;
			this.checkPolicyFile = checkPolicyFile;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public var applicationDomain:ApplicationDomain;

		public var ignoreSecurityDomain:Boolean;

		public var checkPolicyFile:Boolean;

		public var parameters:Object;

	}

}