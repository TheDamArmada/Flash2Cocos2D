////////////////////////////////////////////////////////////////////////////////
//
//  © 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.logging.LogEvent;
	import by.blooddy.core.logging.commands.CommandLog;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.connection.LocalConnection;
	import by.blooddy.core.utils.IAbstractRemoter;
	import by.blooddy.core.utils.UID;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.02.2011 14:31:18
	 */
	public final class ConsoleDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $private;

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function serializeLog(log:Log):Array {
			var result:Array = new Array();
			switch ( true ) {
				case log is CommandLog:
					result.push( 1 ); // log_type
					var command:Command = ( log as CommandLog ).command;
					switch ( true ) {
						case command is NetCommand:
							var netCommand:NetCommand = command as NetCommand;
							result.push(
								1,	// command_type
								netCommand.io,
								netCommand.num,
								netCommand.status
							);
							break;
						default:
							result.push( 0 );	 // command_type
							break;
					}
					result.push( netCommand.name );
					result.push.apply( null, command );
					break;
				
				case log is InfoLog:
					var infoLog:InfoLog = log as InfoLog;
					result.push(
						2, // log_type
						infoLog.text,
						infoLog.type
					);
					break;

				case log is TextLog:
					result.push(
						3, // log_type
						( log as TextLog ).text
					);
					break;
				
				default:
					result.push( 0 ); // log_type
					break;
			}
			
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ConsoleDispatcher(logger:Logger=null) {
			super();
			this._connection.allowDomain( '*' );
			this._connection.allowInsecureDomain( '*' );
			this._connection.client = new Client( this );
			this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_securityError, false, 0, true );
			this._connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, this.handler_asyncError, false, 0, true );
			this._connection.addEventListener( StatusEvent.STATUS, this.handler_status, false, 0, true );
			if ( logger ) this.logger = logger;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _connection:LocalConnection = new LocalConnection( '__blooddy_console' );

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _logger:Logger;
		
		public function get logger():Logger {
			return this._logger;
		}
		
		/**
		 * @private
		 */
		public function set logger(value:Logger):void {
			if ( this._logger === value ) return;
			if ( this._logger ) {
				this._logger.removeEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
				if ( this._connection.connected ) {
					this._connection.close();
				}
			}
			this._logger = value;
			if ( this._logger ) {
				this._logger.addEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
				do {
					try {
						this._connection.open( '__blooddy_console_' + UID.generate() );
						break;
					} catch ( e:* ) {
					}
				} while ( true );
			}
		}

		/**
		 * @private
		 */
		$private var $client:IAbstractRemoter;
		
		public function get client():IAbstractRemoter {
			return this.$client;
		}

		/**
		 * @private
		 */
		public function set client(value:IAbstractRemoter):void {
			if ( this.$client === value ) return;
			this.$client = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedLog(event:LogEvent):void {
			this._connection.call( 'addLog', null, this._connection.name, serializeLog( event.log ) );
		}

		/**
		 * @private
		 */
		private function handler_asyncError(event:AsyncErrorEvent):void {
			trace( 'dispatcher', event );
		}

		/**
		 * @private
		 */
		private function handler_status(event:StatusEvent):void {
			if ( event.type == 'error' || event.type == 'warning' ) {
			trace( 'dispatcher', event );
			}
		}

		/**
		 * @private
		 */
		private function handler_securityError(event:SecurityErrorEvent):void {
			trace( 'dispatcher', event );
		}

	}

}

import by.blooddy.core.logging.ConsoleDispatcher;
import by.blooddy.core.net.Responder;

internal namespace $private;

use namespace $private;

/**
 * @private
 */
internal final class Client {

	public function Client(target:ConsoleDispatcher) {
		super();
		this._target = target;
	}

	/**
	 * @private
	 */
	private var _target:ConsoleDispatcher;
	
	public function call(commandName:String, parameters:Array=null):* {
		if ( this._target ) {
			parameters.unshift( commandName, Responder.DEFAULT_RESPONDER );
			return this._target.$client.call.apply( null, parameters );
		}
	}

}