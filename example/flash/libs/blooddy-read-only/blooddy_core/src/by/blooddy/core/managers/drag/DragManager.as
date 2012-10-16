////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.drag {

	import by.blooddy.core.events.managers.DragEvent;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.DisplayObjectUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Namespaces
	//--------------------------------------
	
	use namespace $internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			y.blooddy.core.events.managers.DragEvent.DRAG_START
	 */
	[Event( name="dragStart", type="by.blooddy.core.events.managers.DragEvent" )]

	/**
	 * @eventType			y.blooddy.core.events.managers.DragEvent.DRAG_STOP
	 */
	[Event( name="dragStop", type="by.blooddy.core.events.managers.DragEvent" )]

	/**
	 * @eventType			y.blooddy.core.events.managers.DragEvent.DRAG_MOVE
	 */
	[Event( name="dragMove", type="by.blooddy.core.events.managers.DragEvent" )]

	/**
	 * @eventType			y.blooddy.core.events.managers.DragEvent.DRAG_FAIL
	 */
	[Event( name="dragFail", type="by.blooddy.core.events.managers.DragEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					dragmanager, drag
	 */
	public final class DragManager extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _inited:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		public static const manager:DragManager = new DragManager();

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function startDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			manager.startDrag( dragSource, rescale, offset, bounds );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function DragManager() {
			if ( _inited ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			_inited = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _lastMouseEvent:MouseEvent;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//--------------------------------------
		//  dropTarget
		//--------------------------------------

		/**
		 * @private
		 */
		private var _dropTarget:DisplayObject;

		public function get dropTarget():DisplayObject {
			return this._dropTarget;
		}

		//--------------------------------------
		//  dragSource
		//--------------------------------------

		/**
		 * @private
		 */
		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		//--------------------------------------
		//  dragObject
		//--------------------------------------

		/**
		 * @private
		 */
		private var _dragObject:DragObject;

		public function get dragObject():DragObject {
			return this._dragObject;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function stopDrag():void {
			if ( !this._dragSource ) throw new IllegalOperationError();
			this.dispatchDragEvent( DragEvent.DRAG_FAIL );
			this.clear();
		}

		/**
		 * @private
		 */
		public function startDrag(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):void {
			if ( !dragSource.stage ) throw new ArgumentError();

			if ( this._dragSource == dragSource ) return;

			if ( this._dragSource ) {
				this.clear();
			}

			this._dragSource = dragSource;

			this._dragObject = DragObject.$getInstance( this._dragSource, rescale, offset, bounds );

			offset = this._dragObject.offset;

			this._lastMouseEvent = new MouseEvent( MouseEvent.MOUSE_DOWN, true, false, offset.x, offset.y, null, false, false, false, true, 0 );

			var stage:Stage = this._dragSource.stage;

			this._dragSource.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_fail,		false, int.MAX_VALUE );
			this._dragSource.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_fail,		true, int.MAX_VALUE );
			this._dragSource.addEventListener( Event.DEACTIVATE,			this.handler_fail,		false, int.MAX_VALUE );
			this._dragSource.addEventListener( Event.DEACTIVATE,			this.handler_fail,		true, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_MOVE,					this.handler_mouseMove,	false, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_MOVE,					this.handler_mouseMove,	true, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_UP,					this.handler_mouseUp,	false, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_UP,					this.handler_mouseUp,	true, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_OVER,					this.handler_mouseOver,	false, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_OVER,					this.handler_mouseOver,	true, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_OUT,					this.handler_mouseOut,	false, int.MAX_VALUE );
			stage.addEventListener( MouseEvent.MOUSE_OUT,					this.handler_mouseOut,	true, int.MAX_VALUE );
			stage.addEventListener( KeyboardEvent.KEY_UP,					this.handler_keyUp,		false, int.MAX_VALUE );

			this._dropTarget = DisplayObjectUtils.getDropTarget( stage, new Point( stage.mouseX, stage.mouseY ) );
			stage.addChild( this._dragObject );
			this.dispatchDragEvent( DragEvent.DRAG_START );

		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			if ( this._dragObject && this._dragObject.$parent ) {
				this._dragObject.$parent.removeChild( this._dragObject );
			}

			if ( this._dragSource && this._dragSource.stage ) {

				var stage:Stage = this._dragSource.stage;

				this._dragSource.removeEventListener( Event.REMOVED_FROM_STAGE,	this.handler_fail,		false );
				this._dragSource.removeEventListener( Event.REMOVED_FROM_STAGE,	this.handler_fail,		true );
				this._dragSource.removeEventListener( Event.DEACTIVATE,			this.handler_fail,		false );
				this._dragSource.removeEventListener( Event.DEACTIVATE,			this.handler_fail,		true );
				stage.removeEventListener( MouseEvent.MOUSE_MOVE,				this.handler_mouseMove,	false );
				stage.removeEventListener( MouseEvent.MOUSE_MOVE,				this.handler_mouseMove,	true );
				stage.removeEventListener( MouseEvent.MOUSE_UP,					this.handler_mouseUp,	false );
				stage.removeEventListener( MouseEvent.MOUSE_UP,					this.handler_mouseUp,	true );
				stage.removeEventListener( MouseEvent.MOUSE_OVER,				this.handler_mouseOver,	false );
				stage.removeEventListener( MouseEvent.MOUSE_OVER,				this.handler_mouseOver,	true );
				stage.removeEventListener( MouseEvent.MOUSE_OUT,				this.handler_mouseOut,	false );
				stage.removeEventListener( MouseEvent.MOUSE_OUT,				this.handler_mouseOut,	true );
				stage.removeEventListener( KeyboardEvent.KEY_UP,				this.handler_keyUp,		false );

			}

			this._dragSource = null;
			this._dragObject = null;
			this._dropTarget = null;
		}

		/**
		 * @private
		 */
		private function dispatchDragEvent(type:String):void {
			var e:MouseEvent = this._lastMouseEvent;
			var offset:Point = ( this._dragObject ? this._dragObject.offset : null ) || new Point();
			super.dispatchEvent( new DragEvent( type, false, false, offset.x, offset.y, null, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta, this._dragSource, this._dragObject, this._dropTarget ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_fail(event:Event):void {
			( event.target as DisplayObject ).removeEventListener(Event.REMOVED_FROM_STAGE, this.handler_fail);
			if ( this._dragSource === event.target ) {
				this.clear();
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseUp(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_STOP );
			this.clear();
		}

		/**
		 * @private
		 */
		private function handler_mouseMove(event:MouseEvent):void {
			this._lastMouseEvent = event;
			this.dispatchDragEvent( DragEvent.DRAG_MOVE );
		}

		/**
		 * @private
		 */
		private function handler_keyUp(event:KeyboardEvent):void {
			if ( event.keyCode == Keyboard.ESCAPE ) {
				this.dispatchDragEvent( DragEvent.DRAG_FAIL );
				this.clear();
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseOver(event:MouseEvent):void {
			this._dropTarget = event.target as DisplayObject;
		}

		/**
		 * @private
		 */
		private function handler_mouseOut(event:MouseEvent):void {
			this._dropTarget = null;
		}

	}

}