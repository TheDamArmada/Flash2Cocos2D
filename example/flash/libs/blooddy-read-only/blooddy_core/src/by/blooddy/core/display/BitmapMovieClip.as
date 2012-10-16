////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.utils.IDisposable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="method", name="addChild" )]
	[Exclude( kind="method", name="addChildAt" )]
	[Exclude( kind="method", name="removeChild" )]
	[Exclude( kind="method", name="removeChildAt" )]
	[Exclude( kind="method", name="getChildAt" )]
	[Exclude( kind="method", name="getChildIndex" )]
	[Exclude( kind="method", name="getChildByName" )]
	[Exclude( kind="method", name="setChildIndex" )]
	[Exclude( kind="method", name="swapChildren" )]
	[Exclude( kind="method", name="swapChildrenAt" )]
	[Exclude( kind="method", name="contains" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					bitmapmovieclip, bitmap, movieclip
	 */
	public class BitmapMovieClip extends MovieClipEquivalent implements IDisposable {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		use namespace $private;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$private static const _EMPTY_BMP:BitmapData = new BitmapData( 1, 1, true, 0x000000 );

		/**
		 * @private
		 * инитиализируем в out-of-package
		 */
		$private static var _EMPTY_LIST:Vector.<Frame>;
		
		//--------------------------------------------------------------------------
		//
		//  Class private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$private static function getElement(bitmap:IBitmapDrawable):Frame {
			var bmp:BitmapData;
			var x:int;
			var y:int;
			if ( bitmap is BitmapData ) {
				bmp = ( bitmap as BitmapData ).clone();
			} else if ( bitmap is Bitmap ) {
				bmp = ( bitmap as Bitmap ).bitmapData.clone();
			} else if ( bitmap is DisplayObject ) {
				var obj:DisplayObject = bitmap as DisplayObject;
				var bounds:Rectangle = obj.getBounds( obj );
				if ( !bounds.isEmpty() ) {
					bmp = new BitmapData( Math.ceil( bounds.width + 2 ), Math.ceil( bounds.height + 2 ), true, 0x000000 );
					bmp.draw( obj, new Matrix( 1, 0, 0, 1, Math.ceil( -bounds.x + 1 ), Math.ceil( -bounds.y + 1 ) ) );
					x = Math.floor( bounds.x - 1 );
					y = Math.floor( bounds.y - 1 );
				}
			} else {
				Error.throwError( ArgumentError, 0 );
			}
			return new Frame( bmp, x, y );
		}

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * 
		 * @param	bitmap
		 * @param	pixelSnapping
		 * @param	smoothing
		 * 
		 * @return
		 * 
		 * @note					после выполнения метода MovieClip будет остановлен на последнем кадре. 
		 *  
		 */
		public static function getAsMovieClip(bitmap:IBitmapDrawable, deferred:Boolean=true, smoothing:Boolean=false):BitmapMovieClip {
			var result:BitmapMovieClip;
			if ( bitmap is MovieClip ) {
				if ( bitmap is BitmapMovieClip ) {
					result = ( bitmap as BitmapMovieClip ).clone();
					result._smoothing = smoothing;
				} else {
					var mc:MovieClip = bitmap as MovieClip;
					const l:uint = mc.totalFrames;
					result = ( deferred ? new DeferredBitmapMovieClip( mc ) : new BitmapMovieClip() );
					result.$totalFrames = l;
					result._list = new Vector.<Frame>( l + 1, true );
					if ( !deferred ) {
						for ( var i:uint = 1; i<=l; ++i ) {
							mc.gotoAndStop( i );
							result._list[ i ] = getElement( mc );
						}
					}
				}
			} else {
				result = new BitmapMovieClip();
				result._list = new Vector.<Frame>( 2, true );
				result._list[ 1 ] = getElement( bitmap );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function BitmapMovieClip() {
			super();
			this.$totalFrames = 1;
			super.mouseChildren = false;
			super.addChild( this._content );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$private var _list:Vector.<Frame> = _EMPTY_LIST;

		/**
		 * @private
		 */
		$private var _smoothing:Boolean;
		
		/**
		 * @private
		 */
		private const _content:Shape = new Shape();

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _mouseChildren:Boolean = true;

		[Deprecated( message="свойство не используется" )]
		/**
		 * @private
		 */
		public override function get mouseChildren():Boolean {
			return this._mouseChildren;
		}
		
		/**
		 * @private
		 */
		public override function set mouseChildren(value:Boolean):void {
			this._mouseChildren = true;
		}

		public override function get numChildren():int {
			return 0;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		[Deprecated( message="метод запрещён" )]
		public override function addChild(child:DisplayObject):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'addChild' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'addChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function removeChild(child:DisplayObject):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'removeChild' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function removeChildAt(index:int):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'removeChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function getChildAt(index:int):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'getChildAt' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function getChildIndex(child:DisplayObject):int {
			Error.throwError( IllegalOperationError, 1001, 'getChildIndex' );
			return -1;
		}

		[Deprecated( message="метод запрещён" )]
		public override function getChildByName(name:String):DisplayObject {
			Error.throwError( IllegalOperationError, 1001, 'getChildByName' );
			return null;
		}

		[Deprecated( message="метод запрещён" )]
		public override function setChildIndex(child:DisplayObject, index:int):void {
			Error.throwError( IllegalOperationError, 1001, 'setChildIndex' );
		}

		[Deprecated( message="метод запрещён" )]
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			Error.throwError( IllegalOperationError, 1001, 'swapChildren' );
		}

		[Deprecated( message="метод запрещён" )]
		public override function swapChildrenAt(index1:int, index2:int):void {
			Error.throwError( IllegalOperationError, 1001, 'swapChildrenAt' );
		}

		[Deprecated( message="метод запрещён" )]
		public override function contains(child:DisplayObject):Boolean {
			Error.throwError( IllegalOperationError, 1001, 'contains' );
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	bind	если установлен в true, то копирует только ссылки на эленты, аставляя связывание.
		 */
		public function clone():BitmapMovieClip {
			var result:BitmapMovieClip = new BitmapMovieClip();
			result._smoothing = this._smoothing;
			result._list = this._list;
			result.$totalFrames = this.$totalFrames;
			return result;
		}

		public function dispose():void {
			this._content.graphics.clear();
			this.$totalFrames = 0;
			var bmp:BitmapData;
			for each ( var e:Frame in this._list ) {
				if ( e && e.bmp !== _EMPTY_BMP ) e.bmp.dispose();
			}
			this._list = null;
			super.stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		$protected override function $setCurrentFrame(value:int):void {
			this.$currentFrame = value;
			if ( this._list.length < value ) return;
			var g:Graphics = this._content.graphics;
			g.clear();
			var e:Frame = this._list[ value ];
			if ( e && e.bmp ) {
				var bmp:BitmapData = e.bmp;
				g.beginBitmapFill( bmp, null, false, this._smoothing );
				g.drawRect( 0, 0, bmp.width, bmp.height );
				this._content.x = e.x;
				this._content.y = e.y;
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.display.BitmapMovieClip;

import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.events.Event;

internal namespace $private;

use namespace $private;

BitmapMovieClip._EMPTY_LIST = new Vector.<Frame>( 2, true );
BitmapMovieClip._EMPTY_LIST[ 1 ] = new Frame( BitmapMovieClip._EMPTY_BMP );

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: CollectionElement
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class Frame {

	public function Frame(bmp:BitmapData, x:int=0, y:int=0) {
		super();
		this.bmp = bmp;
		this.x = x;
		this.y = y;
	}

	public var bmp:BitmapData;

	public var x:int;

	public var y:int;

}

/**
 * @private
 */
internal final class DeferredBitmapMovieClip extends BitmapMovieClip {

	use namespace $protected;

	public function DeferredBitmapMovieClip(mc:MovieClip) {
		super();
		this._mc = mc;
		super.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
	}

	/**
	 * @private
	 */
	private var _mc:MovieClip;

	/**
	 * @private
	 */
	private var _f:int = 0;

	public override function clone():BitmapMovieClip {
		if ( this._f < this.$totalFrames ) {
			var result:DeferredBitmapMovieClip = new DeferredBitmapMovieClip( this._mc );
			result._smoothing = this._smoothing;
			result._list = this._list;
			result._f = this._f;
			result.$totalFrames = this.$totalFrames;
			return result;
		} else {
			return super.clone();
		}
	}

	public override function dispose():void {
		if ( this._mc ) {
			super.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._mc = null;
		}
		super.dispose();
	}

	$protected override function $setCurrentFrame(value:int):void {
		if ( this._mc ) {
			this.createFrame( value );
		}
		super.$setCurrentFrame( value );
	}

	/**
	 * @private
	 */
	private function createFrame(f:int):void {
		if ( this._list[ f ] ) return;
		this._mc.gotoAndStop( f );
		this._list[ f ] = getElement( this._mc );
	}

	/**
	 * @private
	 */
	private function handler_enterFrame(event:Event):void {
		if ( this._f < this.$totalFrames ) {
			++this._f;
			this.createFrame( this._f );
		} else {
			// закончили отрисовку
			super.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this._mc = null;
		}
	}

}