////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.events.IEventDispatcher;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function callDeferred(func:Function, args:Array, target:IEventDispatcher, eventType:String, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void {
		var listener:Listener = ( _listeners.length > 0 ? _listeners.pop() : new Listener() );
		listener.func = func;
		listener.args = args;
		target.addEventListener(
			eventType,
			listener.handler,
			useCapture,
			priority,
			useWeakReference
		);
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.Caller;

import flash.events.Event;
import flash.events.EventPhase;
import flash.events.IEventDispatcher;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper const: _listeners
//
////////////////////////////////////////////////////////////////////////////////

const _listeners:Array = new Array();

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Listener
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class Listener extends Caller {

	public function Listener() {
		super( null );
	}

	public function handler(event:Event):void {
		// надо себя убить из слушателей, иначе есть риск зависнуть, к тому же нам надо выполниться всего один раз
		( event.currentTarget as IEventDispatcher ).removeEventListener(
			event.type,
			this.handler,
			event.eventPhase == EventPhase.CAPTURING_PHASE
		);

		// вызываемся
		super.call();

		this.func = null;
		this.args = null;
		_listeners.push( this );

	}

}