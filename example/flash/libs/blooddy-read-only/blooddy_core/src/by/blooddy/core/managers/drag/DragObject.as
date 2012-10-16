////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.drag {

	import by.blooddy.core.display.BaseShape;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	//--------------------------------------
	//  Namespaces
	//--------------------------------------
	
	use namespace $internal;
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="graphics" )]
	[Exclude( kind="property", name="parent" )]
	[Exclude( kind="property", name="$parent" )]
	[Exclude( kind="property", name="stage" )]
	[Exclude( kind="property", name="visible" )]

	[Exclude( kind="method", name="$getInstance" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					dragobject, drag
	 */
	public final class DragObject extends BaseShape {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _internalCall:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$internal static function $getInstance(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null):DragObject {
			_internalCall = true;
			var result:DragObject = new DragObject( dragSource, rescale, offset, bounds );
			_internalCall = false;
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * На кубунте странные проблемы с драгом. невъебически задержки
		 * при перемещеннии.
		 */
		private static const CORRECT_UPDATE:Boolean = ( Capabilities.os.toLowerCase().indexOf( 'linux' ) <0 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function DragObject(dragSource:DisplayObject, rescale:Boolean=false, offset:Point=null, bounds:Rectangle=null/*, snapAngle:uint=0*/) {
			if ( !_internalCall ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			this._dragSource = dragSource;
			this._rescale = rescale;
			this._offset = offset || (
				rescale ?
				new Point( -dragSource.mouseX, -dragSource.mouseY ) :
				new Point( -dragSource.mouseX * dragSource.scaleX, -dragSource.mouseY * dragSource.scaleY )
			);
			this._bounds = bounds;
			//this._snapAngle = snapAngle;
			//this._lastMouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, this._offset.x, this._offset.y, null, false, false, false, true, 0);
			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _bitmapData:BitmapData;

		/**
		 * @private
		 */
		private var _rescale:Boolean;

		/**
		 * @private
		 */
		//private var _lastMouseEvent:MouseEvent;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: DisplayObject
		//
		//--------------------------------------------------------------------------

		//--------------------------------------
		//  x
		//--------------------------------------

		/**
		 * @private
		 */
		public override function set x(value:Number):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------
		//  y
		//--------------------------------------

		/**
		 * @private
		 */
		public override function set y(value:Number):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------
		//  parent
		//--------------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @default	null
		 */
		public override function get parent():DisplayObjectContainer {
			return null;
		}

		/**
		 * @private
		 */
		$internal function get $parent():DisplayObjectContainer {
			return super.parent;
		}

		//--------------------------------------
		//  stage
		//--------------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @default	null
		 */
		public override function get stage():Stage {
			return null;
		}

		//--------------------------------------
		//  visible
		//--------------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @private
		 */
		public override function get visible():Boolean {
			return true;
		}

		/**
		 * @private
		 */
		public override function set visible(value:Boolean):void {
			throw new IllegalOperationError();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Shape
		//
		//--------------------------------------------------------------------------

		//--------------------------------------
		//  graphics
		//--------------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @default	null
		 */
		public override function get graphics():Graphics {
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _dragSource:DisplayObject;

		public function get dragSource():DisplayObject {
			return this._dragSource;
		}

		/**
		 * @private
		 */
		private var _offset:Point;

		public function get offset():Point {
			return this._offset.clone();
		}

		/**
		 * @private
		 */
		public function set offset(value:Point):void {
			if ( !value || this._offset === value || value.equals( this._offset ) ) return;
			this._offset = value;
			this.updatePosition();
		}

		/**
		 * @private
		 */
		private var _bounds:Rectangle;

		public function get bounds():Rectangle {
			return this._bounds.clone();
		}

		/**
		 * @private
		 */
		public function set bounds(value:Rectangle):void {
			if ( !value || this._bounds === value || value.equals( this._bounds ) ) return;
			this._bounds = value;
			this.updatePosition();
		}

		private var _snapAngle:uint;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * переопределяем и ставим заглушку от идиотов.
		 * useWeakReference всегда true, так как объект долго не живёт.
		 */
		public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
			super.addEventListener( type, listener, useCapture, priority, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updatePosition():void {
			if ( !super.visible ) return;

//			var delim:Number = 180 / (8/2);

			//var oldX:Number = super.x;
			//var oldY:Number = super.y;
			var x:Number = super.stage.mouseX + this._offset.x;
			var y:Number = super.stage.mouseY + this._offset.y;

			//var event:MouseEvent = this._lastMouseEvent;

//			if ( this._snapAngle && event && event.shiftKey ) { // зажат шифт
//				var start:Point = this._dragSource.parent.localToGlobal( new Point( this._dragSource.x, this._dragSource.y ) );
//				var offset:Point = ( new Point( x, y ) ).subtract( start );
//				var angle:Number = Math.round( Math.atan2( offset.y , offset.x ) / Math.PI * 180 / ( this._snapAngle/2 ) ) * ( this._snapAngle/2 ) / 180 * Math.PI;
//				var length:Number = offset.length;
//				x = start.x + Math.cos( angle ) * length;
//				y = start.y + Math.sin( angle ) * length;
//				if ( this._bounds ) {
//
//				}
//			} else {
				if ( this._bounds ) {
					x = Math.min( Math.max( this._bounds.left, x ), this._bounds.right );
					y = Math.min( Math.max( this._bounds.top, y ), this._bounds.bottom );
				}
//			}
			super.x = x;
			super.y = y;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {

			var scaleX:Number, scaleY:Number;
			if ( !this._rescale ) {
				scaleX = this._dragSource.scaleX;
				scaleY = this._dragSource.scaleY;
			}

			var bounds:Rectangle = this._dragSource.getBounds( this._dragSource );

			this._bitmapData = new BitmapData( bounds.width+4, bounds.height+4, true, 0x00FF00 );
			this._bitmapData.draw( this._dragSource, new Matrix( 1, 0, 0, 1, -bounds.x+2, -bounds.y+2 ) );

			super.graphics.beginBitmapFill( this._bitmapData, new Matrix( 1, 0, 0, 1, bounds.x-2, bounds.y-2 ), false, true );
			super.graphics.drawRect( bounds.x-2, bounds.y-2, bounds.width+4, bounds.height+4 );
			super.graphics.endFill();

			if ( !this._rescale ) {
				super.scaleX = this._dragSource.scaleX;
				super.scaleY = this._dragSource.scaleY;
			}

			this.updatePosition();

			super.stage.addEventListener( MouseEvent.MOUSE_MOVE,	this.handler_mouseMove, false, int.MAX_VALUE );
			super.stage.addEventListener( Event.MOUSE_LEAVE,		this.handler_mouseLeave, false, int.MAX_VALUE );

		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {

			super.graphics.clear();
			this._bitmapData.dispose();

			super.stage.removeEventListener( MouseEvent.MOUSE_MOVE,	this.handler_mouseMove );
			super.stage.removeEventListener( Event.MOUSE_LEAVE,		this.handler_mouseLeave );

		}

		/**
		 * @private
		 */
		private function handler_mouseMove(event:MouseEvent):void {
			//this._lastMouseEvent = event;
			if ( !super.visible ) super.visible = true;
			this.updatePosition();
			if ( CORRECT_UPDATE ) event.updateAfterEvent();
		}

		/**
		 * @private
		 */
		private function handler_mouseLeave(event:Event):void {
			super.visible = false;
		}

	}

}