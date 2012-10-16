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
	 * @created					14.03.2010 18:33:07
	 */
	public class DescendantSelector extends ChildSelector {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function DescendantSelector(parent:CSSSelector) {
			super( parent );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toString():String {
			return this.parent + ' ' + this.selector;
		}

		public override function contains(target:CSSSelector):Boolean {
			if ( this.selector.contains( target.selector ) ) {
				if ( target is ChildSelector ) {
					if ( target is DescendantSelector ) {
						var t:CSSSelector = this.parent;
						var p:CSSSelector = ( target as DescendantSelector ).parent;
						while ( t ) {
							if ( t.selector.contains( p.selector ) ) {
								return t.contains( p );
							}
							t = ( t is DescendantSelector ? ( t as DescendantSelector ).parent : null );
						}
					}
					return false;
				}
			}
			return true;
		}

	}
	
}