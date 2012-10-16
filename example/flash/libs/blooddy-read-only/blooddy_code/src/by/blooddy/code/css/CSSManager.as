////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.css {

	import by.blooddy.code.css.definition.CSSMedia;
	import by.blooddy.core.events.net.loading.LoaderEvent;
	import by.blooddy.core.managers.process.IProcessable;
	import by.blooddy.core.managers.resource.IResourceManager;
	import by.blooddy.core.managers.resource.ResourceManager;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="loaderInit", type="by.blooddy.core.events.net.loading.LoaderEvent" )]
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.04.2010 22:40:36
	 */
	public final class CSSManager extends EventDispatcher {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );

		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getManager(manager:IResourceManager=null):CSSManager {
			if ( !manager ) manager = ResourceManager.manager;
			var result:CSSManager = _HASH[ manager ];
			if ( !result ) {
				_privateCall = true;
				_HASH[ manager ] = result = new CSSManager( manager );
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Constructor
		 */
		public function CSSManager(manager:IResourceManager) {
			if ( !_privateCall ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			_privateCall = false;
			this._manager = manager;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _manager:IResourceManager;

		/**
		 * @private
		 */
		private const _medias:Object = new Object();

		/**
		 * @private
		 */
		private const _loaders:Object = new Object();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function hasDefinition(url:String):Boolean {
			return url in this._medias;
		}

		public function getDefinition(url:String):Vector.<CSSMedia> {
			var result:Vector.<CSSMedia> = this._medias[ url ];
			return ( result ? result.slice() : null );
		}

		public function loadDefinition(url:String):IProcessable {
			var result:CSSLoader = this._loaders[ url ];
			if ( !result ) {
				this._loaders[ url ] = result = new CSSLoader( this, this._manager, url );
				result.addEventListener( Event.COMPLETE,	this.handler_complete, false, int.MAX_VALUE );
				result.addEventListener( ErrorEvent.ERROR,	this.handler_complete, false, int.MAX_VALUE );
				if ( result.$loader ) {
					super.dispatchEvent( new LoaderEvent( LoaderEvent.LOADER_INIT, false, false, result.$loader ) );
				}
			}
			return result;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:CSSLoader = event.target as CSSLoader;
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
			this._medias[ loader.$url ] = loader.$content;
		}

	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.code.css.CSSManager;
import by.blooddy.code.css.CSSParser;
import by.blooddy.code.css.definition.CSSMedia;
import by.blooddy.core.managers.process.IProcessable;
import by.blooddy.core.managers.resource.IResourceManager;
import by.blooddy.core.net.loading.ILoadable;
import by.blooddy.core.net.loading.LoaderPriority;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

//--------------------------------------
//  Implements events
//--------------------------------------

[Event( name="complete", type="flash.events.Event" )]

[Event( name="error", type="flash.events.ErrorEvent" )]

/**
 * @private
 */
internal final class CSSLoader extends EventDispatcher implements IProcessable {

	public function CSSLoader(cssManager:CSSManager, resourceManager:IResourceManager, url:String) {
		super();
		this._cssManager = cssManager;
		this._resourceManager = resourceManager;
		this.$url = url;
		this.createLoader();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _cssManager:CSSManager;

	/**
	 * @private
	 */
	private var _resourceManager:IResourceManager;
	
	/**
	 * @private
	 */
	internal var $loader:ILoadable;
	
	/**
	 * @private
	 */
	internal var $parser:CSSParser;
	
	//--------------------------------------------------------------------------
	//
	//  Internal properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal var $url:String;
	
	internal var $content:Vector.<CSSMedia>;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _complete:Boolean = false;
	
	public function get complete():Boolean {
		return this._complete;
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function createLoader():void {
		this.$loader = this._resourceManager.loadResourceBundle( this.$url, LoaderPriority.HIGHEST );
		if ( this.$loader.complete ) {
			this.$loader = null;
			this.createParser();
		} else {
			this.$loader.addEventListener( Event.COMPLETE,		this.handler_loader_complete, false, int.MAX_VALUE );
			this.$loader.addEventListener( ErrorEvent.ERROR,	this.handler_loader_error, false, int.MAX_VALUE );
		}
	}

	/**
	 * @private
	 */
	private function clearLoader():void {
		this.$loader.removeEventListener( Event.COMPLETE,	this.handler_loader_complete );
		this.$loader.removeEventListener( ErrorEvent.ERROR,	this.handler_loader_error );
		this.$loader = null;
	}

	/**
	 * @private
	 */
	private function createParser():void {
		var data:String = this._resourceManager.getResource( this.$url ) as String;
		if ( data ) {
			this.$parser = new CSSParser();
			this.$parser.addEventListener( Event.COMPLETE,		this.handler_parser_complete );
			this.$parser.addEventListener( ErrorEvent.ERROR,	this.handler_parser_error );
			this.$parser.parse( data, this._cssManager );
		} else {
			super.dispatchEvent( new ErrorEvent( ErrorEvent.ERROR ) );
		}
	}

	/**
	 * @private
	 */
	private function clearParser():void {
		this.$parser.removeEventListener( Event.COMPLETE,	this.handler_parser_complete );
		this.$parser.removeEventListener( ErrorEvent.ERROR,	this.handler_parser_error );
		this.$parser = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function handler_loader_complete(event:Event):void {
		this.clearLoader();
		this.createParser();
	}

	/**
	 * @private
	 */
	private function handler_loader_error(event:ErrorEvent):void {
		this.clearLoader();
		this._complete = true;
		super.dispatchEvent( event );
	}

	/**
	 * @private
	 */
	private function handler_parser_complete(event:Event):void {
		this.$content = this.$parser.content;
		this.clearParser();
		this._complete = true;
		super.dispatchEvent( event );
	}
	
	/**
	 * @private
	 */
	private function handler_parser_error(event:ErrorEvent):void {
		this.clearParser();
		this._complete = true;
		super.dispatchEvent( event );
	}
	
}