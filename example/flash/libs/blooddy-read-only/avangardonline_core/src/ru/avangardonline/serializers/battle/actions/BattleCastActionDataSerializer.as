////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleCastActionData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					30.07.2010 1:34:06
	 */
	public class BattleCastActionDataSerializer extends BattleWorldElementActionDataSerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:BattleCastActionDataSerializer = new BattleCastActionDataSerializer();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:BattleCastActionData=null):BattleCastActionData {
			return _serializer.deserialize( source, target ) as BattleCastActionData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleCastActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------
		
		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'c' ) throw new ArgumentError();
			var data:BattleCastActionData = target as BattleCastActionData;
			if ( !data ) data = new BattleCastActionData();
			source = source.substr( 1 );
			data = super.deserialize( source, data );
			var arr:Array = source.split( '|', 2 );
			data.effectType = parseInt( arr[ 1 ] );
			return data;
		}
		
	}
	
}