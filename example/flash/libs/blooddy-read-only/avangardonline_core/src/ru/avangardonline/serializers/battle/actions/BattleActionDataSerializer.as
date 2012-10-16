////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleActionData;
	import ru.avangardonline.data.battle.actions.BattleWorldElementActionData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 21:42:30
	 */
	public class BattleActionDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleActionData=null):BattleActionData {
			return BattleWorldElementActionDataSerializer.deserialize( source, target as BattleWorldElementActionData );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public virtual function deserialize(source:String, target:*=null):* {
			Error.throwError( IllegalOperationError, 2014 );
		}

	}

}