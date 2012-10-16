////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					30.08.2009 15:52:17
	 */
	public class BattleVictoryActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleVictoryActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function isResult():Boolean {
			return true;
		}
		
		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID' );
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				super.getCommand(
					new Command(
						'victory'
					)
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
		}

	}

}