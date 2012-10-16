////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.events.data.DataBaseEvent;

	import flash.errors.IllegalOperationError;

	[Event( name="change", type="by.blooddy.core.events.data.DataBaseEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSPropertyData extends Data implements IRSSElementAsset {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSPropertyData() {
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
		protected var $lock:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Overriden properies
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		public override function set name(value:String):void {
			if ( super.name == value ) return;
			super.name = value;
			this.dispatchChange();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  element
		//----------------------------------

		/**
		 * @private
		 */
		internal var $element:RSSElementData;

		/**
		 * @inheritDoc
		 */
		public function get element():RSSElementData {
			return this.$element;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public virtual function parseXML(xml:XML):void {
			throw new IllegalOperationError();
		}

		/**
		 * @inheritDoc
		 */
		public virtual function toXML():XML { // TODO: руализация
			return new XML();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function dispatchChange():void {
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

	}

}