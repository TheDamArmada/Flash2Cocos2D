////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.application {

	import flash.display.Stage;
	
	import ru.avangardonline.controllers.GameController;

	[Frame( factoryClass="ru.avangardonline.application.factory.AvangardFactory" )]
	[SWF( width="706", height="358", frameRate="21", backgroundColor="#333333" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 21:16:09
	 */
	public final class AvangardBattle extends GameController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function AvangardBattle(stage:Stage) {
			super( stage );
		}

	}

}