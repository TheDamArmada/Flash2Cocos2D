////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import flash.errors.IllegalOperationError;
	import flash.ui.ContextMenu;

	//--------------------------------------------------------------------------
	//
	//  Override properties: InteractiveObject
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  mouseEnabled
	//----------------------------------

	/**
	 * @private
	 */
	public override function set mouseEnabled(enabled:Boolean):void {
		Error.throwError( IllegalOperationError, 3008 );
	}
