////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.data.battle.world.BattleWorldArrowData;
	import ru.avangardonline.data.battle.world.BattleWorldEffectData;
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.data.character.MinionCharacterData;
	import ru.avangardonline.display.gfx.character.HeroCharacterView;
	import ru.avangardonline.display.gfx.character.MinionCharacterView;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 21:30:45
	 */
	public class BattleWorldViewFactory {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldViewFactory() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getElementView(data:BattleWorldAbstractElementData):BattleWorldElementView {
			if ( data is BattleWorldArrowData )			return new BattleWorldArrowView( data as BattleWorldArrowData );
			if ( data is BattleWorldEffectData )		return new BattleWorldEffectView( data as BattleWorldEffectData );
			else if ( data is CharacterData ) {
				if ( data is MinionCharacterData )		return new MinionCharacterView( data as MinionCharacterData );
				else if ( data is HeroCharacterData )	return new HeroCharacterView( data as HeroCharacterData );
			}
			return null;
		}

	}

}