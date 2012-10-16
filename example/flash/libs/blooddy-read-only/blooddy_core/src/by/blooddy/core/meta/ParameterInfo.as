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
	 * @created					06.03.2010 13:08:12
	 */
	public final class ParameterInfo extends AbstractInfo implements ITypedInfo {

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
		public function ParameterInfo() {
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

		/**
		 * @private
		 */
		$protected var _optional:Boolean;

		public function get optional():Boolean {
			return this._optional;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML(local:Boolean=false):XML {
			var result:XML = <parameter />;
			result.@type = this._type;
			if ( this._optional ) result.@optional = this._optional;
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function parse(o:Object):void {
			this._type = ClassUtils.parseClassQName( o.type );
			this._optional = o.optional;
		}

	}

}