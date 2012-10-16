////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 9, 2010 4:41:05 PM
	 */
	public interface IScanner {

		function get tokenKind():uint;
		
		function get tokenText():String;

		function readToken():uint;

		function retreat():void;

	}
	
}

