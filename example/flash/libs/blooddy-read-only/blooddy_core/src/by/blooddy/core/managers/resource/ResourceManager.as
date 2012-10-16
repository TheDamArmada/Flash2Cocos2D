////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.events.managers.ResourceBundleEvent;
	import by.blooddy.core.net.IURLRewriter;
	import by.blooddy.core.net.domain;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.LoaderPriority;
	import by.blooddy.core.utils.RecycleBin;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.core.utils.net.Environment;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, при добавлении "пучка".
	 *
	 * @eventType			by.blooddy.core.events.managers.ResourceBundleEvent.BUNDLE_ADDED
	 */
	[Event( name="bundleAdded", type="by.blooddy.core.events.managers.ResourceBundleEvent" )]

	/**
	 * Транслируется, при удаление "пучка".
	 *
	 * @eventType			by.blooddy.core.events.managers.ResourceBundleEvent.BUNDLE_REMOVED
	 */
	[Event( name="bundleRemoved", type="by.blooddy.core.events.managers.ResourceBundleEvent" )]

	/**
	 * Следитель за ресурсами.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcemanager, resource, manager
	 */
	public final class ResourceManager extends EventDispatcher implements IResourceManager {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _BIN:RecycleBin = new RecycleBin();

		/**
		 * @private
		 */
		private static const _HASH:Object = new Object();

		/**
		 * @private
		 */
		private static var _loading:uint = 0;

		/**
		 * @private
		 */
		private static const _LOADING_QUEUE:Array = new Array();

		/**
		 * @private
		 */
		private static const _SORT_FIELDS:Array = new Array( 'priority', 'time' );

		/**
		 * @private
		 */
		private static const _SORT_OPTIONS:Array = new Array( Array.NUMERIC | Array.DESCENDING, Array.NUMERIC );

		//--------------------------------------------------------------------------
		//
		//  Class properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  manager
		//----------------------------------

		public static const manager:ResourceManager = new ResourceManager();

		//----------------------------------
		//  maxLoading
		//----------------------------------

		/**
		 * @private
		 */
		private static var _maxLoading:uint = getDefaultMaxLoading();

		public static function get maxLoading():uint {
			return _maxLoading;
		}

		/**
		 * @private
		 */
		public static function set maxLoading(value:uint):void {
			if ( _maxLoading == value ) return;
			_maxLoading = value || getDefaultMaxLoading(); // если передаётся 0, то сбрасываем на значение по умолчанию
		 	if ( _loading < _maxLoading || _LOADING_QUEUE.length > 0 ) {
		 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
			}
		}

		//----------------------------------
		//  baseURL
		//----------------------------------

		public static var baseURL:String;

		//----------------------------------
		//  ignoreSecurityDomain
		//----------------------------------
		
		public static var ignoreSecurityDomain:Boolean = true;

		//----------------------------------
		//  store
		//----------------------------------
		
		public static var store:IResourceManagerStore;
		
		//----------------------------------
		//  store
		//----------------------------------
		
		public static var urlRewriter:IURLRewriter;
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function getDefaultMaxLoading():uint {

			if ( domain == 'localhost' ) {

				return uint.MAX_VALUE;

			} else if ( Environment.browserName ) {

				var v:int = parseInt( Environment.browserVersion );
				switch ( Environment.browserName ) {
	
					case Environment.FIREFOX:
						if ( v >= 3 ) return 6;
						break;
	
					case Environment.CHROME:
						if ( v >= 5 ) return 7;
						else if ( v >= 3 )	return 4;
						break;
					
					case Environment.MSIE:
						if ( v >= 8 ) return 6;
						break;
					
					case Environment.SAFARI:
						if ( v >= 4 ) return 6;
					case Environment.OPERA:
						return 4;
	
				}

			}
			
			return 3; // по умолчанию не рыба ни мясо

		}
		
		/**
		 * @private
		 */
		private static function addLoaderQueue(asset:$ResourceLoader, priority:int):void {
			asset._queue = new QueueItem( asset, priority );
			if ( priority >= LoaderPriority.HIGHEST ) {
				_LOADING_QUEUE.unshift( asset._queue );
			} else {
				_LOADING_QUEUE.push( asset._queue ); // TODO: splice to the num
				_LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
			}
		 	if ( _loading < _maxLoading ) {
		 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
			}
		}

		/**
		 * @private
		 */
		private static function updateQueue(event:Event=null):void {
			if (
				_LOADING_QUEUE.length > 0 && (
					_loading < _maxLoading ||
					( _LOADING_QUEUE[ 0 ] as QueueItem ).priority >= LoaderPriority.HIGHEST
				)
			) {
				var asset:$ResourceLoader = _LOADING_QUEUE.shift().asset;
				asset._queue = null;
				registerQueue( asset );
				asset._load();
				++_loading;
			}
		 	if ( _loading >= _maxLoading || _LOADING_QUEUE.length <= 0 ) {
		 		enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, updateQueue );
		 	}
		}

		/**
		 * @private
		 */
		private static function registerQueue(asset:$ResourceLoader):void {
			asset.addEventListener( Event.COMPLETE, handler_queue_complete );
			asset.addEventListener( ErrorEvent.ERROR, handler_queue_complete );
		}

		/**
		 * @private
		 */
		private static function unregisterQueue(asset:$ResourceLoader):void {
			asset.removeEventListener( Event.COMPLETE, handler_queue_complete );
			asset.removeEventListener( ErrorEvent.ERROR, handler_queue_complete );
		}

		/**
		 * @private
		 */
		private static function handler_queue_complete(event:Event=null):void {
			unregisterQueue( event.target as $ResourceLoader );
			--_loading;
		 	if ( _loading < _maxLoading || _LOADING_QUEUE.length > 0 ) {
		 		enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, updateQueue );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function ResourceManager() {
			super();
			this._hash[ '' ] = _DEFAULT_BUNDLE;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сдесь храняться "пучки" ресурсов :)
		 */
		private const _hash:Object = new Object();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Функция находит ресурс в "пучке" и возвращает его.
		 * 
		 * @param	bundleName		Имя либы
		 * @param	resourceName	Имя ресурса из либы
		 * 
		 * @return					Ресурс, если есть, или null.
		 * 
		 * @keyword					resourcemanager.getobject, getobject
		 */
		public function getResource(bundleName:String, resourceName:String=null):* {
			if ( !( bundleName in this._hash ) ) return undefined;
			return ( this._hash[ bundleName ] as IResourceBundle ).getResource( resourceName );
		}

		public function hasResource(bundleName:String, resourceName:String=null):Boolean {
			if ( !this.hasResourceBundle( bundleName ) ) return false;
			return ( this._hash[ bundleName ] as IResourceBundle ).hasResource( resourceName );
		}

		/**
		 * Функция нопределяет, если ли "пучОк".
		 * 
		 * @param	bundleName		Имя либы
		 * 
		 * @return					true, если есть и false, если нету.
		 * 
		 * @keyword					resourcemanager.hasresourcebundle, hasresourcebundle
		 */
		public function hasResourceBundle(bundleName:String, ignoreLoading:Boolean=false):Boolean {
			if ( bundleName in this._hash ) {
				if ( ignoreLoading ) {
					return true;
				} else {
					return ( this._hash[ bundleName ] as ILoadable ).complete;
				}
			}
			return false;
		}

		/**
		 * Функция находит "пучОк" и возвращает его.
		 * 
		 * @param	bundleName		Имя либы
		 * 
		 * @return					"ПучОк".
		 * 
		 * @keyword					resourcemanager.getresourcebundle, getresourcebundle
		 */
		public function getResourceBundle(bundleName:String):IResourceBundle {
			var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
			return ( bundle is ILoadable && !( bundle as ILoadable ).complete ? null : bundle );
		}

		public function getResourceBundles():Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			for ( var name:String in this._hash ) {
				result.push( name );
			}
			return result;
		}

		/**
		 * Добавляет новый ресурс.
		 * 
		 * @param	bundleName		Имя "пучка".
		 * 
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function addResourceBundle(bundle:IResourceBundle):void {
			var name:String = bundle.name;
			if ( !name ) throw new ArgumentError();
			if ( name in this._hash ) {
				if ( this._hash[ name ] !== bundle ) {
					throw new ArgumentError();
				}
			} else {
				this._hash[ name ] = bundle;
				if ( bundle is ILoadable ) {
					var loader:ILoadable = bundle as ILoadable;
					if ( loader is $ResourceLoader ) {
						( loader as $ResourceLoader )._managers[ this ] = true;
					}
					if ( loader.complete ) {
						if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
							super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, bundle ) );
						}
					} else {
						this.registerLoadable( loader );
					}
				}
			}
		}

		/**
		 * Удаляет ресурс.
		 * 
		 * @param	bundleName		Имя "пучка".
		 * 
		 * @keyword					resourcemanager.removeresourcebundle, removeresourcebundle
		 */
		public function removeResourceBundle(bundleName:String):void {
			if ( bundleName in this._hash ) {
				if ( !bundleName ) throw new ArgumentError();
				var bundle:IResourceBundle = this._hash[ bundleName ] as IResourceBundle;
				if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_REMOVED ) ) {
					if ( !super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_REMOVED, false, true, bundle ) ) ) return;
				}
				delete this._hash[ bundleName ];
				var loader:ILoadable = bundle as ILoadable;
				if ( loader ) {
					this.unregisterLoadable( loader );
					var asset:$ResourceLoader = loader as $ResourceLoader;
					if ( asset ) { // если ассет, то помучаемся
						delete asset._managers[ this ];
						for each ( var has:Boolean in asset._managers ) break;
						if ( !has ) {
							delete _HASH[ bundleName ];
							if ( loader.complete ) asset._unload();
							else {
								if ( asset._queue ) {
									var i:int = _LOADING_QUEUE.indexOf( asset._queue );
									_LOADING_QUEUE.splice( i, 1 );
									asset._queue = null;
								} else asset._close();
							}
							asset._name = null;
							asset._url = null;
							asset._bytes = null;
							_BIN.takeIn( '', asset );
						}
					}
				}
			}
		}

		/**
		 * Загружает новый ресурс.
		 * 
		 * @param	url				Урыл, по которому лежит ресурс.
		 * 
		 * @return					Загрузщик, в которм ресурс грузится.
		 * 
		 * @keyword					resourcemanager.loadresourcebundle, loadresourcebundle
		 */
		public function loadResourceBundle(url:String, priority:int=0.0):ILoadable {

			var asset:$ResourceLoader;
			if ( url in this._hash ) { // такой уже есть

				asset = this._hash[ url ] as $ResourceLoader;
				if ( !asset ) throw new ArgumentError();

			} else {

				if ( url in _HASH ) {
					asset = _HASH[ url ];
				} else {
					asset = _BIN.takeOut( '' ) || new $ResourceLoader();
					asset._name = url;
					asset._url = ( urlRewriter ? urlRewriter.getURLByName( url ) : null ) || url;
					asset._bytes = ( store ? store.getFileByName( url ) : null );
					_HASH[ url ] = asset;
					addLoaderQueue( asset, priority );
				}
				asset._managers[ this ] = true;
				this._hash[ url ] = asset;

				if ( asset.complete ) {
					if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
						super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, asset ) );
					}
				} else {
					this.registerLoadable( asset );
				}

			}

			// изменился приоритет загрузки
			if ( !asset.complete ) {
				if ( asset._queue && asset._queue.priority < priority ) {
					asset._queue.priority = priority;
					_LOADING_QUEUE.sortOn( _SORT_FIELDS, _SORT_OPTIONS );
					updateQueue();
				}
			}

			return asset;

		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Добавляем уже грузящийся объект
		 */
		private function registerLoadable(loader:ILoadable):void {
			loader.addEventListener( Event.COMPLETE,	this.handler_complete, false, int.MAX_VALUE );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete, false, int.MAX_VALUE );
			loader.addEventListener( Event.UNLOAD,		this.handler_unload );
		}

		/**
		 * @private
		 * Удаляем загружающайся объект
		 */
		private function unregisterLoadable(loader:ILoadable):void {
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
			loader.removeEventListener( Event.UNLOAD,		this.handler_unload );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Обрабатываем окончание загрузки.
		 */
		private function handler_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			if ( super.hasEventListener( ResourceBundleEvent.BUNDLE_ADDED ) ) {
				super.dispatchEvent( new ResourceBundleEvent( ResourceBundleEvent.BUNDLE_ADDED, false, false, loader as IResourceBundle ) );
			}
		}

		/**
		 * @private
		 * Обрабатываем выгрузку.
		 */
		private function handler_unload(event:Event):void {
			this.removeResourceBundle( ( event.target as IResourceBundle ).name );
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.managers.resource.IResourceBundle;
import by.blooddy.core.managers.resource.ResourceLoader;
import by.blooddy.core.managers.resource.ResourceManager;
import by.blooddy.core.net.loading.LoaderContext;
import by.blooddy.core.utils.ClassUtils;

import flash.display.BitmapData;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper const: _DEFAULT_BUNDLE
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal const _DEFAULT_BUNDLE:DefaultResourceBundle = new DefaultResourceBundle();

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: QueueItem
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class QueueItem {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function QueueItem(asset:$ResourceLoader, priority:int=0.0) {
		super();
		this.asset = asset;
		this.priority = priority;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var asset:$ResourceLoader;
	
	public var priority:int;
	
	public const time:Number = getTimer();
	
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: $ResourceLoader
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class $ResourceLoader extends ResourceLoader {

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
	private static const _URL:RegExp = /^\w+:\/\//;

	/**
	 * @private
	 */
	private static const _DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function $ResourceLoader() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	internal var _bytes:ByteArray;

	internal var _queue:QueueItem;
	
	internal const _managers:Dictionary = new Dictionary( true );

	//--------------------------------------------------------------------------
	//
	//  Overriden properties
	//
	//--------------------------------------------------------------------------

	internal var _name:String;

	public override function get name():String {
		return this._name;
	}

	internal var _url:String;

	public override function get url():String {
		return this._url;
	}

	/**
	 * @private
	 */
	public override function set loaderContext(value:LoaderContext):void {
		throw new IllegalOperationError();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="метод запрещен", replacement="_load" )]
	public override function load(request:URLRequest):void {
		throw new IllegalOperationError();
	}

	[Deprecated( message="метод запрещен", replacement="_load" )]
	public override function loadBytes(request:ByteArray):void {
		throw new IllegalOperationError();
	}
	
	[Deprecated( message="метод запрещен", replacement="_close" )]
	public override function close():void {
		throw new IllegalOperationError();
	}

	[Deprecated( message="метод запрещен", replacement="_unload" )]
	public override function unload():void {
		throw new IllegalOperationError();
	}

	//--------------------------------------------------------------------------
	//
	//  Internal methods
	//
	//--------------------------------------------------------------------------
	
	internal function _load():void {
		if ( this._bytes ) {
			super.loadBytes( this._bytes );
		} else {
			var url:String;
			if ( !ResourceManager.baseURL || _URL.test( this._url ) ) {
				url = this._url;
			} else {
				url = ResourceManager.baseURL + '/' + this._url;
			}
			super.loaderContext = new LoaderContext( new ApplicationDomain( _DOMAIN ), ResourceManager.ignoreSecurityDomain );
			try { // так как запуск отложен, то и ошибку надо генерировать в виде события
				super.load( new URLRequest( url ) );
			} catch ( e:SecurityError ) {
				super.completeHandler( new SecurityErrorEvent( SecurityErrorEvent.SECURITY_ERROR, false, false, e.toString(), e.errorID ) );
			} catch ( e:Error ) {
				super.completeHandler( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, e.toString(), e.errorID ) );
			} catch ( e:* ) {
				super.completeHandler( new IOErrorEvent( IOErrorEvent.IO_ERROR, false, false, String( e ) ) );
			}
		}
	}
	
	internal function _close():void {
		super.close();
		if ( super.isIdle() ) {
			super.loaderContext = null;
		}
	}
	
	internal function _unload():void {
		super.unload();
		if ( super.isIdle() ) {
			super.loaderContext = null;
		}
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: DefaultResourceBundle
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * дефолтный пучёк ресурсов
 * обёртка вокруг ApplicationDomain.currentDomain
 */
internal final class DefaultResourceBundle implements IResourceBundle {
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static const _DOMAIN:ApplicationDomain = ApplicationDomain.currentDomain;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor
	 * 
	 * @param	name		Имя пучка.
	 */
	public function DefaultResourceBundle() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Хранилеще ресурсов.
	 */
	private const _hash:Object = new Object();
	
	//--------------------------------------------------------------------------
	//
	//  Implements properties: IResourceBundle
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function get name():String {
		return '';
	}
	
	//--------------------------------------------------------------------------
	//
	//  Implements methods: IResourceBundle
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function getResource(name:String=null):* {
		if ( !name ) {
			return null;
		} else if ( name in this._hash ) { // пытаемся найти в кэше
			return this._hash[ name ];
		} else {
			
			var resource:*;
			if ( _DOMAIN.hasDefinition( name ) ) {
				resource = _DOMAIN.getDefinition( name );
				if ( resource is Class ) {
					var resourceClass:Class = resource as Class;
					var p:Object = resourceClass.prototype;
					if ( p instanceof BitmapData ) {
						resource = new resourceClass( 0, 0 );
					} else if (
						p instanceof Sound ||
						p instanceof ByteArray
					) {
						resource = new resourceClass();
					}
				}
			}
			this._hash[ name ] = resource;
			return resource;

		}
	}

	/**
	 * @inheritDoc
	 */
	public function hasResource(name:String=null):Boolean {
		return (
			name && (
				name in this._hash || // пытаемся найти в кэше
				_DOMAIN.hasDefinition( name ) // пытаемся найти в домене
			)
		);
	}
	
	/**
	 * @private
	 */
	public function toString():String {
		return '[' + ClassUtils.getClassName( this ) + ' object]';
	}

}