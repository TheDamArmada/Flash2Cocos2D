////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

	import flash.events.Event;

	/**
	 * исправления бага с двойным addedToStage
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.03.2010 3:18:11
	 */

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _addedToStage:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function handler_addedToStage(event:Event):void {
		if ( this._addedToStage ) {
			event.stopImmediatePropagation();
		} else {
			this._addedToStage = true;
		}
	}

	/**
	 * @private
	 */
	private function handler_removedFromStage(event:Event):void {
		this._addedToStage = false;
	}