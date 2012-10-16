////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {
	
	import by.blooddy.core.net.domain;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.RecycleBin;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.core.utils.net.URLUtils;
	
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Implements events: ILoadable
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="error", type="flash.events.ErrorEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="ioError", type="flash.events.IOErrorEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="securityError", type="flash.events.SecurityErrorEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="open", type="flash.events.Event" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]
	
	//--------------------------------------
	//  Implements events: ILoader
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	[Event( name="httpStatus", type="flash.events.HTTPStatusEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="httpResponseStatus", type="flash.events.HTTPStatusEvent" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="init", type="flash.events.Event" )]
	
	/**
	 * @inheritDoc
	 */
	[Event( name="unload", type="flash.events.Event" )]

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected_load" )]

	[Exclude( kind="property", name="HTTP_RESPONSE_STATUS" )]
	[Exclude( kind="property", name="_DOMAIN" )]
	[Exclude( kind="property", name="_URL" )]

	[Exclude( kind="method", name="$getAbstractContent" )]
	[Exclude( kind="method", name="$load" )]
	[Exclude( kind="method", name="$loadBytes" )]
	[Exclude( kind="method", name="$unload" )]
	[Exclude( kind="method", name="updateProgress" )]
	[Exclude( kind="method", name="progressHandler" )]
	[Exclude( kind="method", name="completeHandler" )]

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					24.02.2010 21:47:24
	 */
	internal class LoaderBase extends EventDispatcher implements ILoader {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_load;

		use namespace $protected_load;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		$protected_load static const _HTTP_RESPONSE_STATUS:String = ( 'HTTP_RESPONSE_STATUS' in HTTPStatusEvent ? HTTPStatusEvent[ 'HTTP_RESPONSE_STATUS' ] : null );

		/**
		 * @private
		 */
		$protected_load static const _URL:RegExp = ( domain == 'localhost' ? null : new RegExp( '^(?:(?!\\w+://)|https?://(?:www\\.)?' + domain.replace( /\./g, '\\.' ) + ')', 'i' ) );

		/**
		 * @private
		 */
		$protected_load static const _ROOT:String = URLUtils.getPathURL(
			URLUtils.normalizeURL( ( new flash.display.Loader() ).contentLoaderInfo.loaderURL )
		);

		/**
		 * @private
		 */
		$protected_load static const _BIN:RecycleBin = new RecycleBin();

		/**
		 * @private
		 * статус загрузки. ожидание
		 */
		private static const _STATE_IDLE:uint =		0;
		
		/**
		 * @private
		 * статус загрузки. прогресс
		 */
		private static const _STATE_PROGRESS:uint =	_STATE_IDLE		+ 1;
		
		/**
		 * @private
		 * статус загрузки. всё зашибись
		 */
		private static const _STATE_COMPLETE:uint =	_STATE_PROGRESS	+ 1;
		
		/**
		 * @private
		 * статус загрузки. ошибка
		 */
		private static const _STATE_ERROR:uint =	_STATE_COMPLETE	+ 1;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 */
		public function LoaderBase(request:URLRequest=null) {
			super();
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
//		private var _id:String;
		
		/**
		 * @private
		 * состояние загрзщика
		 */
		private var _state:uint = _STATE_IDLE;
		
		/**
		 * @private
		 */
		private var _frameReady:Boolean = false;
		
		/**
		 * @private
		 */
		private var _input:ByteArray;
		
		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  url
		//----------------------------------

		/**
		 * @private
		 */
		private var _url:String;
		
		/**
		 * @inheritDoc
		 */
		public function get url():String {
			return this._url;
		}
		
		//----------------------------------
		//  bytesLoaded
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;
		
		/**
		 * @inheritDoc
		 */
		public function get bytesLoaded():uint {
			return this._bytesLoaded;
		}
		
		//----------------------------------
		//  bytesTotal
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;
		
		/**
		 * @inheritDoc
		 */
		public function get bytesTotal():uint {
			return this._bytesTotal;
		}
		
		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * @private
		 */
		private var _progress:Number;

		/**
		 * @inheritDoc
		 */
		public function get progress():Number {
			return this._progress;
		}
		
		//----------------------------------
		//  complete
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean {
			return this._state >= _STATE_COMPLETE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implements methods: ILoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function load(request:URLRequest):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
//			if ( NetMonitor.isActive() && !NetMonitor.isURLRequestAdjusted( request ) ) {
//				this._id = UIDUtils.createUID();
//				NetMonitor.monitorInvocation( this._id, request, this );
//				NetMonitor.adjustURLRequest( this._id, request );
//			}
			this.start( URLUtils.createAbsoluteURL( _ROOT, request.url ) );
			this.$load( request );
		}

		/**
		 * @inheritDoc
		 */
		public function loadBytes(bytes:ByteArray):void {
			if ( this._state != _STATE_IDLE ) throw new ArgumentError();
			//else if ( this._state > _STATE_PROGRESS ) this.clear();
			this.start();
			this._input = _BIN.takeOut( 'bytes' ) || new ByteArray();
			this._input.writeBytes( bytes );
			this._input.position = 0;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_loadBytes_enterFrame );
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if ( this._state != _STATE_PROGRESS ) throw new ArgumentError();
			this.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		public function unload():void {
			if ( this._state <= _STATE_PROGRESS ) throw new ArgumentError();
			this.stop();
		}
		
		/**
		 * @inheritDoc
		 */
		public function isIdle():Boolean {
			return this._state == _STATE_IDLE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function dispatchEvent(event:Event):Boolean {
			return this.$dispatchEvent( event );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ( this._url ? ' url="' + this._url + '"' : ' object' ) + ']';
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
//		$protected_load function $getAbstractContent():* {
//		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load function $load(request:URLRequest):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 */
		$protected_load function $loadBytes(bytes:ByteArray):void {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load function $unload():Boolean {
			throw new IllegalOperationError();
		}
		
		/**
		 * @private
		 */
		$protected_load final function start(url:String=null):void {
			this._url = url;
			this._state = _STATE_PROGRESS;
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}
		
		/**
		 * @private
		 * очисщает данные
		 */
		$protected_load final function stop():void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_loadBytes_enterFrame );
			if ( this._input ) {
				this._input.clear();
				_BIN.takeIn( 'bytes', this._input );
				this._input = null;
			}
			this._state = _STATE_IDLE;
			if ( this.$unload() && super.hasEventListener( Event.UNLOAD ) ) {
				super.dispatchEvent( new Event( Event.UNLOAD ) );
			}
			if ( this._state != _STATE_IDLE ) {
//				this._id = null;
				this._url = null;
				this._bytesLoaded = 0;
				this._bytesTotal = 0;
			}
		}
		
		/**
		 * @private
		 * обвновление прогресса
		 */
		$protected_load final function updateProgress(bytesLoaded:uint, bytesTotal:uint):void {
			if ( this._bytesLoaded == bytesLoaded && this._bytesTotal == bytesTotal ) return;
			this._frameReady = false;
			if ( this._bytesLoaded < bytesLoaded ) {
				this._bytesLoaded = bytesLoaded;
			}
			this._bytesTotal = bytesTotal;
			if ( bytesTotal > 0 ) {
				this._progress = this._bytesLoaded / this._bytesTotal;
			} else {
				this._progress = ( this._state >= _STATE_COMPLETE ? 1 : 0 );
			}
			this.$dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, this._bytesLoaded, this._bytesTotal ) );
		}

		/**
		 * @private
		 * слушает прогресс, и обвноляет его, если _frameReady установлен в true.
		 */
		$protected_load final function progressHandler(event:ProgressEvent):void {
			if ( !this._frameReady ) return;
			this.updateProgress( event.bytesLoaded, event.bytesTotal );
		}

		/**
		 * @private
		 */
		$protected_load final function completeHandler(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			if ( event is ErrorEvent ) {
				trace( '[LOADER-ERROR]', this._url );
				this._state = _STATE_ERROR;
			} else {
				this.updateProgress( this._bytesTotal, this._bytesTotal );
				this._state = _STATE_COMPLETE;
			}
			this._state = ( event is ErrorEvent ? _STATE_ERROR : _STATE_COMPLETE );
//			if ( this._id && NetMonitor.isActive() ) {
//				if ( this._state == _STATE_COMPLETE ) {
//					NetMonitor.monitorResult( this._id, this.$getAbstractContent() );
//				} else {
//					NetMonitor.monitorFault( this._id, ( event as ErrorEvent ).text );
//				}
//			}
			this.$dispatchEvent( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $dispatchEvent(event:Event):Boolean {
			// странная штука. после отправки всегда статус становится Error. каким бы событие не было.
			// в самом rpc нигде не используется
			//if ( this._id && NetMonitor.isActive() ) {
			//	NetMonitor.monitorEvent( this._id, event );
			//}
			if (
				event is ErrorEvent &&
				event.type != ErrorEvent.ERROR &&
				super.hasEventListener( ErrorEvent.ERROR )
			) {
				var result:Boolean = super.dispatchEvent(
					new ErrorEvent(
						ErrorEvent.ERROR,
						false,
						false,
						( event as ErrorEvent ).text,
						( event as ErrorEvent ).errorID
					)
				);
				if ( !super.hasEventListener( event.type ) ) {
					return result;
				}
			}
			return super.dispatchEvent( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * устанавливает _frameReady в true. что бы избежать слишком частые обвноления со стороны загрузщиков.
		 */
		private function handler_enterFrame(event:Event):void {
			this._frameReady = true;
		}

		/**
		 * @private
		 */
		private function handler_loadBytes_enterFrame(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_loadBytes_enterFrame );
			if ( super.hasEventListener( Event.OPEN ) ) {
				this.$dispatchEvent( new Event( Event.OPEN ) );
			}
			this.updateProgress( 0, this._input.length );
			this.$loadBytes( this._input );
			this._input = null;
		}
		
	}

}