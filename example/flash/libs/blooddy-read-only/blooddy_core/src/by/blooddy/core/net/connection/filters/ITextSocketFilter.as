////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.connection.filters {

	import by.blooddy.core.net.NetCommand;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.08.2011 18:04:50
	 */
	public interface ITextSocketFilter extends IAbstractSocketFilter {
		
		function decodeCommand(data:String, io:String='input'):NetCommand;
		
		function encodeCommand(command:NetCommand):String;
		
	}
	
}