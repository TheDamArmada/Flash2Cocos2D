////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public final class LoaderPriority {

		public static const HIGHEST:int =		int.MAX_VALUE;

		public static const PRELOADER:int =		HIGHEST -1;

		public static const PRELOADING:int =	LOWER + 1;

		public static const LOWER:int =			int.MIN_VALUE;

	}

}