////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.LoadableResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	
	import flash.display.DisplayObject;
	
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:12:19
	 */
	public class BattleWorldElementView extends LoadableResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementView(data:BattleWorldAbstractElementData!) {
			super();
			this._data = data;
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.handler_rotation );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_START,		this.handler_rotation );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_STOP,		this.handler_rotation );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldAbstractElementData;

		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//--------------------------------------------------------------------------

		protected var $element:DisplayObject;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function updateRotation():void {
			if ( this.$element ) {
				this.$element.scaleX = ( this._data.rotation < 90 ? 1 : -1 );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_rotation(event:BattleWorldCoordinateDataEvent):void {
			this.updateRotation();
		}

	}

}