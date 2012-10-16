////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	
	import ru.avangardonline.events.data.battle.world.BattleWorldDataEvent;

	[Event( name="addedToWorld", type="ru.avangardonline.events.data.battle.world.BattleWorldDataEvent" )]
	[Event( name="removedFromWorld", type="ru.avangardonline.events.data.battle.world.BattleWorldDataEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.08.2009 21:54:53
	 */
	public class BattleWorldAssetData extends Data implements IBattleWorldAssetData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldAssetData() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _world:BattleWorldData;

		public final function get world():BattleWorldData {
			return this._world;
		}

		/**
		 * @private
		 */
		internal final function set$world(value:BattleWorldData):void {
			if ( this._world && super.hasEventListener( BattleWorldDataEvent.REMOVED_FROM_WORLD ) ) {
				super.dispatchEvent( new BattleWorldDataEvent( BattleWorldDataEvent.REMOVED_FROM_WORLD ) );
			}
			this._world = value;
			if ( this._world && super.hasEventListener( BattleWorldDataEvent.ADDED_TO_WORLD ) ) {
				super.dispatchEvent( new BattleWorldDataEvent( BattleWorldDataEvent.ADDED_TO_WORLD ) );
			}
		}

	}

}