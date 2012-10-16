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
	 * @created					14.03.2010 17:29:18
	 */
	public class TagSelector extends AttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function TagSelector(tag:QName, selector:AttributeSelector=null) {
			super( selector );
			this.value = tag;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var value:QName;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/*      ___
		 * AABBBCCC
		 */
		public override function getSpecificity():uint {
			if ( this.selector ) {
				return this.selector.getSpecificity() + 1;
			}
			return 1;
		}

		public override function toString():String {
			return this.value + ( this.selector || '' );
		}

	}
	
}