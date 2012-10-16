////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {
	
	import by.blooddy.external.net.DataLoaderController;
	
	import flash.display.Stage;
	
	[Frame( factoryClass="by.blooddy.factory.SimpleApplicationFactory" )]
	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.01.2010 22:36:44
	 */
	public class DataLoader extends DataLoaderController {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function DataLoader(stage:Stage) {
			super( stage, stage.loaderInfo.parameters.so );
		}
		
	}
	
}