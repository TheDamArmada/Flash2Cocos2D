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
	 * @created					14.03.2010 18:14:06
	 */
	public class ChildSelector extends CSSSelector {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ChildSelector(parent:CSSSelector) {
			super();
			this.parent = parent;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var parent:CSSSelector;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

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
						return false;
					} else {
						return this.parent.contains( ( target as ChildSelector ).parent );
					}
				}
			}
			return true;
		}

		public override function getSpecificity():uint {
			var p:uint = this.parent.getSpecificity();
			var s:uint = this.selector.getSpecificity()
			return	( ( (   p                >> 24 ) + (   s                >> 24 ) ) << 24 ) |
					( ( ( ( p & 0x00FFFF00 ) >>  8 ) + ( ( s & 0x00FFFF00 ) >>  8 ) ) <<  8 ) |
					  ( (   p & 0x000000FF         ) + (   s & 0x000000FF         ) )         ;
		}
		
		public override function toString():String {
			return this.parent + '>' + this.selector;
		}

	}
	
}