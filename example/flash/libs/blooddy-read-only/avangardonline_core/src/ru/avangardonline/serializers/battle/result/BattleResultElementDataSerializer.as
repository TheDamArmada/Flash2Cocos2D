////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.result {
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.result.BattleResultElementData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.11.2009 0:18:34
	 */
	public class BattleResultElementDataSerializer implements ISerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:BattleResultElementDataSerializer = new BattleResultElementDataSerializer();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:BattleResultElementData=null):BattleResultElementData {
			return _serializer.deserialize( source, target ) as BattleResultElementData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleResultElementDataSerializer() {
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
			var data:BattleResultElementData = target as BattleResultElementData;
			if ( !data ) throw new ArgumentError();
			var tmp:Array = source.split( '|', 2 );
			data.experience = parseInt( tmp[ 0 ] );
			var values:Vector.<int> = new Vector.<int>();
			if ( tmp[ 1 ] ) {
				tmp = tmp[ 1 ].split( ',' );
				var l:uint = tmp.length;
				for ( var i:uint = 0; i<l; i++ ) {
					values[ i ] = parseInt( tmp[ i ] );
				}
			}
			data.values = values;
			return data;
		}
		
	}
	
}