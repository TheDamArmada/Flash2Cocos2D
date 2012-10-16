////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import by.blooddy.core.utils.ClassUtils;

	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxy, object
	 */
	public dynamic class Proxy extends flash.utils.Proxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Proxy() {
			super();
			var c:Class;
			this._constructor = c = ClassUtils.getClassFromName( this );
			if ( c && c.prototype ) {
				this._prototype = c.prototype;
			} else {
				c = ClassUtils.getSuperclassFromName( this );
				if ( c && c.prototype ) {
					this._prototype = c.prototype;
				} else {
					this._prototype = prototype;
				}
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
		private var _constructor:Class;

		/**
		 * @private
		 */
		private var _prototype:Object;

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: flash.utils.Proxy
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		flash_proxy override function hasProperty(name:*):Boolean {
			return name in this._prototype;
		}

		/**
		 * @inheritDoc
		 */
		flash_proxy override function getProperty(name:*):* {
			if ( name in this._prototype ) {
				if ( name == 'constructor' ) return this._constructor;
				return this._prototype[ name ];
			}
		}

		/**
		 * @inheritDoc
		 * 
		 * @throws	ReferenceError
		 */
		flash_proxy override function setProperty(name:*, value:*):void {
			Error.throwError( ReferenceError, 1056, name, getQualifiedClassName( this ) );
		}

		/**
		 * @inheritDoc
		 */
		flash_proxy override function deleteProperty(name:*):Boolean {
			return false;
		}

		/**
		 * @inheritDoc
		 * 
		 * @throws	TypeError
		 * @throws	ReferenceError
		 */
		flash_proxy override function callProperty(name:*, ...rest):* {
			var f:* = this._prototype[ name ];
			if ( f ) {
				if ( f is Function ) {
					return ( f as Function ).apply( this, rest );
				}
				Error.throwError( TypeError, 1006, name );
			}
			Error.throwError( ReferenceError, 1069, name, getQualifiedClassName( this ) );
		}

		/**
		 * @inheritDoc
		 * 
		 * @throws	TypeError
		 */
		flash_proxy override function getDescendants(name:*):* {
			Error.throwError( TypeError, 1016, getQualifiedClassName( this ) );
		}

		/**
		 * @inheritDoc
		 */
		flash_proxy override function nextNameIndex(index:int):int {
			return 0;
		}

		/**
		 * @inheritDoc
		 */
		flash_proxy override function nextName(index:int):String {
			return null;
		}

		/**
		 * @inheritDoc
		 */
		flash_proxy override function nextValue(index:int):* {
		}

	}

}