////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {
	
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.controllers.IController;
	import by.blooddy.core.data.DataBase;
	import by.blooddy.core.net.Responder;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.IAbstractRemoter;
	import by.blooddy.gui.controller.ComponentController;
	import by.blooddy.gui.events.ComponentEvent;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					07.04.2010 20:14:57
	 */
	public class NativeComponentController extends EventDispatcher implements IController, IAbstractRemoter {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $internal;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function NativeComponentController() {
			if ( !( this is ComponentController ) ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  componentInfo
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _componentInfo:ComponentInfo;
		
		public function get componentInfo():ComponentInfo {
			return this._componentInfo;
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
		
		//----------------------------------
		//  constructed
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _constructed:Boolean = false;
		
		public function get constructed():Boolean {
			return this._constructed;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function call(commandName:String, responder:Responder=null, ...parameters):* {
			parameters.unshift( commandName, responder );
			this._baseController.call.apply( null, parameters );
		}

		public override function dispatchEvent(event:Event):Boolean {
			return this.$dispatchEvent( event );
		}

		public override function hasEventListener(type:String):Boolean {
			return	super.hasEventListener( type ) ||
					this._componentInfo.hasEventListener( type );
		}
		
		public override function willTrigger(type:String):Boolean {
			return	super.willTrigger( type ) ||
					this._componentInfo.willTrigger( type );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Namespace methonds
		//
		//--------------------------------------------------------------------------
		
		$internal final function $init(info:ComponentInfo, controller:IBaseController=null):void {
			this._componentInfo = info;
			if ( controller ) {
				this._baseController = controller;
				this._sharedObject = controller.sharedObject[ 'component_' + info.name ];
			}
			if ( !this._sharedObject ) controller.sharedObject[ 'component_' + info.name ] = this._sharedObject = new Object();
			info.component.addEventListener( ComponentEvent.COMPONENT_CONSTRUCT, this.handler_componentConstruct, false, int.MAX_VALUE, true );
			info.component.addEventListener( ComponentEvent.COMPONENT_DESTRUCT, this.handler_componentDestruct, false, int.MAX_VALUE, true );
			if ( info.component.constructed ) {
				info.component.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}
		
		$internal final function $clear():void {
			if ( this._constructed ) {
				this._constructed = false;
				this.destruct();
			}
			this._componentInfo.component.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._componentInfo.component.removeEventListener( ComponentEvent.COMPONENT_CONSTRUCT, this.handler_componentConstruct );
			this._componentInfo.component.removeEventListener( ComponentEvent.COMPONENT_DESTRUCT, this.handler_componentDestruct );
			this._sharedObject = null;
			this._baseController = null;
			this._componentInfo = null;
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
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		private function $dispatchEvent(event:Event):Boolean {
			var componentInfo:ComponentInfo = this._componentInfo;
			if ( event is ErrorEvent ) {
				var result:Boolean = true;
				if ( super.hasEventListener( event.type ) || !componentInfo || !componentInfo.hasEventListener( event.type ) ) {
					result &&= super.dispatchEvent( event );
				}
				if ( componentInfo && componentInfo.hasEventListener( event.type ) ) {
					result &&= componentInfo.$dispatchEvent( event );
				}
				return result;
			} else {
				return	super.dispatchEvent( event ) &&
						( !componentInfo || componentInfo.$dispatchEvent( event ) );
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			this._componentInfo.component.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			if ( !this._constructed && this._componentInfo.component.constructed ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_componentConstruct(event:Event):void {
			if ( !this._constructed ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_componentDestruct(event:Event):void {
			if ( this._constructed ) {
				this._constructed = false;
				this.destruct();
			}
		}

	}
	
}