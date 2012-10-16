////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition.values {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.04.2010 2:29:37
	 */
	public class ComplexValue extends AbstractCollectionValue {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ComplexValue(name:String, values:Vector.<CSSValue>) {
			super( values );
			this.name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var name:String;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toString():String {
			for each ( var v:CSSValue in this.values ) {
				if ( v is AbstractCollectionValue ) {
					throw new ArgumentError();
				}
			}
			return this.name + '(' + this.values.join( ',' ) + ')';
		}

	}
	
}