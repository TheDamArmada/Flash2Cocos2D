////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.ide.net.monitor {

	import by.blooddy.core.net.IAbstractSocket;
	import by.blooddy.core.net.Socket;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.monitor.INetMonitor;
	import by.blooddy.core.utils.Caller;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.net.Location;
	import by.blooddy.core.utils.net.URLUtils;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.02.2010 9:40:35
	 */
	public class FBNetMonitor implements INetMonitor {

		//--------------------------------------------------------------------------
		//
		//  Namespace
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_net;

		use namespace $protected_net;

		//--------------------------------------------------------------------------
		//
		//  Class constant
		//
		//--------------------------------------------------------------------------
		
		public static const DEFAULT_HOST:String =		'localhost';
		
		public static const DEFAULT_SOCKET_PORT:int =	27813;
		
		public static const DEFAULT_HTTP_PORT:int =		37813;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _STATE_IDLE:uint =			0;

		/**
		 * @private
		 */
		private static const _STATE_PAUSE:uint =	1 + _STATE_IDLE;

		/**
		 * @private
		 */
		private static const _STATE_ACTIVE:uint =	1 + _STATE_PAUSE;

		/**
		 * @private
		 */
		private static const _R_LINE:RegExp = /^\s*at\s+([^(\/]+)(?:\/([^(]+))?\(\)(?:\[(.*?):(\d+)\])?$/gm;

		/**
		 * @private
		 */
		private static const _R_EXCLUDE_DEFAULT:RegExp = /^by\.blooddy\.(core|ide)/;
		
		/**
		 * @private
		 */
		private static const _R_HTTP:RegExp =	/^https?$/;

		private static const _MSG_EVENT:uint =		1;
		private static const _MSG_RESULT:uint =		2;
		private static const _MSG_FAULT:uint =		3;
		private static const _MSG_INVOCATION:uint =	4;
		private static const _MSG_SUSPEND:uint =	5;
		private static const _MSG_RESUME:uint =		6;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function FBNetMonitor(appRoot:String, host:String=null, socketPort:int=0, httpPort:int=0) {
			super();

			this._appRoot = appRoot;
			this._host = host || DEFAULT_HOST;
			this._socketPort = socketPort || DEFAULT_SOCKET_PORT;
			this._httpPort = httpPort || DEFAULT_HTTP_PORT;
			
			this._socket = new Socket();
			this._socket.addEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.addEventListener( Event.CLOSE,							this.handler_close );
			this._socket.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_close );
			this._socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_close );
			this._socket.addEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket.connect( this._host, this._socketPort );

		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _appRoot:String;
		
		/**
		 * @private
		 */
		private var _socket:Socket;

		/**
		 * @private
		 */
		private var _host:String;
		
		/**
		 * @private
		 */
		private var _socketPort:int;

		/**
		 * @private
		 */
		private var _httpPort:int;

		/**
		 * @private
		 */
		private var _state:uint = _STATE_ACTIVE;

		/**
		 * @private
		 */
		private var _cache:Vector.<Caller>;
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function isActive():Boolean {
			return this._state >= _STATE_ACTIVE;
		}

		public function isURLAdjusted(url:String):Boolean {
			return false;
		}
		
		public function isURLRequestAdjusted(request:URLRequest):Boolean {
			return this.isURLAdjusted( request.url );
		}
		
		/**
		 * @inheritDoc
		 */
		public function adjustURL(url:String, correlationID:String=null):String {
			if ( this._state < _STATE_ACTIVE ) return url;
			// TODO: проверка на урыл!
			return this.adjustAbstractURL( this._appRoot, url, correlationID );
		}
		
		/**
		 * @inheritDoc
		 */
		public function adjustURLRequest(correlationID:String, request:URLRequest):void {
			if ( this._state < _STATE_ACTIVE ) return;
			request.url = this.adjustAbstractURL( this._appRoot, request.url, correlationID );
		}

		/**
		 * @inheritDoc
		 */
		public function monitorLoadableEvent(correlationID:String, event:Event):void {
			if ( this._state < _STATE_ACTIVE ) return;
			if ( this._socket.connected ) {
				this.sendEvent( correlationID, event );
			} else {
				this.addToCache( this.sendEvent, correlationID, event );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function monitorLoadableInvocation(correlationID:String, request:URLRequest, loader:ILoadable):void {
			if ( this._state < _STATE_ACTIVE ) return;
			var context:SourceContext = this.getSourceContext();
			this.sendInvocation(
				correlationID,
				request.url,
				request.data,
				String( request ),
				request.method,
				ClassUtils.parseClassName( context.value ),
				ClassUtils.getClassName( loader ),
				context
			);
		}

		/**
		 * @inheritDoc
		 */
		public function monitorLoadableResult(correlationID:String, responceData:Object):void {
			if ( this._state < _STATE_ACTIVE ) return;
			this.sendResult( correlationID, responceData, '' );
		}

		/**
		 * @inheritDoc
		 */
		public function monitorLoadableFault(correlationID:String, message:String):void {
			if ( this._state < _STATE_ACTIVE ) return;
			this.sendFault( correlationID, message, '' );
		}
		
		/**
		 * @inheritDoc
		 */
		public function monitorSocketOutput(correlationID:String, data:Object, socket:IAbstractSocket):void {
			if ( this._state < _STATE_ACTIVE ) return;
			var context:SourceContext = this.getSourceContext();
			this.sendInvocation(
				correlationID,
				( socket.protocol ? socket.protocol + '://' : '' ) + socket.host + ':' + socket.port,
				data,
				String( data ),
				'output',
				ClassUtils.parseClassName( context.value ),
				ClassUtils.getClassName( socket ),
				context
			);
		}
		
		/**
		 * @inheritDoc
		 */
		public function monitorSocketInput(correlationID:String, data:Object, socket:IAbstractSocket):void {
			if ( this._state < _STATE_ACTIVE ) return;
			var context:SourceContext = this.getSourceContext();
			this.sendInvocation(
				correlationID,
				( socket.protocol ? socket.protocol + '://' : '' ) + socket.host + ':' + socket.port,
				'',
				'',
				'input',
				ClassUtils.parseClassName( context.value ),
				ClassUtils.getClassName( socket ),
				context
			);
			this.sendResult( correlationID, data, ClassUtils.parseClassName( context.value ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addToCache(func:Function, ...args):void {
			if ( !this._cache ) this._cache = new Vector.<Caller>();
			this._cache.push( new Caller( func, args ) );
		}

		/**
		 * @private
		 */
		$protected_net function getSourceContext(exclude:RegExp=null):SourceContext {
			var stack:String = ( new Error() ).getStackTrace();
			
			_R_LINE.lastIndex = 10; // ~ пропускаем самих себя =)
			
			var row:Array;
			while ( row = _R_LINE.exec( stack ) ) {
				if (
					!_R_EXCLUDE_DEFAULT.test( row[ 1 ] ) &&
					!( exclude && exclude.test( row[ 1 ] ) ) &&
					ApplicationDomain.currentDomain.hasDefinition( row[ 1 ] ) // exclude internal classes
				) {
					return new SourceContext( row[ 3 ], parseInt( row[ 4 ], 10 ), row[ 1 ] );
				}
			}
			
			return new SourceContext( '', 0, '' );
		}

		/**
		 * @private
		 */
		$protected_net function adjustAbstractURL(root:String, url:String, correlationID:String=null):String {
			var loc:Location;
			loc = new Location( url );
			
			loc = new Location( URLUtils.createAbsoluteURL( root , url ) );
			var arr:Array = loc.protocol.match( _R_HTTP );
			if ( !arr ) return url;
			
			var hostname:String = loc.hostname;
			var httpsName:String = ( arr[ 1 ] ? 'Y' : 'N' );
			
			loc.host = this._host;
			loc.port = this._httpPort;
			
			return loc.toString() + '?hostport=' + hostname + '&https=' + httpsName + '&id=' + ( correlationID || '-1' );
		}
		
		/**
		 * @private
		 */
		$protected_net function sendEvent(correlationID:String, event:Event):void {
			if ( this._socket.connected ) {
				this._socket.writeByte( _MSG_EVENT );
				this._socket.writeUTF( correlationID );
				this._socket.writeUTF( event.type );
				this._socket.flush();
			} else {
				this.addToCache( this.sendEvent, correlationID, event );
			}
		}

		/**
		 * @private
		 */
		$protected_net function sendInvocation(correlationID:String, url:String, requestData:Object, requestString:String, operation:String, destination:String, serviceName:String, context:SourceContext):void {
			if ( this._socket.connected ) {
				this._socket.writeByte( _MSG_INVOCATION );
				this._socket.writeUTF( serviceName );
				this._socket.writeUTF( context.file );
				this._socket.writeInt( context.line );
				this._socket.writeUTF( correlationID );
				this._socket.writeObject( requestData );
				this._socket.writeUTF( requestString );
				this._socket.writeUTF( operation );
				this._socket.writeUTF( url );
				this._socket.writeUTF( destination );
				this._socket.flush();
			} else {
				this.addToCache( this.sendInvocation, correlationID, url, requestData, requestString, operation, destination, serviceName, context );
			}
		}

		/**
		 * @private
		 */
		$protected_net function sendResult(correlationID:String, responceData:Object, destination:String):void {
			if ( this._socket.connected ) {
				this._socket.writeByte( _MSG_RESULT );
				this._socket.writeUTF( correlationID );
				this._socket.writeObject( responceData );
				this._socket.writeUTF( destination );
				this._socket.flush();
			} else {
				this.addToCache( this.sendResult, correlationID, responceData, destination );
			}
		}

		/**
		 * @private
		 */
		$protected_net function sendFault(correlationID:String, responceData:Object, destination:String):void {
			if ( this._socket.connected ) {
				this._socket.writeByte( _MSG_FAULT );
				this._socket.writeUTF( correlationID );
				this._socket.writeUTF( destination );
				this._socket.writeObject( responceData );
				this._socket.flush();
			} else {
				this.addToCache( this.sendFault, correlationID, responceData, destination );
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_connect(event:Event):void {
			trace( this + ' constructed!' );
			if ( this._cache ) {
				while ( this._cache.length > 0 ) {
					this._cache.shift().call();
				}
				this._cache = null;
			}
		}

		/**
		 * @private
		 */
		private function handler_close(event:ErrorEvent):void {
			trace( this + ' destructed!' );
			this._state = _STATE_IDLE;
			this._cache = null;
			this._socket.removeEventListener( Event.CONNECT,						this.handler_connect );
			this._socket.removeEventListener( Event.CLOSE,							this.handler_close );
			this._socket.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_close );
			this._socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_close );
			this._socket.removeEventListener( ProgressEvent.SOCKET_DATA,			this.handler_socketData );
			this._socket = null;
		}
		
		/**
		 * @private
		 */
		private function handler_socketData(event:ProgressEvent):void {
			trace( event );
		}
		
	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventContainer
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class SourceContext {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor.
	 */
	public function SourceContext(file:String, line:uint, value:String) {
		super();
		this.file = file;
		this.line = line;
		this.value = value;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var file:String;

	public var line:uint;

	public var value:String;
	
}