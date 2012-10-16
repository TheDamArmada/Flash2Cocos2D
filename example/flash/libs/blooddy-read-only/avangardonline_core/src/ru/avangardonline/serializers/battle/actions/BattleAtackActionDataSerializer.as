////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleAtackActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:06:53
	 */
	public class BattleAtackActionDataSerializer extends BattleWorldElementActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleAtackActionDataSerializer = new BattleAtackActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleAtackActionData=null):BattleAtackActionData {
			return _serializer.deserialize( source, target ) as BattleAtackActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleAtackActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'a' ) throw new ArgumentError();
			var data:BattleAtackActionData = target as BattleAtackActionData;
			if ( !data ) data = new BattleAtackActionData();
			source = source.substr( 1 );
			data = super.deserialize( source, data );
			var arr:Array = source.split( '|', 3 );
			data.targetID = parseInt( arr[ 1 ] );
			data.targetHealthIncrement = -parseInt( arr[ 2 ] );
			return data;
		}

	}

}