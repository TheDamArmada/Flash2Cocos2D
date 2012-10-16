////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.data.battle.turns.BattleTurnData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.08.2009 20:57:48
	 */
	public class BattleMoveActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleMoveActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		public var x:int;

		//----------------------------------
		//  y
		//----------------------------------

		public var y:int;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID', 'x', 'y' );
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				super.getCommand(
					new Command(
						'moveTo',
						[ this.x, this.y, this.startTime + BattleTurnData.TURN_LENGTH ]
					)
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:BattleWorldElementData = collection.getElement( super.elementID );
			if ( !element ) throw new ArgumentError();
			element.coord.setValues( this.x, this.y );
		}

	}

}