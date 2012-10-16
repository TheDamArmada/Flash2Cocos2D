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
	 * @created					06.03.2010 2:22:30
	 */
	public final class MethodInfo extends MemberInfo implements IFunctionInfo {

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
		private static const _TYPE:QName = new QName( '', 'Function' );

		/**
		 * @private
		 */
		private static const _EMPTY_PARAMETERS:Vector.<ParameterInfo> = new Vector.<ParameterInfo>( 0, true );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MethodInfo() {
			super();
			this._type = _TYPE;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _parameters:Vector.<ParameterInfo>;

		/**
		 * @private
		 */
		private var _parameters_required:Vector.<ParameterInfo>;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get parent():MethodInfo {
			return this._parent as MethodInfo;
		}

		/**
		 * @private
		 */
		$protected var _returnType:QName;

		public function get returnType():QName {
			return this._returnType;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getParameters(required:Boolean=false):Vector.<ParameterInfo> {
			if ( required ) {
				return this._parameters_required.slice();
			} else {
				return this._parameters.slice();
			}
		}

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = super.toXML( local );
			xml.setLocalName( 'method' );
			xml.@returnType = this._returnType;
			var i:uint, l:uint = this._parameters.length;
			for ( i=0; i<l; ++i ) {
				xml.appendChild( this._parameters[ i ].toXML( local ) );
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
			if ( this._parent ) { // сигнатура метода не может именяться, так что нечего лишний раз парсить
				this._returnType = ( this._parent as MethodInfo )._returnType;
				this._parameters = ( this._parent as MethodInfo )._parameters;
				this._parameters_required = ( this._parent as MethodInfo )._parameters_required;
			} else {
				this._returnType = ClassUtils.parseClassQName( o.returnType );
				if ( o.parameters.length > 0 ) {
					this._parameters = new Vector.<ParameterInfo>();
					this._parameters_required = new Vector.<ParameterInfo>();
					var p:ParameterInfo;
					for each ( o in o.parameters ) {
						p = new ParameterInfo();
						p.parse( o );
						this._parameters.push( p );
						if ( !p._optional ) {
							this._parameters_required.push( p );
						}
					}
				} else {
					this._parameters = _EMPTY_PARAMETERS;
					this._parameters_required = _EMPTY_PARAMETERS;
				}
			}
		}

	}

}