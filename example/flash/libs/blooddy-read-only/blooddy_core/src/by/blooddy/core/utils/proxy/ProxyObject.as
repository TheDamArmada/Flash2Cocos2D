////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.proxy {

	import flash.utils.ByteArray;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Dictionary;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					proxyobject, proxy, object
	 */
	public dynamic class ProxyObject extends Proxy {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_px;

		use namespace $protected_px;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function ProxyObject(target:Object) {
			super();

			if ( typeof target != 'object' ) throw new TypeError();
			if ( !target ) throw new ArgumentError();

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
		private var _target:Object;

		/**
		 * @private
		 */
		private var _keys:Array;

		/**
		 * @private
		 */
		private const _proxies:Object = new Object();

		/**
		 * @private
		 */
		private var _parents:Dictionary;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function valueOf():Object {
			return this._target;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden flash_proxy methods: Proxy
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			return name in this._proxies || name in this._target;
		}

		flash_proxy override function getProperty(name:*):* {
			if ( name in this._proxies ) {

				return this._proxies[ name ];

			} else if ( name in this._target ) {

				var value:* = this._target[ name ];
				if (
					value &&
					typeof value == 'object' &&
					!( value is Array ) &&
					!( value is Date ) &&
					!( value is ByteArray )
				) {

					value = this.setProxyProperty( name, value );

				}
				return value;

			}
		}

		flash_proxy override function setProperty(name:*, value:*):void {

			if ( this._target[ name ] === value ) return;

			if ( value is ProxyObject ) {

				var p:ProxyObject = value as ProxyObject;

				if ( name in this._proxies ) {
					if ( this._proxies[ name ] === p ) return;
					else this.deleteProxyProperty( name );
				}

				this._proxies[ name ] = p;
				if ( !p._parents ) p._parents = new Dictionary();
				p._parents[ this ] = name;

				if ( p._target != this._target[ name ] ) {

					this._target[ name ] = p._target;
					this.bubble( name );

				}

			} else {

				this._target[ name ] = value;

				if ( name in this._proxies ) {
					this.deleteProxyProperty( name );
				}

				if (
					value &&
					typeof value == 'object' &&
					!( value is Array ) &&
					!( value is Date ) &&
					!( value is ByteArray )
				) {

					this.setProxyProperty( name, value );

				}

				this.bubble( name );

			}

		}

		flash_proxy override function deleteProperty(name:*):Boolean {
			var result:Boolean;
			if ( name in this._target ) {
				result = delete this._target[ name ];
			}
			if ( result ) {
				if ( name in this._proxies ) {
					this.deleteProxyProperty( name );
					if ( this._keys.pop() != name ) {
						this._keys = null;
					}
				}
				this.bubble( name );
			}
			return result;
		}

		flash_proxy override function callProperty(name:*, ...rest):* {
			var f:* = this._target[ name ];
			if ( f ) {
				if ( f is Function ) {
					return ( f as Function ).apply( null, rest );
				}
				Error.throwError( TypeError, 1006, name );
			}
			Error.throwError( ReferenceError, 1069, name, getQualifiedClassName( this._target ) );
		}

		flash_proxy override function nextNameIndex(index:int):int {
			if ( !this._keys ) {
				this._keys = new Array();
				for ( var i:Object in this._target ) {
					this._keys.push( i );
				}
			}
			return ( !index ? this._keys.length : index - 1 );
		}

		flash_proxy override function nextName(index:int):String {
			return ( this._keys ? this._keys[ index - 1 ] : null );
		}

		flash_proxy override function nextValue(index:int):* {
			if ( this._keys ) {
				return this.getProperty( this._keys[ index - 1 ] );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected_px function bubble(name:String, path:Vector.<String>=null, hash:Dictionary=null):void {
			if ( !hash ) hash = new Dictionary();
			else if ( this in hash ) return; // рекурсии нас не интерисуют
			if ( !path ) path = new Vector.<String>();
			path.push( name );
			hash[ this ] = true;
			for ( var o:Object in this._parents ) {
				( o as ProxyObject ).bubble( this._parents[ o ], path, hash );
			}
			delete hash[ this ];
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function setProxyProperty(name:*, value:*):ProxyObject {
			var p:ProxyObject = new ProxyObject( value );
			p._parents = new Dictionary();
			p._parents[ this ] = name;
			this._proxies[ name ] = p;
			if ( this._keys ) {
				this._keys.push( name );
			}
			return p;
		}

		/**
		 * @private
		 */
		private function deleteProxyProperty(name:*):void {
			var p:ProxyObject = this._proxies[ name ];
			delete p._parents[ this ];
			delete this._proxies[ name ];
		}

	}

}