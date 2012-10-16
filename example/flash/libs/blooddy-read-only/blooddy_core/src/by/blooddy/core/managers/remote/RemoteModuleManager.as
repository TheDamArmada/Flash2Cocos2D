////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.remote {

	import by.blooddy.core.events.managers.RemoteModuleEvent;
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.LoaderContext;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	[Event( name="init", type="by.blooddy.core.events.managers.RemoteModuleEvent" )]
	[Event( name="unload", type="by.blooddy.core.events.managers.RemoteModuleEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class RemoteModuleManager extends EventDispatcher implements IRemoteModuleManager {

		public function RemoteModuleManager(applicationDomain:ApplicationDomain=null) {
			super();
			this._applicationDomain = applicationDomain || ApplicationDomain.currentDomain;
		}

		private const _loaders:Vector.<ModuleLoader> = new Vector.<ModuleLoader>();

		private var _applicationDomain:ApplicationDomain;

		public function get applicationDomain():ApplicationDomain {
			return this._applicationDomain;
		}

		public function hasDefinition(name:String):Boolean {
			for each ( var loader:ModuleLoader in this._loaders ) {
				if ( loader.loaderInfo.applicationDomain.hasDefinition( name ) ) return true;
			}
			return false;
		}

		public function getDefinition(name:String):Object {
			var app:ApplicationDomain, result:Object;
			for each ( var loader:ModuleLoader in this._loaders ) {
				app = loader.loaderInfo.applicationDomain;
				if ( app.hasDefinition( name ) ) {
					result = app.getDefinition( name );
					if ( result ) return result;
				}
			}
			return null;
		}

		public function load(request:URLRequest, applicationDomain:ApplicationDomain=null):void {
			var loader:ModuleLoader = new ModuleLoader();
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( Event.INIT,		this.handler_init );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_error );
			loader.loaderContext = new LoaderContext( applicationDomain || new ApplicationDomain( this._applicationDomain ) );
			loader.load( request );
		}

		public function loadBytes(bytes:ByteArray, applicationDomain:ApplicationDomain=null):void {
			var loader:ModuleLoader = new ModuleLoader();
			loader.addEventListener( Event.COMPLETE,	this.handler_complete );
			loader.addEventListener( Event.INIT,		this.handler_init );
			loader.addEventListener( ErrorEvent.ERROR,	this.handler_error );
			loader.loaderContext = new LoaderContext( applicationDomain || new ApplicationDomain( this._applicationDomain ) );
			loader.loadBytes( bytes );
		}

		public function unload():void {
			var loader:ModuleLoader;
			var id:String;
			while ( this._loaders.length ) {
				loader = this._loaders.pop();
				id = loader.id;
				loader.unload();
				super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.UNLOAD, false, false, id ) );
			}
		}

		public function unloadModule(id:String):void {
			if ( !id ) return;
			for each ( var module:ModuleLoader in this._loaders ) {
				if ( module.id == id ) {
					module.unload();
					this._loaders.splice( this._loaders.indexOf( module ), 1 );
					super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.UNLOAD, false, false, id ) );
					return;
				}
			}
			throw new ArgumentError();
		}

		public function hasModule(id:String):Boolean {
			for each ( var module:ModuleLoader in this._loaders ) {
				if ( module.id == id ) return true;
			}
			return false;
		}

		private function handler_init(event:Event):void {
			var loader:ModuleLoader = event.target as ModuleLoader;
			loader.removeEventListener( Event.INIT, this.handler_init );
			if ( loader.contentType != MIME.FLASH || !( loader.content is IRemoteModule ) && loader.id ) {
				loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
				loader.removeEventListener( ErrorEvent.ERROR,	this.handler_error );
				loader.close();
			}
		}

		private function handler_complete(event:Event):void {
			var loader:ModuleLoader = event.target as ModuleLoader;
			loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			loader.removeEventListener( ErrorEvent.ERROR,	this.handler_error );
			this._loaders.push( loader );
			super.dispatchEvent( new RemoteModuleEvent( RemoteModuleEvent.INIT, false, false, loader.id ) );
		}

		private function handler_error(event:ErrorEvent):void {
			var loader:ModuleLoader = event.target as ModuleLoader;
			loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			loader.removeEventListener( Event.INIT, this.handler_init );
			loader.removeEventListener( ErrorEvent.ERROR, this.handler_error );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.managers.remote.IRemoteModule;
import by.blooddy.core.net.loading.Loader;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ModuleLoader
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class ModuleLoader extends Loader {

	public function ModuleLoader() {
		super();
	}

	public function get id():String {
		var module:IRemoteModule = super.content as IRemoteModule;
		if ( module ) return module.id;
		return null;
	}

	public override function unload():void {
		var module:IRemoteModule = super.content as IRemoteModule;
		if ( module ) {
			module.dispose();
		}
		super.unload();
	}

}