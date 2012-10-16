////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.application.factory {

	import by.blooddy.factory.ApplicationFactory;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 22:26:06
	 */
	public final class AvangardFactory extends ApplicationFactory {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function AvangardFactory() {
			super( 'ru.avangardonline.application.AvangardBattle' );
			super.color = 0x6C4130;
		}

	}

}