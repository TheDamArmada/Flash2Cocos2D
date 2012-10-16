////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.core.utils.proxy.Proxy;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;

	use namespace flash_proxy;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					17.05.2010 15:07:47
	 */
	public dynamic class DisplayObjectContainerProxy extends Proxy {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function DisplayObjectContainerProxy(container:DisplayObjectContainer) {
			super();
			this._container = container;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function valueOf():DisplayObjectContainer {
			return this._container;
		}

		//--------------------------------------------------------------------------
		//
		//  flash_proxy methods
		//
		//--------------------------------------------------------------------------

		flash_proxy override function hasProperty(name:*):Boolean {
			if ( super.isAttribute( name ) ) {
				return new QName( name.uri, name.localName ) in this._container;
			} else {
				if ( name is QName ) name = name.toString();
				else if ( ( !name is String ) ) throw new ArgumentError();
				return Boolean( this._container.getChildByName( name ) );
			}
		}

		flash_proxy override function getProperty(name:*):* {
			if ( super.isAttribute( name ) ) {
				return this._container[ new QName( name.uri, name.localName ) ];
			} else {
				if ( name is QName ) name = name.toString();
				else if ( ( !name is String ) ) throw new ArgumentError();
				return this._container.getChildByName( name );
			}
		}

		flash_proxy override function setProperty(name:*, value:*):void {
			if ( !super.isAttribute( name ) ) {
				Error.throwError( IllegalOperationError, 0 );
			}
			this._container[ name ] = value;
		}

		flash_proxy override function deleteProperty(name:*):Boolean {
			if ( !super.isAttribute( name ) ) {
				Error.throwError( IllegalOperationError, 0 );
			}
			return delete this._container[ name ];
		}

		flash_proxy override function callProperty(name:*, ...rest):* {
			if ( !super.isAttribute( name ) ) {
				Error.throwError( IllegalOperationError, 0 );
			}
			var f:* = this._container[ name ];
			if ( f ) {
				if ( f is Function ) {
					return ( f as Function ).apply( this._container, rest );
				}
				Error.throwError( TypeError, 1006, name );
			}
			Error.throwError( ReferenceError, 1069, name, getQualifiedClassName( this._container ) );
		}

		flash_proxy override function getDescendants(name:*):* {
			if ( super.isAttribute( name ) ) {
				Error.throwError( IllegalOperationError, 0 );
			}
			if ( name is QName ) name = name.toString();
			else if ( ( !name is String ) ) throw new ArgumentError();
			return DisplayObjectUtils.getDescendants( this._container, name );
		}

		flash_proxy override function nextNameIndex(index:int):int {
			Error.throwError( IllegalOperationError, 0 );
			return 0;
		}

		flash_proxy override function nextName(index:int):String {
			Error.throwError( IllegalOperationError, 0 );
			return null;
		}

		flash_proxy override function nextValue(index:int):* {
			Error.throwError( IllegalOperationError, 0 );
		}

	}

}