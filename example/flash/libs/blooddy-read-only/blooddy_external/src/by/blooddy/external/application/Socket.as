////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.application {

	import by.blooddy.core.net.connection.filters.SincereSocketFilter;
	import by.blooddy.core.net.loading.URLLoader;
	import by.blooddy.external.net.SocketController;
	
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;

	[Frame( factoryClass="by.blooddy.factory.SimpleApplicationFactory" )]
	[SWF( width="1", height="1", frameRate="120", backgroundColor="#FF0000", scriptTimeLimit="60" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					13.09.2009 19:02:05
	 */
	public final class Socket {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Socket(stage:Stage) {
			super();
			this._stage = stage;
			var loader:URLLoader = new URLLoader( new URLRequest( stage.loaderInfo.parameters.protocol || 'protocol.xml' ) );
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete );

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stage:Stage;
		
		/**
		 * @private
		 */
		private var _controller:SocketController;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
			if ( !( event is ErrorEvent ) ) { // протокол загрузился
				try {
					var filter:SincereSocketFilter = new SincereSocketFilter();
					filter.parseXML( new XML( loader.content ) );
					this._controller = new SocketController( this._stage, filter, this._stage.loaderInfo.parameters.so );
				} catch ( e:Error ) { // тупо гасим
					trace( e.getStackTrace() || e.toString() );
				}
			}
		}

	}

}