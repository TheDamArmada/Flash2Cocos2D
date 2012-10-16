////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package mx.netmon {

	import by.blooddy.core.net.monitor.NetMonitor;
	import by.blooddy.core.utils.net.URLUtils;
	import by.blooddy.ide.net.monitor.FBFlexNetMonitor;
	import by.blooddy.ide.net.monitor.FBNetMonitor;
	
	import flash.display.DisplayObject;
	
	import mx.messaging.config.LoaderConfig;

	[Mixin]
	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 25, 2010 5:24:51 PM
	 */
	public class NetworkMonitorImpl {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function init(root:DisplayObject):void {
			trace( FBNetMonitor + ' initialization...' );

			var appRoot:String = URLUtils.getPathURL(
				URLUtils.normalizeURL( root.loaderInfo.loaderURL )
			);

			var host:String;
			var socketPort:int;
			var httpPort:int;

			var parameters:Object = LoaderConfig.parameters;
			if ( parameters ) {
				if ( parameters[ 'netmonRTMPPort' ] != null ) {
					socketPort = int( parameters[ 'netmonRTMPPort' ] );
				}
				if ( parameters[ 'netmonHTTPPort' ] != null ) {
					httpPort = int( parameters[ 'netmonHTTPPort' ] );
				}
			}

			var monitor:FBFlexNetMonitor = new FBFlexNetMonitor( appRoot, host, socketPort, httpPort );
			
			if ( !NetMonitor.monitor ) {
				NetMonitor.monitor = monitor;
			}

			NetworkMonitor.isMonitoringImpl =			monitor.isActive;
			NetworkMonitor.adjustURLRequestImpl =		monitor.adjustFlexURLRequest;
			NetworkMonitor.adjustNetConnectionURLImpl =	monitor.adjustFlexURL;
			NetworkMonitor.monitorEventImpl =			monitor.monitorFlexEvent;
			NetworkMonitor.monitorInvocationImpl =		monitor.monitorFlexInvocation;
			NetworkMonitor.monitorResultImpl =			monitor.monitorFlexResult;
			NetworkMonitor.monitorFaultImpl =			monitor.monitorFlexFault;

		}

	}

}