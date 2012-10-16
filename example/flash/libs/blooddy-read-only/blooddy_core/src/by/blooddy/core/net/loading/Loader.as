////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.display.dispose;
	import by.blooddy.core.net.MIME;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					loader
	 * 
	 * @see						flash.display.Loader
	 */
	public class Loader extends LoaderBase {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected_load;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const IS_REMOTE:Boolean = ( Security.sandboxType == Security.REMOTE );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 * Constructor.
		 *
		 * @param	request			Если надо, то сразу передадим и начнётся загрузка.
		 * @param	loaderContext	Если надо грузить, то возможно пригодится.
		 */
		public function Loader(request:URLRequest=null, loaderContext:by.blooddy.core.net.loading.LoaderContext=null) {
			super();
			this._loaderContext = loaderContext;
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
		private var _loader:$Loader;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  loaderContext
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderContext:by.blooddy.core.net.loading.LoaderContext;

		/**
		 * A LoaderContext object to use to control loading of the content.
		 * This is an advanced property. 
		 * Most of the time you can use the trustContent property.
		 * 
		 * @default					null
		 * 
		 * @keyword					loader.loadercontext, loadercontext
		 * 
		 * @see						flash.system.LoaderContext
		 * @see						flash.system.ApplicationDomain
		 * @see						flash.system.SecurityDomain
		 */
		public function get loaderContext():by.blooddy.core.net.loading.LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:by.blooddy.core.net.loading.LoaderContext):void {
			if ( this._loaderContext === value ) return;
			if ( !super.isIdle() ) throw new ArgumentError();
			this._loaderContext = value;
		}

		//----------------------------------
		//  contentType
		//----------------------------------

		/**
		 * @private
		 */
		private var _contentType:String;

		public function get contentType():String {
			return this._contentType;
		}

		//----------------------------------
		//  content
		//----------------------------------

		/**
		 * @private
		 */
		private var _content:IBitmapDrawable;

		/**
		 * @copy					flash.display.Loader#content
		 */
		public function get content():IBitmapDrawable {
			return this._content;
		}

		//----------------------------------
		//  loaderInfo
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderInfo:LoaderInfo;
		
		/**
		 * @copy					flash.display.Loader#contentLoaderInfo
		 */
		public final function get loaderInfo():LoaderInfo {
			return this._loaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_load function $assign(input:ByteArray, url:String=null):void {
			this.start( url );
			this.$loadBytes( input );
		}
		
		/**
		 * @private
		 */
		$protected_load override function $load(request:URLRequest):void {
			this._loader = this.create_loader( true, true );
			this._loaderInfo = this._loader._loaderInfo;
			this._loader._load( request, this.create_loaderContext( _URL && _URL.test( request.url ) ) );
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			this._loader = this.create_loader();
			this._loaderInfo = this._loader._loaderInfo;
			this._loader._loadBytes( bytes, this.create_loaderContext() );
			bytes.clear();
			_BIN.takeIn( 'bytes', bytes );
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._content || this._loader );
			if ( this._content ) {
				if ( this._content is DisplayObject ) {
					var d:DisplayObject = this._content as DisplayObject;
					if ( d.parent ) {
						_JUNK.addChild( d );
						_JUNK.removeChild( d );
					}
					dispose( d );
				} else if ( this._content is BitmapData ) {
					( this._content as BitmapData ).dispose();
				}
				this._content = null;
			}
			this.clear_loader();
			this._contentType = null;
			return unload;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * создаёт лоадер для загрузки
		 */
		private function create_loader(open:Boolean=false, security:Boolean=false):$Loader {
			var result:$Loader = new $Loader();
			result._target = this;
			var li:LoaderInfo = result._loaderInfo;
			if ( open ) {	// событие уже могло быть послано
				li.addEventListener( Event.OPEN,					super.dispatchEvent,			false, int.MAX_VALUE );
			}
			li.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent,			false, int.MAX_VALUE );
			li.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler,			false, int.MAX_VALUE );
			if ( security ) { // с подозрением на секурность, используем расширенный обработчик
				li.addEventListener( Event.INIT,					this.handler_security_init,		false, int.MAX_VALUE );
			} else {
				li.addEventListener( Event.INIT,					this.handler_init,				false, int.MAX_VALUE );
			}
			li.addEventListener( Event.COMPLETE,					this.handler_complete,			false, int.MAX_VALUE );
			li.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_error,				false, int.MAX_VALUE );
			li.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error,				false, int.MAX_VALUE );
			return result;
		}

		/**
		 * @private
		 */
		private function create_loaderContext(canSecurity:Boolean=false):flash.system.LoaderContext {
			var result:flash.system.LoaderContext;
			if (
				this._loaderContext && (
					( canSecurity && this._loaderContext.ignoreSecurityDomain ) ||
					this._loaderContext.checkPolicyFile ||
					this._loaderContext.applicationDomain ||
					this._loaderContext.parameters
				)
			) {
				result = new flash.system.LoaderContext();
				result.checkPolicyFile = this._loaderContext.checkPolicyFile;
				result.applicationDomain = this._loaderContext.applicationDomain;
				if ( canSecurity && this._loaderContext.ignoreSecurityDomain ) {
					result.securityDomain = SecurityDomain.currentDomain;
				}
				result.parameters = this._loaderContext.parameters;
			}
			return result;
		}
		
		/**
		 * @private
		 */
		private function clear_loader():void {
			if ( this._loader ) {
				var li:LoaderInfo = this._loaderInfo;
				li.removeEventListener( Event.OPEN,							super.dispatchEvent );
				li.removeEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
				li.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				li.removeEventListener( Event.INIT,							this.handler_security_init );
				li.removeEventListener( Event.INIT,							this.handler_init );
				li.removeEventListener( Event.COMPLETE,						this.handler_security_complete );
				li.removeEventListener( Event.COMPLETE,						this.handler_complete );
				li.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_error );
				li.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_error );
				this._loaderInfo = null;
				this._loader._target = null;
				// TODO: uncatch errors
				if ( !super.complete ) {
					try {
						this._loader._close();
					} catch ( e:* ) {
					}
				}
				try {
					this._loader._unload();
				} catch ( e:* ) {
				}
				this._loader = null;
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
		private function handler_security_init(event:Event):void {

			var hasError:Boolean = false;
			switch ( this._loaderInfo.contentType ) {
				case MIME.FLASH:
					hasError = !( IS_REMOTE || this._loaderInfo.sameDomain ) || !this._loaderInfo.childAllowsParent || !this._loaderInfo.parentAllowsChild;
					break;
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					hasError = !this._loaderInfo.childAllowsParent;
					break;
			}

			var error:Error;

			if ( !hasError ) {

				try {
	
					this._loader._content;
					this.handler_init( event );
	
				} catch ( e:SecurityError ) {
					hasError = true;
					error = e;
				} catch ( e:* ) {
					// ignore
				}

			}

			if ( hasError ) {

				if ( this._loaderContext && this._loaderContext.ignoreSecurityDomain ) {
					
					this._contentType = this._loaderInfo.contentType;
					this._loaderInfo.removeEventListener( Event.COMPLETE, this.handler_complete );
					this._loaderInfo.addEventListener( Event.COMPLETE, this.handler_security_complete );
					
				} else {

					if ( !error ) {
						try {
							Error.throwError( SecurityError, 2048, this._loaderInfo.loaderURL, this._loaderInfo.url );
						} catch ( e:SecurityError ) {
							error = e;
						}
					}

					this.handler_error( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, error.toString(), error.errorID ) );
					
				}

			}
			
		}

		/**
		 * @private
		 */
		private function handler_init(event:Event):void {
			var content:DisplayObject;
			// TODO: что делать, если content null?
			content = this._loader._content;

			_JUNK.addChild( content );
			_JUNK.removeChild( content );

			var invalidSWF:Boolean = false;
			
			if ( this._contentType && this._contentType != this._loaderInfo.contentType ) { // если они не равны, то протикала загрузка через loadBytes.
				// BUGFIX: если грузить каринку черезе loadBytes, то она неправильно обрабатывается, и почему-то кладётся в MovieClip, что нас не устраивает.
				switch ( this._loaderInfo.contentType ) {
					case MIME.FLASH: break;
					default: invalidSWF = true;
				}
				if ( !invalidSWF ) {
					switch ( this._contentType ) {
						case MIME.PNG: case MIME.JPEG: case MIME.GIF: break;
						default: invalidSWF = true;
					}
					if ( !invalidSWF && !( content is MovieClip ) && ( content as MovieClip ).numChildren <= 0 ) {
						invalidSWF = true;
					}
					if ( !invalidSWF ) {
						content = ( content as MovieClip ).removeChildAt( 0 );
						if ( !( content is Bitmap ) ) {
							invalidSWF = true;
						}
					}
				}
			} else {
				this._contentType = this._loaderInfo.contentType;
			}

			if ( invalidSWF ) {

				if ( content ) {
					_JUNK.addChild( content );
					_JUNK.removeChild( content );
					dispose( content );
				}
				this.handler_error( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, 'плохой swf подсунулся' ) );

			} else {

				switch ( this._contentType ) {
					case MIME.FLASH:
						this._content = content;
						break;
					case MIME.PNG:
					case MIME.JPEG:
					case MIME.GIF:
						this._content = ( content as Bitmap ).bitmapData;
						break;
				}
				if ( super.hasEventListener( Event.INIT ) ) {
					super.dispatchEvent( event );
				}

			}
		}

		/**
		 * @private
		 */
		private function handler_security_complete(event:Event):void {
			var loader:$Loader = this.create_loader();
			loader._loadBytes( this._loaderInfo.bytes, this.create_loaderContext() );
			this.clear_loader();	// очищаем старый лоадер
			this._loader = loader;	// записываем новый
			this._loaderInfo = loader._loaderInfo;
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var bytesTotal:uint = this._loaderInfo.bytesTotal;
			super.updateProgress( bytesTotal, bytesTotal );
			super.completeHandler( event );
		}

		/**
		 * @private
		 */
		private function handler_error(event:ErrorEvent):void {
			this.clear_loader();
			super.completeHandler( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.ClassUtils;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Timer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper constant: _JUNK
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal const _JUNK:Sprite = new Sprite();

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: $Loader
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class $Loader extends flash.display.Loader {

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static const _GC_TIMER:Timer = new Timer( 1e3, 1 );
	
	/**
	 * @private
	 */
	private static var _waitGC:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function $Loader() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal var _target:by.blooddy.core.net.loading.Loader;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="свойство запрещено", replacement="_content" )]
	/**
	 * @private
	 */
	public override function get content():DisplayObject {
		Error.throwError( IllegalOperationError, 1069, 'content', ClassUtils.getClassName( this ) );
		return null;
	}

	[Deprecated( message="свойство запрещено", replacement="_loaderInfo" )]
	/**
	 * @private
	 */
	public override function get contentLoaderInfo():LoaderInfo {
		Error.throwError( IllegalOperationError, 1069, 'contentLoaderInfo', ClassUtils.getClassName( this ) );
		return null;
	}

	//--------------------------------------------------------------------------
	//
	//  Internal properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function get _content():DisplayObject {
		return super.content;
	}
	
	/**
	 * @private
	 */
	internal function get _loaderInfo():LoaderInfo {
		return super.contentLoaderInfo;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="метод запрещен", replacement="_load" )]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:LoaderContext=null):void {
		Error.throwError( IllegalOperationError, 1001, 'load' );
	}

	[Deprecated( message="метод запрещен", replacement="_loadBytes" )]
	/**
	 * @private
	 */
	public override function loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		Error.throwError( IllegalOperationError, 1001, 'loadBytes' );
	}

	/**
	 * @private
	 */
	public override function unload():void {
		this._target.unload();
	}

	[Deprecated( message="метод бесмысленен", replacement="unload" )]
	/**
	 * @private
	 */
	public override function unloadAndStop(gc:Boolean=true):void {
		this._target.unload();
	}

	/**
	 * @private
	 */
	public override function close():void {
		this._target.close();
	}

	//--------------------------------------------------------------------------
	//
	//  Internal methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function _load(request:URLRequest, context:LoaderContext=null):void {
		super.load( request, context );
	}
	
	/**
	 * @private
	 */
	internal function _loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		super.loadBytes( bytes, context );
	}
	
	/**
	 * @private
	 */
	internal function _close():void {
		super.close();
	}

	/**
	 * @private
	 */
	internal function _unload():void {
		if ( super.parent ) {
			_JUNK.addChild( this );
			_JUNK.removeChild( this );
		}
		if ( _waitGC ) {
			super.unloadAndStop( false );
		} else {
			_waitGC = true;
			_GC_TIMER.addEventListener( TimerEvent.TIMER_COMPLETE, this.handler_timerComplete );
			_GC_TIMER.start();
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
	private function handler_timerComplete(event:TimerEvent):void {
		_GC_TIMER.reset();
		_GC_TIMER.removeEventListener( TimerEvent.TIMER_COMPLETE, this.handler_timerComplete );
		super.unloadAndStop( true );
		_waitGC = false;
	}

}