////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.utils.xml.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSEnclosureData extends RSSPropertyData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSEnclosureData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden roperties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		[Deprecated( message="свойство устарело", replacement="url" )]
		/**
		 * @private
		 */
		public override function set name(value:String):void {
			super.name = name;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		public function get url():String {
			return super.name;
		}

		/**
		 * @private
		 */
		public function set url(value:String):void {
			super.name = value;
		}

		//----------------------------------
		//  length
		//----------------------------------

		/**
		 * @private
		 */
		private var _length:uint;

		public function get length():uint {
			return this._length;
		}

		/**
		 * @private
		 */
		public function set length(value:uint):void {
			if ( this._length == value ) return;
			this._length = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  type
		//----------------------------------

		/**
		 * @private
		 */
		private var _type:String;

		public function get type():String {
			return this._type;
		}

		/**
		 * @private
		 */
		public function set type(value:String):void {
			if ( this._type == value ) return;
			this._type = value;
			this.dispatchChange();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function parseXML(xml:XML):void {
			if ( xml.name().toString() != 'enclosure' ) throw new ArgumentError();
			++this.$lock;
			super.name =		XMLUtils.parseListToString( xml.@url );
			this._length =		XMLUtils.parseListToInt( xml.@length );
			this._type =		XMLUtils.parseListToString( xml.@type );
			--this.$lock;
			this.dispatchChange();
		}

	}

}