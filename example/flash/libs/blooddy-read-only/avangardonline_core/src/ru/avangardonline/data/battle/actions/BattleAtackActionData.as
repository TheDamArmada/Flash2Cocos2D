////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.character.MinionCharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.08.2009 21:23:40
	 */
	public class BattleAtackActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleAtackActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  targetID
		//----------------------------------

		public var targetID:uint;

		//----------------------------------
		//  targetIncreaseHealth
		//----------------------------------

		public var targetHealthIncrement:int;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID', 'targetID', 'targetHealthIncrement' );
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				this.getCommand(
					new Command(
						'atack',
						[ this.targetID ]
					)
				),
				this.getCommand(
					new Command(
						'defence',
						[ super.elementID ]
					),
					this.targetID
				),
				this.getCommand(
					new Command(
						'incHealth',
						[ this.targetHealthIncrement ]
					),
					this.targetID
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:MinionCharacterData = collection.getElement( this.targetID ) as MinionCharacterData;
			if ( !element ) throw new ArgumentError();
			element.health.current += this.targetHealthIncrement;
		}

	}

}