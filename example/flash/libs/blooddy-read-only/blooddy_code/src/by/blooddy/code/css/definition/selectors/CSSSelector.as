////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition.selectors {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.03.2010 5:32:46
	 */
	public class CSSSelector implements ISelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSSelector() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var selector:AttributeSelector;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function contains(target:CSSSelector):Boolean {
			return	( this as Object ).constructor === ( target as Object ).constructor &&
					this.selector.contains( target.selector );
		}

		public function getSpecificity():uint {
			return this.selector.getSpecificity();
		}

		public function toString():String {
			return this.selector.toString();
		}

	}
	
}