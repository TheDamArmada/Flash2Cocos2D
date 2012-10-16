////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import by.blooddy.core.utils.ClassUtils;

	import flash.display.Graphics;
	import flash.errors.IllegalOperationError;

	//--------------------------------------------------------------------------
	//
	//  Override properties: Sprite
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  graphics
	//----------------------------------

	[Deprecated( message="свойство запрещено" )]
	/**
	 * @private
	 */
	public override function get graphics():Graphics {
		Error.throwError( IllegalOperationError, 1069, 'graphics', ClassUtils.getClassName( this ) );
		return null;
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
		Error.throwError( IllegalOperationError, 1001, 'startDrag' );
	}

	[Deprecated( message="метод запрещён" )]
	/**
	 * @private
	 */
	public override function stopDrag():void {
		Error.throwError( IllegalOperationError, 1001, 'stopDrag' );
	}
