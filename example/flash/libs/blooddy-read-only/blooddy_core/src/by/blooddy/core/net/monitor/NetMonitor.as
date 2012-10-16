////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.monitor {

	import by.blooddy.core.net.loading.ILoadable;

	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 26, 2010 12:34:08 PM
	 */
	public final class NetMonitor {

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		public static var monitor:INetMonitor;

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#isActive
		 */
		public static function isActive():Boolean {
			return ( monitor ? monitor.isActive() : false );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#isURLAdjusted()
		 */
		public static function isURLAdjusted(url:String):Boolean {
			if ( !monitor ) return false;
			return monitor.isURLAdjusted( url );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#isURLRequestAdjusted()
		 */
		public static function isURLRequestAdjusted(request:URLRequest):Boolean {
			if ( !monitor ) return false;
			return monitor.isURLRequestAdjusted( request );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#adjustURL()
		 */
		public static function adjustURL(url:String, correlationID:String=null):String {
			if ( !monitor ) return url;
			return monitor.adjustURL( url, correlationID );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#adjustURLRequest()
		 */
		public static function adjustURLRequest(correlationID:String, request:URLRequest):void {
			if ( !monitor ) return;
			monitor.adjustURLRequest( correlationID, request );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#monitorEvent()
		 */
		public static function monitorEvent(correlationID:String, event:Event):void {
			if ( !monitor ) return;
			monitor.monitorLoadableEvent( correlationID, event );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#monitorLoadableInvocation()
		 */
		public static function monitorInvocation(correlationID:String, request:URLRequest, loader:ILoadable):void {
			if ( !monitor ) return;
			monitor.monitorLoadableInvocation( correlationID, request, loader );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#monitorLoadableResult()
		 */
		public static function monitorResult(correlationID:String, responceData:Object):void {
			if ( !monitor ) return;
			monitor.monitorLoadableResult( correlationID, responceData );
		}

		/**
		 * @copy	by.blooddy.core.net.monitor.INetMonitor#monitorLoadableFault()
		 */
		public static function monitorFault(correlationID:String, message:String):void {
			if ( !monitor ) return;
			monitor.monitorLoadableFault( correlationID, message );
		}

	}

}