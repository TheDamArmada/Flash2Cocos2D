////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.display.Shape;
	import flash.events.EventDispatcher;

	[Event( name="enterFrame", type="flash.events.Event" )]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public const enterFrameBroadcaster:EventDispatcher = new Shape();

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.enterFrameBroadcaster;

import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;

enterFrameBroadcaster.addEventListener( Event.ADDED_TO_STAGE, this.handler_added );

/**
 * @private
 */
internal const _JUNK:Sprite = new Sprite();

/**
 * @private
 */
internal function handler_added(event:Event):void {
	if ( this.parent === _JUNK ) return;
	_JUNK.addChild( this );
	_JUNK.removeChild( this );
	Error.throwError( IllegalOperationError, 2037 );
}