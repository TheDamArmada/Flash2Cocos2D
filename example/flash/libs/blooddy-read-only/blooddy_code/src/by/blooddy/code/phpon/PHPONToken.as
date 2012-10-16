////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.phpon {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.06.2010 21:00:12
	 */
	internal final class PHPONToken {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static var i:uint = 0;
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		public static const EOF:uint =				i++;
		public static const COLON:uint =			i++;
		public static const SEMI_COLON:uint =		i++;
		public static const LEFT_BRACE:uint =		i++;
		public static const RIGHT_BRACE:uint =		i++;
		public static const DOUBLE_QUOTE:uint =		i++;
		public static const NUMBER_LITERAL:uint =	i++;
		public static const STRING_LITERAL:uint =	i++;
		public static const IDENTIFIER:uint =		i++;
		public static const UNKNOWN:uint =			i++;

	}
	
}