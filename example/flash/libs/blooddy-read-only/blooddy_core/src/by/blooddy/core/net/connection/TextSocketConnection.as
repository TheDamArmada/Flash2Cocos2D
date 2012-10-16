////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.net.SerializeErrorEvent;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.net.ITextSocket;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.net.TextSocket;
	import by.blooddy.core.net.connection.filters.ITextSocketFilter;
	
	import flash.errors.IllegalOperationError;
	import flash.events.DataEvent;
	
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
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.08.2011 17:28:57
	 */
	public class TextSocketConnection extends AbstractSocketConnection {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function TextSocketConnection(socket:ITextSocket=null) {
			if ( !socket ) socket = socket = new TextSocket();
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
		private var _socket:ITextSocket;
		
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
		private var _filter:ITextSocketFilter;
		
		/**
		 * Через эту фигню идёт обработка протокола.
		 */
		public function get filter():ITextSocketFilter {
			return this._filter;
		}
		
		/**
		 * @private
		 */
		public function set filter(value:ITextSocketFilter):void {
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
			this._socket.addEventListener( DataEvent.DATA, this.handler_data );
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
			this._socket.removeEventListener( DataEvent.DATA, this.handler_data );
		}
		
		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {
			this._socket.send(
				this._filter.encodeCommand( command as NetCommand )
			);
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
		private function handler_data(event:DataEvent):void {
			
			try {
				
				// серилизуем комманду
				// вызываем метод обработки
				super.$invokeCallInputCommand(
					this._filter.decodeCommand( event.data, NetCommand.INPUT )
				);

			} catch ( e:* ) {
				
				if ( super.logging ) {
					super.logger.addLog(
						new InfoLog(
							( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) ),
							InfoLog.FATAL
						)
					);
					trace( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) );
				}
				
				if ( super.dispatchEvent( new SerializeErrorEvent( SerializeErrorEvent.SERIALIZE_ERROR, false, true, String( e ), e as Error, event.data ) ) ) {
					this.close();
				}
				
			}
				
		}
		
	}
}