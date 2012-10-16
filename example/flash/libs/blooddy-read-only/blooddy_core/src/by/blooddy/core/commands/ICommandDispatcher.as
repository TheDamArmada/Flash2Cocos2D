////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.commands {

	import flash.events.IEventDispatcher;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 17:25:06
	 */
	public interface ICommandDispatcher extends IEventDispatcher {

		function dispatchCommand(command:Command):void;

		function addCommandListener(commandName:String, listener:Function, priority:int=0, useWeakReference:Boolean=false):void;

		function removeCommandListener(commandName:String, listener:Function):void;

		function hasCommandListener(commandName:String):Boolean;

	}

}