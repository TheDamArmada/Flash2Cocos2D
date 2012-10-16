////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.text.TextSnapshot;

	//--------------------------------------------------------------------------
	//
	//  Override properties: DisplayObjectContainer
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  mouseChildren
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseChildren(enable:Boolean):void {
		Error.throwError( IllegalOperationError, 3008 );
	}

	//----------------------------------
	//  tabChildren
	//----------------------------------

	/**
	 * @private
	 */
	public override function set tabChildren(enable:Boolean):void {
		Error.throwError( IllegalOperationError, 3008 );
	}

	//----------------------------------
	//  numChildren
	//----------------------------------

	[Deprecated( message="свойство запрещено" )]
	/**
	 * @private
	 */
	public override function get numChildren():int {
		return 0;
	}

	//----------------------------------
	//  textSnapshot
	//----------------------------------

	[Deprecated( message="свойство запрещено" )]
	/**
	 * @private
	 */
	public override function get textSnapshot():TextSnapshot {
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//  Override methods: DisplayObjectContainer
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function addChild(child:DisplayObject):DisplayObject {
		return super.addChild( this );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
		return super.addChildAt( this, -1 );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function contains(child:DisplayObject):Boolean {
		return false;
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function getChildAt(index:int):DisplayObject {
		return super.getChildAt(-1);
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function getChildByName(name:String):DisplayObject {
		return null;
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function getChildIndex(child:DisplayObject):int {
		return super.getChildIndex(this);
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function getObjectsUnderPoint(point:Point):Array {
		return new Array();
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function removeChild(child:DisplayObject):DisplayObject {
		return super.removeChild( child ? this : null );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function removeChildAt(index:int):DisplayObject {
		return super.removeChildAt( -1 );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function setChildIndex(child:DisplayObject, index:int):void {
		super.setChildIndex( this, -1 );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
		super.swapChildren( this, this );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function swapChildrenAt(index1:int, index2:int):void {
		super.swapChildrenAt( -1, -1 );
	}
