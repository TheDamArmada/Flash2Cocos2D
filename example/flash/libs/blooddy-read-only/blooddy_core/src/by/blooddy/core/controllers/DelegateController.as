////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.net.IRemoter;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.utils.IAbstractRemoter;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					22.12.2010 15:30:31
	 */
	public class DelegateController extends EventDispatcher implements IController, IAbstractRemoter {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DelegateController(name:String, baseController:IBaseController=null) {
			super();
			this._name = name;
			if ( baseController ) this.baseController = baseController; // TODO: exit frame
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		public function get name():String {
			return this._name;
		}

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

		/**
		 * @private
		 */
		public function set baseController(value:IBaseController):void {
			if ( this._baseController === value ) return;
			if ( this._baseController ) this.destruct();
			this._baseController = value;
			if ( this._baseController ) this.construct();
		}

		//----------------------------------
		//  dataBase
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get dataBase():DataBase {
			return ( this._baseController ? this._baseController.dataBase : null );
		}

		//----------------------------------
		//  sharedObject
		//----------------------------------

		/**
		 * @inheritDoc
		 */
		public function get sharedObject():Object {
			var sharedObject:Object;
			if ( this._baseController ) {
				sharedObject = this._baseController.sharedObject[ 'delegate_' + this._name ];
				if ( !sharedObject ) {
					this._baseController.sharedObject[ 'delegate_' + this._name ] = sharedObject = new Object();
				}
			}
			return sharedObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function call(commandName:String, responder:Responder=null, ...parameters):* {
			parameters.unshift( commandName, responder );
			return this._baseController.call.apply( null, parameters );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected virtual function construct():void {
		}

		protected virtual function destruct():void {
		}

	}

}