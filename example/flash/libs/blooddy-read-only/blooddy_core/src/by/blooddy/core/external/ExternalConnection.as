////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.external {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.DynamicErrorEvent;
	import by.blooddy.core.events.DynamicEvent;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.net.connection.IConnection;
	import by.blooddy.core.utils.callLater;
	import by.blooddy.core.utils.copyObject;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="connect", type="flash.events.Event" )]

	[Event( name="ioError", type="flash.events.IOErrorEvent" )]

	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]

	[Event( name="close", type="flash.events.Event" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ExternalConnection extends AbstractRemoter implements IConnection {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _init:Boolean = false;

		/**
		 * @private
		 */
		private static var _PROXY_METHOD:String = '__flash__call';

		/**
		 * @private
		 */
		private static var _objectID:String = ExternalInterface.objectID;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function ExternalConnection(objectID:String=null) {
			super();
			if ( _init ) throw new ArgumentError();
			_init = true;
			if ( ExternalInterface.available ) {
				if ( _objectID ) {
					if ( objectID && _objectID != objectID ) {
						throw new ArgumentError();
					}
				} else {
					if ( !objectID ) throw new ArgumentError();
					_objectID = objectID;
				}
				ExternalInterface.addCallback( _PROXY_METHOD, this.$call );
			}
			callLater( this.init );
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IConnection
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  connected
		//----------------------------------

		/**
		 * @private
		 */
		private var _connected:Boolean = false;

		/**
		 * @inheritDoc
		 */
		public function get connected():Boolean {
			return this._connected;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IConnection
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function call(commandName:String, responder:Responder=null, ...parameters):* {
			if ( !this._connected ) throw new IllegalOperationError( 'соединение не установленно' );
			if ( responder ) throw new ArgumentError();
			return super.$invokeCallOutputCommand(
				new NetCommand( commandName, NetCommand.OUTPUT, parameters )
			);
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(event:Event):Boolean {
			var o:Object = copyObject( event.clone() ); // делаем клон, что бы разорвать связи
			delete o.type;
			delete o.bubbles;
			delete o.cancelable;
			delete o.eventPhase;
			delete o.target;
			delete o.currentTarget;
			return this.call(
				( event is ErrorEvent ? 'dispatchErrorEvent' : 'dispatchEvent' ),
				null,
				event.type,
				event.cancelable,
				o
			);
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {
			var parameters:Array = command.slice();
			parameters.unshift( _PROXY_METHOD, _objectID, command.name );
			return ExternalInterface.call.apply( ExternalInterface, parameters );
		}

		/**
		 * @private
		 */
		protected override function $callInputCommand(command:Command):* {
			switch ( command.name ) {

				case 'dispatchErrorEvent':
					var event:Event = new DynamicErrorEvent( command[ 0 ], false, command[ 1 ] );
				case 'dispatchEvent':
					if ( !event ) {
						event = new DynamicEvent( command[ 0 ], false, command[ 1 ] );
					}
					if ( command[ 2 ] ) {
						copyObject( command[ 2 ], event );
					}
					if ( command[ 1 ] ) { // синхронный ответ
						return super.dispatchEvent( event );
					} else {
						setTimeout( super.dispatchEvent, 1, event );
						return true;
					}

				case 'dispose':
					this._connected = false;
					super.dispatchEvent( new Event( Event.CLOSE ) );
					break;

				default:
					return	super.$callInputCommand( command );

			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function init():void {
			try {
				if ( !ExternalInterface.available ) {
					throw new IllegalOperationError( 'ExternalInterface не поддерживается' );
				}
				this._connected = true;
				if ( true !== this.call( 'dispatchEvent', null, Event.INIT ) ) {
					throw new IllegalOperationError( 'ExternalConnection не поддерживается' );
				}
				super.dispatchEvent( new Event( Event.CONNECT ) );
			} catch ( e:SecurityError ) { // bug fixing: ExternalInterface.available == true, but method ExternalInterface.call throws SecurityError
				this._connected = false;
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.toString(), e.errorID ) );
			} catch ( e:Error ) {
				this._connected = false;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString(), e.errorID ) );
			} catch ( e:* ) {
				this._connected = false;
				super.dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, String( e ) ) );
			}
		}

		/**
		 * @private
		 */
		private function $call(id:String, commandName:String, ...parameters):* {
			if ( id != _objectID ) {
				super.dispatchEvent( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, 'левое обращение' ) );
			} else {
				return super.$invokeCallInputCommand( new NetCommand( commandName, NetCommand.INPUT, parameters ) );
			}
		}

	}

}