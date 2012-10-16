package by.blooddy.core.utils {

	import by.blooddy.core.utils.time.getTimer;
	
	import flash.events.TimerEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					15.12.2011 16:02:29
	 */
	public function callLater(func:Function, args:Array=null, priority:int=0.0):void {
		callDeferred( func, args,  target, TimerEvent.TIMER, false, priority ); 
	}
	
}

import by.blooddy.core.utils.time.AutoTimer;

import flash.display.Shape;

/**
 * @private
 */
internal const target:AutoTimer = new AutoTimer( 1 );