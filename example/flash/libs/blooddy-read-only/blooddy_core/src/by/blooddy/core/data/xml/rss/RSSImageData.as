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
	public class RSSImageData extends RSSElementData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSImageData() {
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

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		private var _width:uint;

		public function get width():uint {
			return this._width;
		}

		/**
		 * @private
		 */
		public function set width(value:uint):void {
			if ( this._width == value ) return;
			this._width = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		private var _height:uint;

		public function get height():uint {
			return this._height;
		}

		/**
		 * @private
		 */
		public function set height(value:uint):void {
			if ( this._height == value ) return;
			this._height = value;
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
			if ( xml.name().toString() != 'image' ) throw new ArgumentError();
			super.parseXML( xml );
			this._url =		XMLUtils.parseListToString( xml.image );
			this._width =	XMLUtils.parseListToInt( xml.width );
			this._height =	XMLUtils.parseListToInt( xml.height );
			this.dispatchChange();
		}

	}

}