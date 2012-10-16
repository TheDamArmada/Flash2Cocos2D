////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function callNextFrame(func:Function, args:Array=null, priority:int=0.0):void {
		callDeferred( func, args,  target, Event.ENTER_FRAME, false, priority ); 
	}

}

import flash.display.Shape;

/**
 * @private
 */
internal const target:Shape = new Shape();