////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.data.DataBase;

	import flash.events.EventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class AbstractController extends EventDispatcher implements IController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function AbstractController(controller:IBaseController!, sharedObjectKey:String=null) {
			super();
			this._baseController = controller;
			if ( sharedObjectKey ) {
				this._sharedObject = controller.sharedObject[ sharedObjectKey ];
				if ( !this._sharedObject ) this._sharedObject = controller.sharedObject[ sharedObjectKey ] = new Object();
			} else {
				this._sharedObject = controller.sharedObject;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  baseController
		//----------------------------------

		/**
		 * @private
		 */
		private var _baseController:IBaseController;

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this._baseController;
		}

		//----------------------------------
		//  dataBase
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._baseController.dataBase;
		}

		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @private
		 */
		private var _sharedObject:Object;

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._sharedObject;
		}

	}

}