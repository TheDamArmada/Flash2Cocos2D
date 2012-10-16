////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import flash.errors.IllegalOperationError;

	import flash.geom.Rectangle;

	//--------------------------------------------------------------------------
	//
	//  Override properties: DisplayObject
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  width
	//----------------------------------

	/**
	 * @private
	 */
	public override function set width(value:Number):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  height
	//----------------------------------

	/**
	 * @private
	 */
	public override function set height(value:Number):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  scaleX
	//----------------------------------

	/**
	 * @private
	 */
	public override function set scaleX(value:Number):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  scaleY
	//----------------------------------

	/**
	 * @private
	 */
	public override function set scaleY(value:Number):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  opaqueBackground
	//----------------------------------

	/**
	 * @private
	 */
	public override function set opaqueBackground(value:Object):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  scale9Grid
	//----------------------------------

	/**
	 * @private
	 */
	public override function set scale9Grid(innerRectangle:Rectangle):void {
		Error.throwError( IllegalOperationError, 2071 );
	}

	//----------------------------------
	//  scrollRect
	//----------------------------------

	/**
	 * @private
	 */
	public override function get scrollRect():Rectangle {
		return null;
	}

	/**
	 * @private
	 */
	public override function set scrollRect(value:Rectangle):void {
		Error.throwError( IllegalOperationError, 2071 );
	}