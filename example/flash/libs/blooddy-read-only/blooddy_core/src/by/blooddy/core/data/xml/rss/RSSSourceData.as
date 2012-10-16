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
	public class RSSSourceData extends RSSPropertyData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSSourceData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @private
		 */
		private var _url:String;

		public function get url():String {
			return this._url;
		}

		/**
		 * @private
		 */
		public function set url(value:String):void {
			if ( this._url == value ) return;
			this._url = value;
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
			if ( xml.name().toString() != 'source' ) throw new ArgumentError();
			++this.$lock;
			super.name =	XMLUtils.parseListToString( xml.* );
			this._url =		XMLUtils.parseListToString( xml.@url );
			--this.$lock;
			this.dispatchChange();
		}

	}

}