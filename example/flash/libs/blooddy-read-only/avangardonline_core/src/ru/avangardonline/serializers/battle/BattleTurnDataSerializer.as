////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleActionData;
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	import ru.avangardonline.serializers.ISerializer;
	import ru.avangardonline.serializers.battle.actions.BattleActionDataSerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:33:00
	 */
	public class BattleTurnDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleTurnDataSerializer = new BattleTurnDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleTurnData=null):BattleTurnData {
			return _serializer.deserialize( source, target ) as BattleTurnData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function deserialize(source:String, target:*=null):* {
			var data:BattleTurnData = target as BattleTurnData;
			if ( !data ) throw new ArgumentError();

			for each ( var action:BattleActionData in data.getActions() ) {
				data.removeChild( action );
			}

			var tmp:Array = source.split( '\n' );
			var l:uint = tmp.length;
			for ( var i:int = 0; i<l; i++ ) {
				if ( !tmp[ i ] ) continue;
				action = BattleActionDataSerializer.deserialize( tmp[ i ] );
				data.addChild( action );
			}

			return data;
		}

	}

}