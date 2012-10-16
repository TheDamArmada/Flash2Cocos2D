////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	import flash.errors.IllegalOperationError;

	//--------------------------------------
	//  Namespaces
	//--------------------------------------
	
	use namespace $internal;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					database, data
	 */
	public final class DataBase extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DataBase() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Data
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		$internal override function $setParent(value:DataContainer):void {
			Error.throwError( IllegalOperationError, 2037 );
		}

	}

}