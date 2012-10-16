////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.json {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.03.2010 14:33:41
	 */
	internal final class JSONToken {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var i:int = -1;

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		public static const EOF:uint =				++i;
		public static const UNDEFINED:uint =		++i;
		public static const NULL:uint =				++i;
		public static const TRUE:uint =				++i;
		public static const FALSE:uint =			++i;
		public static const NAN:uint =				++i;
		public static const COLON:uint =			++i;
		public static const LEFT_BRACE:uint =		++i;
		public static const RIGHT_BRACE:uint =		++i;
		public static const LEFT_BRACKET:uint =		++i;
		public static const RIGHT_BRACKET:uint =	++i;
		public static const COMMA:uint =			++i;
		public static const NUMBER_LITERAL:uint =	++i;
		public static const STRING_LITERAL:uint =	++i;
		public static const IDENTIFIER:uint =		++i;
		public static const BLOCK_COMMENT:uint =	++i;
		public static const LINE_COMMENT:uint =		++i;
		public static const UNKNOWN:uint =			++i;
		
	}
	
}