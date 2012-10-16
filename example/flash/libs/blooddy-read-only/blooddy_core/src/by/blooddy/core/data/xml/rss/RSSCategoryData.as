////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.utils.xml.XMLUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					rss, xml, data
	 */
	public class RSSCategoryData extends RSSPropertyData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSCategoryData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  domain
		//----------------------------------

		/**
		 * @private
		 */
		private var _domain:String;

		public function get domain():String {
			return this._domain;
		}

		/**
		 * @private
		 */
		public function set domain(value:String):void {
			if ( this._domain == value ) return;
			this._domain = value;
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
			if ( xml.name().toString() != 'category' ) throw new ArgumentError();
			++this.$lock;
			this._domain = XMLUtils.parseListToString( xml.@domain );
			super.name = XMLUtils.parseListToString( xml.* );
			--this.$lock;
			this.dispatchChange();
		}

	}

}