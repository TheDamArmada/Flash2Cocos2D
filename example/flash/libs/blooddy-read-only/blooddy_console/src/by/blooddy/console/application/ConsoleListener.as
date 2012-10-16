////////////////////////////////////////////////////////////////////////////////
//
//  © 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.console.application {
	
	import by.blooddy.console.display.LogField;
	import by.blooddy.console.display.LogTab;
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.controllers.BaseController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.display.text.BaseTextField;
	import by.blooddy.core.logging.InfoLog;
	import by.blooddy.core.logging.Log;
	import by.blooddy.core.logging.Logger;
	import by.blooddy.core.logging.TextLog;
	import by.blooddy.core.logging.commands.CommandLog;
	import by.blooddy.core.managers.KeyboardManager;
	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.net.connection.LocalConnection;
	import by.blooddy.crypto.serialization.JSON;
	
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.events.SecurityErrorEvent;

	[SWF( width="1024", height="768", frameRate="60", backgroundColor="#777777", scriptTimeLimit="60" )]
	[Frame( factoryClass="by.blooddy.factory.ApplicationFactory" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.02.2011 13:19:22
	 */
	public class ConsoleListener extends BaseController {
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static function deserializeLog(arr:Array):Log {
			var result:Log;
			
			switch ( arr.shift() ) {
				case 1:
					var command:Command;
					switch ( arr.shift() ) {
						case 1:
							var io:String = arr.shift();
							var num:uint = arr.shift();
							var status:Boolean = arr.shift();
							var netCommand:NetCommand = new NetCommand( arr.shift(), io, arr );
							netCommand.num = num;
							netCommand.status = status;
							command = netCommand;
							break;
						default:
							command = new Command( arr.shift(), arr );
							break;
					}
					result = new CommandLog( command );
					break;

				case 2:
					result = new InfoLog( arr.shift(), arr.shift() );
					break;

				case 3:
					result = new TextLog( arr.shift() );
					break;

				default:
					result = new Log();
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
		public function ConsoleListener(stage:Stage) {
			super( stage, new DataBase(), ProxySharedObject.getLocal( 'blooddy_console' ) );

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			var i:uint = 0;
			this._connection.allowDomain( '*' );
			this._connection.allowInsecureDomain( '*' );
			this._connection.open( '__blooddy_console' );
			this._connection.client = this;
			this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_securityError, false, 0, true );
			this._connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, this.handler_asyncError, false, 0, true );
			this._connection.addEventListener( StatusEvent.STATUS, this.handler_status, false, 0, true );

			this._logFiled.name = 'log';
			this._logFiled.y = 25;
			this._logFiled.width = stage.stageWidth;
			this._logFiled.height = stage.stageHeight - 40 - 25;
			stage.addChild( this._logFiled );

			this._input.defaultTextFormat = new TextFormat( '_sans', 16, 0xFFFFFF, true );
			this._input.background = true;
			this._input.backgroundColor = 0x333333;
			this._input.y = stage.stageHeight - 40;
			this._input.width = stage.stageWidth;
			this._input.height = 40;
			this._input.type = TextFieldType.INPUT;
			this._input.mouseEnabled = true;
			stage.addChild( this._input );

			var key:KeyboardManager = KeyboardManager.getManager( this._input );
			key.addKeyboardEventListener( KeyboardEvent.KEY_UP, this.handler_ENTER, false, 0, false, Keyboard.ENTER );
			
			stage.addEventListener( Event.RESIZE, this.handler_resize );
			stage.addEventListener( MouseEvent.CLICK, this.handler_click );
			stage.addEventListener( MouseEvent.DOUBLE_CLICK, this.handler_doubleClick );

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private const _list:Vector.<$Logger> = new Vector.<$Logger>();
		
		/**
		 * @private
		 */
		private const _hash_tab:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private var _selectedLogger:$Logger;

		/**
		 * @private
		 */
		private const _logFiled:LogField = new LogField();

		/**
		 * @private
		 */
		private const _input:BaseTextField = new BaseTextField();
		
		/**
		 * @private
		 */
		private const _connection:LocalConnection = new LocalConnection();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function call(commandName:String, responder:Responder=null, ...parameters):* {
			parameters.unshift( commandName, responder );
			return this._connection.call.apply( null, parameters );
		}

		//--------------------------------------------------------------------------
		//
		//  Commands
		//
		//--------------------------------------------------------------------------

		public function addLog(target:String, logData:Array):void {
			if ( !( target in this._hash ) ) {
				this.addLogger( target );
			}
			this._hash[ target ].addLog( deserializeLog( logData ) );
		}

		public function $close():void {
			for each ( var logger:$Logger in this._list ) {
				this.removeLogger( logger.name );
			}
			this._connection.close();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addLogger(name:String):void {
			var logger:$Logger = new $Logger( name );
			this._hash[ name ] = logger;
			this._list.push( logger );
			var tab:LogTab = new LogTab();
			tab.logger = logger;
			tab.text = 'log' + this._list.length;
			this._hash_tab[ logger ] = tab;
			super.container.addChildAt( tab, 0 );
			this.selectLogger( logger );
			this.updateTabsPosition();
		}

		/**
		 * @private
		 */
		private function removeLogger(name:String):void {
			var logger:$Logger = this._hash[ name ];
			delete this._hash[ name ];
			var tab:LogTab = this._hash_tab[ logger ];
			tab.logger = null;
			this._hash_tab[ logger ];
			super.container.removeChild( tab );
			var i:int = this._list.indexOf( logger );
			this._list.splice( i, 1 );
			if ( this._selectedLogger === logger ) {
				this.selectLogger( this._list.length > 0 ? this._list[ 0 ] : null );
			}
			this.updateTabsPosition();
		}

		/**
		 * @private
		 */
		private function selectLogger(logger:$Logger):void {
			if ( this._selectedLogger ) {
				this._hash_tab[ this._selectedLogger ].deselect();
			}
			this._selectedLogger = logger;
			this._logFiled.logger = logger;
			if ( this._selectedLogger ) {
				this._connection.targetName = logger.name;
				this._hash_tab[ this._selectedLogger ].select();
			} else {
				this._connection.targetName = null;
			}
		}

		/**
		 * @private
		 */
		private function updateTabsPosition():void {
			var tab:LogTab;
			var logger:$Logger;
			for ( var i:uint = 0; i < this._list.length; ++i ) {
				logger = this._list[ i ];
				tab = this._hash_tab[ logger ];
				tab.x = 80 * i;
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
		private function handler_asyncError(event:AsyncErrorEvent):void {
			trace( 'listener', event );
		}

		/**
		 * @private
		 */
		private function handler_status(event:StatusEvent):void {
			if ( event.code == 'error' && event.code == 'warinig' ) {
				trace( 'listener', event );
			}
		}

		/**
		 * @private
		 */
		private function handler_securityError(event:SecurityErrorEvent):void {
			trace( 'listener', event );
		}

		/**
		 * @private
		 */
		private function handler_resize(event:Event):void {
			this._logFiled.width = super.container.stage.stageWidth;
			this._logFiled.height = super.container.stage.stageHeight - 40 - 25;
			this._input.width = super.container.stage.stageWidth;
			this._input.y = super.container.stage.stageHeight - 40;
		}

		/**
		 * @private
		 */
		private function handler_click(event:MouseEvent):void {
			if ( event.target is LogTab ) {
				this.selectLogger( event.target.logger );
			}
		}

		/**
		 * @private
		 */
		private function handler_doubleClick(event:MouseEvent):void {
			if ( event.target is LogTab ) {
				this.removeLogger( event.target.logger.name );
			}
		}

		/**
		 * @private
		 */
		private function handler_ENTER(event:KeyboardEvent):void {
			if ( !this._selectedLogger ) return;
			var arr:Array;
			var i:int = this._input.text.indexOf( ',' );
			var name:String;
			if ( i < 0 ) {
				name = this._input.text;
				arr = new Array();
			} else {
				name = this._input.text.substring( 0, i );
				arr = JSON.decode( '[' + this._input.text.substr( i + 1 ) + ']' );
			}
			try {
				name = JSON.decode( name );
			} catch ( e:* ) {
			}
			this._connection.call( 'call', null, name, arr );
		}
		
		
	}
	
}

import by.blooddy.core.logging.Logger;

/**
 * @private
 */
internal final class $Logger extends Logger {

	public function $Logger(name:String) {
		super();
		this.name = name;
	}

	public var name:String;

}