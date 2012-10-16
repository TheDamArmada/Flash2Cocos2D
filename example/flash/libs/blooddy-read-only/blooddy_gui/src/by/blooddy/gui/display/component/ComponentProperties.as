package by.blooddy.gui.display.component {

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.01.2011 13:46:24
	 */
	public final class ComponentProperties {

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public static const DEFAULT:ComponentProperties = new ComponentProperties();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ComponentProperties(singleton:Boolean=true, alwaysOnTop:Boolean=false, modal:Boolean=false, fixed:Boolean=false) {
			super();
			this._singleton = singleton;
			this._alwaysOnTop = alwaysOnTop;
			this._modal = modal;
			this._fixed = fixed;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _singleton:Boolean;

		public function get singleton():Boolean {
			return this._singleton;
		}

		/**
		 * @private
		 */
		private var _alwaysOnTop:Boolean;

		public function get alwaysOnTop():Boolean {
			return this._alwaysOnTop;
		}
		
		/**
		 * @private
		 */
		private var _modal:Boolean;

		public function get modal():Boolean {
			return this._modal;
		}

		/**
		 * @private
		 */
		private var _fixed:Boolean = false;

		public function get fixed():Boolean {
			return this._fixed;
		}

		public function get rating():uint {
			return ( this._alwaysOnTop ? 1 : 0 ) | ( this._modal ? 2 : 0 );
		}

	}
	
}