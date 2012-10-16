////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.net.SerializeErrorEvent;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.net.ISocket;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.net.Socket;
	import by.blooddy.core.net.connection.filters.ISocketFilter;
	import by.blooddy.core.utils.ByteArrayUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * ошибка сериализации протокола
	 */
	[Event( name="serializeError", type="by.blooddy.core.events.net.SerializeErrorEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					socketconnection, connection, proxysocket, socket, proxy
	 */
	public class SocketConnection extends AbstractSocketConnection {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function SocketConnection(socket:ISocket=null) {
			if ( !socket ) socket = new Socket();
			super( socket );
			this._socket = socket;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сцылка на конкретное сокетное соединение.
		 */
		private var _socket:ISocket;

		/**
		 * @private
		 */
		private const _inputBuffer:ByteArray = new ByteArray();

		/**
		 * @private
		 */
		private var _inputPosition:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  filter
		//----------------------------------

		/**
		 * @private
		 */
		private var _filter:ISocketFilter;

		/**
		 * Через эту фигню идёт обработка протокола.
		 */
		public function get filter():ISocketFilter {
			return this._filter;
		}

		/**
		 * @private
		 */
		public function set filter(value:ISocketFilter):void {
			this._filter = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function connect(host:String, port:int):void {
			super.connect( host, port );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA, this.handler_socketData );
		}

		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, responder:Responder=null, ...parameters):* {
			if ( !this._socket || !this._socket.connected ) throw new IllegalOperationError( 'соединение не установленно' );
			if ( !this._filter ) throw new IllegalOperationError( 'нету фильтра сообщений' );
			var command:NetCommand = new NetCommand( commandName, NetCommand.OUTPUT, parameters );
			command.system = this._filter.isSystem( commandName, NetCommand.OUTPUT );
			return super.$invokeCallOutputCommand( command, responder );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $clear():void {
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA, this.handler_socketData );
			this._inputBuffer.length = 0;
			this._inputPosition = 0;
		}
		
		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {

//			var bytes:ByteArray = new ByteArray();
//			this._filter.writeCommand( bytes, command as NetCommand );
//			this._socket.writeBytes( bytes );
//			trace( ByteArrayUtils.dump( bytes ) );

			this._filter.writeCommand( this._socket, command as NetCommand );
			this._socket.flush(); 
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * обрабатываем пришедшие данные и запускаем.
		 */
		private function handler_socketData(event:ProgressEvent):void {

			if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
				super.dispatchEvent(
					new ProgressEvent(
						ProgressEvent.PROGRESS, false, false,
						this._socket.bytesAvailable - this._inputBuffer.bytesAvailable, 0
					)
				);
			}

//			var pos:uint = this._inputBuffer.length;
			// запихиваем фсё в буфер
			this._socket.readBytes( this._inputBuffer, this._inputBuffer.length );
//			trace( ByteArrayUtils.dump( this._inputBuffer, pos  ) );

			var command:NetCommand;

			do { // считываем до тех пор, пока есть чего читать

				try { // серилизуем комманду

					command = this._filter.readCommand( this._inputBuffer, NetCommand.INPUT );

				} catch ( e:* ) {

					command = null;

					var data:ByteArray = new ByteArray();
					this._inputBuffer.position = this._inputPosition;
					this._inputBuffer.readBytes( data );
					this._inputBuffer.length = 0;

					if ( super.logging ) {
						super.logger.addLog(
							new InfoLog(
								( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) ),
								InfoLog.FATAL
							)
						);
						trace( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) );
						trace( ByteArrayUtils.dump( data ) );
					}

					if ( super.dispatchEvent( new SerializeErrorEvent( SerializeErrorEvent.SERIALIZE_ERROR, false, true, String( e ), e as Error, data ) ) ) {
						this.close();
					}

				}

				if ( command ) {

					this._inputPosition = this._inputBuffer.position;

					// вызываем метод обработки
					super.$invokeCallInputCommand( command );

				}

			} while ( command && this._inputBuffer.bytesAvailable > 0 );

			if ( this._inputPosition == this._inputBuffer.length ) { // нечего накапливать буфер. чистим.
				this._inputPosition = 0;
				this._inputBuffer.length = 0;
			}

		}

	}
}