////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.items {
	
	import by.blooddy.core.data.Data;
	
	import ru.avangardonline.data.IClonableData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					31.03.2010 23:31:48
	 */
	public class RuneData extends Data implements IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function RuneData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _type:uint;

		public function get type():uint {
			return this._type;
		}

		/**
		 * @private
		 */
		public function set type(value:uint):void {
			if ( this._type == value ) return;
			this._type = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:RuneData = new RuneData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:RuneData = data as RuneData;
			if ( !target ) throw new ArgumentError();
			this.type = target._type;
			super.name = target.name;
		}


	}
	
}