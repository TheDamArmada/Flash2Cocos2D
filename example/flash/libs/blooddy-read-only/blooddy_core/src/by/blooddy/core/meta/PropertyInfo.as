////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	import by.blooddy.core.utils.ClassUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 2:11:47
	 */
	public final class PropertyInfo extends MemberInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ACCESS_READ:uint =			1;

		public static const ACCESS_WRITE:uint =			2;

		public static const ACCESS_READ_WRITE:uint =	0;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _ACCESS_VALUES:Object = {
			readonly: ACCESS_READ,
			writeonly: ACCESS_WRITE,
			readwrite: ACCESS_READ_WRITE
		};

		/**
		 * @private
		 */
		private static const _ACCESS_STRINGS:Object = {
			1: 'readonly',
			2: 'writeonly',
			0: 'readwrite'
		};
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function PropertyInfo() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get parent():PropertyInfo {
			return this._parent as PropertyInfo;
		}

		/**
		 * @private
		 */
		$protected var _access:uint;

		public function get access():uint {
			return this._access;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = super.toXML( local );
			xml.setLocalName( 'property' );
			xml.@type = this._type;
			xml.@access = _ACCESS_STRINGS[ this._access ];
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function parse(o:Object):void {
			super.parse( o );
			if ( this._parent ) { // нефига парсить лишний раз
				this._type = ( this._parent as PropertyInfo )._type;
			} else {
				this._type = ClassUtils.parseClassQName( o.type );
			}
			this._access = _ACCESS_VALUES[ o.access ];
		}

	}

}