////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.result {
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import ru.avangardonline.data.battle.result.BattleResultData;
	import ru.avangardonline.data.battle.result.BattleResultElementData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.11.2009 23:46:20
	 */
	public class BattleResultDataSerializer implements ISerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:BattleResultDataSerializer = new BattleResultDataSerializer();
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:BattleResultData=null):BattleResultData {
			return _serializer.deserialize( source, target ) as BattleResultData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleResultDataSerializer() {
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
			var data:BattleResultData = target as BattleResultData;
			if ( !data ) data = new BattleResultData();

			var tmp:Array = source.split( '\n', 3 );

			switch ( tmp[ 0 ].charAt( 0 ) ) {
				case 'l':	data.group = 1;	break;
				case 'r':	data.group = 2;	break;
				default:	throw new ArgumentError();
			}

			tmp.shift();

			var gr:uint;
			var element:BattleResultElementData;
			var hash:Dictionary = new Dictionary();
			for each ( var s:String in tmp ) {
				switch ( s.charAt( 0 ) ) {
					case 'l':	gr = 1;	break;
					case 'r':	gr = 2;	break;
					default:	throw new ArgumentError();
				}
				element = data.getElement( gr );
				if ( !element ) {
					element = new BattleResultElementData( gr );
					data.addChild( element );
				}
				BattleResultElementDataSerializer.deserialize( s.substr( 1 ), element );
				hash[ element ] = true;
			}
			for each ( element in data.getElements() ) {
				if ( !( element in hash ) ) data.removeChild( element );
			}

			return null;
		}

	}

}