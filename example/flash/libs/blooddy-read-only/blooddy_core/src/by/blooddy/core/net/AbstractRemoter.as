////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.commands.CommandDispatcher;
	import by.blooddy.core.logging.ILogging;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.logging.Logger;
	import by.blooddy.core.logging.commands.CommandLog;
	import by.blooddy.core.utils.time.AutoTimer;
	import by.blooddy.core.utils.time.getTimer;
	
	import flash.errors.ScriptTimeoutError;
	import flash.events.TimerEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					iconnection, connection
	 */
	public class AbstractRemoter extends CommandDispatcher implements IRemoter, ILogging {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TIMER:AutoTimer = new AutoTimer( 60 );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior
		 */
		public function AbstractRemoter(unassisted:Boolean=false) {
			super();
			this._client = this;
			this._unassisted = unassisted;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _unassisted:Boolean;

		/**
		 * @private
		 */
		private var _responderNum:uint = 0;

		/**
		 * @private
		 */
		private const _responders:Object = new Object();

		/**
		 * @private
		 */
		private var _responderCount:uint = 0;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties: INetConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  client
		//----------------------------------

		/**
		 * @private
		 */
		private var _client:Object;

		/**
		 * @inheritDoc
		 */
		public function get client():Object {
			return this._client;
		}

		/**
		 * @private
		 */
		public function set client(value:Object):void {
			if ( this._client === value ) return;
			this._client = value || this;
		}

		//----------------------------------
		//  logger
		//----------------------------------

		/**
		 * @private
		 */
		private const _logger:Logger = new Logger();

		/**
		 * @inheritDoc
		 */
		public function get logger():Logger {
			return this._logger;
		}

		//----------------------------------
		//  logging
		//----------------------------------

		/**
		 * @private
		 */
		private var _logging:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get logging():Boolean {
			return this._logging;
			
		}

		/**
		 * @private
		 */
		public function set logging(value:Boolean):void {
			if ( this._logging == value ) return;
			this._logging = value;
		}

		//----------------------------------
		//  responderTimeout
		//----------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods: IRemoter
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function call(commandName:String, responder:Responder=null, ...parameters):* {
			return this.$invokeCallOutputCommand(
				new Command( commandName, parameters ),
				responder
			);
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function rejectResponders():void {
			for ( var num:* in this._responders ) {
				this.invokeResponder( num );
			}
			this._responderCount = 0;
			_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
		}

		//----------------------------------
		//  output
		//----------------------------------

		protected function $invokeCallOutputCommand(command:Command!, responder:Responder=null):* {
			var netCommand:NetCommand;
			if ( command is NetCommand ) {
				netCommand = command as NetCommand;
				if ( netCommand.status || netCommand.num != 0 ) throw new ArgumentError();
			}
			if ( responder ) {
				if ( !netCommand ) {
					command = netCommand = new NetCommand( command.name, NetCommand.OUTPUT, command );
				}
				netCommand.num = ++this._responderNum;
				this._responders[ this._responderNum ] = new ResponderAsset( responder, netCommand ); // сохраняем, что бы обработать в ответе
				if ( this._responderCount == 0 ) {
					_TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
				}
				++this._responderCount;
			}
			if ( this._logging && ( !netCommand || !netCommand.system ) ) {
				this._logger.addLog( new CommandLog( command ) );
			}
			return this.$callOutputCommand( command );
		}

		protected function $callOutputCommand(command:Command):* {
			if ( command is NetCommand && ( command as NetCommand ).num ) {
				throw new ArgumentError();
			}
			return this.$invokeCallInputCommand( command, false );
		}

		//----------------------------------
		//  input
		//----------------------------------

		protected function $invokeCallInputCommand(command:Command!, async:Boolean=true):* {

			if ( this._logging ) {
				var system:Boolean = false;
				if ( command is NetCommand ) {
					var netCommand:NetCommand = command as NetCommand;
					if ( netCommand.num && netCommand.num in this._responders ) {
						var request:NetCommand = ( this._responders[ netCommand.num ] as ResponderAsset ).command;
						netCommand.system = system = request.system;
						netCommand.parent = request;
					}
				}
				if ( !system ) {
					this._logger.addLog( new CommandLog( command ) );
				}
			}

			if ( async ) {

				try { // отлавливаем ошибки выполнения
					return this.$callInputCommand( command );
				} catch ( e:* ) {
					if ( this._logging ) {
						this._logger.addLog( new InfoLog( ( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) ), InfoLog.ERROR ) );
						trace( e is Error ? ( e.getStackTrace() || e.toString() ) : String( e ) );
					}
					if ( !this._unassisted ) {
						this.dispatchError( e );
					}
				}

			} else {

				return this.$callInputCommand( command );

			}

		}

		protected function $callInputCommand(command:Command):* {
			if ( !command ) throw new ArgumentError(); // TODO: описать ошибку
			var num:uint;
			if ( command is NetCommand ) {
				num = ( command as NetCommand ).num;
			}
			var has:Boolean = false;
			var result:*;
			if ( num ) { // удалённый клиент считает, что у нас есть респондер

				if ( !( num in this._responders ) ) {
					throw new DefinitionError( 'не найден responder: ' + command );
				}
				var responder:Responder = ( this._responders[ num ] as ResponderAsset ).responder;
				delete this._responders[ num ];
				--this._responderCount;
				if ( this._responderCount == 0 ) {
					_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				}

				var func:Function = ( ( command as NetCommand ).status ? responder.status : responder.result );
				has = Boolean( func );
				if ( has ) {
					result = func.apply( null, command );
				}

			} else {

				// пытаемся выполнить что-нить
				has = command.name in this._client;
				if ( has ) {
					result = command.call( this._client );
				}
				// проверим нету ли хендлера на нашу комманду
				if ( super.hasCommandListener( command.name ) ) {
					has = true;
					super.dispatchCommand( command );
				}

			}
			if ( !has ) {
				throw new DefinitionError( 'не найдено слушетелей команды: ' + command );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function invokeResponder(num:int, kind:String='reject'):void {

			var assset:ResponderAsset = this._responders[ num ] as ResponderAsset;
			var func:Function = assset.responder.status;
			if ( func != null ) {
				
				var command:NetCommand = new NetCommand( kind, NetCommand.INPUT );
				command.status = true;
				command.num = assset.command.num;
				command.length = func.length;
				this.$invokeCallInputCommand( command );

			} else if ( !this._unassisted ) {

				// если метода нету, то кидаем исключение
				this.dispatchError( new ScriptTimeoutError() );

			}

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			const time:Number = getTimer();
			var asset:ResponderAsset;
			for ( var num:* in this._responders ) {
				asset = this._responders[ num ] as ResponderAsset;
				if ( asset.responder.timeout && asset.time <= time - asset.responder.timeout ) {
					this.invokeResponder( num, 'timeout' );
				}
			}
			if ( this._responderCount == 0 ) {
				_TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.commands.Command;
import by.blooddy.core.net.NetCommand;
import by.blooddy.core.net.Responder;
import by.blooddy.core.utils.time.getTimer;

/**
 * @private
 */
internal final class ResponderAsset {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function ResponderAsset(responder:Responder, command:NetCommand) {
		super();
		this.responder = responder;
		this.command = command;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var command:NetCommand;

	public var responder:Responder;

	public const time:Number = getTimer();

}