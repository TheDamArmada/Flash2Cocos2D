////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.character {

	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.data.character.MinionCharacterData;
	import ru.avangardonline.serializers.battle.world.BattleWorldElementDataSerializer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:37:12
	 */
	public class CharacterDataSerializer extends BattleWorldElementDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:CharacterData=null):CharacterData {
			switch ( source.charAt( 0 ) ) {
				case 'h':	return HeroCharacterDataSerializer.deserialize( source, target as HeroCharacterData );
				case 'u':	return MinionCharacterDataSerializer.deserialize( source, target as MinionCharacterData );
			}
			throw new ArgumentError();
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			var data:CharacterData = target as CharacterData;
			if ( !data ) throw new ArgumentError();
			switch ( source.charAt( 1 ) ) {
				case 'l':	data.group = 1;	break;
				case 'r':	data.group = 2;	break;
				default:	throw new ArgumentError();
			}
			return data;
		}

	}

}