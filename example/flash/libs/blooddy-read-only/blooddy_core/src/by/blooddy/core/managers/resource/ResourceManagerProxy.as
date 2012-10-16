////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.errors.display.resource.ResourceError;
	import by.blooddy.core.events.managers.ResourceBundleEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.core.utils.RecycleBin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.02.2010 3:46:27
	 */
	public final class ResourceManagerProxy implements IResourceManager {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _SEPARATOR:String = '#';

		/**
		 * @private
		 */
		private static const _NAME_DISPLAY_OBJECT:String = getQualifiedClassName( DisplayObject );

		/**
		 * @private
		 */
		private static const _LINKERS:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ResourceManagerProxy() {
			super();
			this._manager.addEventListener( ResourceBundleEvent.BUNDLE_ADDED,	this.handler_bundleAdded, false, int.MAX_VALUE, true );
			this._manager.addEventListener( ResourceBundleEvent.BUNDLE_REMOVED,	this.handler_bundleRemoved, false, int.MAX_VALUE, true );
			// added default bundle
			 var usage:ResourceUsage = new ResourceUsage();
			 usage.lock = -1;
			 this._resourceUsages[ '' ] = usage;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _manager:ResourceManager = new ResourceManager();

		/**
		 * @private
		 */
		private const _bin:RecycleBin = new RecycleBin();

		/**
		 * @private
		 */
		private const _resources:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private const _resourceUsages:Object = new Object();

		/**
		 * @private
		 */
		private const _timer:Timer = new Timer( 60e3 );

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _resourceLiveTime:uint = 60e3;

		public final function get resourceLiveTime():uint {
			return this._resourceLiveTime;
		}

		/**
		 * @private
		 */
		public final function set resourceLiveTime(value:uint):void {
			if ( this._resourceLiveTime == value ) return;
			this._resourceLiveTime = value;
			this._timer.delay = this._resourceLiveTime;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clear():void {
			var resources:Vector.<ResourceDefinition>;
			var hash:Object = new Object();
			for each ( var def:ResourceLinker in this._resources ) {
				if ( !resources ) resources = new Vector.<ResourceDefinition>();
				resources.push( def );
				hash[ def.bundleName ] = true;
			}
			var locks:Vector.<ResourceDefinition>;
			var usage:ResourceUsage;
			var bundles:Vector.<String> = new Vector.<String>();
			var bundleName:String;
			for ( bundleName in this._resourceUsages ) {
				// создаём отдельный вектор, так как удаления из хэша во время перебора, нарушает порядок перебора
				bundles.push( bundleName );
				if ( !resources ) { // у нас другая ошибка будет
					usage = this._resourceUsages[ bundleName ];
					if ( usage.lock > 0 ) {
						if ( !locks ) locks = new Vector.<ResourceDefinition>();
						locks.push( new ResourceDefinition( bundleName ) );
					}
				}
			}
			for each ( bundleName in bundles ) {
				this.unloadResourceBundle( bundleName );
				delete this._resourceUsages[ bundleName ];
			}
			if ( resources ) {
				throw new ResourceError( 'Некоторые ресурсы не были возвращены в мэннеджер ресурсов.', 0, resources );
			} else if ( locks ) {
				throw new ResourceError( 'Некоторые ресурсы не были разблокированны.', 0, locks );
			}
		}

		public function loadResourceBundle(url:String, priority:int=0.0):ILoadable {
			return this._manager.loadResourceBundle( url, priority );
		}

		public function hasResource(bundleName:String, resourceName:String=null):Boolean {
			if ( !resourceName ) resourceName = '';
			if ( this._bin.has( bundleName + _SEPARATOR + resourceName ) ) return true;
			else return this._manager.hasResource( bundleName, resourceName );
		}

		public function getResource(bundleName:String, resourceName:String=null):* {
			var result:* = this._manager.getResource( bundleName, resourceName );
			switch ( typeof result ) {
				case 'object':
				case 'function':
					if ( !resourceName ) resourceName = '';
					this.saveResource( bundleName, resourceName, result );
					break;
				case 'xml':
					result = result.copy();
					break;
			}
			return result;
		}

		public function getDisplayObject(bundleName:String, resourceName:String=null):DisplayObject {
			if ( !resourceName ) resourceName = '';
			var key:String = bundleName + _SEPARATOR + resourceName;
			var result:DisplayObject;
			if ( this._bin.has( key ) ) {
				result = this._bin.takeOut( key ) as DisplayObject;
				DisplayObjectUtils.reset( result );
			} else {
				var resource:Object = this._manager.getResource( bundleName, resourceName );
				if ( resource is Class ) {
					var resourceClass:Class = resource as Class;
					var p:Object = resourceClass.prototype;
					if (
						p instanceof DisplayObject ||
						p instanceof this._manager.getResource( bundleName, _NAME_DISPLAY_OBJECT )	// проверяем на поддоменность
					) {
						result = new resourceClass() as DisplayObject;
					}
				} else if ( resource is DisplayObject ) {
					result = resource as DisplayObject;
				} else if ( resource is BitmapData ) {
					result = new Bitmap( resource as BitmapData );
				}
			}
			if ( result ) {
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		public function getSound(bundleName:String, resourceName:String=null):Sound {
			var resource:Object = this._manager.getResource( bundleName, resourceName );
			var result:Sound;
			if ( resource is Sound ) {
				result = resource as Sound;
			} else if ( resource is Class && resource.prototype instanceof Sound ) {
				var resourceClass:Class = resource as Class;
				result = new resourceClass() as Sound;
			}
			if ( result ) {
				if ( !resourceName ) resourceName = '';
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		public function trashResource(resource:Object, time:uint=3*60*1E3):void {
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) throw new ArgumentError( 'Ресурс не был создан.', 5101 );
			--def.count;
			if ( !def.count ) {
				delete this._resources[ resource ];
				_LINKERS.push( def );
			}
			if ( resource is DisplayObject ) {
				var mc:DisplayObject = resource as DisplayObject;
				if ( mc is MovieClip ) {
					( mc as MovieClip ).stop();
				}
				if ( mc.parent ) {
					mc.parent.removeChild( mc );
				}
				if ( time > 0 ) {
					this._bin.takeIn( def.bundleName + _SEPARATOR + def.resourceName, resource, time );
				}
			}
			var usage:ResourceUsage = this._resourceUsages[ def.bundleName ] as ResourceUsage;
			--usage.count;
			if ( usage.count <= 0 ) usage.lastUse = getTimer();
		}

		public function lockResourceBundle(bundleName:String):void {
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( !usage ) {
				if ( !this._manager.hasResourceBundle( bundleName, true ) ) {
					throw new ArgumentError( 'Ресурс не был загружен.', 5102 );
				}
				this._resourceUsages[ bundleName ] = usage = new ResourceUsage();
			}
			if ( !usage.lock ) {
				usage.lock = 1;
			}
		}

		public function unlockResourceBundle(bundleName:String):void {
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			if ( usage && usage.lock ) {
				if ( usage.lock < 0 ) throw new ArgumentError( 'Ресурс не может быть разблокирован.', 5103 );
				usage.lock = 0;
				if ( usage.count <= 0 ) usage.lastUse = getTimer();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function saveResource(bundleName:String, resourceName:String, resource:Object):void {
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) {
				def = _LINKERS.pop() || new ResourceLinker();
				def.bundleName = bundleName;
				def.resourceName = resourceName;
				this._resources[ resource ] = def;
			}
			++def.count;
			var usage:ResourceUsage = this._resourceUsages[ bundleName ] as ResourceUsage;
			++usage.count;
		}

		/**
		 * @private
		 */
		private function unloadResourceBundle(bundleName:String):void {
			this._bin.clear( new RegExp( '^' + bundleName + _SEPARATOR ) );
			if ( this._resourceUsages[ bundleName ].lock >= 0 ) {
				this._manager.removeResourceBundle( bundleName );
			}
		}

		/**
		 * @private
		 */
		private function isEmpty():Boolean {
			for each ( var usage:ResourceUsage in this._resourceUsages ) {
				if ( usage.lock < 0 ) continue; // системный бандл
				return false;
			}
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_bundleAdded(event:ResourceBundleEvent):void {
			if ( this.isEmpty() ) {
				this._timer.addEventListener( TimerEvent.TIMER, this.handler_timer );
				this._timer.start();
			}
			var name:String = event.bundle.name;
			if ( !( name in this._resourceUsages ) ) {
				this._resourceUsages[ name ] = new ResourceUsage();
			}
		}

		/**
		 * @private
		 */
		private function handler_bundleRemoved(event:ResourceBundleEvent):void {
			delete this._resourceUsages[ event.bundle.name ];
			if ( this.isEmpty() ) {
				this._timer.reset();
				this._timer.removeEventListener( TimerEvent.TIMER, this.handler_timer );
			}
		}

		/**
		 * @private
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:Number = getTimer() - this._resourceLiveTime;
			var usage:ResourceUsage;
			for ( var bundleName:String in this._resourceUsages ) {
				usage = this._resourceUsages[ bundleName ] as ResourceUsage;
				if ( !usage.lock && usage.count <= 0 && usage.lastUse <= time ) {
					this.unloadResourceBundle( bundleName );
				}
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.display.resource.ResourceDefinition;

import flash.utils.Dictionary;
import flash.utils.getTimer;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceLinker
//
////////////////////////////////////////////////////////////////////////////////

internal final class ResourceLinker extends ResourceDefinition {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor
	 */
	public function ResourceLinker() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Proeprties
	//
	//--------------------------------------------------------------------------
	
	public var count:uint = 0;
	
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceUsage
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ResourceUsage {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor
	 */
	public function ResourceUsage() {
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var count:uint;
	
	public var lastUse:Number = getTimer();
	
	public var lock:int = 0;
	
}