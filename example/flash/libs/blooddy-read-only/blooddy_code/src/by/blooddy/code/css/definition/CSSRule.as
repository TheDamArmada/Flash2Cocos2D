////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition {

	import by.blooddy.code.css.definition.selectors.CSSSelector;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.04.2010 6:03:15
	 */
	public class CSSRule {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function convertName(name:String):String {
			var result:String = '';
			const l:uint = name.length;
			var c:String, c2:String;
			var j:uint = 0;
			for ( var i:uint = 0; i<l; ++i ) {
				c = name.charAt( i );
				c2 = c.toLowerCase();
				if ( c2 != c ) {
					result += name.substring( j, i ) + '-' + c2;
					j = i + 1;
				}
			}
			result += name.substr( j );
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSRule(selector:CSSSelector, declarations:Object) {
			super();
			this.selector = selector;
			this.declarations = declarations;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var selector:CSSSelector;

		public var declarations:Object;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			var arr:Vector.<String> = new Vector.<String>();
			for ( var n:String in this.declarations ) {
				arr.push( convertName( n ) + ':' + this.declarations[ n ] );
			}
			return this.selector + '{' + arr.join( ';' ) + '}';
		}

	}
	
}