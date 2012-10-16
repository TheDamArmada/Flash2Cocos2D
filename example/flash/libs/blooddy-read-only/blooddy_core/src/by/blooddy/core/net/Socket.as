////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="open", type="flash.events.Event" )]

	/**
	 * @copy					flash.net.Socket
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					socket
	 * 
	 * @see						flash.net.Socket
	 */
	public class Socket extends flash.net.Socket implements ISocket {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function Socket(host:String=null, port:int=0.0) {
			super( host, port );
			super.addEventListener( Event.CLOSE,						this.handler_close, false, int.MAX_VALUE, true );
			super.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error, false, int.MAX_VALUE, true );
			super.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _hasError:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ISocket
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get protocol():String {
			return Protocols.SOCKET;
		}

		//----------------------------------
		//  host
		//----------------------------------

		/**
		 * @private
		 */
		private var _host:String;

		/**
		 * @inheritDoc
		 */
		public function get host():String {
			return this._host;
		}

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * @private
		 */
		private var _port:int;

		/**
		 * @inheritDoc
		 */
		public function get port():int {
			return this._port;
		}

		//--------------------------------------------------------------------------
		//
		//  Overrided methods: Socket
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function connect(host:String, port:int):void {
			super.connect( host, port );
			this._host = host;
			this._port = port;
			super.dispatchEvent( new Event( Event.OPEN ) ); // задержечку надо бы сделать
			this._hasError = false;
		}

		/**
		 * @inheritDoc
		 */
		public override function close():void {
			super.close();
			// патч. эта сука не генерит событие.
			super.dispatchEvent( new Event( Event.CLOSE ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			this._host = null;
			this._port = 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			this._hasError = true;
			this.clear();
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			if ( this._hasError ) {
				// ошибка уже была. поэтому блокируем остальные
				event.stopImmediatePropagation();
			} else {
				this._hasError = true;
				this.clear();
				// надо оптисаться, что бы не мешать вызову исключения
				super.removeEventListener( event.type, this.handler_error );
				if ( !super.hasEventListener( event.type ) ) {
					// если подписчиков нету, диспатчим ошибку, что бы вывалился unhadled securityError
					super.dispatchEvent( event );
				}
				// подписываемся обратно
				super.addEventListener( event.type, this.handler_error, false, int.MAX_VALUE, true );
			}
		}

	}

}