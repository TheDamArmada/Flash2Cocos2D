////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css.definition.values {

	import by.blooddy.code.utils.CSSColors;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.04.2010 1:49:03
	 */
	public class ColorValue extends CSSValue {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _SHORT:RegExp = /(.)\1(.)\2(.)\3(?:(.)\4)?/i;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ColorValue(value:uint) {
			super();
			this.value = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var value:uint;

		public function get name():String {
			return CSSColors.getName( this.value );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function valueOf():uint {
			return this.value;
		}

		public function toString():String {
			var v:String;
			if ( this.value > 0xFFFFFF && ( this.value & 0xFF000000 ) != 0xFF000000 ) {
				v = this.value.toString( 16 );
				while ( v.length < 8 ) {
					v = '0' + v;
				}
				v = v.replace( _SHORT, '$1$2$3$4' );
			} else {
				v = ( this.value & 0xFFFFFF ).toString( 16 );
				while ( v.length < 6 ) {
					v = '0' + v;
				}
				v = v.replace( _SHORT, '$1$2$3' );
				var s:String = CSSColors.getName( this.value );
				if ( s && s.length < v.length + 1 ) {
					return s;
				}
			}
			return '#' + v.toUpperCase();
		}

	}
	
}