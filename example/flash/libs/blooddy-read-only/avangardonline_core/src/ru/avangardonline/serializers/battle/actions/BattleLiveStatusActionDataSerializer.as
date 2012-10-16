////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.actions {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.battle.actions.BattleLiveStatusActionData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:27:32
	 */
	public class BattleLiveStatusActionDataSerializer extends BattleWorldElementActionDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleLiveStatusActionDataSerializer = new BattleLiveStatusActionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleLiveStatusActionData=null):BattleLiveStatusActionData {
			return _serializer.deserialize( source, target ) as BattleLiveStatusActionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleLiveStatusActionDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'd' ) throw new ArgumentError();
			var data:BattleLiveStatusActionData = target as BattleLiveStatusActionData;
			if ( !data ) data = new BattleLiveStatusActionData();
			source = source.substr( 1 );
			data = super.deserialize( source, data );
			var arr:Array = source.split( '|', 2 );
			data.live = Boolean( parseInt( arr[ 1 ] ) );
			return data;
		}

	}

}