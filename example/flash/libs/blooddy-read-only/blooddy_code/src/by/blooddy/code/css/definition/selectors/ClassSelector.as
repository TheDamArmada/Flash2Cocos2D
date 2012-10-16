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
	 * @created					14.03.2010 17:30:21
	 */
	public class ClassSelector extends TextAttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ClassSelector(styleClass:String, selector:AttributeSelector=null) {
			super( styleClass, selector );
			this.selector = selector;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/*   ___
		 * AABBBCCC
		 */
		public override function getSpecificity():uint {
			if ( this.selector ) {
				var result:uint = this.selector.getSpecificity();
				var v:uint = ( ( result & 0x00FFF000 ) >> 12 ) + 1;
				return ( result & 0xFF000FFF ) | ( v << 12 );
			}
			return 0x00000100;
		}

		public override function toString():String {
			return '.' + this.value + ( this.selector || '' );
		}

	}
	
}