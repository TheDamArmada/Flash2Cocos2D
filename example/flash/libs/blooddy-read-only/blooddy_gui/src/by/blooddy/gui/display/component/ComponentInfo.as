////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {

	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.display.DisplayObjectContainerProxy;
	import by.blooddy.core.managers.process.IProgressProcessable;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.UID;
	import by.blooddy.gui.controller.ComponentController;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="componentConstruct", type="by.blooddy.gui.events.ComponentEvent" )]
	[Event( name="componentDestruct", type="by.blooddy.gui.events.ComponentEvent" )]
	[Event( name="componentError", type="by.blooddy.gui.events.ComponentErrorEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.04.2010 18:41:19
	 */
	public final class ComponentInfo extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------
		
		use namespace $internal;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		$internal static var internalCall:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ComponentInfo() {
			if ( !internalCall ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			internalCall = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  id
		//----------------------------------
		
		/**
		 * @private
		 */
		public const id:String = UID.generate();
		
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
		//  component
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _component:Component;
		
		public function get component():Component {
			return this._component;
		}
		
		//----------------------------------
		//  proxy
		//----------------------------------

		/**
		 * @private
		 */
		private var _proxy:DisplayObjectContainerProxy;
		
		public function get proxy():DisplayObjectContainerProxy {
			if ( !this._proxy && this._component ) this._proxy = this._component.proxy;
			return this._proxy;
		}
		
		//----------------------------------
		//  controller
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _controller:ComponentController;
		
		public function get controller():ComponentController {
			return this._controller;
		}
		
		//----------------------------------
		//  properties
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _properties:ComponentProperties;
		
		public function get properties():ComponentProperties {
			return this._properties;
		}
		
		//----------------------------------
		//  parameters
		//----------------------------------

		/**
		 * @private
		 */
		private const _parameters:Object = new Object();
		
		public function get parameters():Object {
			var result:Object = new Object();
			for ( var i:String in this._parameters ) {
				result[ i ] = this._parameters[ i ];
			}
			return result;
		}

		//----------------------------------
		//  loader
		//----------------------------------

		/**
		 * @private
		 */
		private var _loader:$LoaderListener;
		
		public function get loader():IProgressProcessable {
			if ( !this._loader ) this._loader = new $LoaderListener();
			return this._loader;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' name="' + this._name + '"]';
		}

		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$internal function $initP(parameters:Object):void {
			for ( var i:String in parameters ) {
				this._parameters[ i ] = parameters[ i ];
			}
		}

		/**
		 * @private
		 */
		$internal function $init(name:String, component:Component, controller:ComponentController, properties:ComponentProperties, baseController:IBaseController):void {

			this._name = name;
			this._component = component;
			this._controller = controller;
			this._properties = properties || ComponentProperties.DEFAULT;

			if ( !this._loader ) this._loader = new $LoaderListener();
			this._loader.set$target( this._component );

			component.$init( this, this._properties.singleton ? name : name + '-' + this.id );
			if ( controller ) {
				controller.$init( this, baseController );
			}
			
		}
		
		/**
		 * @private
		 */
		$internal function $clear():void {
			if ( this._loader ) {
				this._loader.set$target( null );
			}
			if ( this._controller ) {
				this._controller.$clear();
			}
			if ( this._component ) {
				this._component.$clear();
			}
			this._properties = null;
			this._controller = null;
			this._component = null;
			this._name = null;
			this._proxy = null;
		}

		/**
		 * @private
		 */
		$internal function $dispatchEvent(event:Event):Boolean {
			return super.dispatchEvent( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_componentConstruct():void {
			
		}

		/**
		 * @private
		 */
		private function handler_componentDestruct():void {
			
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.loading.LoaderListener;
import by.blooddy.core.utils.ClassUtils;
import by.blooddy.gui.display.component.Component;

import flash.errors.IllegalOperationError;
import flash.events.IEventDispatcher;

/**
 * @private
 */
internal final class $LoaderListener extends LoaderListener {

	public function $LoaderListener() {
		super();
	}

	[Deprecated( message="метод запрещен", replacement="set$target" )]
	/**
	 * @private
	 */
	public override function set target(value:IEventDispatcher):void {
		Error.throwError( IllegalOperationError, 1069, 'target', ClassUtils.getClassName( this ) );
	}

	internal function set$target(value:Component):void {
		super.target = value;
	}

}