////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.time {

	import flash.utils.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public function getTimer():Number {
		return flash.utils.getTimer() + deltaTime;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.utils.getTimer;
import flash.utils.setInterval;

/**
 * эта величина характеризует на сколько флэшовый таймер сбился
 * относительно системного времени
 */
internal var deltaTime:Number = 0;

/**
 * время старта таймера
 */
internal const startTime:Number = ( new Date() ).getTime() - getTimer();

/**
 * взводим таймер для периодической синхронизации
 */
setInterval( function():void {
	deltaTime = ( new Date() ).getTime() - startTime - getTimer();
}, 10e3 );