////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {

	import by.blooddy.external.media.SoundController;
	
	import flash.display.Stage;
	
	[Frame( factoryClass="by.blooddy.factory.SimpleApplicationFactory" )]
	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.11.2009 3:24:22
	 */
	public class Sound extends SoundController {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Sound(stage:Stage) {
			super( stage, stage.loaderInfo.parameters.so );
		}
		
	}
	
}