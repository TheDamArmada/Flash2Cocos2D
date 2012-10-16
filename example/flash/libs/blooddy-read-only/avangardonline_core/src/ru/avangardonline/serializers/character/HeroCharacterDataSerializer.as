////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.character {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.character.HeroCharacterData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:39:30
	 */
	public class HeroCharacterDataSerializer extends CharacterDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:HeroCharacterDataSerializer = new HeroCharacterDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:HeroCharacterData=null):HeroCharacterData {
			return _serializer.deserialize( source, target ) as HeroCharacterData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function HeroCharacterDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'h' ) throw new ArgumentError();
			var data:HeroCharacterData = target as HeroCharacterData;
			var arr:Array = source.substr( 2 ).split( ',', 4 );
			var id:uint = parseInt( arr[ 0 ] );
			if ( !data ) {
				data = new HeroCharacterData( id, arr[ 1 ] );
			} else if ( data.id != id || data.name != arr[ 1 ] ) {
				throw new ArgumentError();
			}
			super.deserialize( source, data );
			data.race = parseInt( arr[ 2 ] );
			data.sex = parseBoolean( arr[ 3 ] );
			return data;
		}

	}

}