////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.remote {

	import by.blooddy.core.utils.IDisposable;

	import flash.events.IEventDispatcher;

	public interface IRemoteModule extends IEventDispatcher, IDisposable {

		function get id():String;

	}

}