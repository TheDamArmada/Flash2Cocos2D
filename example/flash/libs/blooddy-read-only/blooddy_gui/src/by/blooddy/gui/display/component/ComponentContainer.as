////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.display.component {
	
	import by.blooddy.core.controllers.IBaseController;
	import by.blooddy.core.display.resource.MainResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.DisplayObjectUtils;
	import by.blooddy.gui.controller.ComponentController;
	import by.blooddy.gui.events.ComponentEvent;
	import by.blooddy.gui.parser.component.ComponentParser;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude( kind="method", name="addChild" )]
	[Exclude( kind="method", name="addChildAt" )]
	[Exclude( kind="method", name="removeChild" )]
	[Exclude( kind="method", name="removeChildAt" )]
	[Exclude( kind="method", name="getChildAt" )]
	[Exclude( kind="method", name="getChildIndex" )]
	[Exclude( kind="method", name="getChildByName" )]
	[Exclude( kind="method", name="setChildIndex" )]
	[Exclude( kind="method", name="swapChildren" )]
	[Exclude( kind="method", name="swapChildrenAt" )]
	[Exclude( kind="method", name="contains" )]
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="componentConstruct", type="by.blooddy.gui.events.ComponentEvent" )]
	[Event( name="componentDestruct", type="by.blooddy.gui.events.ComponentEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					08.04.2010 14:47:51
	 */
	public class ComponentContainer extends MainResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Namepsaces
		//
		//--------------------------------------------------------------------------

		use namespace $internal;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ComponentContainer(baseController:IBaseController=null) {
			super();
			this._baseController = baseController;
			super.addEventListener( ResourceEvent.ADDED_TO_MAIN,		this.handler_addedToMain,		false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MAIN,	this.handler_removedFromMain,	false, int.MAX_VALUE, true );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _components_id:Object = new Object();

		/**
		 * @private
		 */
		private var _components_name:Object = new Object();
		
		/**
		 * @private
		 */
		private var _components_list:Vector.<ComponentInfo> = new Vector.<ComponentInfo>();
		
		/**
		 * @private
		 */
		private var _queue:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private var _lastFocusComponent:Component;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _baseController:IBaseController;
		
		public function get baseController():IBaseController {
			return this._baseController;
		}

		public function get stageWidth():int {
			return ( stage ? stage.stageWidth : 0 );
		}

		public function get stageHeight():int {
			return ( stage ? stage.stageHeight : 0 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getComponents():Vector.<ComponentInfo> {
			return this._components_list.slice();
		}

		public function loadComponent(url:String, params:Object=null):ComponentInfo {
//			if ( !super.hasManager() ) throw new ArgumentError();
//			var loader:ILoadable = super.loadResourceBundle( url );
//			if ( loader.complete ) {
//				// TODO: inline
//			} else {
//				loader.addEventListener( Event.COMPLETE,	this.handler_loader_complete );
//				loader.addEventListener( ErrorEvent.ERROR,	this.handler_loader_error );
//				var asset:ComponentAsset = this._queue[ loader ];
//				if ( !asset ) this._queue[ loader ] = asset = new ComponentAsset( url );
//				asset.params.push( params );
//			}
			ComponentInfo.internalCall = true;
			var info:ComponentInfo = new ComponentInfo();
			info.$initP( params );
			
			this._components_id[ info.id ] = info;
			
			return info;
		}

		public function removeComponent(info:ComponentInfo):void {
			if ( !( info.id in this._components_id ) ) throw new ArgumentError();

			// focus
			var setNewFocus:Boolean = false;
			if ( super.stage && super.stage.focus ) {
				var f:InteractiveObject = super.stage.focus;
				if ( f && info.component.contains( f ) ) {
					setNewFocus = true;
				}
			}

//			var i:int = super.getChildIndex( info.component );
			var i:int = this._components_list.indexOf( info );
			this._components_list.splice( i, 1 );

			delete this._components_id[ info.id ];
			i = this._components_name[ info.name ].indexOf( info );
			if ( i >= 0 ) this._components_name[ info.name ].splice( i, 1 );

			super.removeChild( info.component );

			if ( setNewFocus ) {
				var num:int = super.numChildren;
				var component:Component;
				while ( num-- ) {
					component = super.getChildAt( num ) as Component;
					if ( component ) {
						stage.focus = component;
						break;
					}
				}
			}

		}

		public function removeComponentByID(id:String):void {
			return this.removeComponent( this._components_id[ id ] );
		}

		public function getComponentByID(id:String):ComponentInfo {
			return this._components_id[ id ];
		}

		public function getComponentByName(name:String):ComponentInfo {
			var list:Vector.<ComponentInfo> = this._components_name[ name ];
			return ( list && list.length > 0 ? list[ 0 ] : null );
		}
		
		public function hasComponentByID(id:String):Boolean {
			return id in this._components_id;
		}
		
		public function hasComponentByName(name:String):Boolean {
			return name in this._components_name && this._components_name[ name ].length > 0;
		}

		public function clear():void {
			for each ( var info:ComponentInfo in this._components_id ) {
				if ( info.component && !info.properties.fixed ) { // могло удалить в результате других дейсвий
					this.removeComponent( info );
				}
			}
		}

		public function bringToFront(info:ComponentInfo):void {

			var rating:uint = info.properties.rating;

//			var i:int = super.getChildIndex( info.component );
			var i:int = this._components_list.indexOf( info );
			this._components_list.splice( i, 1 );

			i = this._components_list.length;

			while ( i-- > 0 ) {
				if ( rating >= this._components_list[ i ].properties.rating ) break;
			}
			++i;

			this._components_list.splice( i, 0, info );
			super.setChildIndex( info.component, i );

		}

		public function sendToBack(info:ComponentInfo):void {

			var rating:uint = info.properties.rating;
			
//			var i:int = super.getChildIndex( info.component );
			var i:int = this._components_list.indexOf( info );
			this._components_list.splice( i, 1 );

			i = -1;
			var l:uint = this._components_list.length;
			while ( ++i < l ) {
				if ( rating <= this._components_list[ i ].properties.rating ) break;
			}
			
			this._components_list.splice( i, 0, info );
			super.setChildIndex( info.component, i );

		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		$internal function $dispatchEvent(event:Event):void {
			super.dispatchEvent( event );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function initComponent(info:ComponentInfo, name:String, component:Component, controller:ComponentController, properties:ComponentProperties):void {
			info.$init( name, component, controller, properties, this._baseController );
		}

		protected function addComponent(info:ComponentInfo):void {

			if ( !( info.name in this._components_name ) ) {
				this._components_name[ info.name ] = new Vector.<ComponentInfo>();
			}
			if ( info.properties.singleton ) {
				for each ( var ci:ComponentInfo in this._components_name[ info.name ] ) {
					this.removeComponent( ci );
				}
			}
			this._components_name[ info.name ].push( info );

			// focus
			if ( info.component.mouseEnabled ) {
				super.stage.focus = info.component;
			}

			this._components_list.push( info );
			super.addChild( info.component );

			this.bringToFront( info );

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToMain(event:ResourceEvent):void {
			super.addEventListener( FocusEvent.FOCUS_IN, this.handler_focusIn );
		}

		/**
		 * @private
		 */
		private function handler_removedFromMain(event:ResourceEvent):void {
			super.removeEventListener( FocusEvent.FOCUS_IN, this.handler_focusIn );
		}

		/**
		 * @private
		 */
		private function handler_focusIn(event:FocusEvent):void {
			if (
				this._lastFocusComponent &&
				this._lastFocusComponent.contains( event.target as DisplayObject )
			) return;
			var c:Component;
			var parent:DisplayObjectContainer = event.target.parent as DisplayObjectContainer;
			if ( parent === this ) {
				c = event.target as Component;
			} else {
				while ( parent.parent !== this ) {
					parent = parent.parent;
				}
				c = parent as Component;
			}
			this._lastFocusComponent = c;
		}

		/**
		 * @private
		 */
		private function handler_loader_complete(event:Event):void {
			var asset:ComponentAsset = this._queue[ event.target ];
			this.handler_loader_error( event );

			var xml:XML = new XML( super.getResource( asset.url ) );
			if ( xml ) {

				var parser:ComponentParser = new ComponentParser();
				parser.addEventListener( Event.COMPLETE,			this.handler_parser_complete );
				parser.addEventListener( ErrorEvent.ERROR,			this.handler_parser_error );
				parser.addEventListener( LoaderEvent.LOADER_INIT,	this.handler_loaderInit );
				parser.parse( xml, super.$protected_rs::getResourceManager() );
				this._queue[ parser ] = asset;

			} else {

				

			}
		}

		/**
		 * @private
		 */
		private function handler_loader_error(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE,		this.handler_loader_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_loader_error );
			delete this._queue[ event.target ];
		}

		/**
		 * @private
		 */
		private function handler_parser_complete(event:Event):void {
			var parser:ComponentParser = event.target as ComponentParser;
			var asset:ComponentAsset = this._queue[ event.target ];
			this.handler_parser_error( event );
		}

		/**
		 * @private
		 */
		private function handler_parser_error(event:Event):void {
			var parser:ComponentParser = event.target as ComponentParser;
			parser.removeEventListener( Event.COMPLETE,				this.handler_parser_complete );
			parser.removeEventListener( ErrorEvent.ERROR,			this.handler_parser_error );
			parser.removeEventListener( LoaderEvent.LOADER_INIT,	this.handler_loaderInit );
			delete this._queue[ parser ];
		}
		
		/**
		 * @private
		 */
		private function handler_loaderInit(event:LoaderEvent):void {
			super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, true, false, event.loader ) );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------
		
		[Deprecated( message="метод запрещён", replacement="addComponent" )]
		public override function addChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChild' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="addComponent" )]
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'addChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="removeComponent" )]
		public override function removeChild(child:DisplayObject):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChild' );
			return null;
		}
		
		[Deprecated( message="метод запрещён", replacement="removeComponent" )]
		public override function removeChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'removeChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildAt(index:int):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildAt' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildIndex(child:DisplayObject):int {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildIndex' );
			return -1;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function getChildByName(name:String):DisplayObject {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'getChildByName' );
			return null;
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function setChildIndex(child:DisplayObject, index:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'setChildIndex' );
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildren' );
		}
		
		[Deprecated( message="метод запрещён" )]
		public override function swapChildrenAt(index1:int, index2:int):void {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'swapChildrenAt' );
		}
		
		[Deprecated( message="метод запрещён", replacement="hasComponent" )]
		public override function contains(child:DisplayObject):Boolean {
			if ( !Capabilities.isDebugger ) Error.throwError( IllegalOperationError, 1001, 'contains' );
			return false;
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

/**
 * @private
 */
internal final class ComponentAsset {

	public function ComponentAsset(url:String) {
		super();
		this.url = url;
	}

	public var url:String;

	public const params:Array = new Array();

}