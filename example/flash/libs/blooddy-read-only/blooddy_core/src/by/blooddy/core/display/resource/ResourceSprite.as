////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.display.BaseSprite;
	import by.blooddy.core.events.display.resource.ResourceErrorEvent;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.resource.ResourceManagerProxy;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * @eventType			by.blooddy.core.events.net.loading.LoaderEvent.LOADER_INIT
	 */
	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.ADDED_TO_MANAGER
	 */
	[Event( name="addedToMain", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceEvent.REMOVED_FROM_MANAGER
	 */
	[Event( name="removedFromMain", type="by.blooddy.core.events.display.resource.ResourceEvent" )]

	/**
	 * @eventType			by.blooddy.core.events.display.resource.ResourceErrorEvent.RESOURCE_ERROR
	 */
	[Event( name="resourceError", type="by.blooddy.core.events.display.resource.ResourceErrorEvent" )]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected_rs" )]

	[Exclude( kind="method", name="getResourceManager" )]
	[Exclude( kind="method", name="getDepth" )]

	/**
	 * Класс у когорого есть ссылка на манагер ресурсов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourcemangerownersprite, resourcemanagerowner, resourcemanager, resource, manager, sprite
	 */
	public class ResourceSprite extends BaseSprite {

		//--------------------------------------------------------------------------
		//
		//  Namepsaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected_rs;

		use namespace $protected_rs;
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _MANAGER:ResourceManagerProxy = new ResourceManagerProxy();

		/**
		 * @private
		 */
		private static const _LOCK_HASH:Dictionary = new Dictionary( true );

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
		public function ResourceSprite() {
			super();
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MIN_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _resources:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private var _manager:ResourceManagerProxy;

		/**
		 * @private
		 */
		private var _lockers:Object;
		
		/**
		 * @private
		 */
		private var _depth:int = 0;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stage:Stage;

		public override function get stage():Stage {
			return this._stage || super.stage;
		}

		//--------------------------------------------------------------------------
		//
		//  $protected_rs methods
		//
		//--------------------------------------------------------------------------

		$protected_rs function getResourceManager():ResourceManagerProxy {
			var parent:DisplayObjectContainer = super.parent;
			while ( parent ) {
				if ( parent is ResourceSprite ) {
					return ( parent as ResourceSprite )._manager;
				}
				parent = parent.parent;
			}
			return ( super.stage ? _MANAGER : null );
		}
		
		$protected_rs function getDepth():int {
			var parent:DisplayObjectContainer = super.parent;
			while ( parent ) {
				if ( parent is ResourceSprite ) {
					return ( parent as ResourceSprite )._depth + 1;
				}
				parent = parent.parent;
			}
			return int.MIN_VALUE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected final function hasManager():Boolean {
			return Boolean( this._manager );
		}

		/**
		 * @event	loaderInit
		 */
		protected final function loadResourceBundle(bundleName:String, priority:int=0.0):ILoadable {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var loader:ILoadable = this._manager.loadResourceBundle( bundleName, priority );
			// диспатчим событие о том что началась загрузка
			if ( !loader.complete ) super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, true, false, loader ) );
			return loader;
		}

		protected final function hasResource(bundleName:String, resourceName:String=null):Boolean {
			if ( !this._manager ) throw new ArgumentError();
			return this._manager.hasResource( bundleName, resourceName );
		}

		/**
		 * @event	resourceError
		 */
		protected final function getResource(bundleName:String, resourceName:String=null):Object {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var result:Object = this._manager.getResource( bundleName, resourceName );
			if ( result ) {
				switch ( typeof result ) {
					case 'object':
					case 'function':
						if ( !resourceName ) resourceName = '';
						this.saveResource( bundleName, resourceName, result );
				}
			}
			return result;
		}

		/**
		 * @event	resourceError
		 */
		protected final function getDisplayObject(bundleName:String, resourceName:String=null):DisplayObject {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var result:DisplayObject = this._manager.getDisplayObject( bundleName, resourceName );
			if ( result ) {
				if ( !resourceName ) resourceName = '';
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		/**
		 * @event	resourceError
		 */
		protected final function getSound(bundleName:String, resourceName:String=null):Sound {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var result:Sound = this._manager.getSound( bundleName, resourceName );
			if ( result ) {
				if ( !resourceName ) resourceName = '';
				this.saveResource( bundleName, resourceName, result );
			}
			return result;
		}

		protected final function trashResource(resource:Object, time:uint=3*60*1E3):void {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var def:ResourceLinker = this._resources[ resource ];
			if ( !def ) throw new ArgumentError( 'неизвестный ресурс' );
			--def.count;
			if ( !def.count ) {
				delete this._resources[ resource ];
				_LINKERS.push( def );
			}
			this._manager.trashResource( resource, time );
		}

		protected final function lockResourceBundle(bundleName:String):void {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var lockers:Dictionary = this._lockers[ bundleName ];
			if ( !lockers ) {
				this._lockers[ bundleName ] = lockers = new Dictionary( true );
				this._manager.lockResourceBundle( bundleName );
			}
			lockers[ this ] = true;
		}

		protected final function unlockResourceBundle(bundleName:String):void {
			if ( !this._manager ) throw new ArgumentError( 'спрайт не имеет связи с ResourceManager' );
			var lockers:Dictionary = this._lockers[ bundleName ];
			if ( lockers ) {
				delete lockers[ this ];
				for each ( var lock:Boolean in lockers ) break;
				if ( !lock ) {
					delete this._lockers[ bundleName ];
					this._manager.unlockResourceBundle( bundleName );
				}
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
				def = ( _LINKERS.length > 0 ? _LINKERS.pop() : new ResourceLinker() );
				def.bundleName = bundleName;
				def.resourceName = resourceName;
				this._resources[ resource ] = def;
			}
			++def.count;
		}

		/**
		 * @private
		 */
		private function removeFromManager():void {
			if ( super.hasEventListener( ResourceEvent.REMOVED_FROM_MAIN ) ) {
				super.dispatchEvent( new ResourceEvent( ResourceEvent.REMOVED_FROM_MAIN ) );
			}
			// если у нас остались ресурсы, это ЖОПА!
			var resources:Vector.<ResourceDefinition>;
			for each ( var def:ResourceLinker in this._resources ) {
				if ( !resources ) resources = new Vector.<ResourceDefinition>();
				resources.push( def );
			}
			if ( resources && super.hasEventListener( ResourceErrorEvent.RESOURCE_ERROR ) ) {
				super.dispatchEvent( new ResourceErrorEvent( ResourceErrorEvent.RESOURCE_ERROR, false, false, 'Некоторые ресурсы не были возвращены в мэннеджер ресурсов.', 0, resources ) );
			}
			// зануляем resourceManager
			this._manager = null;
			this._lockers = null;
			this._stage = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {

			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );

			this._depth = this.getDepth();
			var manager:ResourceManagerProxy = this.getResourceManager();
			
			if ( this._manager && this._manager !== manager ) {
				this.removeFromManager();
			}
			
			if ( !this._manager && manager ) {
				this._stage = super.stage;
				this._manager = manager;
				this._lockers = _LOCK_HASH[ manager ];
				if ( !this._lockers ) {
					_LOCK_HASH[ manager ] = this._lockers = new Object();
				}
				if ( super.hasEventListener( ResourceEvent.ADDED_TO_MAIN ) ) {
					super.dispatchEvent( new ResourceEvent( ResourceEvent.ADDED_TO_MAIN ) );
				}
			}

		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			if ( this._manager ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame, false, this._depth );
			}
		}

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			this.removeFromManager();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.display.resource.ResourceDefinition;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ResourceLinker
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
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