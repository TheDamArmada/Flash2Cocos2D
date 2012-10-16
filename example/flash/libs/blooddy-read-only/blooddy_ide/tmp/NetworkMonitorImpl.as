package mx.netmon.origin
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import mx.collections.errors.*;
	import mx.core.*;
	import mx.messaging.*;
	import mx.messaging.config.*;
	import mx.messaging.messages.*;
	import mx.utils.*;
	import mx.netmon.*;

	[ExcludeClass]
	public class NetworkMonitorImpl extends Responder
	{
		private var connectQueue:Array;
		private var httpIndirectHostPort:String;
		private var httpPort:String = "37813";
		private var nc:Socket;
		private var rtmpPort:uint = 27813;
		private static var instance:NetworkMonitorImpl;
		private static var connecting:Boolean = true;
		private static var shouldMonitor:Boolean = true;
		private static const EVENT:uint = 1;
		private static const RESULT:uint = 2;
		private static const FAULT:uint = 3;
		private static const INVOCATION:uint = 4;
		private static const SUSPEND:uint = 5;
		private static const RESUME:uint = 6;
		private static const MAXCHUNKSIZE:uint = 64000;
		
		public function NetworkMonitorImpl()
		{
			super(this.defaultResult, this.defaultStatus);
			this.nc = new Socket();
			this.nc.addEventListener(Event.CONNECT, this.connectHandler);
			this.nc.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
			this.nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
			this.nc.addEventListener(ProgressEvent.SOCKET_DATA, this.socketDataHandler);
			this.nc.addEventListener(Event.CLOSE, this.closeHandler);
			var _loc_1:* = LoaderConfig.parameters;
			if (_loc_1)
			{
			}
			if (_loc_1["netmonRTMPPort"] != null)
			{
				this.rtmpPort = _loc_1["netmonRTMPPort"];
			}
			if (_loc_1)
			{
			}
			if (_loc_1["netmonHTTPPort"] != null)
			{
				this.httpPort = _loc_1["netmonHTTPPort"];
			}
			this.httpIndirectHostPort = "localhost:" + this.httpPort;
			this.nc.connect("localhost", this.rtmpPort);
			this.connectQueue = [];
			return;
		}// end function
		
		public function isMonitoring() : Boolean
		{
			if (!shouldMonitor)
			{
			}
			return connecting;
		}// end function
		
		public function adjustURLRequest(urlRequest:URLRequest, rootURL:String, correlationId:String) : void
		{
			var _loc_6:String = null;
			if (!this.isMonitoring())
			{
				return;
			}
			if (!URLUtil.isHttpURL(urlRequest.url))
			{
				return;
			}
			var _loc_4:* = URLUtil.getFullURL(rootURL, urlRequest.url);
			var _loc_5:* = URLUtil.getServerNameWithPort(_loc_4);
			if (_loc_4.indexOf("https:", 0) != -1)
			{
				_loc_6 = "Y";
			}
			else
			{
				_loc_6 = "N";
			}
			var _loc_7:* = /https/;
			_loc_4 = _loc_4.replace(_loc_7, "http");
			var _loc_8:* = _loc_4.replace(_loc_5, this.httpIndirectHostPort);
			var _loc_9:* = _loc_8.split(" ");
			_loc_8 = _loc_9.join("");
			_loc_8 = _loc_8 + "?hostport=" + _loc_5 + "&https=" + _loc_6 + "&id=" + correlationId;
			urlRequest.url = _loc_8;
			return;
		}// end function
		
		public function adjustNetConnectionURL(rootURL:String, endPointUrl:String) : String
		{
			var _loc_5:String = null;
			if (!this.isMonitoring())
			{
				return null;
			}
			if (!URLUtil.isHttpURL(endPointUrl))
			{
				return null;
			}
			var _loc_3:* = URLUtil.getFullURL(rootURL, endPointUrl);
			var _loc_4:* = URLUtil.getServerNameWithPort(_loc_3);
			if (_loc_3.indexOf("https:", 0) != -1)
			{
				_loc_5 = "Y";
			}
			else
			{
				_loc_5 = "N";
			}
			var _loc_6:* = /https/;
			_loc_3 = _loc_3.replace(_loc_6, "http");
			var _loc_7:* = _loc_3.replace(_loc_4, this.httpIndirectHostPort);
			var _loc_8:* = _loc_7.split(" ");
			_loc_7 = _loc_8.join("");
			_loc_7 = _loc_7 + "?hostport=" + _loc_4 + "&https=" + _loc_5 + "&id=-1";
			return _loc_7;
		}// end function
		
		public function monitorEvent(event:Event, correlationId:String) : void
		{
			if (!this.isMonitoring())
			{
				return;
			}
			if (this.nc.connected)
			{
				this.flushConnectQueue();
				this.nc.writeByte(EVENT);
				this.nc.writeUTF(correlationId);
				this.nc.writeUTF(event.toString());
				this.nc.flush();
			}
			else
			{
				this.connectQueue.push({type:EVENT, event:event.toString(), correlationId:correlationId});
			}
			return;
		}// end function
		
		public function monitorInvocation(id:String, invocationMessage:AbstractMessage, agent:MessageAgent) : void
		{
			var msgType:String;
			var destination:String;
			var url:String;
			var endpoint:String;
			var id:* = id;
			var invocationMessage:* = invocationMessage;
			var agent:* = agent;
			if (!this.isMonitoring())
			{
				return;
			}
			var sourceContext:* = this.getSourceContext();
			if (sourceContext.sourcePath == null)
			{
				sourceContext.sourcePath = new String("null");
			}
			sourceContext.tagId = id;
			var operationType:String;
			var classType:Class;
			try
			{
				classType = getDefinitionByName("mx.data.messages.DataMessage") as Class;
			}
			catch (e:Error)
			{
			}
			if (invocationMessage is RemotingMessage)
			{
				msgType;
				operationType = RemotingMessage(invocationMessage).operation;
			}
			else if (invocationMessage is SOAPMessage)
			{
				msgType;
				operationType = SOAPMessage(invocationMessage).method;
			}
			else if (invocationMessage is HTTPRequestMessage)
			{
				msgType;
				operationType = HTTPRequestMessage(invocationMessage).method;
				if (HTTPRequestMessage(invocationMessage).contentType == HTTPRequestMessage.CONTENT_TYPE_SOAP_XML)
				{
					msgType;
				}
			}
			else
			{
				if (classType && invocationMessage is classType)
				{
					msgType;
				}
				else if (invocationMessage is CommandMessage)
				{
					msgType;
					operationType = CommandMessage.getOperationAsString(CommandMessage(invocationMessage).operation);
				}
				else if (invocationMessage is AsyncMessage)
				{
					msgType;
				}
				else
				{
					msgType;
				}
			}
			if (invocationMessage.destination != null)
			{
				destination = invocationMessage.destination;
			}
			else
			{
				destination;
			}
			if (invocationMessage.hasOwnProperty("url"))
			{
				invocationMessage.hasOwnProperty("url");
				url = invocationMessage["url"];
			}
			else
			{
				endpoint = ( agent ? agent.channelSet.currentChannel.endpoint : null );
				url = endpoint != null ? (endpoint) : ("");
			}
			if (this.nc.connected)
			{
				this.flushConnectQueue();
				this.nc.writeByte(INVOCATION);
				this.nc.writeUTF(msgType);
				this.nc.writeUTF(sourceContext.sourcePath);
				this.nc.writeInt(sourceContext.lineNumber);
				this.nc.writeUTF(invocationMessage.messageId);
				this.nc.writeObject(invocationMessage.body);
				this.nc.writeUTF(invocationMessage.toString());
				this.nc.writeUTF(operationType);
				this.nc.writeUTF(url);
				this.nc.writeUTF(destination);
				this.nc.flush();
			}
			else
			{
				this.connectQueue.push({type:INVOCATION, mesgType:msgType, sourcePath:sourceContext.sourcePath, lineNumber:sourceContext.lineNumber, messageId:invocationMessage.messageId, msgBody:invocationMessage.body, body:invocationMessage.toString(), operation:operationType, url:url, destination:destination});
			}
			return;
		}// end function
		
		private function getSourceContext() : Object
		{
			var stack:String;
			var pattern:RegExp;
			var result:Array;
			var prevResult:Array;
			var sourcePath:String;
			var sourceLine:int;
			var path:String;
			try
			{
				throw new Error("Stack trace trigger");
			}
			catch (err:Error)
			{
				stack = err.getStackTrace();
				pattern = /\[(.+?):(\d+?)\]/g;
				result = pattern.exec(stack);
				sourcePath;
				sourceLine;
				while (result != null)
				{
					
					path = result[1];
					if (!isInternalFile(path))
					{
						sourcePath = path;
						sourceLine = result[2];
						break;
					}
					result = pattern.exec(stack);
				}
			}
			var ctx:Object = new Object();
			ctx.sourcePath = sourcePath;
			ctx.lineNumber = new String(sourceLine);
			return ctx;
		}// end function
		
		private function isInternalFile(path:String) : Boolean
		{
			if (path.indexOf("\\mx\\rpc\\") <= 0)
			{
			}
			if (path.indexOf("\\mx\\netmon\\") > 0)
			{
				return true;
			}
			if (path.indexOf("\\mx\\messaging\\") <= 0)
			{
			}
			if (path.indexOf("\\mx\\data\\") <= 0)
			{
			}
			if (path.indexOf("\\mx\\core\\") > 0)
			{
				return true;
			}
			if (path.indexOf("\\framework\\src\\mx\\") <= 0)
			{
			}
			if (path.indexOf("\\mx\\core\\") > 0)
			{
				return true;
			}
			if (this.endsWith(path, "NetworkMonitorImpl.as"))
			{
				return true;
			}
			return false;
		}// end function
		
		private function endsWith(str:String, end:String) : Boolean
		{
			var _loc_3:* = str.substr(str.length - end.length, end.length);
			var _loc_4:* = _loc_3 == end;
			if (str.length >= end.length)
			{
			}
			return str.substr(str.length - end.length, end.length) == end;
		}// end function
		
		public function monitorResult(resultMessage:AbstractMessage, actualResult:Object) : void
		{
			if (!this.isMonitoring())
			{
				return;
			}
			if (resultMessage.destination == null)
			{
				resultMessage.destination = "";
			}
			if (this.nc.connected)
			{
				this.flushConnectQueue();
				this.nc.writeByte(RESULT);
				this.nc.writeUTF(resultMessage["correlationId"]);
				this.nc.writeObject(resultMessage.body);
				this.nc.writeUTF(resultMessage.destination);
				this.nc.flush();
			}
			else
			{
				this.connectQueue.push({type:RESULT, messageId:resultMessage["correlationId"], resultBody:resultMessage.body, destination:resultMessage.destination});
			}
			return;
		}// end function
		
		public function monitorFault(faultMessage:AbstractMessage, actualFault:Object) : void
		{
			if (!this.isMonitoring())
			{
				return;
			}
			if (faultMessage.destination == null)
			{
				faultMessage.destination = "";
			}
			if (this.nc.connected)
			{
				this.flushConnectQueue();
				this.nc.writeByte(FAULT);
				this.nc.writeUTF(faultMessage.messageId);
				this.nc.writeUTF(faultMessage.destination);
				this.nc.writeObject(actualFault);
				this.nc.flush();
			}
			else
			{
				this.connectQueue.push({type:FAULT, messageId:faultMessage.messageId, destination:faultMessage.destination, actualFault:actualFault});
			}
			return;
		}// end function
		
		private function flushConnectQueue() : void
		{
			var i:int;
			var toSend:Object;
			var buffer:ByteArray;
			if (this.connectQueue != null)
			{
				i;
				while (i < this.connectQueue.length)
				{
					
					toSend = this.connectQueue[i];
					switch(toSend.type)
					{
						case EVENT:
						{
							this.nc.writeByte(EVENT);
							this.nc.writeUTF(toSend.correlationId);
							this.nc.writeUTF(toSend.event);
							this.nc.flush();
							break;
						}
						case RESULT:
						{
							try
							{
								buffer = new ByteArray();
								buffer.writeObject(toSend.resultBody);
								this.nc.writeByte(RESULT);
								this.nc.writeUTF(toSend.messageId);
								this.nc.writeObject(toSend.resultBody);
							}
							catch (e:ItemPendingError)
							{
								nc.writeByte(RESULT);
								nc.writeUTF(toSend.messageId);
								nc.writeObject(e);
							}
							this.nc.writeUTF(toSend.destination);
							this.nc.flush();
							break;
						}
						case FAULT:
						{
							this.nc.writeByte(FAULT);
							this.nc.writeUTF(toSend.messageId);
							this.nc.writeUTF(toSend.destination);
							this.nc.writeObject(toSend.actualFault);
							this.nc.flush();
							break;
						}
						case INVOCATION:
						{
							this.nc.writeByte(INVOCATION);
							this.nc.writeUTF(toSend.mesgType);
							this.nc.writeUTF(toSend.sourcePath);
							this.nc.writeInt(toSend.lineNumber);
							this.nc.writeUTF(toSend.messageId);
							this.nc.writeObject(toSend.msgBody);
							this.nc.writeUTF(toSend.body);
							this.nc.writeUTF(toSend.operation);
							this.nc.writeUTF(toSend.url);
							this.nc.writeUTF(toSend.destination);
							this.nc.flush();
							break;
						}
						default:
						{
							trace(" ****** FlushQueue: Error Message ID");
							break;
						}
					}
					i = (i + 1);
				}
				this.connectQueue = [];
			}
			return;
		}// end function
		
		public function monitor(value:Boolean) : void
		{
			shouldMonitor = value;
			return;
		}// end function
		
		private function defaultResult(result:Object) : void
		{
			return;
		}// end function
		
		private function defaultStatus(info:Object) : void
		{
			return;
		}// end function
		
		private function connectHandler(event:Event) : void
		{
			connecting = false;
			this.flushConnectQueue();
			return;
		}// end function
		
		private function ioErrorHandler(event:IOErrorEvent) : void
		{
			this.nc.removeEventListener(Event.CONNECT, this.connectHandler);
			this.nc.removeEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
			this.nc.removeEventListener(ProgressEvent.SOCKET_DATA, this.socketDataHandler);
			this.nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
			this.nc.removeEventListener(Event.CLOSE, this.closeHandler);
			return;
		}// end function
		
		private function securityErrorHandler(event:SecurityErrorEvent) : void
		{
			return;
		}// end function
		
		private function socketDataHandler(event:ProgressEvent) : void
		{
			var _loc_4:uint = 0;
			var _loc_2:* = event.bytesLoaded;
			var _loc_3:uint = 0;
			while (_loc_3 < _loc_2)
			{
				
				_loc_4 = this.nc.readByte();
				_loc_3 = _loc_3 + 1;
				if (_loc_4 == SUSPEND)
				{
					shouldMonitor = false;
					continue;
				}
				if (_loc_4 == RESUME)
				{
					shouldMonitor = true;
				}
			}
			return;
		}// end function
		
		private function closeHandler(event:Event) : void
		{
			return;
		}// end function

		public static function init():void
		{
			instance = new NetworkMonitorImpl();
			NetworkMonitor.isMonitoringImpl = instance.isMonitoring;
			NetworkMonitor.adjustURLRequestImpl = instance.adjustURLRequest;
			NetworkMonitor.adjustNetConnectionURLImpl = instance.adjustNetConnectionURL;
			NetworkMonitor.monitorEventImpl = instance.monitorEvent;
			NetworkMonitor.monitorInvocationImpl = instance.monitorInvocation;
			NetworkMonitor.monitorResultImpl = instance.monitorResult;
			NetworkMonitor.monitorFaultImpl = instance.monitorFault;
			return;
		}// end function
		
	}
}
