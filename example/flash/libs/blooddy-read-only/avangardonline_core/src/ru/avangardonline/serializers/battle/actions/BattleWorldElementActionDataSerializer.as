////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import ru.avangardonline.data.battle.actions.BattleAtackActionData;
	import ru.avangardonline.data.battle.actions.BattleCastActionData;
	import ru.avangardonline.data.battle.actions.BattleLiveStatusActionData;
	import ru.avangardonline.data.battle.actions.BattleMoveActionData;
	import ru.avangardonline.data.battle.actions.BattleSpellActionData;
	import ru.avangardonline.data.battle.actions.BattleVictoryActionData;
	import ru.avangardonline.data.battle.actions.BattleWorldElementActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 22:22:27
	 */
	public class BattleWorldElementActionDataSerializer extends BattleActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleWorldElementActionData=null):BattleWorldElementActionData {
			switch ( source.charAt( 0 ) ) {
				case 'm':	return BattleMoveActionDataSerializer.deserialize( source, target as BattleMoveActionData );
				case 'a':	return BattleAtackActionDataSerializer.deserialize( source, target as BattleAtackActionData );
				case 'd':	return BattleLiveStatusActionDataSerializer.deserialize( source, target as BattleLiveStatusActionData );
				case 'v':	return BattleVictoryActionDataSerializer.deserialize( source, target as BattleVictoryActionData );
				case 'c':	return BattleCastActionDataSerializer.deserialize( source, target as BattleCastActionData );
				case 's':	return BattleSpellActionDataSerializer.deserialize( source, target as BattleSpellActionData );
			}
			throw new ArgumentError();
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementActionDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:BattleWorldElementActionData = target as BattleWorldElementActionData;
			if ( !data ) throw new ArgumentError();
			data.elementID = parseInt( source.split( '|', 1 )[0] );
			return data;
		}

	}

}