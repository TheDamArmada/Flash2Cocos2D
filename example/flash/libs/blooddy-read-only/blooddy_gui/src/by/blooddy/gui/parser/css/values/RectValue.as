////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css.values {
	
	import by.blooddy.code.css.definition.values.CSSValue;
	
	import flash.geom.Rectangle;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.05.2010 16:52:21
	 */
	public class RectValue extends CSSValue {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function RectValue(value:Rectangle) {
			super();
			this.value = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var value:Rectangle;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function valueOf():Rectangle {
			return this.value;
		}
		
		public function toString():String {
			return 'rect(' +
				this.value.x + ',' +
				this.value.y + ',' +
				this.value.width + ',' +
				this.value.height +
			')';
		}
		
	}
	
}