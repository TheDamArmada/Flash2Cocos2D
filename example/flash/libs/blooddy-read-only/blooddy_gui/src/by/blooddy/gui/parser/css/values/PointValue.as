////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css.values {
	
	import by.blooddy.code.css.definition.values.CSSValue;
	
	import flash.geom.Point;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.08.2010 14:22:37
	 */
	public class PointValue extends CSSValue {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function PointValue(value:Point) {
			super();
			this.value = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var value:Point;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function valueOf():Point {
			return this.value;
		}
		
		public function toString():String {
			return 'point(' +
				this.value.x + ',' +
				this.value.y +
				')';
		}
		
	}
	
}