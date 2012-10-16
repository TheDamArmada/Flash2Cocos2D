////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.events.commands.CommandEvent;
	import by.blooddy.core.utils.proxy.ProxyEventDispatcher;

	import flash.events.IEventDispatcher;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	[Event( name="command", type="by.blooddy.core.events.commands.CommandEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public dynamic class ProxyClient extends ProxyEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function ProxyClient(target:IEventDispatcher=null) {
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
		private var _qname:Object = new Object();

		/**
		 * @private
		 */
		private var _name:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy override function hasProperty(name:*):Boolean {
			return name && ( name is QName || name is String );
		}

		/**
		 * @private
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( super.hasProperty( name ) ) {
				return super.getProperty( name );
			} else if ( name ) {
				var result:*;
				if ( name is QName )	result = this._qname[ name.toString() ];
				else					result = this._name[ name ];
				if ( result == null ) {
					var app:ProxyClient = this;
					result = function(...rest):* {
						return app.dispatchCommand( name, rest );
					};
					if ( name is QName )	this._qname[ name.toString() ] = result;
					else					this._name[ name ] = result;
				}
				return result;
			}
		}

		/**
		 * @private
		 */
		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( super.hasProperty( name ) ) {
				rest.unshift( name );
				return super.callProperty.apply( this, rest );
			} else if ( name ) {
				return this.dispatchCommand( name, rest );
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
		private function dispatchCommand(name:*, args:Array=null):Boolean {
			return super.dispatchEvent( new CommandEvent( CommandEvent.COMMAND, false, false, new Command( name.toString(), args ) ) );
		}

	}

}