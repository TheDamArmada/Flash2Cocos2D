////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final class WeakRef {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function WeakRef(obj:Object) {
			super();
			//if ( !obj || obj is Number || obj is String || obj is Boolean ) throw new ArgumentError();
			this._ref[ obj ] = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _ref:Dictionary = new Dictionary ( true );

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public function get():* {
			for ( var obj:* in this._ref ) {
				return obj;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function valueOf():* {
			return this.get();
		}

		/**
		 * @private
		 */
		public function toString():String {
			return String( this.get() ); // maybe null
		}

	}

}