////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.net.Responder;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					iabstractremoter
	 */
	public interface IAbstractRemoter {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Функа выполняет некую комманду.
		 * 
		 * @param	commandName		Команда.
		 * @param	arguments		Аргументы команды.
		 *
		 * @keyword					iabstractremoter.call, call
		 */
		function call(commandName:String, responder:Responder=null, ...parameters):*;

	}

}