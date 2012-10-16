////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.character {

	import flash.errors.IllegalOperationError;
	
	import ru.avangardonline.data.character.MinionCharacterData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:43:21
	 */
	public class MinionCharacterDataSerializer extends CharacterDataSerializer {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _serializer:MinionCharacterDataSerializer = new MinionCharacterDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function deserialize(source:String, target:MinionCharacterData=null):MinionCharacterData {
			return _serializer.deserialize( source, target ) as MinionCharacterData;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MinionCharacterDataSerializer() {
			super();
			if ( _serializer ) throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function deserialize(source:String, target:*=null):* {
			if ( source.charAt( 0 ) != 'u' ) throw new ArgumentError();
			var data:MinionCharacterData = target as MinionCharacterData;
			var arr:Array = source.substr( 2 ).split( '|', 3 );
			var arr2:Array = arr[ 0 ].split( ',', 2 );
			if ( !data ) {
				data = new MinionCharacterData( parseInt( arr2[ 0 ] ) );
			}
			super.deserialize( source, data );
			data.type = parseInt( arr2[ 1 ] );
			arr2 = arr[ 1 ].split( ',', 2 );
			data.coord.x = parseInt( arr2[ 0 ] ) - 5;
			data.coord.y = parseInt( arr2[ 1 ] ) - 1;
			var health:int = parseInt( arr[ 2 ] );
			data.health.current = health;
			data.health.max = health;
			return data;
		}

	}

}