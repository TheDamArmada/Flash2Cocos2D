////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.turns {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;
	
	import ru.avangardonline.data.battle.actions.BattleActionData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					02.08.2009 12:12:51
	 */
	public class BattleTurnData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const TURN_LENGTH:uint = 700;

		public static const TURN_DELAY:uint = 1000;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnData(num:uint) {
			super();
			this._num = num;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _actions:Vector.<BattleActionData> = new Vector.<BattleActionData>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  num
		//----------------------------------

		/**
		 * @private
		 */
		private var _num:uint;

		public function get num():uint {
			return this._num;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'num' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getActions():Vector.<BattleActionData> {
			return this._actions.slice();
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
			if ( child is BattleActionData ) {
				this._actions.push( child );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleActionData ) {
				var index:int = this._actions.indexOf( child );
				if ( index >= 0 ) this._actions.splice( index, 1 );
			}
		}

	}

}