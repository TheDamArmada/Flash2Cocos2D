////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.actions {

	import by.blooddy.core.commands.Command;
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					11.08.2009 21:03:12
	 */
	public class BattleWorldElementActionData extends BattleActionData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementActionData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  elementID
		//----------------------------------

		public var elementID:uint;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'startTime', 'elementID' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public virtual function apply(collection:BattleWorldElementCollectionData):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function getCommand(command:Command, id:uint=0):Command {
			return	new Command(
						'forWorldElement',
						new Array( id || this.elementID, command )
					);
		}

	}

}