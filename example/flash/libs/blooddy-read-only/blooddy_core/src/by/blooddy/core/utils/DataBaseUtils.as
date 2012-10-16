////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					22.08.2009 17:03:45
	 */
	public final class DataBaseUtils {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function toTreeString(data:Data):String {
			return _toTreeString( data );
		}

		//--------------------------------------------------------------------------
		//
		//  Private Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function _toTreeString(data:Data, tabs:String=''):String {
			var result:String = tabs + data.toLocaleString();
			if ( data is DataContainer ) {
				var cont:DataContainer = data as DataContainer;
				var l:uint = cont.numChildren;
				for ( var i:uint = 0; i<l; ++i ) {
					result += '\n' + _toTreeString( cont.getChildAt( i ), tabs + '\t' );
				}
			}
			return result;
		}

	}

}