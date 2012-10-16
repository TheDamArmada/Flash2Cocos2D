////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;
	import by.blooddy.core.data.DataLinker;
	import by.blooddy.core.utils.time.RelativeTime;
	
	import ru.avangardonline.data.battle.result.BattleResultData;
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	import ru.avangardonline.data.battle.world.BattleWorldData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.07.2009 20:20:44
	 */
	public class BattleData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleData(time:RelativeTime) {
			super();
			this._world = new BattleWorldData( time )
			DataLinker.link( this, this._world, true );
			DataLinker.link( this, this.result, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _turns:Vector.<BattleTurnData> = new Vector.<BattleTurnData>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  world
		//----------------------------------

		/**
		 * @private
		 */
		private var _world:BattleWorldData;

		public function get world():BattleWorldData {
			return this._world;
		}

		//----------------------------------
		//  time
		//----------------------------------

		public function get time():RelativeTime {
			return this._world.time;
		}

		//----------------------------------
		//  numTurns
		//----------------------------------

		public function get numTurns():uint {
			return this._turns.length;
		}

		//----------------------------------
		//  numTurns
		//----------------------------------
		
		public const result:BattleResultData = new BattleResultData();
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'numTurns' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getTurn(num:uint):BattleTurnData {
			if ( num >= this._turns.length ) return null;
			return this._turns[ num ];
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			if ( child is BattleTurnData ) {
				var data:BattleTurnData = child as BattleTurnData;
				if ( data.num != this._turns.length ) throw new ArgumentError();
				this._turns.push( data );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleTurnData ) {
				var data:BattleTurnData = child as BattleTurnData;
				if ( data.num != this._turns.length-1 ) throw new ArgumentError();
				if ( this._turns[ data.num ] !== data ) throw new ArgumentError();
				this._turns.pop();
			}
		}

	}

}