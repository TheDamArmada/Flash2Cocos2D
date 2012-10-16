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
	public class RSSCloudData extends RSSPropertyData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Contructor
		 */
		public function RSSCloudData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		[Deprecated( message="свойство устарело", replacement="domain" )]
		/**
		 * @private
		 */
		public override function set name(value:String):void {
			super.name = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//<cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="myCloud.rssPleaseNotify" protocol="xml-rpc" />

		//----------------------------------
		//  domain
		//----------------------------------

		public function get domain():String {
			return super.name;
		}

		/**
		 * @private
		 */
		public function set domain(value:String):void {
			super.name = value;
		}

		//----------------------------------
		//  port
		//----------------------------------

		/**
		 * @private
		 */
		private var _port:uint;

		public function get port():uint {
			return this._port;
		}

		/**
		 * @private
		 */
		public function set port(value:uint):void {
			if ( this._port == value ) return;
			this._port = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  path
		//----------------------------------

		/**
		 * @private
		 */
		private var _path:String;

		public function get path():String {
			return this._path;
		}

		/**
		 * @private
		 */
		public function set path(value:String):void {
			if ( this._path == value ) return;
			this._path = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  registerProcedure
		//----------------------------------

		/**
		 * @private
		 */
		private var _registerProcedure:String;

		public function get registerProcedure():String {
			return this._registerProcedure;
		}

		/**
		 * @private
		 */
		public function set registerProcedure(value:String):void {
			if ( this._registerProcedure == value ) return;
			this._registerProcedure = value;
			this.dispatchChange();
		}

		//----------------------------------
		//  protocol
		//----------------------------------

		/**
		 * @private
		 */
		private var _protocol:String;

		public function get protocol():String {
			return this._protocol;
		}

		/**
		 * @private
		 */
		public function set protocol(value:String):void {
			if ( this._protocol == value ) return;
			this._protocol = value;
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
			if ( xml.name().toString() != 'cloud' ) throw new ArgumentError();
			++this.$lock;

			super.name =				XMLUtils.parseListToString( xml.@domain );
			this._port =				XMLUtils.parseListToInt( xml.@port );
			this._path =				XMLUtils.parseListToString( xml.@path );
			this._registerProcedure =	XMLUtils.parseListToString( xml.@registerProcedure );
			this._protocol =			XMLUtils.parseListToString( xml.@protocol );

			--this.$lock;
			this.dispatchChange(); 
		}

	}

}