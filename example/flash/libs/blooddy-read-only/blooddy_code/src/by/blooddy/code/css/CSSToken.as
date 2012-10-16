////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 10, 2010 12:23:35 PM
	 */
	internal final class CSSToken {

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
		public static const WHITESPACE:uint =		++i;
		public static const COLON:uint =			++i;
		public static const LEFT_BRACE:uint =		++i;
		public static const RIGHT_BRACE:uint =		++i;
		public static const LEFT_PAREN:uint =		++i;
		public static const RIGHT_PAREN:uint =		++i;
		public static const LEFT_ANGLE:uint =		++i;
		public static const RIGHT_ANGLE:uint =		++i;
		public static const LEFT_BRACKET:uint =		++i;
		public static const RIGHT_BRACKET:uint =	++i;
		public static const HASH:uint =				++i;
		public static const PERCENT:uint =			++i;
		public static const DOT:uint =				++i;
		public static const COMMA:uint =			++i;
		public static const DASH:uint =				++i;
		public static const BAR:uint =				++i;
		public static const AT:uint =				++i;
		public static const SEMI_COLON:uint =		++i;
		public static const NUMBER_LITERAL:uint =	++i;
		public static const STRING_LITERAL:uint =	++i;
		public static const IDENTIFIER:uint =		++i;
		public static const BLOCK_COMMENT:uint =	++i;
		public static const UNKNOWN:uint =			++i;

	}
	
}