////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public dynamic class HashArray {

		public function HashArray() {
			super();
		}

		public function get length():uint {
			var length:uint = 0;
			for ( var name:String in this ) ++length;
			return length;
		}

		public function toArray():Array {
			var result:Array = new Array();
			for each ( var obj:Object in this ) {
				result.push( obj );
			}
			return result;
		}

		public function clone():HashArray {
			var result:HashArray = new HashArray();
			for ( var name:String in this ) {
				result[ name ] = this[ name ];
			}
			return result;
		}

		public function combine(target:HashArray):void {
			for ( var name:String in target ) {
				this[ name ] = target[ name ];
			}
		}

		public function toString():String {
			var arr:Array = new Array();
			for ( var name:String in this ) {
				arr.push( name + '=' + ( this[ name ] is String ? '"' + this[ name ] + '"' : this[ name ].toString() ) );
			}
			return '[' + ClassUtils.getClassName( this ) + ' ' + arr.join(' ') + ']';
		}

	}

}