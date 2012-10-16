////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {

	import by.blooddy.core.net.IAbstractSocket;
	import by.blooddy.core.net.loading.ILoadable;

	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 26, 2010 11:52:23 AM
	 */
	public interface INetMonitor {

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		function isActive():Boolean;

		function isURLAdjusted(url:String):Boolean;

		function isURLRequestAdjusted(request:URLRequest):Boolean;

		function adjustURL(url:String, correlationID:String=null):String;

		function adjustURLRequest(correlationID:String, request:URLRequest):void;

		function monitorLoadableInvocation(correlationID:String, request:URLRequest, loader:ILoadable):void;

		function monitorLoadableEvent(correlationID:String, event:Event):void;

		function monitorLoadableResult(correlationID:String, responceData:Object):void;

		function monitorLoadableFault(correlationID:String, message:String):void;

		function monitorSocketOutput(correlationID:String, data:Object, socket:IAbstractSocket):void;

		function monitorSocketInput(correlationID:String, data:Object, socket:IAbstractSocket):void;

	}

}