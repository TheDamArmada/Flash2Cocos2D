////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.commands {

	import by.blooddy.core.events.commands.CommandEvent;

	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * какая-то ошибка при исполнении.
	 */
	[Event( name="asyncError", type="flash.events.AsyncErrorEvent" )]	
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 16:48:52
	 */
	public class CommandDispatcher extends EventDispatcher implements ICommandDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		protected namespace $protected;

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const PREFIX:String = 'command_';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CommandDispatcher(target:ICommandDispatcher=null) {
			super( target );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _listeners:Dictionary = new Dictionary( true );

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function dispatchCommand(command:Command):void {
			super.dispatchEvent( new CommandEvent( PREFIX + command.name, false, false, command ) );
		}

		/**
		 * @inheritDoc
		 */
		public function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void {
			var commandListener:CommandEventListener = this._listeners[ listener ];
			if ( !commandListener ) this._listeners[ listener ] = commandListener =  new CommandEventListener( this, listener );
			super.addEventListener( PREFIX + commandName, commandListener.handler, false, priority, useWeakReference );
		}

		/**
		 * @inheritDoc
		 */
		public function removeCommandListener(commandName:String, listener:Function):void {
			var commandListener:CommandEventListener = this._listeners[ listener ];
			if ( commandListener ) {
				super.removeEventListener( PREFIX + commandName, commandListener.handler );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function hasCommandListener(commandName:String):Boolean {
			return super.hasEventListener( PREFIX + commandName );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		$protected final function dispatchError(e:*):void {
			if ( super.hasEventListener( AsyncErrorEvent.ASYNC_ERROR ) ) {
				super.dispatchEvent( new AsyncErrorEvent( AsyncErrorEvent.ASYNC_ERROR, false, false, String( e ), e as Error ) );
			}
		}

		$private final function dispatchError(e:*):void {
			this.dispatchError( e );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.commands.CommandDispatcher;
import by.blooddy.core.events.commands.CommandEvent;

internal namespace $private;

use namespace $private;

/**
 * @private
 */
internal final class CommandEventListener {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function CommandEventListener(dispatcher:CommandDispatcher, listener:Function) {
		super();
		this.dispatcher = dispatcher;
		this.listener = listener;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var dispatcher:CommandDispatcher;

	public var listener:Function;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public function handler(event:CommandEvent):void {
		try {
			this.listener.apply( null, event.command );
		} catch ( e:* ) {
			this.dispatcher.dispatchError( e );
		}
	}

}