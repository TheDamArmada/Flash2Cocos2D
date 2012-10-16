////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDhounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style.meta {

	import by.blooddy.core.meta.AbstractInfo;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.08.2010 13:56:44
	 */
	public class AbstractStyle extends AbstractInfo {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $protected;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function AbstractStyle() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		$protected var _owner:StyleInfo;
		
		public function get owner():StyleInfo {
			return this._owner;
		}

	}
	
}