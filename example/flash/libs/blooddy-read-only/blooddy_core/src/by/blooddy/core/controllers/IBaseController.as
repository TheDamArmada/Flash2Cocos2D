////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.commands.ICommandDispatcher;
	import by.blooddy.core.utils.IAbstractRemoter;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					baseconstroller, controller
	 */
	public interface IBaseController extends IController, IAbstractRemoter, ICommandDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Ссылка на грфический контэйнер.
		 * 
		 * @keyword					baseconstroller.container, container
		 */
		function get container():DisplayObjectContainer;

	}

}