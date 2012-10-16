////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.meta {

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="_owner" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.03.2010 2:08:41
	 */
	public class MemberInfo extends DefinitionInfo implements ITypedInfo {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MemberInfo() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected var _type:QName;

		/**
		 * @inheritDoc
		 */
		public function get type():QName {
			return this._type;
		}

		$protected var _owner:TypeInfo;

		public function get owner():TypeInfo {
			return this._owner;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = super.toXML( local );
			xml.@name = this._name.localName;
			if ( this._name.uri ) {
				xml.@uri = this._name.uri;
			}
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function parse(o:Object):void {
			super.parse( o );
			if ( this._parent ) {
				this._name = this._parent._name;
			}
		}

	}

}