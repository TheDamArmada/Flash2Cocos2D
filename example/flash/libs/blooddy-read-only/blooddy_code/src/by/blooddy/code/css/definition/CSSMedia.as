////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					18.04.2010 18:39:09
	 */
	public class CSSMedia {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function CSSMedia(rules:Vector.<CSSRule>, name:String=null) {
			super();
			this.rules = rules;
			this.name = name;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var name:String;

		public var rules:Vector.<CSSRule>;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			var h:Boolean = ( this.name && this.name != 'all' );
			return ( h ? '@media ' + this.name + '{' : '' ) + this.rules.join( '' ) + ( h ? '}' : '' );
		}

	}

}