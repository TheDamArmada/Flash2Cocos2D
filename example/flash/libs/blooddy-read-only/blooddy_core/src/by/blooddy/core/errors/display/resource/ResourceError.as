////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.errors.display.resource {

	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.utils.ClassUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.11.2009 23:25:32
	 */
	public class ResourceError extends Error {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceError(message:String='', id:int=0, resources:Vector.<ResourceDefinition>=null) {
			super( message, id );
			this.name = ClassUtils.getClassName( this );
			if ( resources) {
				this.resources = resources.slice();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var resources:Vector.<ResourceDefinition>;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function toString():String {
			return	this.name +
					( this.errorID ? ' #' + this.errorID : '' ) +
					( this.message ? ': ' + this.message : '' ) +
					( this.resources && this.resources.length > 0 ? ' (' + this.resources + ')' : '' );
		}

	}

}