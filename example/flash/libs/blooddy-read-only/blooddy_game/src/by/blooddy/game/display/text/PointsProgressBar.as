package by.blooddy.game.display.text {
	
	import by.blooddy.core.display.text.TextProgressBar;
	import by.blooddy.game.data.PointsData;
	
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.01.2012 15:18:49
	 */
	public class PointsProgressBar extends TextProgressBar {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function PointsProgressBar() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  percents
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _percents:Boolean = false;
		
		public function get percents():Boolean {
			return this._percents;
		}
		
		/**
		 * @private
		 */
		public function set percents(value:Boolean):void {
			if ( this._percents ) return;
			this._percents = value;
			this.render();
		}

		//----------------------------------
		//  adjust
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _adjust:Boolean = true;
		
		public function get adjust():Boolean {
			return this._adjust;
		}
		
		/**
		 * @private
		 */
		public function set adjust(value:Boolean):void {
			if ( this._adjust ) return;
			this._adjust = value;
			this.render();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;
			if ( super.progressDispatcher is PointsData && !this._percents ) {
				var points:PointsData = super.progressDispatcher as PointsData;
				var current:int = points.current;
				var max:int = points.max;
				if ( this._adjust ) {
					var min:int = points.min;
					current -= min;
					max -= min;
				}
				super.setText( current + ' / ' + max );
				return true;
			} else {
				return super.render( event );
			}
		}

	}
	
}