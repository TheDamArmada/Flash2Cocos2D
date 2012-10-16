////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {
	
	import by.blooddy.core.blooddy;
	import by.blooddy.core.display.DisplayObjectContainerProxy;
	import by.blooddy.core.display.resource.ResourceSprite;
	import by.blooddy.core.managers.process.IProgressProcessable;
	import by.blooddy.core.utils.ClassAlias;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.gui.events.ComponentEvent;
	
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;

	//--------------------------------------
	//  Aliases
	//--------------------------------------
	
	ClassAlias.registerNamespaceAlias( blooddy, Component );

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="componentConstruct", type="by.blooddy.gui.events.ComponentEvent" )]
	[Event( name="componentDestruct", type="by.blooddy.gui.events.ComponentEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					07.04.2010 20:16:02
	 */
	public class Component extends ResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Namepsaces
		//
		//--------------------------------------------------------------------------

		use namespace $internal;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _POINT:Point = new Point();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function Component() {
			super();
			super.transform = new $Transform( this );
			super.mouseEnabled = true;
			super.mouseChildren = true;
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage, false, int.MIN_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _fixed:Boolean;

		/**
		 * @private
		 */
		private var _lock:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loader
		//----------------------------------

		public function get loader():IProgressProcessable {
			return this._componentInfo.loader;
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
		
		//----------------------------------
		//  name
		//----------------------------------
		
		/**
		 * @private
		 */
		public override function set name(value:String):void {
			if ( this._fixed ) {
				throw new IllegalOperationError();
			} else {
				super.name = name;
			}
		}

		//----------------------------------
		//  proxy
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _proxy:DisplayObjectContainerProxy;
		
		public function get proxy():DisplayObjectContainerProxy {
			if ( !this._proxy ) this._proxy = new DisplayObjectContainerProxy( this );
			return this._proxy;
		}
		
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
		
		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:ComponentContainer;
		
		public function get container():ComponentContainer {
			return this._container;
		}

		//----------------------------------
		//  backgroundColor
		//----------------------------------

		/**
		 * @private
		 */
		private var _backgroundColor:uint = 0x00FF0000;

		public function get backgroundColor():uint {
			return this._backgroundColor;
		}

		/**
		 * @private
		 */
		public function set backgroundColor(value:uint):void {
			if ( this._backgroundColor == value ) return;
			this._backgroundColor = value;
			this.drawLock();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function close():void {
			if ( this._container ) {
				this._container.removeComponent( this._componentInfo );
			}
		}

		/**
		 * @private
		 */
		public override function dispatchEvent(event:Event):Boolean {
			return this.$dispatchEvent( event );
		}

		/**
		 * @private
		 */
		public override function hasEventListener(type:String):Boolean {
			return	super.hasEventListener( type ) ||
					this._componentInfo.hasEventListener( type );
		}

		/**
		 * @private
		 */
		public override function willTrigger(type:String):Boolean {
			return	super.willTrigger( type ) ||
					this._componentInfo.willTrigger( type );
		}

		public function bringToFront():void {
			this._container.bringToFront( this._componentInfo );
		}
		
		public function sendToBack():void {
			this._container.sendToBack( this._componentInfo );
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
		//  Namespace methods
		//
		//--------------------------------------------------------------------------

		$internal final function $init(componentInfo:ComponentInfo, name:String=null):void {
			this._componentInfo = componentInfo;
			if ( name ) {
				this._fixed = true;
				super.name = name;
			}
			this._lock = componentInfo.properties.modal;
		}

		$internal final function $clear():void {
			this._componentInfo = null;
			this._fixed = false;
			super.name = '';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function drawLock():void {
			if ( !super.stage ) return;
			var p:Point = super.globalToLocal( _POINT );
			with ( super.graphics ) {
				clear();
				beginFill( this._backgroundColor & 0xFFFFFF, ( this._backgroundColor >>> 24 ) / 0xFF );
				drawRect( p.x, p.y, super.stage.stageWidth, super.stage.stageHeight );
				endFill();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateLock(event:Event=null):void {
			this.drawLock(); 
		}

		/**
		 * @private
		 */
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
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			if ( !this._constructed && this._container ) {

				this._constructed = true;
				this.construct();

				var resultEvent:ComponentEvent = new ComponentEvent( ComponentEvent.COMPONENT_CONSTRUCT, false, false, this._componentInfo );
				this.$dispatchEvent( resultEvent );
				if ( this._container ) { // могли уже удалить нечаенно )
					this._container.$dispatchEvent( resultEvent ); // TODO: перенести?
				}

			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			var parent:DisplayObject = this;
			while ( ( parent = parent.parent ) && !( parent is ComponentContainer ) ) {};
			this._container = parent as ComponentContainer;
			if ( this._lock ) {
				super.stage.addEventListener( Event.RESIZE, this.updateLock, false, int.MIN_VALUE );
				this.updateLock();
			}
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame, false, int.MIN_VALUE );
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			if ( this._constructed ) {
				this._constructed = false;

				var resultEvent:ComponentEvent = new ComponentEvent( ComponentEvent.COMPONENT_DESTRUCT, false, false, this._componentInfo );
				this.$dispatchEvent( resultEvent );
				this._container.$dispatchEvent( resultEvent ); // TODO: перенести?

				this.destruct();

			}
			if ( this._lock ) {
				super.stage.removeEventListener( Event.RESIZE, this.updateLock );
			}
			if ( this._componentInfo ) {
				this._componentInfo.$clear(); // TODO: перенести?
			}
			this._container = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Deprecated
		//
		//--------------------------------------------------------------------------

		[Deprecated( message="свойство запрещено" )]
		public override function set x(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'x', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set y(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'y', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set z(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'z', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set scaleX(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'scaleX', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set scaleY(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'scaleY', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set scaleZ(value:Number):void {
			Error.throwError( IllegalOperationError, 1069, 'scaleZ', ClassUtils.getClassName( this ) );
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set transform(value:Transform):void {
			Error.throwError( IllegalOperationError, 1069, 'transform', ClassUtils.getClassName( this ) );
		}
		
		public override function set mouseEnabled(value:Boolean):void {
			if ( this._lock ) {
				Error.throwError( IllegalOperationError, 1069, 'mouseEnabled', ClassUtils.getClassName( this ) );
			}
			super.mouseEnabled = value;
		}
		
		[Deprecated( message="свойство запрещено" )]
		public override function set mouseChildren(value:Boolean):void {
			Error.throwError( IllegalOperationError, 1069, 'mouseChildren', ClassUtils.getClassName( this ) );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.ClassUtils;

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Transform;

/**
 * @private
 */
internal final class $Transform extends Transform {


	public function $Transform(target:DisplayObject) {
		super( target );
	}

	public override function set matrix(value:Matrix):void {
		Error.throwError( IllegalOperationError, 1069, 'matrix', ClassUtils.getClassName( this ) );
	}

	public override function set matrix3D(m:Matrix3D):* {
		Error.throwError( IllegalOperationError, 1069, 'matrix3D', ClassUtils.getClassName( this ) );
	}

}