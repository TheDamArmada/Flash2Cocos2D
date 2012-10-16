////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import by.blooddy.core.utils.proxy.ProxyEventDispatcher;

	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * класс, нужен для того, что бы при вызове у него неопределённымх методов,
	 * он перенаправлял это всё на remoter.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.09.2009 20:12:04
	 */
	public dynamic class RemoterProxy extends ProxyEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function RemoterProxy(remoter:IRemoter!) {
			super();
			this._remoter = remoter;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _remoter:IRemoter;

		public function get remoter():IRemoter {
			return this._remoter;
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
		//  Overriden flash_proxy methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		flash_proxy override function hasProperty(name:*) : Boolean {
			return name && ( name is QName || name is String );
		}

		/**
		 * @private
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( super.hasProperty( name ) ) {
				return super.getProperty( name );
			} else if ( name ) {
				var n:String = name.toString();
				var result:* = this._hash[ n ];
				if ( result == null ) {
					var app:RemoterProxy = this;
					this._hash[ n ] = result = function(...rest):* {
						return app.call( n, rest );
					}
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
				if ( !name ) throw new ReferenceError();
				return this.call( name.toString(), rest );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function call(methodName:String, args:Array):* {
			args.unshift( methodName, null );
			return this._remoter.call.apply( this._remoter, args );
		}

	}

}