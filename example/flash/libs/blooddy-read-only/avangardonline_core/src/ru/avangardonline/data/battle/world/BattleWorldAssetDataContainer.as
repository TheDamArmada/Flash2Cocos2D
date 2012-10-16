////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;
	
	import ru.avangardonline.events.data.battle.world.BattleWorldDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.08.2009 21:54:53
	 */
	public class BattleWorldAssetDataContainer extends DataContainer implements IBattleWorldAssetData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldAssetDataContainer() {
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
			const numChildren:int = super.numChildren;
			var child:Data;
			for ( var i:int = 0; i<numChildren; i++ ) {
				child = super.getChildAt( i );
				if ( child is BattleWorldAssetData ) {
					( child as BattleWorldAssetData ).set$world( value );
				} else if ( child is BattleWorldAssetDataContainer ) {
					( child as BattleWorldAssetDataContainer ).set$world( value );
				}
			}
			if ( this._world && super.hasEventListener( BattleWorldDataEvent.ADDED_TO_WORLD ) ) {
				super.dispatchEvent( new BattleWorldDataEvent( BattleWorldDataEvent.ADDED_TO_WORLD ) );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		protected override function addChild_before(child:Data):void {
			if ( child is BattleWorldAssetData ) {
				( child as BattleWorldAssetData ).set$world( this._world );
			} else if ( child is BattleWorldAssetDataContainer ) {
				( child as BattleWorldAssetDataContainer ).set$world( this._world );
			}
		}

		protected override function removeChild_before(child:Data):void {
			if ( child is BattleWorldAssetData ) {
				( child as BattleWorldAssetData ).set$world( null );
			} else if ( child is BattleWorldAssetDataContainer ) {
				( child as BattleWorldAssetDataContainer ).set$world( null );
			}
		}

	}

}