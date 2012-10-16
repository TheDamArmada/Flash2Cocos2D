////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.net {

	import by.blooddy.core.net.loading.LoaderPriority;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.04.2010 12:55:45
	 */
	public final class GUILoaderPriority {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const DESCRIPTION:int =	LoaderPriority.PRELOADER - 1;
		
		public static const STYLE:int =			DESCRIPTION - 1;
		
		public static const RESOURCE:int =		STYLE - 1;
		
	}
	
}