////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2010 23:47:02
	 */
	public class BattleCastActionData extends BattleWorldElementActionData {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleCastActionData() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  effectType
		//----------------------------------
		
		/**
		 * @private
		 */
		public var effectType:uint;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------
		
		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'effectType', 'elementID' );
		}
		
		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				this.getCommand(
					new Command(
						'cast',
						[ this.effectType ]
					)
				)
			);
			return result;
		}
		
	}
	
}