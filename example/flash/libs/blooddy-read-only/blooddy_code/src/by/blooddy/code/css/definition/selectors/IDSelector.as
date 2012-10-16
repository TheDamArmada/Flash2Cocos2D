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
	 * @created					14.03.2010 17:18:03
	 */
	public class IDSelector extends TextAttributeSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function IDSelector(id:String, selector:AttributeSelector=null) {
			super( id, selector );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/*
		 * __
		 * AABBBCCC
		 */
		public override function getSpecificity():uint {
			if ( this.selector ) {
				var result:uint = this.selector.getSpecificity();
				var v:uint = ( ( result & 0xFF000000 ) >> 24 ) + 1;
				return ( result & 0x00FFFFFF ) | ( v << 24 );
			}
			return 0x01000000;
		}

		public override function toString():String {
			if ( this.selector is TagSelector ) {
				return ( this.selector as TagSelector ).value + '#' + this.value + ( this.selector.selector || '' );
			} else {
				return '#' + this.value + ( this.selector || '' );
			}
		}

	}
	
}