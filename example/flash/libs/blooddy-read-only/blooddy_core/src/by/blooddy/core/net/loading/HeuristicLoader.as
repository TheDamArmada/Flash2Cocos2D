////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net.loading {

	import by.blooddy.core.net.MIME;
	import by.blooddy.core.utils.ByteArrayUtils;
	import by.blooddy.core.utils.net.copyURLRequest;
	
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

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
	public class HeuristicLoader extends LoaderBase {

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
		private static const _XML:RegExp = /^\s*<.*>\s*$/s;
		
		/**
		 * @private
		 */
		private static const _ERROR_LOADER:RegExp = /^Error #2124:/;

		//--------------------------------------------------------------------------
		//
		//  Cosntructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	request
		 * @param	loaderContext
		 */
		public function HeuristicLoader(request:URLRequest=null, loaderContext:by.blooddy.core.net.loading.LoaderContext=null) {
			super();
			this._loaderContext = loaderContext;
			if ( request ) this.load( request );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _request:URLRequest;
		
		/**
		 * @private
		 * сюда грузится данные для анализа, если анализ неудовлетваряет требованию,
		 * то они продолжают сюда грузится
		 */
		private var _stream:flash.net.URLStream;

		/**
		 * @private
		 * сюда грузится swf, а так же картинки
		 */
		private var _loader:$Loader;

		/**
		 * @private
		 * сюда грузятся звуки
		 */
		private var _sound:$SoundLoader;

		/**
		 * @private
		 * сюда грузятся zip
		 */
		private var _zip:$ZIPLoader;
		
		/**
		 * @private
		 * буфер загруженных данных
		 */
		private var _input:ByteArray;

		//--------------------------------------------------------------------------
		//
		//  Implements properties: ILoader
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  uri
		//----------------------------------
		
		/**
		 * @inheritDoc
		 */
		public override function get url():String {
			return ( this._request ? this._request.url : null );
		}
		
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
		private var _loaderContext:LoaderContext;

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
		public function get loaderContext():LoaderContext {
			return this._loaderContext;
		}

		/**
		 * @private
		 */
		public function set loaderContext(value:LoaderContext):void {
			if ( this._loaderContext === value ) return;
			if ( !super.isIdle() ) throw new ArgumentError();
			this._loaderContext = value;
		}

		//----------------------------------
		//  loaderInfo
		//----------------------------------

		/**
		 * @private
		 */
		private var _loaderInfo:LoaderInfo;

		/**
		 * ссылка на информацию о Loader
		 */
		public function get loaderInfo():LoaderInfo {
			return this._loaderInfo;
		}

		//----------------------------------
		//  contentType
		//----------------------------------

		/**
		 * @private
		 */
		private var _contentType:String;

		/**
		 * MIME-type загруженного содержания
		 */
		public function get contentType():String {
			return this._contentType;
		}

		//----------------------------------
		//  content
		//----------------------------------

		/**
		 * @private
		 */
		private var _content:*;

		/**
		 * загруженный контент
		 */
		public function get content():* {
			return this._content;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected_load override function $load(request:URLRequest):void {
			this._request = copyURLRequest( request );
			// определяем первоначальны контэнт по расширению
			this._contentType = MIME.analyseURL( this._request.url );
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:	// для отображаемых типов сразу же пытаемся использовать обычный Loader
					this._loader = this.create_loader( true, true );
					this._loader.load( this._request );
					break;

				default:		// для остальных используем загрузку через stream
					this._input = this.create_input();
					this._stream = this.create_stream( true, !_URL || _URL.test( this._request.url ) );
					this._stream.load( this._request );
					break;

			}
		}

		/**
		 * @private
		 */
		$protected_load override function $loadBytes(bytes:ByteArray):void {
			if ( !this._contentType ) {
				this._contentType = MIME.analyseBytes( bytes ); // пытаемся узнать что за говно мы грузим
			}
			switch ( this._contentType ) {
				
				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = this.create_loader();
					this._loader.$assign( bytes, super.url );
					break;
				
				case MIME.MP3:
					this._sound = this.create_sound();
					this._sound.$assign( bytes, super.url );
					break;
				
				case MIME.ZIP:
					this._zip = this.create_zip();
					this._zip.$assign( bytes, null, super.url );
					break;
				
				default:	// а вот хз, что это

					if ( this._contentType == MIME.BINARY ) {
						this._content = bytes;
					} else {
						this.parseUnknownData( bytes );
						if ( bytes !== this._content ) {
							bytes.clear();
							_BIN.takeIn( 'bytes', bytes );
						}
					}
					if ( super.hasEventListener( Event.INIT ) ) {
						super.dispatchEvent( new Event( Event.INIT ) );
					}
					super.completeHandler( new Event( Event.COMPLETE ) );
				
			}
		}

		/**
		 * @private
		 */
		$protected_load override function $unload():Boolean {
			var unload:Boolean = Boolean( this._content || this._stream || this._loader || this._sound || this._zip || this._input );
			this.clear_asset();
			this._request = null;
			this._content = undefined;
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
		 * создаёт URLStream для загрузки
		 */
		private function create_stream(open:Boolean=false, progress:Boolean=false):flash.net.URLStream {
			var result:flash.net.URLStream = _BIN.takeOut( 'stream' ) || new flash.net.URLStream();
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			if ( _HTTP_RESPONSE_STATUS ) {
				result.addEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
			}
			if ( progress ) { // если беда с доменами, то пытаемся выебнуться
				result.addEventListener( ProgressEvent.PROGRESS,		this.handler_stream_init_progress );
			} else {
				result.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
			}
			result.addEventListener( Event.COMPLETE,					this.handler_stream_init_complete );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
			return result;
		}

		/**
		 * @private
		 * создаёт лоадер для загрузки
		 */
		private function create_loader(url:Boolean=false, open:Boolean=false):$Loader {
			var result:$Loader = _BIN.takeOut( 'loader' ) || new $Loader();
			result.loaderContext = this._loaderContext;
			result._target = this;
			if ( open ) {	// событие уже могло быть послано
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
			result.addEventListener( Event.INIT,						this.handler_loader_init );
			result.addEventListener( Event.COMPLETE,					super.completeHandler );
			if ( url ) { // если загрущик инитиализатор, то загрузка идёт по урлу
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_url_ioError );
			} else {
				result.addEventListener( IOErrorEvent.IO_ERROR,			this.handler_loader_input_ioError );
			}
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
			return result;
		}

		/**
		 * @private
		 * создаём звук для загрузки
		 */
		private function create_sound(open:Boolean=false):$SoundLoader {
			var result:$SoundLoader = _BIN.takeOut( 'sound' ) || new $SoundLoader();
			result.loaderContext = this._loaderContext;
			result._target = this;
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
			result.addEventListener( Event.INIT,						this.handler_sound_init );
			result.addEventListener( Event.COMPLETE,					super.completeHandler );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
			return result;
		}

		/**
		 * @private
		 * создаём звук для загрузки
		 */
		private function create_zip(open:Boolean=false):$ZIPLoader {
			var result:$ZIPLoader = _BIN.takeOut( 'zip' ) || new $ZIPLoader();
			result._target = this;
			if ( open ) {
				result.addEventListener( Event.OPEN,					super.dispatchEvent );
			}
			result.addEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
			result.addEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
			result.addEventListener( Event.INIT,						this.handler_zip_init );
			result.addEventListener( Event.COMPLETE,					super.completeHandler );
			result.addEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
			result.addEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
			return result;
		}

		/**
		 * @private
		 */
		private function create_input():ByteArray {
			return _BIN.takeOut( 'bytes' ) || new ByteArray();
		}

		/**
		 * @private
		 */
		private function clear_asset():void {
			this.clear_stream();
			this.clear_loader();
			this.clear_sound();
			this.clear_zip();
			this.clear_input();
		}
		
		/**
		 * @private
		 * очищает stream
		 */
		private function clear_stream(safe:Boolean=false):void {
			if ( this._stream ) {
				this._stream.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._stream.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				if ( _HTTP_RESPONSE_STATUS ) {
					this._stream.removeEventListener( _HTTP_RESPONSE_STATUS,			super.dispatchEvent );
				}
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				this.handler_stream_init_progress );
				this._stream.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_init_complete );
				this._stream.removeEventListener( Event.COMPLETE,						this.handler_stream_complete );
				this._stream.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
				this._stream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_stream_init_securityError );
				if ( !safe ) {
					if ( this._stream.connected ) {
						this._stream.close();
					}
					_BIN.takeIn( 'stream', this._stream ); 
				}
				this._stream = null;
			}
		}

		/**
		 * @private
		 * очищает loader
		 */
		private function clear_loader():void {
			if ( this._loader ) {
				this._loader._target = null;
				this._loader.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				this._loader.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._loader.removeEventListener( Event.INIT,							this.handler_loader_init );
				this._loader.removeEventListener( Event.COMPLETE,						super.completeHandler );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_url_ioError );
				this._loader.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_loader_input_ioError );
				this._loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
				this._loaderInfo = null;
				this._loader.stop(); // unload
				this._loader.loaderContext = null;
				_BIN.takeIn( 'loader', this._loader );
				this._loader = null;
			}
		}

		/**
		 * @private
		 * очищает sound
		 */
		private function clear_sound():void {
			if ( this._sound ) {
				this._sound._target = null;
				this._sound.removeEventListener( Event.OPEN,						super.dispatchEvent );
				this._sound.removeEventListener( HTTPStatusEvent.HTTP_STATUS,		super.dispatchEvent );
				this._sound.removeEventListener( ProgressEvent.PROGRESS,			super.progressHandler );
				this._sound.removeEventListener( Event.INIT,						this.handler_sound_init );
				this._sound.removeEventListener( Event.COMPLETE,					super.completeHandler );
				this._sound.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
				this._sound.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
				this._sound.stop(); // unload
				this._sound.loaderContext = null;
				_BIN.takeIn( 'sound', this._sound );
				this._sound = null;
			}
		}

		/**
		 * @private
		 * очищает sound
		 */
		private function clear_zip():void {
			if ( this._zip ) {
				this._zip._target = null;
				this._zip.removeEventListener( Event.OPEN,							super.dispatchEvent );
				this._zip.removeEventListener( HTTPStatusEvent.HTTP_STATUS,			super.dispatchEvent );
				this._zip.removeEventListener( ProgressEvent.PROGRESS,				super.progressHandler );
				this._zip.removeEventListener( Event.INIT,							this.handler_zip_init );
				this._zip.removeEventListener( Event.COMPLETE,						super.completeHandler );
				this._zip.removeEventListener( IOErrorEvent.IO_ERROR,				this.handler_common_error );
				this._zip.removeEventListener( SecurityErrorEvent.SECURITY_ERROR,	this.handler_common_error );
				this._zip.stop(); // unload
				_BIN.takeIn( 'zip', this._zip );
				this._zip = null;
			}
		}
		
		/**
		 * @private
		 * очищает буфер
		 */
		private function clear_input(safe:Boolean=false):void {
			if ( this._input ) {
				if ( !safe ) {
					this._input.clear();
					_BIN.takeIn( 'bytes', this._input );
				}
				this._input = null;
			}
		}

		/**
		 * @private
		 */
		private function parseUnknownData(bytes:ByteArray):void {
			var l:uint = bytes.length;
			if ( l > 0 ) {
				if ( ByteArrayUtils.isUTFString( bytes ) ) {

					this._content = bytes.readUTFBytes( bytes.length );

					if ( _XML.test( this._content ) ) { // возможно это xml

						try {
							
							this._content = new XMLList( this._content );
							if ( ( this._content as XMLList ).length() == 1 ) {
								this._content = this._content[ 0 ];
							}
							this._contentType = MIME.XML;
							
						} catch ( e:* ) {

							this._contentType = MIME.TEXT;

						}

					} else {

						this._contentType = MIME.TEXT;

					}

				} else {
					
					this._contentType = MIME.BINARY;
					this._content = bytes;
					
				}
				
			} else {
				
				this._contentType = null;
				
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  common
		//----------------------------------
		
		/**
		 * @private
		 */
		private function handler_common_error(event:ErrorEvent):void {
			this.clear_asset();
			super.completeHandler( event );
		}
		
		//----------------------------------
		//  stream init
		//----------------------------------

		/**
		 * @private
		 * слушает событие progress от stream.
		 * и пытается в процессе, понять, кто же это.
		 * при успешном определение меняет поведение загрузки.
		 */
		private function handler_stream_init_progress(event:ProgressEvent):void {
			this._stream.readBytes( this._input, this._input.length );
			this._contentType = MIME.analyseBytes( this._input ); // пытаемся узнать что за говно мы грузим
			if ( this._contentType ) {
				switch ( this._contentType ) {

					case MIME.FLASH:
					case MIME.PNG:
					case MIME.JPEG:
					case MIME.GIF:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._loader = this.create_loader( true );
						this._loader.load( this._request );
						break;

					case MIME.MP3:
						this.clear_stream();	// закрываем поток
						this.clear_input();
						this._sound = this.create_sound();
						this._sound.load( this._request );
						break;

					case MIME.ZIP:
						this._zip = this.create_zip();
						this._zip.$assign( this._input, this._stream, super.url );
						this.clear_stream( true );
						this._input = null;
						break;

					default:
						// усё. стало всё попроще
						this._stream.removeEventListener( ProgressEvent.PROGRESS,	this.handler_stream_init_progress );
						this._stream.removeEventListener( Event.COMPLETE,			this.handler_stream_init_complete );
						this._stream.addEventListener( ProgressEvent.PROGRESS,		super.progressHandler );
						this._stream.addEventListener( Event.COMPLETE,				this.handler_stream_complete );
						break;

				}

			}
			super.progressHandler( event );
		}

		/**
		 * @private
		 * слушает событие complete от stream.
		 * и пытается в процессе, понять, кто же это.
		 * если неудаётся определить по содержанию, запускается механизм определение по расширению.
		 */
		private function handler_stream_init_complete(event:Event):void {
			this._stream.readBytes( this._input, this._input.length );
			this._input.position = 0;
			this.clear_stream();	// закрываем поток
			// данные закончились, а мы так и не знали, что у нас тут за дерьмо
			this._contentType = MIME.analyseBytes( this._input ) || MIME.analyseURL( this._request.url ); // пытаемся узнать что за говно мы грузим
			this.$loadBytes( this._input );
			this.clear_input( true );
		}

		/**
		 * @private
		 * слушает событие securityError от stream.
		 * так как загрузка на этом заканчивается, мы прежмепринимает отчаенную попытку определения содержания по расширению.
		 */
		private function handler_stream_init_securityError(event:SecurityErrorEvent):void {
			this.clear_stream();	// закрываем поток
			this.clear_input();
			// опа :( нам это низя прочитать. ну что ж ... давайте попробуем по расширению узнать что это цаца
			this._contentType = MIME.analyseURL( this._request.url ); // пытаемся узнать что за говно мы грузим
			switch ( this._contentType ) {

				case MIME.FLASH:
				case MIME.PNG:
				case MIME.JPEG:
				case MIME.GIF:
					this._loader = this.create_loader( true, true );
					this._loader.load( this._request );
					break;

				case MIME.MP3:
					this._sound = this.create_sound( true );
					this._sound.load( this._request );
					break;

				default:
					// усё. пипец
					super.completeHandler( event );
					break;
			}
		}

		//----------------------------------
		//  stream
		//----------------------------------

		/**
		 * @private
		 * загрузились бинарные данные.
		 */
		private function handler_stream_complete(event:Event):void {
			// мы знаем кто нам нужен. нужно просто вычитать всё что там лежит
			var bytesTotal:uint = this._input.length;
			this._stream.readBytes( this._input, this._input.length );
			this.clear_stream();
			this._input.position = 0;

			this.parseUnknownData( this._input );

			this.clear_input( this._input === this._content );

			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( new Event( Event.INIT ) );
			}
			super.updateProgress( bytesTotal, bytesTotal );
			super.completeHandler( event );
		}

		//----------------------------------
		//  loader
		//----------------------------------

		/**
		 * @private
		 * обычная инитиализация loader.
		 */
		private function handler_loader_init(event:Event):void {
			this._loaderInfo = this._loader.loaderInfo;
			this._contentType = this._loader.contentType;
			this._content = this._loader.content;
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( event );
			}
		}

		/**
		 * @private
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_url_ioError(event:IOErrorEvent):void {
			this.clear_loader();
			if ( _ERROR_LOADER.test( event.text ) ) {
				this._input = this.create_input();
				this._stream = this.create_stream( false, !_URL || _URL.test( this._request.url ) );
				this._stream.load( this._request );
			} else {
				super.completeHandler( event );
			}
		}

		/**
		 * @private
		 * слушает событие ioError у loader.
		 * если оно срабатывается, значит мы грузим не swf.
		 */
		private function handler_loader_input_ioError(event:IOErrorEvent):void {
			this.clear_loader();
			if ( _ERROR_LOADER.test( event.text ) ) {
				// загрузка не прошла. пробуем сделать из этой пижни бинарник
				this._input.position = 0;
				
				this.parseUnknownData( this._input );
				
				this.clear_input( this._input === this._content );

				if ( super.hasEventListener( Event.INIT ) ) {
					super.dispatchEvent( new Event( Event.INIT ) );
				}
				super.completeHandler( new Event( Event.COMPLETE ) );
			} else {
				super.completeHandler( event );
			}
		}

		//----------------------------------
		//  sound
		//----------------------------------

		/**
		 * @private
		 */
		private function handler_sound_init(event:Event):void {
			this._content = this._sound.content;
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( event );
			}
		}

		//----------------------------------
		//  zip
		//----------------------------------
		
		/**
		 * @private
		 */
		private function handler_zip_init(event:Event):void {
			this._content = this._zip;
			if ( super.hasEventListener( Event.INIT ) ) {
				super.dispatchEvent( event );
			}
		}
		
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.net.loading.HeuristicLoader;
import by.blooddy.core.net.loading.Loader;
import by.blooddy.core.net.loading.SoundLoader;
import by.blooddy.core.net.loading.ZIPLoader;

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
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	internal var _target:HeuristicLoader;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function close():void {
		this._target.close();
	}
	
	/**
	 * @private
	 */
	public override function unload():void {
		this._target.unload();
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: SoundAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * необходим, что бы при попытки обратится через различные ссылки
 * свойства были перекрыты
 */
internal final class $SoundLoader extends SoundLoader {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function $SoundLoader() {
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
	internal var _target:HeuristicLoader;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function close():void {
		this._target.close();
	}

	/**
	 * @private
	 */
	public override function unload():void {
		this._target.unload();
	}
	
}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ZIPAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * необходим, что бы при попытки обратится через различные ссылки
 * свойства были перекрыты
 */
internal final class $ZIPLoader extends ZIPLoader {
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Constructor
	 */
	public function $ZIPLoader() {
		super( null );
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal var _target:HeuristicLoader;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public override function close():void {
		this._target.close();
	}
	
	/**
	 * @private
	 */
	public override function unload():void {
		this._target.unload();
	}
	
}