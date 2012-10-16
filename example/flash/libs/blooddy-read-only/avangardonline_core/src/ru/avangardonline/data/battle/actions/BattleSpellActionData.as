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
	 * @created					30.07.2010 0:24:47
	 */
	public class BattleSpellActionData extends BattleAtackActionData {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleSpellActionData() {
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
		
		public override function isResult():Boolean {
			return true;
		}
		
		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'effectType', 'elementID', 'targetID', 'targetHealthIncrement' );
		}
		
		public override function getCommands():Vector.<Command> {
			var result:Vector.<Command> = new Vector.<Command>();
			result.push(
				new Command(
					'createEffectAtElement',
					[ this.effectType, this.targetID ]
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
		
	}
	
}