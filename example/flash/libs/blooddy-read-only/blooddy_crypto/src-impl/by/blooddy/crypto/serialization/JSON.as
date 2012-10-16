////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.serialization {
	
	/**
	 * @author					BlooDHounD
	 * @version					3.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.10.2010 15:53:38
	 * 
	 * @see						http://www.json.org
	 */
	public class JSON {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	value
		 * 
		 * @return
		 * 
		 * @throws	StackOverflowError	
		 */
		public static native function encode(value:*):String;
		
		/**
		 * @param	value
		 * 
		 * @return
		 * 
		 * @throws	TypeError			
		 * @throws	SyntaxError
		 */
		public static native function decode(value:String):*;
		
	}
	
}