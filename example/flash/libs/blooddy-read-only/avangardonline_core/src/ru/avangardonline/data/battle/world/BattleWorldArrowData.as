////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.utils.nextframeCall;
	
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	import ru.avangardonline.events.data.battle.world.BattleWorldDataEvent;
	import ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="removeElement", type="ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					16.09.2009 20:00:36
	 */
	public class BattleWorldArrowData extends BattleWorldAbstractElementData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldArrowData(ownerID:uint, targetID:uint) {
			super();
			this._ownerID = ownerID;
			this._targetID = targetID;
			super.addEventListener( BattleWorldDataEvent.ADDED_TO_WORLD, this.handler_addedToWorld, false, int.MIN_VALUE, true );
			super.coord.addEventListener( BattleWorldCoordinateDataEvent.MOVING_STOP, this.handler_movingStop, false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  ownerID
		//----------------------------------

		/**
		 * @private
		 */
		private var _ownerID:uint;

		public function get ownerID():uint {
			return this._ownerID;
		}

		//----------------------------------
		//  targetID
		//----------------------------------

		/**
		 * @private
		 */
		private var _targetID:uint;

		public function get targetID():uint {
			return this._targetID;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function destroy():void {
			super.dispatchEvent( new BattleWorldTempElementEvent( BattleWorldTempElementEvent.REMOVE_ELEMENT, true, false, this ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToWorld(event:BattleWorldDataEvent):void {
			var owner:BattleWorldElementData = super.world.elements.getElement( this._ownerID );
			var target:BattleWorldElementData = super.world.elements.getElement( this._targetID );
			if ( owner && target ) {
				super.coord.setValues( owner.coord.x, owner.coord.y );
				super.coord.moveTo( target.coord.x, target.coord.y, super.world.time.currentTime + 500 - 100 * Math.random() );
			} else {
				nextframeCall( this.destroy );
			}
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			this.destroy();
		}

	}

}