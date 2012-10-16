////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data.xml.rss {

	import by.blooddy.core.data.Data;
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
	public class RSSGuidData extends RSSPropertyData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSGuidData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  isPermaLink
		//----------------------------------

		/**
		 * @private
		 */
		private var _isPermaLink:Boolean;

		public function get isPermaLink():Boolean {
			return this._isPermaLink;
		}

		/**
		 * @private
		 */
		public function set isPermaLink(value:Boolean):void {
			if ( this._isPermaLink == value ) return;
			this._isPermaLink = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  url
		//----------------------------------

		public function get url():String {
			if ( this._isPermaLink ) {
				return super.name;
			}
			return null;
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
			if ( xml.name().toString() != 'guid' ) throw new ArgumentError();
			++this.$lock;
			super.name =		XMLUtils.parseListToString( xml.* );;
			this._isPermaLink =	XMLUtils.parseListToBoolean( xml.@isPermaLink );
			--this.$lock;
			this.dispatchChange();
		}

	}

}