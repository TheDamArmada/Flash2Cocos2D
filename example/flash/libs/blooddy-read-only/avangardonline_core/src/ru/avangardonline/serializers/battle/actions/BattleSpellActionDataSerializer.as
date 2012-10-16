////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleAtackActionData;
	import ru.avangardonline.data.battle.actions.BattleSpellActionData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:06:53
	 */
	public class BattleSpellActionDataSerializer extends BattleWorldElementActionDataSerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:BattleSpellActionDataSerializer = new BattleSpellActionDataSerializer();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:BattleSpellActionData=null):BattleSpellActionData {
			return _serializer.deserialize( source, target ) as BattleSpellActionData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleSpellActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------
		
		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 's' ) throw new ArgumentError();
			var data:BattleSpellActionData = target as BattleSpellActionData;
			if ( !data ) data = new BattleSpellActionData();
			source = source.substr( 1 );
			var arr:Array = source.split( '|', 3 );
			data.effectType = parseInt( arr[ 0 ] );
			data.targetID = parseInt( arr[ 1 ] );
			data.targetHealthIncrement = -parseInt( arr[ 2 ] );
			return data;
		}
		
	}
	
}