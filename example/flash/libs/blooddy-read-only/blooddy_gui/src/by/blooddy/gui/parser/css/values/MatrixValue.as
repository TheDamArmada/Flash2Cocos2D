////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css.values {
	
	import by.blooddy.code.css.definition.values.CSSValue;
	
	import flash.geom.Matrix;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.05.2010 16:10:28
	 */
	public class MatrixValue extends CSSValue {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function MatrixValue(value:Matrix) {
			super();
			this.value = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var value:Matrix;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function valueOf():Matrix {
			return this.value;
		}

		public function toString():String {
			return 'matrix(' +
				this.value.a +
				this.value.b +
				this.value.c +
				this.value.d +
				this.value.tx +
				this.value.ty +
			')';
		}

	}
	
}