////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent;
	import ru.avangardonline.events.data.battle.world.BattleWorldDataEvent;
	import by.blooddy.core.utils.time.setTimeout;
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					30.07.2010 2:53:40
	 */
	public class BattleWorldEffectData extends BattleWorldAbstractElementData {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleWorldEffectData(type:uint) {
			super();
			this._type = type;
			super.addEventListener( BattleWorldDataEvent.ADDED_TO_WORLD, this.handler_addedToWorld, false, int.MIN_VALUE, true );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _type:uint;
		
		public function get type():uint {
			return this._type;
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
			setTimeout( this.destroy, BattleTurnData.TURN_LENGTH );
		}
		
	}
	
}