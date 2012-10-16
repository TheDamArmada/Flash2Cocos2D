////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {
	
	import by.blooddy.external.net.SocketController;
	import by.blooddy.external.net.connection.filters.JSONSocketFilter;
	
	import flash.display.DisplayObjectContainer;
	
	[Frame( factoryClass="by.blooddy.factory.SimpleApplicationFactory" )]
	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000", scriptTimeLimit="60" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.09.2010 14:28:13
	 */
	public final class JSONSocket extends SocketController {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function JSONSocket(container:DisplayObjectContainer) {
			super( container, new JSONSocketFilter(), container.loaderInfo.parameters.so );
		}
		
	}
	
}