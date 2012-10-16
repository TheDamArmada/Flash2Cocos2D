////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.battle.world {

	import by.blooddy.core.data.Data;
	
	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.serializers.ISerializer;
	import ru.avangardonline.serializers.character.CharacterDataSerializer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 23:40:56
	 */
	public class BattleWorldElementDataSerializer implements ISerializer {

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:Data=null):Data {
			return CharacterDataSerializer.deserialize( source, target as CharacterData );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementDataSerializer() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		public virtual function deserialize(source:String, target:*=null):* {
			Error.throwError( IllegalOperationError, 2014 );
		}

	}

}