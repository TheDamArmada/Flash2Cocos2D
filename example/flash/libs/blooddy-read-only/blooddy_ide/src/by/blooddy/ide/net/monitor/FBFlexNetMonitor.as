////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.ide.net.monitor {

	import by.blooddy.core.utils.net.URLUtils;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	import mx.messaging.MessageAgent;
	import mx.messaging.messages.AbstractMessage;
	import mx.messaging.messages.AsyncMessage;
	import mx.messaging.messages.CommandMessage;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.messaging.messages.RemotingMessage;
	import mx.messaging.messages.SOAPMessage;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.02.2010 0:48:34
	 */
	public class FBFlexNetMonitor extends FBNetMonitor {
		
		//--------------------------------------------------------------------------
		//
		//  Namespace
		//
		//--------------------------------------------------------------------------

		use namespace $protected_net;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const _R_EXCLUDE:RegExp = /^mx\./;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function FBFlexNetMonitor(appRoot:String, host:String=null, socketPort:int=0, httpPort:int=0) {
			super( appRoot, host, socketPort, httpPort );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function adjustFlexURL(rootURL:String, url:String):String {
			if ( !super.isActive() ) return url;
			return this.adjustAbstractURL(
				URLUtils.getPathURL(
					URLUtils.normalizeURL( rootURL )
				),
				url
			);
		}

		public function adjustFlexURLRequest(request:URLRequest, rootURL:String, correlationID:String):void {
			if ( !super.isActive() ) return;
			request.url = this.adjustAbstractURL(
				URLUtils.getPathURL(
					URLUtils.normalizeURL( rootURL )
				),
				request.url,
				correlationID
			);
		}

		public function monitorFlexEvent(event:Event, correlationID:String):void {
			if ( !super.isActive() ) return;
			this.sendEvent( correlationID, event );
		}

		public function monitorFlexInvocation(id:String, invocationMessage:AbstractMessage, agent:MessageAgent):void {
			if ( !super.isActive() ) return;
			
			var url:String;
			if ( 'url' in invocationMessage ) {
				url = invocationMessage[ 'url' ];
			} else {
				url = ( agent ? agent.channelSet.currentChannel.endpoint : null ) || '';
			}

			var serviceName:String;
			var operationName:String;
			if ( invocationMessage is RemotingMessage ) {

				serviceName = 'RemoteService';
				operationName = ( invocationMessage as RemotingMessage ).operation;

			} else if ( invocationMessage is HTTPRequestMessage ) {

				var httpMessage:HTTPRequestMessage = invocationMessage as HTTPRequestMessage;
				if ( httpMessage is SOAPMessage || httpMessage.contentType == HTTPRequestMessage.CONTENT_TYPE_SOAP_XML ) {
					serviceName = 'WebService';
				} else {
					serviceName = 'HTTPService';
				}
				operationName = httpMessage.method;
					
			} else if ( invocationMessage is AsyncMessage ) {

				if ( invocationMessage is CommandMessage ) {

					serviceName = 'MessageService';
					operationName = CommandMessage.getOperationAsString( ( invocationMessage as CommandMessage ).operation );

				} else {

					var DataMessage:Class = ApplicationDomain.currentDomain.getDefinition( 'mx.data.messages.DataMessage' ) as Class;
					if ( DataMessage && invocationMessage as DataMessage ) {

						serviceName = 'DataService';
						operationName = DataMessage[ 'getOperationAsString' ]( invocationMessage[ 'operation' ] );

					} else {

						serviceName = 'MessageService';
						operationName = '';

					}

				}

			} else {

				serviceName = 'AbstractMessage';
				operationName = '';

			}

			this.sendInvocation(
				invocationMessage.messageId,
				url,
				invocationMessage.body,
				invocationMessage.toString(),
				operationName,
				invocationMessage.destination || '',
				serviceName,
				this.getSourceContext( _R_EXCLUDE )
			);

		}

		public function monitorFlexResult(resultMessage:AbstractMessage, actualResult:Object):void {
			if ( !super.isActive() ) return;
			this.sendResult(
				resultMessage[ 'correlationID' ],
				resultMessage.body,
				resultMessage.destination
			);
		}

		public function monitorFlexFault(faultMessage:AbstractMessage, actualFault:Object):void {
			if ( !super.isActive() ) return;
			this.sendResult(
				faultMessage.messageId,
				actualFault,
				faultMessage.destination
			);
		}

	}

}