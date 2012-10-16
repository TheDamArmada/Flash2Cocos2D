////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleMoveActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 22:41:07
	 */
	public class BattleMoveActionDataSerializer extends BattleWorldElementActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleMoveActionDataSerializer = new BattleMoveActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleMoveActionData=null):BattleMoveActionData {
			return _serializer.deserialize( source, target ) as BattleMoveActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleMoveActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'm' ) throw new ArgumentError();
			var data:BattleMoveActionData = target as BattleMoveActionData;
			if ( !data ) data = new BattleMoveActionData();
			source = source.substr( 1 );
			super.deserialize( source, data );
			var arr:Array = source.substr( 1 ).split( '|', 2 );
			arr = arr[1].split( ',', 2 );
			data.x = parseInt( arr[ 0 ] ) - 5;
			data.y = parseInt( arr[ 1 ] ) - 1;
			return data;
		}

	}

}