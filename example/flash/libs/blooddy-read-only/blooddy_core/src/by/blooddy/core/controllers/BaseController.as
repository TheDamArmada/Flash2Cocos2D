////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.commands.Command;
	import by.blooddy.core.commands.CommandDispatcher;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.net.Responder;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					basecontroller, controller
	 */
	public class BaseController extends CommandDispatcher implements IBaseController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BaseController(container:DisplayObjectContainer!, dataBase:DataBase!, sharedObject:ProxySharedObject!) {
			if ( !container )		Error.throwError( TypeError, 2007, 'container' );
			if ( !dataBase )		Error.throwError( TypeError, 2007, 'dataBase' );
			if ( !sharedObject )	Error.throwError( TypeError, 2007, 'sharedObject' );
			super();
			this._dataBase = dataBase;
			this._container = container;
			this._sharedObject = sharedObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		/**
		 * @inheritDoc
		 */
		public function get container():DisplayObjectContainer {
			return this._container;
		}

		//----------------------------------
		//  baseController
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get baseController():IBaseController {
			return this;
		}

		//----------------------------------
		//  database
		//----------------------------------

		/**
		 * @private
		 */
		private var _dataBase:DataBase;

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return this._dataBase;
		}

		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @private
		 */
		private var _sharedObject:ProxySharedObject;

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			return this._sharedObject;
		}		

		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function call(commandName:String, responder:Responder=null, ...arguments):* {
			if ( responder ) throw new ArgumentError();
			super.dispatchCommand( new Command( commandName, arguments ) );
		}

	}

}