////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.world {

	import by.blooddy.core.data.Data;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.data.battle.world.BattleWorldElementCollectionData;
	import ru.avangardonline.data.battle.world.BattleWorldElementData;
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.data.items.RuneData;
	import ru.avangardonline.serializers.ISerializer;
	import ru.avangardonline.serializers.items.RuneDataSerializer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					12.08.2009 23:30:07
	 */
	public class BattleWorldElementCollectionDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:BattleWorldElementCollectionDataSerializer = new BattleWorldElementCollectionDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:BattleWorldElementCollectionData=null):BattleWorldElementCollectionData {
			return _serializer.deserialize( source, target ) as BattleWorldElementCollectionData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementCollectionDataSerializer() {
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
			var data:BattleWorldElementCollectionData = target as BattleWorldElementCollectionData;
			if ( !data ) throw new ArgumentError();
			var arr:Array = source.split( '\n' );
			var element:Data;
			var h:Boolean;
			var g:uint;
			var id:uint;
			var type:String;
			var non:Vector.<CharacterData> = new Vector.<CharacterData>();
			var heroes:Object = new Object();
			var char:CharacterData;
			var hash:Dictionary = new Dictionary();
			var runes:Object = new Object();
			for each ( var s:String in arr ) {
				type = s.charAt( 0 );
				switch ( type ) {
					case 'r':
						switch ( s.charAt( 1 ) ) {
							case 'l':	g = 1;	break;
							case 'r':	g = 2;	break;
							default:	throw new ArgumentError();
						}
						element = RuneDataSerializer.deserialize( s );
						if ( g in heroes ) {
							heroes[ g ].addChild( element );
						} else {
							if ( !( g in runes ) ) runes[ g ] = new Vector.<RuneData>();
							runes[ g ].push( element );
						}
						break;
					default:
						id = parseInt( s.split( ',', 1 )[0].substr( 2 ) );
						element = data.getElement( id );
						h = Boolean( element );
						element = BattleWorldElementDataSerializer.deserialize( s, element );
						if ( element is BattleWorldElementData ) {
							if ( element is CharacterData ) { // хук для экономии трафика
								char = element as CharacterData;
								if ( char is HeroCharacterData ) { // если это герой, то надо сохранить рассу
									heroes[ char.group ] = char;
								} else {
									if ( char.group in heroes ) {
										char.race = heroes[ char.group ].race;
									} else {
										non.push( char );
									}
								}
							}
							if ( !h ) data.addChild( element );
						}
						hash[ element ] = true;
				}
			}
			// попишем рассу запоздавшим персонажам
			for each ( char in non ) {
				if ( char.group in heroes ) {
					char.race = heroes[ char.group ].race;
				}
			}
			// добавим запаздавгие руны
			var o:Object;
			for ( o in runes ) {
				for each ( element in runes[ o ] ) {
					heroes[ o ].addChild( element );
				}
			}
			// удалим ненужные элементы
			var elements:Vector.<BattleWorldAbstractElementData> = data.getElements();
			for each ( element in elements ) {
				if ( !( element in hash ) ) {
					data.removeChild( element );
				}
			}
			return data;
		}

	}

}