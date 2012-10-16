////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
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
	public dynamic class AbstractClient extends ProxyEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function AbstractClient(target:IEventDispatcher=null) {
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
		private var _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( super.hasProperty( name ) ) {
				return super.getProperty( name );
			} else {
				var n:String = name.toString();
				var result:* = this._hash[ n ];
				if ( result == null ) {
					var app:AbstractClient = this;
					this._hash[ n ] = result = function(...rest):* {
						rest.unshift( n );
						return app.callProperty.apply( null, rest );
					};
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
			} else {
				return super.dispatchEvent( new CommandEvent( CommandEvent.COMMAND, false, false, new Command( name.toString(), rest ) ) );
			}
		}

	}

}