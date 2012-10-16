////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.net {
	
	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.ProxySharedObject;
	import by.blooddy.core.utils.net.Location;
	import by.blooddy.external.ExternalConnectionController;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.01.2010 22:31:28
	 */
	public class DataLoaderController extends ExternalConnectionController {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _MAX_LOADING:uint = ( Capabilities.playerType == 'StandAlone' ? uint.MAX_VALUE : 3 );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DataLoaderController(container:DisplayObjectContainer, sharedObject:ProxySharedObject=null) {
			super( container, sharedObject || ProxySharedObject.getLocal( 'dataLoader' ) );
			super.externalConnection.client = this;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _lastID:uint = 0;
		
		/**
		 * @private
		 */
		private var _loading:uint = 0;
		
		/**
		 * @private
		 */
		private const _ids:Object = new Object();

		/**
		 * @private
		 */
		private const _loaders:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private const _queue:Vector.<LoaderAsset> = new Vector.<LoaderAsset>();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function load(uri:String, contentGET:String=null, contentPOST:String=null, contentType:String=null):uint {

			if ( contentGET ) {
				contentGET = encodeURI( contentGET );
				var loc:Location = new Location( uri );
				if ( loc.search || loc.hash ) {
					loc.search = ( loc.search ? loc.search + '&' : '?' ) + contentGET;
					uri = loc.toString();
				} else {
					uri += '?' + contentGET;
				}
			}

			var request:URLRequest = new URLRequest( uri );
			if ( contentPOST ) {
				request.contentType = ( contentType || MIME.TEXT );
				request.requestHeaders.push(
					new URLRequestHeader( 'Content-Type', request.contentType )
				);
				request.method = URLRequestMethod.POST;
				request.data = contentPOST;
			}
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener( Event.COMPLETE,					this.handler_complete );
			loader.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );

			var id:uint = ++this._lastID;

			this._ids[ id ] = loader;
			this._loaders[ loader ] = id;

			this._queue.push( new LoaderAsset( loader, request ) );
			this.updateQueue();

			return id;
		}

		public function close(id:uint):void {
			var loader:URLLoader = this._ids[ id ];
			if ( !loader ) throw new ArgumentError( 'нету загрущика с таким id' );
			this.clearLoader( loader );
			var i:int = this._queue.indexOf( loader );
			if ( i >= 0 ) {
				this._queue.splice( i, 1 );
			} else {
				loader.close();
				this._loading--;
				this.updateQueue();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Protected override methods
		//
		//--------------------------------------------------------------------------

		protected override function construct():void {
		}

		protected override function destruct():void {
			for each ( var id:uint in this._loaders ) {
				this.close( id );
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
		private function updateQueue():void {
			if ( this._loading < _MAX_LOADING && this._queue.length > 0 ) {
				this._loading++;
				var asset:LoaderAsset = this._queue.shift();
				asset.loader.load( asset.request );
			}
		}
		
		/**
		 * @private
		 */
		private function clearLoader(loader:URLLoader):void {

			loader.removeEventListener( Event.COMPLETE,						this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_complete );

			var id:uint = this._loaders[ loader ];

			delete this._loaders[ loader ];
			delete this._ids[ id ];
			
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

			var loader:URLLoader = event.target as URLLoader;
			var id:uint = this._loaders[ loader ];

			this.clearLoader( loader );
			
			if ( event is ErrorEvent ) {
				event = new ErrorEventAsset( event as ErrorEvent, id );
			} else {
				event = new EventAsset( event, id, loader.data as String );
			}
			
			this._loading--;
			this.updateQueue();
			
			super.externalConnection.dispatchEvent( event );

		}
		
	}
	
}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.utils.ClassUtils;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class LoaderAsset {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor.
	 */
	public function LoaderAsset(loader:URLLoader, request:URLRequest) {
		super();
		this.loader = loader;
		this.request = request;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var loader:URLLoader;

	public var request:URLRequest;

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class EventAsset extends Event {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor.
	 */
	public function EventAsset(event:Event, id:uint=0, data:String=null) {
		super( event.type, event.bubbles, event.cancelable );
		this.id = id;
		this.data = data;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var id:uint;

	public var data:String;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	public override function clone():Event {
		return new EventAsset( this, this.id, this.data );
	}

	public override function toString():String {
		return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'id', 'data' );
	}
	
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ErrorEventAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class ErrorEventAsset extends ErrorEvent {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor.
	 */
	public function ErrorEventAsset(event:ErrorEvent, id:uint=0) {
		super( event.type, event.bubbles, event.cancelable, event.text );
		this.id = id;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	public var id:uint;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	public override function clone():Event {
		return new ErrorEventAsset( this, this.id );
	}
	
	public override function toString():String {
		return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'text', 'id' );
	}
	
}