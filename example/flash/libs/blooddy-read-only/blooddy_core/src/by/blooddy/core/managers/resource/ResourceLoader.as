////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.resource {

	import by.blooddy.core.net.MIME;
	import by.blooddy.core.net.loading.HeuristicLoader;
	import by.blooddy.core.net.loading.LoaderContext;
	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.DefinitionFinder;
	import by.blooddy.core.utils.dispose;
	import by.blooddy.crypto.MD5;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	/**
	 * Загружает свф и воспринимает его как ресурсы.
	 * Если загружается не свф, то обижаемся на него и просим убираться во свояси.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					resourceloader, resource, loader
	 */
	public class ResourceLoader extends HeuristicLoader implements IResourceBundle {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _NAME_BITMAP_DATA:String =		getQualifiedClassName( BitmapData );

		/**
		 * @private
		 */
		private static const _NAME_SOUND:String =			getQualifiedClassName( Sound );

		/**
		 * @private
		 */
		private static const _NAME_BYTE_ARRAY:String =		getQualifiedClassName( ByteArray );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function ResourceLoader(name:String=null, request:URLRequest=null, loaderContext:LoaderContext=null) {
			super( request, loaderContext );
			this._name = name;
			super.addEventListener( Event.INIT, this.handler_init, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private var _domain:ApplicationDomain;
		
		/**
		 * @private
		 */
		private var _definitions:DefinitionFinder;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IResourceBundle
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _name:String;

		/**
		 * @inheritDoc
		 */
		public function get name():String {
			return this._name || super.url;
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

				return super.content;

			} else if ( name in this._hash ) { // пытаемся найти в кэше

				return this._hash[ name ];

			} else {

				var resource:*;

				if ( this._domain && this._domain.hasDefinition( name ) ) { // пытаемся найти в домене
					resource = this._domain.getDefinition( name );
				} else if ( super.content && name in super.content ) { // пытаемся найти в контэнте
					resource = super.content[ name ];
				}

				if ( resource is Class ) {
					var resourceClass:Class = resource as Class;
					var p:Object = resourceClass.prototype;
					if (
						p instanceof BitmapData || (
							this._domain &&
							p instanceof this._domain.getDefinition( _NAME_BITMAP_DATA )
						)
					) {
						try {
							resource = new resourceClass( 0, 0 );
						} catch ( e:* ) {
							resource = new resourceClass();
						}
					} else if ( 
						p instanceof Sound ||
						p instanceof ByteArray || (
							this._domain && (
								p instanceof this._domain.getDefinition( _NAME_SOUND ) ||
								p instanceof this._domain.getDefinition( _NAME_BYTE_ARRAY )
							)
						)
					) {
						resource = new resourceClass();
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
			if ( !name ) {
				return super.content != undefined;
			}
			return (
				( name in this._hash ) || // пытаемся найти в кэше
				( this._domain && this._domain.hasDefinition( name ) ) || // пытаемся найти в домене
				( super.content && name in super.content ) // пытаемся найти в контэнте
			);
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: HeuristicLoader
		//
		//--------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public override function loadBytes(bytes:ByteArray):void {
			super.loadBytes( bytes );
			if ( this._name == null ) {
				this._name = MD5.hashBytes( bytes );
			}
		}

		/**
		 * @inheritDoc
		 */
		public override function unload():void {
			this.clear();
			super.unload();
			if ( super.isIdle() ) {
				this._name = null;
			}
		}

		/**
		 * @inheritDoc
		 */
		public override function close():void {
			this.clear();
			super.close();
			if ( super.isIdle() ) {
				this._name = null;
			}
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return '[' + ClassUtils.getClassName( this ) +
						( super.url ? ' url="' + this.url + '"' : ' object' ) +
						( this._name || super.url ? ' name="' + ( this._name || super.url ) + '"' : ' object' ) +
					']';
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 */
		public function getResources():Array {
			if ( super.complete && super.contentType == MIME.FLASH ) {
				if ( !this._definitions ) {
					if ( super.loaderInfo ) this._definitions = new DefinitionFinder( super.loaderInfo.bytes );
				}
				return this._definitions.getDefinitionNames();
			}
			return new Array();
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function clear():void {
			this._definitions = null;
			var resource:*;
			var arr:Vector.<String> = new Vector.<String>();
			for ( var name:String in this._hash ) {
				arr.push( name );
			}
			for each ( name in arr ) {
				resource = this._hash[ name ];
				if ( typeof resource == 'object' ) {
					dispose( resource );
				}
				delete this._hash[ name ];
			}
			this._domain = null;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_init(event:Event):void {
			if ( super.loaderInfo ) {
				this._domain = super.loaderInfo.applicationDomain;
			}
		}

	}

}