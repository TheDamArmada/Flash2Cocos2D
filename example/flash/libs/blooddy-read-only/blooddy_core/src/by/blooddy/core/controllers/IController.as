////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.data.DataBase;

	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					controller
	 */
	public interface IController extends IEventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * Вызываем метод контроллера.
		 * 
		 * @keyword					controller.basecontroller, basecontroller
		 */
		function get baseController():IBaseController;

		/**
		 * Сыылка на структуру данных.
		 * 
		 * @keyword					controller.basecontroller, basecontroller
		 */
		function get dataBase():DataBase;

		/**
		 * Ссылка на SharedObject.
		 * 
		 * @keyword					controller.sharedobject, sharedobject
		 */
		function get sharedObject():Object;

	}

}