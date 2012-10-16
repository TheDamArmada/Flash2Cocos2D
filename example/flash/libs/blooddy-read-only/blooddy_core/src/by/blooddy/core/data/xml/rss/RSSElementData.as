////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.DataContainer;
	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.data.Data;
	import by.blooddy.core.utils.xml.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSElementData extends DataContainer implements IRSSElementAsset {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSElementData() {
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
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		[Deprecated( message="свойство устарело", replacement="title" )]
		/**
		 * @private
		 */
		public override function set name(value:String):void {
			this.setName( value );
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
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  title
		//----------------------------------

		public function get title():String {
			return super.name;
		}

		/**
		 * @private
		 */
		public function set title(value:String):void {
			this.setName( value );
		}

		//----------------------------------
		//  link
		//----------------------------------

		/**
		 * @private
		 */
		private var _link:String;

		public function get link():String {
			return this._link;
		}

		/**
		 * @private
		 */
		public function set link(value:String):void {
			if ( this._link == value ) return;
			this._link = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  description
		//----------------------------------

		/**
		 * @private
		 */
		private var _description:String;

		public function get description():String {
			return this._description;
		}

		/**
		 * @private
		 */
		public function set description(value:String):void {
			if ( this._description == value ) return;
			this._description = value;
			this.dispatchChange();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function parseXML(xml:XML):void {
			super.name =		XMLUtils.parseListToString( xml.title );
			this._link =		XMLUtils.parseListToString( xml.link );
			this._description =	XMLUtils.parseListToString( xml.description );
			this.dispatchChange();
		}

		/**
		 * @inheritDoc
		 */
		public function toXML():XML { // TODO: руализация
			var xml:XML = new XML();
			xml.link = this._link;
			xml.title = super.name;
			xml.description = this._description;
			return xml;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			if ( child is RSSPropertyData ) {
				( child as RSSPropertyData ).$element = this;
			} else if ( child is RSSElementData ) {
				( child as RSSElementData ).$element = this;
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is RSSPropertyData ) {
				( child as RSSPropertyData ).$element = null;
			} else if ( child is RSSElementData ) {
				( child as RSSElementData ).$element = null;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function dispatchChange():void {
			if ( !this.$lock ) super.dispatchEvent( new DataBaseEvent( DataBaseEvent.CHANGE, true ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function setName(value:String):void {
			if ( super.name == value ) return;
			super.name = value;
			this.dispatchChange();
		}

	}

}