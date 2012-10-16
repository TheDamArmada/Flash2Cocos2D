////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.utils.ClassUtils;

	/**
	 * Динамический пучёк ресурсов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcebundle, resource, bundle
	 */
	public class ResourceBundle implements IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	name		Имя пучка.
		 */
		public function ResourceBundle(name:String) {
			if ( !name ) {
				Error.throwError( TypeError, 2007, 'name' );
			}
			super();
			this._name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Хранилеще ресурсов.
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IResourceBundle
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return this._name;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function getResource(name:String=null):* {
			return this._hash[ ( name || '' ) ] || null;
		}

		/**
		 * @inheritDoc
		 */
		public function hasResource(name:String=null):Boolean {
			return ( name || '' ) in this._hash;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Добавляет ресурс в хранилище.
		 * 
		 * @param	name		Имя ресурса.
		 * @param	value		Ресурс.
		 * 
		 * @keyword				resourcebundle.addresource, addresource
		 */
		public function addResource(name:String, object:*):void {
			this._hash[ name ] = object;
		}

		/**
		 * Добавляет ресурс в хранилище.
		 * 
		 * @param	name		Имя ресурса.
		 * 
		 * @keyword				resourcebundle.removeresource, removeresource
		 */
		public function removeResource(name:String):void {
			delete this._hash[ name ];
		}

		/**
		 * @private
		 */
		public function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' name="' + this._name + '"]';
		}

	}

}