////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleVictoryActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					30.08.2009 15:57:14
	 */
	public class BattleVictoryActionDataSerializer extends BattleWorldElementActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleVictoryActionDataSerializer = new BattleVictoryActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleVictoryActionData=null):BattleVictoryActionData {
			return _serializer.deserialize( source, target ) as BattleVictoryActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleVictoryActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'v' ) throw new ArgumentError();
			var data:BattleVictoryActionData = target as BattleVictoryActionData;
			if ( !data ) data = new BattleVictoryActionData();
			source = source.substr( 1 );
			data = super.deserialize( source, data );
			return data;
		}

	}

}