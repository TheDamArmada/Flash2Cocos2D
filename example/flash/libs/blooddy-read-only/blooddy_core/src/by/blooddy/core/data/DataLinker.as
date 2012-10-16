////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	import by.blooddy.core.events.data.DataBaseEvent;

	import flash.errors.IllegalOperationError;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 20:25:21
	 */
	public final class DataLinker {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function link(dataContainer:DataContainer!, data:Data!, strict:Boolean=false):DataLinker {
			return new DataLinker( dataContainer, data, strict );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DataLinker(dataContainer:DataContainer!, data:Data!, strict:Boolean=false) {
			super();
			this._dataContainer = dataContainer;
			this._data = data;
			this._strict = strict;
			if ( !dataContainer.contains( data ) ) dataContainer.addChild( data );
			data.addEventListener( DataBaseEvent.REMOVED, this.handler_removed, false, ( strict ? int.MAX_VALUE : int.MIN_VALUE ), true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:Data;

		/**
		 * @private
		 */
		private var _dataContainer:DataContainer;

		/**
		 * @private
		 */
		private var _strict:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removed(event:DataBaseEvent):void {
			if ( event.target === this._data ) {
				this._dataContainer.addChild( this._data );
				if ( this._strict ) throw new IllegalOperationError();
			}
		}

	}

}