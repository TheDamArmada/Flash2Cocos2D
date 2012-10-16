////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.world {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.world.BattleWorldFieldData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					22.11.2009 23:06:07
	 */
	public class BattleWorldFieldDataSerializer implements ISerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:BattleWorldFieldDataSerializer = new BattleWorldFieldDataSerializer();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:BattleWorldFieldData=null):BattleWorldFieldData {
			return _serializer.deserialize( source, target ) as BattleWorldFieldData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleWorldFieldDataSerializer() {
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
			var data:BattleWorldFieldData = target as BattleWorldFieldData;
			if ( !data ) throw new ArgumentError();
			data.width = 11;
			data.height = 5;

			var tmp:Array = source.split( ',' );

			var time:uint = parseInt( tmp[ 0 ] );
			data.type = parseInt( tmp[ 1 ] );

			return data;
		}

	}

}