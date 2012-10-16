////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.serializers.items {
	
	import ru.avangardonline.data.items.RuneData;
	import ru.avangardonline.serializers.ISerializer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					31.03.2010 23:40:12
	 */
	public class RuneDataSerializer implements ISerializer {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _serializer:RuneDataSerializer = new RuneDataSerializer();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function deserialize(source:String, target:RuneData=null):RuneData {
			return _serializer.deserialize( source, target ) as RuneData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function RuneDataSerializer() {
			super();
		}
		
		public function deserialize(source:String, target:*=null):* {
			var data:RuneData = target as RuneData;
			if ( !data ) data = new RuneData();
			var arr:Array = source.split( ',' );
			data.type = parseInt( arr[ 0 ].substr( 2 ) );
			data.name = arr[ 1 ];
			return data;
		}
		
	}
	
}