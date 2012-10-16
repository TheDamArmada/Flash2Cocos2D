////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="_parent" )]
	[Exclude( kind="property", name="_name" )]
	[Exclude( kind="property", name="_metadata" )]
	[Exclude( kind="property", name="_metadata_local" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 0:37:29
	 */
	public class DefinitionInfo extends AbstractInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected static const _EMPTY_METADATA:XMLList = new XMLList();

		/**
		 * @private
		 */
		private static const _SKIP_METADATA:Object = {
			'__go_to_ctor_definition_help': true,
			'__go_to_definition_help': true
		};
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DefinitionInfo() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected var _parent:DefinitionInfo;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected var _name:QName;

		public function get name():QName {
			return this._name;
		}

		/**
		 * @private
		 */
		$protected var _metadata:XMLList;

		/**
		 * @private
		 */
		$protected var _metadata_local:XMLList;

		public function getMetadata(local:Boolean=false):XMLList {
			if ( local ) {
				return this._metadata_local.copy();
			} else {
				return this._metadata.copy();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = <definition />;
			xml.appendChild( local ? this._metadata_local : this._metadata );
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function parse(o:Object):void {
			var i:uint;
			var list:XMLList;
			if ( o.metadata && o.metadata.length > 0 ) {
				list = new XMLList();
				var m:XML;
				var a:XML;
				for each ( o in o.metadata ) {
					if ( o.name in _SKIP_METADATA ) continue;
					m = <metadata />;
					m.@name = o.name;
					for each ( o in o.value ) {
						a = <arg />;
						if ( 'key' in o ) a.@key = o.key;
						if ( 'value' in o ) a.@value = o.value;
						m.appendChild( a );
					};
					list[ i++ ] = m;
				}
			}
			if ( i > 0 ) {
				this._metadata_local = list;
				if ( !this._parent || this._parent._metadata === _EMPTY_METADATA ) {
					this._metadata = list;
				} else {
					this._metadata = list + this._parent._metadata;
				}
			} else {
				this._metadata_local = _EMPTY_METADATA;
				this._metadata = ( this._parent ? this._parent._metadata : _EMPTY_METADATA );
			}
		}

	}

}