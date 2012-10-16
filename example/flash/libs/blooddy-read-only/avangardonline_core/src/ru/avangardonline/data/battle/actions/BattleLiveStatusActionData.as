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
	 * @created					12.08.2009 23:23:12
	 */
	public class BattleLiveStatusActionData extends BattleWorldElementActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLiveStatusActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  live
		//----------------------------------

		public var live:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID', 'live' );
		}

		public override function isResult():Boolean {
			return true;
		}

		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				super.getCommand(
					new Command(
						'changeLiveStatus',
						[ this.live ]
					)
				)
			);
			return result;
		}

		public override function apply(collection:BattleWorldElementCollectionData):void {
			var element:MinionCharacterData = collection.getElement( super.elementID ) as MinionCharacterData;
			if ( !element ) throw new ArgumentError();
			element.live = this.live;
		}

	}

}