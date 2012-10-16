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
	 * @created					21.08.2011 18:05:26
	 */
	internal interface IAbstractSocketFilter {
		
		function getHash():String;
		
		function isSystem(commandName:String, io:String=''):Boolean;
		
	}
	
}