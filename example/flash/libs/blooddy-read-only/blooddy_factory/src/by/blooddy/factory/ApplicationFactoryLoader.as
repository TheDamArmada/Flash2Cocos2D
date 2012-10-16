////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.factory {

	import flash.accessibility.AccessibilityImplementation;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.errors.InvalidSWFError;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.media.SoundTransform;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextSnapshot;
	import flash.ui.ContextMenu;
	import flash.utils.getQualifiedClassName;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="accessibilityProperties" )]
	[Exclude( kind="property", name="alpha" )]
	[Exclude( kind="property", name="blendMode" )]
	[Exclude( kind="property", name="blendShader" )]
	[Exclude( kind="property", name="cacheAsBitmap" )]
	[Exclude( kind="property", name="filters" )]
	[Exclude( kind="property", name="height" )]
	[Exclude( kind="property", name="mask" )]
	[Exclude( kind="property", name="name" )]
	[Exclude( kind="property", name="opaqueBackground" )]
	[Exclude( kind="property", name="parent" )]
	[Exclude( kind="property", name="root" )]
	[Exclude( kind="property", name="rotation" )]
	[Exclude( kind="property", name="rotationX" )]
	[Exclude( kind="property", name="rotationY" )]
	[Exclude( kind="property", name="rotationZ" )]
	[Exclude( kind="property", name="scale9Grid" )]
	[Exclude( kind="property", name="scaleX" )]
	[Exclude( kind="property", name="scaleY" )]
	[Exclude( kind="property", name="scaleZ" )]
	[Exclude( kind="property", name="scrollRect" )]
	[Exclude( kind="property", name="stage" )]
	[Exclude( kind="property", name="transform" )]
	[Exclude( kind="property", name="visible" )]
	[Exclude( kind="property", name="width" )]
	[Exclude( kind="property", name="x" )]
	[Exclude( kind="property", name="y" )]
	[Exclude( kind="property", name="z" )]
	[Exclude( kind="property", name="accessibilityImplementation" )]
	[Exclude( kind="property", name="contextMenu" )]
	[Exclude( kind="property", name="doubleClickEnabled" )]
	[Exclude( kind="property", name="focusRect" )]
	[Exclude( kind="property", name="mouseEnabled" )]
	[Exclude( kind="property", name="tabEnabled" )]
	[Exclude( kind="property", name="tabIndex" )]
	[Exclude( kind="property", name="textSnapshot" )]
	[Exclude( kind="property", name="buttonMode" )]
	[Exclude( kind="property", name="hitArea" )]
	[Exclude( kind="property", name="useHandCursor" )]
	[Exclude( kind="property", name="soundTransform" )]

	[Exclude( kind="method", name="dispatchEvent" )]
	[Exclude( kind="method", name="addChild" )]
	[Exclude( kind="method", name="addChildAt" )]
	[Exclude( kind="method", name="areInaccessibleObjectsUnderPoint" )]
	[Exclude( kind="method", name="contains" )]
	[Exclude( kind="method", name="getChildAt" )]
	[Exclude( kind="method", name="getChildByName" )]
	[Exclude( kind="method", name="getChildIndex" )]
	[Exclude( kind="method", name="getObjectsUnderPoint" )]
	[Exclude( kind="method", name="removeChild" )]
	[Exclude( kind="method", name="removeChildAt" )]
	[Exclude( kind="method", name="setChildIndex" )]
	[Exclude( kind="method", name="swapChildren" )]
	[Exclude( kind="method", name="swapChildrenAt" )]
	[Exclude( kind="method", name="startDrag" )]
	[Exclude( kind="method", name="stopDrag" )]

	/**
	 * Грузитель приложения.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					applicationfactoryloader, applicationloader, loader, application, applicationfactory, factory 
	 */
	public class ApplicationFactoryLoader extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var inited:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ApplicationFactoryLoader(url:String=null) {
			super();

			if ( inited || !super.stage || super.stage != super.parent  ) {
				throw new ReferenceError( 'The ' + getQualifiedClassName( ( this as Object ).constructor ) + '' );
			}

			super.mouseEnabled = false;
			super.tabEnabled = false;

			inited = true;

			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE );

			if ( url ) this.load( url );
			
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _url:String;
		
		/**
		 * @private
		 */
		private var _loaded:Boolean = false;
		
		/**
		 * @private
		 */
		private var _loader:$Loader;

		/**
		 * @private
		 */
		private var _factory:MovieClip;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected final function load(url:String):LoaderInfo {
			if ( this._loaded ) throw new ArgumentError();
			this._loaded = true;

			const domain:String = (
				Capabilities.playerType == 'Desktop' || Capabilities.playerType == 'StandAlone'
				?	'localhost'
				:	( new LocalConnection() ).domain
			);
			const URL:RegExp = ( domain == 'localhost' ? null : new RegExp( '^(?:(?!\\w+://)|https?://(?:www\\.)?' + domain.replace( /\./g, '\\.' ) + ')', 'i' ) );
			
			this._loader = new $Loader();
			this._loader.contentLoaderInfo.addEventListener( Event.INIT, this.handler_loader_init );
			this._loader.$load(
				new URLRequest( url ),
				new LoaderContext( false, ApplicationDomain.currentDomain, ( URL && URL.test( url ) ? SecurityDomain.currentDomain : null ) )
			);
			super.addChild( this._loader );

			return this._loader.contentLoaderInfo;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		private function handler_loader_init(event:Event):void {
			var info:LoaderInfo = event.target as LoaderInfo;
			info.removeEventListener( Event.INIT, this.handler_loader_init );
			if (
				info.applicationDomain.hasDefinition( 'by.blooddy.factory::SimpleApplicationFactory' ) &&
				info.content is ( info.applicationDomain.getDefinition( 'by.blooddy.factory::SimpleApplicationFactory' ) as Class ) 
			) {
				this._factory = info.content as MovieClip;
				this._factory.addEventListener( Event.COMPLETE, this.handler_factory_complete );
			} else {
				this._loader.$lockStage();
				this._loader = null;
				super.removeEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage );
				super.parent.removeChild( this );
			}
		}

		/**
		 * @private
		 */
		private function handler_factory_complete(event:Event):void {
			this._factory.removeEventListener( Event.COMPLETE, this.handler_factory_complete );
			this._factory = null;
			( new Sprite() ).addChild( this._loader );
			this._loader.$lockStage();
			this._loader = null;
			super.removeEventListener( Event.REMOVED_FROM_STAGE, this.handler_removedFromStage );
			super.parent.removeChild( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  DisplayObject
		//----------------------------------

		public override final function set accessibilityProperties(value:AccessibilityProperties):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set alpha(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set blendMode(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set blendShader(value:Shader):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set cacheAsBitmap(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set filters(value:Array):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set height(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set mask(value:DisplayObject):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set name(value:String):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set opaqueBackground(value:Object):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get parent():DisplayObjectContainer {
			return null;
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get root():DisplayObject {
			return null;
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set rotation(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set rotationX(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set rotationY(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set rotationZ(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set scale9Grid(innerRectangle:Rectangle):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set scaleX(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set scaleY(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set scaleZ(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set scrollRect(value:Rectangle):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @private
		 */
		public override final function get stage():Stage {
			return null;
		}

		[Deprecated( message="свойство запрещено" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function get transform():Transform {
			throw new IllegalOperationError();
		}

		/**
		 * @private
		 */
		public override final function set transform(value:Transform):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set visible(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set width(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set x(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set y(value:Number):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set z(value:Number):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  InteractiveObject
		//----------------------------------

		public override final function set accessibilityImplementation(value:AccessibilityImplementation):void {
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set contextMenu(cm:ContextMenu):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set doubleClickEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set focusRect(focusRect:Object):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set mouseEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set tabEnabled(enabled:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set tabIndex(index:int):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  DisplayObjectContainer
		//----------------------------------

		/**
		 * @private
		 */
		public override final function get textSnapshot():TextSnapshot {
			return null;
		}

		//----------------------------------
		//  Sprite
		//----------------------------------

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set buttonMode(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set hitArea(value:Sprite):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set useHandCursor(value:Boolean):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="свойство не используется" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function set soundTransform(sndTransform:SoundTransform):void {
			throw new IllegalOperationError();
		} 

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  EventDispatcher
		//----------------------------------


		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function dispatchEvent(event:Event):Boolean {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  DisplayObjectContainer
		//----------------------------------

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function addChild(child:DisplayObject):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function addChildAt(child:DisplayObject, index:int):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function areInaccessibleObjectsUnderPoint(point:Point):Boolean {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function contains(child:DisplayObject):Boolean {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function getChildAt(index:int):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function getChildByName(name:String):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function getChildIndex(child:DisplayObject):int {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function getObjectsUnderPoint(point:Point):Array {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function removeChild(child:DisplayObject):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function removeChildAt(index:int):DisplayObject {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function setChildIndex(child:DisplayObject, index:int):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function swapChildrenAt(index1:int, index2:int):void {
			throw new IllegalOperationError();
		}

		//----------------------------------
		//  Sprite
		//----------------------------------

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function startDrag(lockCenter:Boolean=false, bounds:Rectangle=null):void {
			throw new IllegalOperationError();
		}

		[Deprecated( message="метод запрещён" )]
		/**
		 * @throws	flash.errors.IllegalOperationError
		 */
		public override final function stopDrag():void {
			throw new IllegalOperationError();
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: LoaderAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * необходим, что бы при попытки обратится через различные ссылки, типа loaderInfo,
 * свойства были перекрыты
 */
internal final class $Loader extends Loader {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function $Loader() {
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="свойство запрещено", replacement="$content" )]
	/**
	 * @private
	 */
	public override function get content():DisplayObject {
		throw new IllegalOperationError();
	}

	/**
	 * @private
	 */
	internal function get $content():DisplayObject {
		return super.content;
	}

	//--------------------------------------------------------------------------
	//
	//  Internal methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal function $lockStage():void {
		super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE, true );
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	[Deprecated( message="метод запрещен", replacement="$load" )]
	/**
	 * @private
	 */
	public override function load(request:URLRequest, context:LoaderContext=null):void {
		throw new IllegalOperationError();
	}

	/**
	 * @private
	 */
	internal function $load(request:URLRequest, context:LoaderContext=null):void {
		super.load( request, context );
	}

	[Deprecated( message="метод запрещен", replacement="$loadBytes" )]
	/**
	 * @private
	 */
	public override function loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
		throw new IllegalOperationError();
	}

	[Deprecated( message="метод запрещен" )]
	/**
	 * @private
	 */
	public override function unload():void {
		throw new IllegalOperationError();
	}

	[Deprecated( message="метод запрещен" )]
	/**
	 * @private
	 */
	public override function unloadAndStop(gc:Boolean=true):void {
		throw new IllegalOperationError();
	}

	[Deprecated( message="метод запрещен" )]
	/**
	 * @private
	 */
	public override function close():void {
		throw new IllegalOperationError();
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
		var s:Sprite = new Sprite();
		s.addChild( this );
		s.removeChild( this );
		throw new IllegalOperationError();
	}

}