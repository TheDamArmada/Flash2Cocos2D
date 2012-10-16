////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import by.blooddy.core.utils.proxy.Proxy;

	import flash.events.IEventDispatcher;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.10.2010 14:36:32
	 */
	public class CallbackProxy extends Proxy {

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function CallbackProxy(target:IEventDispatcher) {
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
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private var _target:IEventDispatcher;

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: flash.utils.Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			if ( name is QName ) {
				if ( name.uri ) throw new TypeError();
				name = name.localName;
			}
			if ( !( name is String ) ) throw new TypeError();
			return name in this._hash;
		}

		flash_proxy override function getProperty(name:*):* {
			if ( name is QName ) {
				if ( name.uri ) throw new TypeError();
				name = name.localName;
			}
			if ( !( name is String ) ) throw new TypeError();
			return this._hash[ name ];
		}

		flash_proxy override function setProperty(name:*, value:*):void {
			if ( name is QName ) {
				if ( name.uri ) throw new TypeError();
				name = name.localName;
			}
			if ( !( name is String ) ) throw new TypeError();
			if ( !( value is Function ) ) throw new TypeError();
			this._hash[ name ] = value;
			this._target.addEventListener( name, value );
		}

		flash_proxy override function deleteProperty(name:*):Boolean {
			if ( name is QName ) {
				if ( name.uri ) throw new TypeError();
				name = name.localName;
			}
			if ( !( name is String ) ) throw new TypeError();
			if ( !( value is Function ) ) throw new TypeError();
			if ( name in this._hash ) {
				var value:Function = this._hash[ name ];
				var result:Boolean = delete this._hash[ name ];
				if ( result ) {
					this._target.addEventListener( name, value );
				}
				return result;
			} else {
				return false;
			}
		}

	}

}