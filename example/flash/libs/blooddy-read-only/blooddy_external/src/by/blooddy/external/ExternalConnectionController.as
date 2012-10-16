////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external {
	
	import by.blooddy.core.controllers.BaseController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.external.ExternalConnection;
	import by.blooddy.core.net.ProxySharedObject;
	
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.10.2009 23:50:26
	 */
	public class ExternalConnectionController extends BaseController {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ExternalConnectionController(container:DisplayObjectContainer, sharedObject:ProxySharedObject) {
			super( container, new DataBase(), sharedObject );
			this._external = new ExternalConnection( container.loaderInfo.parameters.externalID );
			this._external.logging = false;
			this._external.addEventListener( Event.CONNECT,						this.handler_connect, false, int.MAX_VALUE, true );
			this._external.addEventListener( Event.CLOSE,						this.handler_close, false, int.MAX_VALUE, true );
			this._external.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error, false, int.MAX_VALUE, true );
			this._external.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error, false, int.MAX_VALUE, true );
			this._external.addEventListener( AsyncErrorEvent.ASYNC_ERROR,		this._external.dispatchEvent, false, int.MAX_VALUE, true );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _external:ExternalConnection;

		public function get externalConnection():ExternalConnection {
			return this._external;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected virtual function construct():void {
			throw new IllegalOperationError();
		}

		protected virtual function destruct():void {
			throw new IllegalOperationError();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			trace( event );
		}
		
		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			this.construct();
		}

		/**
		 * @private
		 */
		private function handler_close(event:Event):void {
			this.destruct();
		}
		
	}
	
}