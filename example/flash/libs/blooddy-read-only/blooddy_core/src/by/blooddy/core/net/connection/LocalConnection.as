////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.core.utils.UID;
	
	import flash.errors.IOError;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	
	// TODO: log events

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]	
	
	[Event( name="status", type="flash.events.StatusEvent" )]	
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 20:49:37
	 */
	public class LocalConnection extends AbstractRemoter implements IConnection {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _JUNK:ByteArray = new ByteArray();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LocalConnection(targetName:String=null) {
			super();
			this._targetName = targetName;
			this._connection.client = new Client( this );
			this._connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	super.dispatchEvent, false, 0, true );
			this._connection.addEventListener( StatusEvent.STATUS,					super.dispatchEvent, false, 0, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _connection:flash.net.LocalConnection = new flash.net.LocalConnection();

		//--------------------------------------------------------------------------
		//
		//  Properties
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

		//----------------------------------
		//  name
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _name:String;
		
		public function get name():String {
			return this._name;
		}
		
		//----------------------------------
		//  targetName
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _targetName:String;

		public function get targetName():String {
			return this._targetName;
		}

		/**
		 * @private
		 */
		public function set targetName(value:String):void {
			if ( this._targetName == value ) return;
			this._targetName = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function open(name:String):void {
			if ( this._connected ) throw new ArgumentError();
			this._connection.connect( name );
			this._name = name;
			this._connected = true;
		}

		/**
		 * @copy flash.net.LocalConnection#close()
		 */
		public function close():void {
			if ( this._connected ) throw new ArgumentError();
			this._connection.close();
			this._name = null;
			this._connected = false;
		}

		/**
		 * @copy flash.net.LocalConnection#allowDomain()
		 */
		public function allowDomain(...parameters):void {
			this._connection.allowDomain.apply( null, parameters );
		}

		/**
		 * @copy flash.net.LocalConnection#allowInsecureDomain()
		 */
		public function allowInsecureDomain(...parameters):void {
			this._connection.allowInsecureDomain.apply( null, parameters );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function $callOutputCommand(command:Command):* {
			if ( !this._targetName ) throw new IOError();
			var option:uint = 0;
			_JUNK.writeObject( command.slice() );
			if ( _JUNK.length > 40e3 ) {
				option |= 1;
				_JUNK.compress();
			}
			var uid:String;
			var bytes:ByteArray;
			if ( _JUNK.length > 40e3 ) {
				option |= 2;
				_JUNK.position = 0;
				uid = UID.generate();
				bytes = new ByteArray();
				do {
					_JUNK.readBytes( bytes, 0, 40e3 );
					this._connection.send( this._targetName, '$', uid, null, option, bytes );
					bytes.length = 0;
				} while ( _JUNK.bytesAvailable > 40e3 );
				_JUNK.readBytes( bytes );
				option |= 4;
			} else {
				bytes = _JUNK;
			}
			this._connection.send( this._targetName, '$', uid, command.name, option, bytes );
			_JUNK.length = 0;

		}

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$private function $invokeCallInputCommand(name:String, args:Array):* {
			return super.$invokeCallInputCommand( new Command( name, args ) );
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.commands.Command;
import by.blooddy.core.net.connection.LocalConnection;

import flash.utils.ByteArray;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

internal namespace $private;

use namespace flash_proxy;
use namespace $private;

/**
 * @private
 */
internal final dynamic class Client extends Proxy {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Client(target:LocalConnection) {
		super();
		this._target = target;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var _target:LocalConnection;

	/**
	 * @private
	 */
	private const _methods_hash:Object = new Object();

	/**
	 * @private
	 */
	private const _parts_hash:Object = new Object();

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public function $(uid:String, name:String, option:uint, bytes:ByteArray):* {
		if ( option & 2 ) { // данные приходят кусками
			if ( uid in this._parts_hash ) {
				this._parts_hash[ uid ].writeBytes( bytes );
			} else {
				bytes.position = bytes.length;
				this._parts_hash[ uid ] = bytes;
			}
			if ( option & 4 ) {
				bytes = this._parts_hash[ uid ];
				delete this._parts_hash[ uid ];
			} else {
				bytes = null;
			}
		}
		if ( bytes ) {
			if ( option & 1 ) {
				bytes.uncompress();
			}
			var args:Array = bytes.readObject();
			return this._target.$invokeCallInputCommand( name, args );
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Overriden flash_proxy methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	flash_proxy override function hasProperty(name:*):Boolean {
		return true;
	}
	
	/**
	 * @private
	 */
	flash_proxy override function getProperty(name:*):* {
		var n:String = name.toString();
		var result:* = this._methods_hash[ n ];
		if ( result == null ) {
			var app:Client = this;
			this._methods_hash[ n ] = result = function(...rest):* {
				return app._target.$invokeCallInputCommand( n, rest );
			};
		}
		return result;
	}

	/**
	 * @private
	 */
	flash_proxy override function callProperty(name:*, ...parameters):* {
		this._target.$invokeCallInputCommand( name, parameters );
	}

}