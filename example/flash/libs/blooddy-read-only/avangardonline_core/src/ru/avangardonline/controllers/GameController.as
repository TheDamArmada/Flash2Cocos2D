////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.controllers {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.BaseController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.external.ExternalConnection;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.net.RemoterProxy;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.LoaderListener;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	import ru.avangardonline.controllers.battle.BattleController;
	import ru.avangardonline.controllers.battle.BattleLogicalController;
	import ru.avangardonline.data.battle.BattleData;
	import ru.avangardonline.serializers.battle.BattleDataSerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class GameController extends BaseController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function GameController(container:DisplayObjectContainer) {
			super( container, new DataBase(), ProxySharedObject.getLocal( 'avangard' ) );

			this._relativeTime.speed = 0;

			this._battleContainer = new Sprite();
			super.container.addChild( this._battleContainer );

			this._battleLogicalController =	new BattleLogicalController	( this );
			this._battleController =		new BattleController		( this, this._relativeTime, this._battleContainer );

			this._battleLogicalController.logging = true;
			
			var params:Object = container.loaderInfo.parameters;
			if ( params.battleURI ) {
				this.setBattle( params.battleURI );
			} else {
				this.setBattle( '1.txt' );
			}
			if ( params.externalID ) {
				this._externalConnection = new ExternalConnection( params.externalID );
				this._externalConnection.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_external_error, false, int.MAX_VALUE, true );
				this._externalConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_external_error, false, int.MAX_VALUE, true );
				this._externalConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR,			this.handler_external_error, false, int.MAX_VALUE, true );
				this._externalConnection.addCommandListener( 'setBattle', this.setBattle );
				var proxy:RemoterProxy = new RemoterProxy( this._externalConnection );
				this._battleLogicalController.addCommandListener( 'setTurn', proxy.setTurn );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:LoaderListener;

		/**
		 * @private
		 */
		private var _battleContainer:Sprite;

		/**
		 * @private
		 */
		private var _currentBattle:String;

		/**
		 * @private
		 */
		private var _loadedBattle:String;

		/**
		 * @private
		 */
		private var _battleController:BattleController;

		/**
		 * @private
		 */
		private var _battleLogicalController:BattleLogicalController;

		/**
		 * @private
		 */
		private var _externalConnection:ExternalConnection;

		/**
		 * @private
		 */
		private const _relativeTime:RelativeTime = new RelativeTime( 0 );

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function call(commandName:String, ...parameters):* {
			parameters.unshift( commandName );
			if ( commandName != 'closeBattle' ) {
				return this._battleLogicalController.call.apply( null, parameters );
			} else {
				super.container.removeChild( this._battleContainer );
				this._battleContainer = null;
				this._battleController = null;
				this._battleLogicalController.battle = null
				this._battleLogicalController = null;
				if ( this._externalConnection.connected ) {
					return this._externalConnection.call.apply( null, parameters );
				}
			}
		}

		public override function dispatchCommand(command:Command):void {
			Error.throwError( IllegalOperationError, 2014 );
		}

		public override function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void {
			this._battleLogicalController.addCommandListener( commandName, listener, priority, useWeakReference );
		}

		public override function removeCommandListener(commandName:String, listener:Function):void {
			this._battleLogicalController.removeCommandListener( commandName, listener );
		}

		public override function hasCommandListener(commandName:String):Boolean {
			return this._battleLogicalController.hasCommandListener( commandName );
		}

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if ( type.indexOf( 'command_' ) == 0 )	this._battleLogicalController.addEventListener( type, listener, useCapture, priority, useWeakReference );
			else									super.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			if ( type.indexOf( 'command_' ) == 0 )	this._battleLogicalController.removeEventListener( type, listener, useCapture );
			else									super.removeEventListener( type, listener, useCapture );
		}

		public override function hasEventListener(type:String):Boolean {
			if ( type.indexOf( 'command_' ) == 0 )	return this._battleLogicalController.hasEventListener( type );
			else									return super.hasEventListener( type );
		}

		public override function willTrigger(type:String):Boolean {
			if ( type.indexOf( 'command_' ) == 0 )	return this._battleLogicalController.willTrigger( type );
			else									return super.willTrigger( type );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function setBattle(uri:String):void {
			if ( this._currentBattle == uri ) return;
			this._currentBattle = uri;
			this.updateBattle();
		}

		/**
		 * @private
		 */
		private function updateBattle(event:Event=null):void {
			var loader:ILoadable;

			if ( this._loadedBattle ) {
				loader = ResourceManager.manager.loadResourceBundle( this._loadedBattle );
				if ( loader ) {
					loader.removeEventListener( Event.COMPLETE,						this.updateBattle );
					loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.updateBattle );
					loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.updateBattle );
				}
			}

			this._battleLogicalController.battle = null;

			this._loadedBattle = this._currentBattle;

			loader = ResourceManager.manager.loadResourceBundle( this._loadedBattle );
			if ( loader.complete ) {
				var txt:String = ResourceManager.manager.getResource( this._loadedBattle, null );
				if ( !txt ) {
					this.error( 'Произошла ошибка загрзуки боя.' );
				} else {
					var battle:BattleData = new BattleData( this._relativeTime )
					try {

						BattleDataSerializer.deserialize( txt, battle );

						this._loader = new LoaderListener( container );
						this._loader.addEventListener( Event.COMPLETE, this.handler_loader_complete );

						this._relativeTime.speed = 0;
						this._battleLogicalController.battle = battle;

					} catch ( e:Error ) {
						this.error( 'Произошла ошибка обработки боя:\n' + ( e.getStackTrace() || e.toString() ) );
					}
				}
			} else {
				loader.addEventListener( Event.COMPLETE,					this.updateBattle );
				loader.addEventListener( IOErrorEvent.IO_ERROR,				this.updateBattle );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.updateBattle );
			}
		}

		/**
		 * @private
		 */
		private function error(txt:String):void {
			trace( txt );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_external_error(event:ErrorEvent):void {
			trace( event );
		}

		/**
		 * @private
		 */
		private function handler_loader_complete(event:Event):void {
			this._loader.removeEventListener( Event.COMPLETE, this.handler_loader_complete );
			this._loader = null;
			this._relativeTime.speed = 1;
		}

	}

}