////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.factory {

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Создатель приложения. Покаывает процесс загрузки как самого
	 * приложения так и его библиотек необходимых для инициализации.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					applicationfactory, application, factory
	 */
	public class ApplicationFactory extends SimpleApplicationFactory {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ApplicationFactory(rootClassName:String=null, initializationTimeout:uint=0) {
			super( rootClassName );

			// сохраним наш класс для дальнейшей работы
			this._initializationTimeout = initializationTimeout;

			super.addEventListener( Event.ADDED, this.handler_added_removed, false, int.MAX_VALUE, true );
			super.addEventListener( Event.ADDED, this.handler_added_removed, true, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED, this.handler_added_removed, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED, this.handler_added_removed, true, int.MAX_VALUE, true );

			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE );

		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {

			super.removeEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage );

			this._stageAlign = super.stage.align;
			this._stageScaleMode = super.stage.scaleMode;

			super.stage.align = StageAlign.TOP_LEFT;
			super.stage.scaleMode = StageScaleMode.NO_SCALE;
			super.stage.addEventListener( Event.RESIZE, this.handler_resize );

			this._context = new LoaderContext( false, ApplicationDomain.currentDomain ); // wtf with SecurityDomain.currentDomain ?

			// рузим себя
			this.addLoader( super.loaderInfo );

			this.showPreloader = true;

			try {
				this.onConstruct();
			} catch ( e:Error ) {
				this.throwError( e );
			}

		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _stageScaleMode:String;

		/**
		 * @private
		 */
		private var _stageAlign:String;

		/**
		 * @private
		 */
		private const _loaded:Vector.<Boolean> = new Vector.<Boolean>();

		/**
		 * @private
		 */
		private const _loaders:Vector.<LoaderInfo> = new Vector.<LoaderInfo>();

		/**
		 * @private
		 */
		private var _context:LoaderContext;

		/**
		 * @private
		 */
		private var _info:TextSprite;

		/**
		 * @private
		 */
		private var _initializationTimeout:uint;

		/**
		 * @private
		 */
		private var _timeoutID:uint;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  bytesLoaded
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesLoaded:uint = 0;

		/**
		 * Количество считанных байт
		 * 
		 * @keyword					applicationfactory.bytesloaded, bytesloaded
		 */
		public final function get bytesLoaded():uint {
			return this._bytesLoaded;
		}

		//----------------------------------
		//  bytesTotal
		//----------------------------------

		/**
		 * @private
		 */
		private var _bytesTotal:uint = 0;

		/**
		 * Всего байт
		 * 
		 * @keyword					applicationfactory.bytestotal, bytestotal
		 */
		public final function get bytesTotal():uint {
			return this._bytesTotal;
		}

		//----------------------------------
		//  loaded
		//----------------------------------

		/**
		 * Загрузились ли мы?
		 * 
		 * @keyword					applicationfactory.loaded, loaded
		 */
		public final function get loaded():Boolean {
			for each ( var l:Boolean in this._loaded ) {
				if ( !l ) return false;
			}
			return true;
		}

		//----------------------------------
		//  showPreloader
		//----------------------------------

		/**
		 * @private
		 */
		private var _showPreloader:Boolean = false;

		/**
		 * Показывать ли прелоадер?
		 * 
		 * @keyword					applicationfactory.showpreloader, showpreloader
		 */
		public final function get showPreloader():Boolean {
			return this._showPreloader;
		}

		/**
		 * @private
		 */
		public final function set showPreloader(value:Boolean):void {
			if ( this._showPreloader == value ) return;
			this._showPreloader = value;
			if ( this._showPreloader ) {
				if ( !this._info || !( this._info is PreloaderSprite ) ) {
					if ( this._info && super.contains( this._info ) ) {
						super.removeChild( this._info );
					}
					this._info = new PreloaderSprite( 0, this._color );
				}
				if ( !super.contains( this._info ) ) {
					super.addChildAt( this._info, 0 );
				}
				this.updatePosition();
				if ( this._info is PreloaderSprite ) {
					( this._info as PreloaderSprite ).progress = this._bytesLoaded / this._bytesTotal
				}
			} else {
				if ( this._info ) {
					super.removeChild( this._info );
				}
			}
		}

		//----------------------------------
		//  color
		//----------------------------------

		/**
		 * @private
		 */
		private var _color:uint = 0xFFFFFF;

		/**
		 * Цвет
		 * 
		 * @keyword					applicationfactory.color, color
		 */
		public final function get color():uint {
			return this._color;
		}

		/**
		 * @private
		 */
		public final function set color(value:uint):void {
			this._color = value;
			if ( this._info ) this._info.color = this._color;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Событие инитиализации приложения.
		 * 
		 * @keyword					applicationfactory.oninitialize, oninitialize
		 */
		protected function onConstruct():void {
		}

		/**
		 * Событие инитиализации приложения.
		 * 
		 * @keyword					applicationfactory.oninitialize, oninitialize
		 */
		protected function onInitialize():void {
		}

		/**
		 * Событие окончания загрузки.
		 * 
		 * @keyword					applicationfactory.oncomplete, oncomplete
		 * 
		 * @see						flash.display.LoaderInfo#complete
		 */
		protected function onComplete():void {
		}

		/**
		 * Событие процесса загрузки загрузки.
		 * 
		 * @keyword					applicationfactory.onprogress, onprogress
		 * 
		 * @see						flash.display.LoaderInfo#progress
		 */
		protected function onProgress():void {
		}

		/**
		 * Событие изменение размеров экрана.
		 * 
		 * @keyword					applicationfactory.onprogress, onprogress
		 * 
		 * @see						flash.display.Stage#resize
		 */
		protected function onResize():void {
		}

		/**
		 * Какая-то ошибка произошла.
		 * 
		 * @parma	e				Ошибка.
		 *  
		 * @keyword					applicationfactory.onerror, onerror
		 */
		protected function onError(e:Error):void {
			this.showError( e );
		}

		/**
		 * Загрузить новую свф.
		 * 
		 * @param	url			Урыл по которому грузить.
		 * 
		 * @return				LoaderInfo свфки, которую грузим.
		 * 
		 * @see					flash.display.Loader#load()
		 * @see					flash.display.Loader#contentLoaderInfo
		 */
		protected function load(request:URLRequest):LoaderInfo {
			var loader:$Loader = new $Loader();
			try {
				loader.$load( request, this._context );
				this.addLoader( loader.contentLoaderInfo );
				return loader.contentLoaderInfo;
			} catch ( e:Error ) {
				this.throwError( e );
			}
			return null;
		}

		/**
		 * @private
		 */
		protected override function initialize():void {
			if ( !this.loaded ) return;
			clearTimeout( this._timeoutID );
			super.stage.align = this._stageAlign;
			super.stage.scaleMode = this._stageScaleMode;
			super.stage.removeEventListener( Event.RESIZE, this.handler_resize );
			try {
				// отошлём евент
				this.onInitialize();
				super.initialize();
				if ( super.contains( this._info ) ) super.removeChild( this._info );
				this._info = null;
			} catch ( e:Error ) {
				this.throwError( e );
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
		private function updatePosition():void {
			if ( !this._info ) return;
			var p:Point = super.globalToLocal( new Point( super.stage.stageWidth / 2, super.stage.stageHeight / 2 ) );
			this._info.x = p.x;
			this._info.y = p.y;
		}

		/**
		 * @private
		 */
		private function updateProgress():void {
			var bytesLoaded:uint = 0;
			var bytesTotal:uint = 0;
			for each ( var loaderInfo:LoaderInfo in this._loaders ) {
				if ( loaderInfo.bytesTotal > 0 ) {
					bytesLoaded += loaderInfo.bytesLoaded;
					bytesTotal += loaderInfo.bytesTotal;
				}
			}
			if ( this._info is PreloaderSprite ) {
				( this._info as PreloaderSprite ).progress = this._bytesLoaded / this._bytesTotal
			}
			if ( this._bytesLoaded != bytesLoaded || this._bytesTotal != bytesTotal ) {
				this._bytesLoaded = bytesLoaded;
				this._bytesTotal = bytesTotal;
				try {
					this.onProgress();
				} catch ( e:Error ) {
					this.throwError( e );
				}
			}
		}

		/**
		 * @private
		 */
		private function throwError(e:Error):void {
			trace( e.getStackTrace() || e.toString() );
			for each ( var loaderInfo:LoaderInfo in this._loaders ) {
				this.removeLoader( loaderInfo );
			}
			if ( this._info && super.contains( this._info ) ) {
				super.removeChild( this._info );
			}
			try {
				this.onError( e );
			} catch ( skip:Error ) { // не важная ошибка
				this.showError( e );
			}
		}

		/**
		 * @private
		 */
		private function showError(e:Error):void {
			if ( this._info && super.contains( this._info ) ) {
				super.removeChild( this._info );
			}
			this._info = new ErrorSprite( e.getStackTrace() || e.toString(), this._color );
			this.updatePosition();
			super.addChildAt( this._info, 0 );
		}

		/**
		 * @private
		 */
		private function addLoader(loaderInfo:LoaderInfo):void {
			if ( this._loaders.indexOf( loaderInfo ) >=0 ) return;
			loaderInfo.addEventListener( Event.COMPLETE, this.handler_complete );
			loaderInfo.addEventListener( IOErrorEvent.IO_ERROR, this.handler_ioError );
			loaderInfo.addEventListener( ProgressEvent.PROGRESS, this.handler_progress );
			this._loaders.push( loaderInfo );
			this._loaded.push( false );
			if ( loaderInfo.bytesTotal > 0 ) {
				this.updateProgress();
			}
		}

		/**
		 * @private
		 */
		private function removeLoader(loaderInfo:LoaderInfo):void {
			if ( loaderInfo.bytesLoaded <= loaderInfo.bytesTotal ) {
				try {
					loaderInfo.loader.close();
				} catch ( e:Error ) {
				}
			}
			loaderInfo.removeEventListener( Event.COMPLETE, this.handler_complete );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_ioError );
			loaderInfo.removeEventListener( ProgressEvent.PROGRESS, this.handler_progress );
			var index:int = this._loaders.indexOf( loaderInfo );
			if ( index >= 0 ) {
				this._loaders.splice( index, 1 );
				this._loaded.splice( index, 1 );
				this.updateProgress();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			this.updateProgress();
		}

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var index:uint = this._loaders.indexOf( loaderInfo );
			if ( index >= 0 ) this._loaded[ index ] = true;

			if ( this.loaded ) {

				// убъем лоадеры
				for each ( loaderInfo in this._loaders ) {
					this.removeLoader( loaderInfo );
				}

				if ( this._info && super.contains( this._info ) ) {
					super.removeChild( this._info );
				}

				try {
					this.onComplete();
				} catch ( e:Error ) {
					this.throwError( e );
					return;
				}

				if ( this._initializationTimeout > 0 ) {
					this._timeoutID = setTimeout( this.initialize, this._initializationTimeout );
				} else {
					this.initialize();
				}

			}
		}

		/**
		 * @private
		 * прерывает все загрузки и выкидывает исключение
		 */
		private function handler_ioError(event:IOErrorEvent):void {
			this.throwError( new IOError( event.text, parseInt( event.text.match( /(?<=^Error #)\d+(?=:.*)/ )[0] ) ) );
		}

		/**
		 * @private
		 * стопаем всякіе штуки
		 */
		private function handler_added_removed(event:Event):void {
			if ( event.target === this._info ) event.stopImmediatePropagation();
		}

		/**
		 * @private
		 */
		private function handler_resize(event:Event):void {
			this.updatePosition();
			try {
				this.onResize();
			} catch ( e:Error ) {
				this.throwError( e );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  DisplayObject
		//----------------------------------

		/**
		 * @private
		 */
		public override final function set x(value:Number):void {
			if ( super.x == value ) return;
			super.x = value;
			this.updatePosition();
		}

		/**
		 * @private
		 */
		public override final function set y(value:Number):void {
			if ( super.y == value ) return;
			super.y = value;
			this.updatePosition();
		}

		//----------------------------------
		//  DisplayObjectContainer
		//----------------------------------

		/**
		 * @private
		 */
		public override final function get numChildren():int {
			return super.numChildren - ( this._info && super.contains( this._info ) ? 1 : 0 );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  DisplayObjectContainer
		//----------------------------------

		/**
		 * @private
		 */
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if ( this._showPreloader ) ++index;
			return super.addChildAt( child, index );
		}

		/**
		 * @private
		 */
		public override function removeChildAt(index:int):DisplayObject {
			if ( this._showPreloader ) index--;
			return super.removeChildAt( index );
		}

		/**
		 * @private
		 */
		public override function getChildAt(index:int):DisplayObject {
			if ( this._showPreloader ) index--;
			return super.getChildAt( index );
		}

		/**
		 * @private
		 */
		public override function getChildIndex(child:DisplayObject):int {
			return super.getChildIndex( child ) + ( this._showPreloader ? -1 : 0 );
		}

		/**
		 * @private
		 */
		public override function getObjectsUnderPoint(point:Point):Array {
			var result:Array = super.getObjectsUnderPoint( point );
			if ( this._showPreloader && this._info ) {
				var index:int = result.indexOf( this._info );
				if ( index >= 0 ) result.splice( index, 1 );
			}
			return result;
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
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;


////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: TextSprite
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * 
 * @author					BlooDHounD
 */
internal class TextSprite extends Sprite {

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static const _FORMAT:TextFormat = new TextFormat( '_sans', 10, null, null, null, null, null, null, TextFormatAlign.CENTER );

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function TextSprite(color:uint=0xFFFFFF):void {
		super();
		super.mouseEnabled = false;
		super.tabEnabled = false;
		this.label.selectable = false;
		this.label.defaultTextFormat = _FORMAT;
		this.label.autoSize = TextFieldAutoSize.CENTER;
		super.addChild( this.label );
		this.color = color;
	}

	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	protected const label:TextField = new TextField();

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  color
	//----------------------------------

	/**
	 * @private
	 */
	public function get color():uint {
		return this.label.textColor;
	}

	/**
	 * @private
	 */
	public function set color(value:uint):void {
		this.label.textColor = value;
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PreloaderSprite
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Отображалка загрузки. 
 * 
 * @author					BlooDHounD
 */
internal final class PreloaderSprite extends TextSprite {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function PreloaderSprite(progress:Number=0.0, color:uint=0xFFFFFF):void {
		super( color );
		super.mouseChildren = false;
		this.label.width = 100;
		this.label.y = - 20;
		this.label.x = -( this.label.width >>> 1 );
		this.label.text = 'Initialization...';
		this._progress = progress;
		this.redraw();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  color
	//----------------------------------

	/**
	 * @private
	 */
	public override function get color():uint {
		return this.label.textColor;
	}

	/**
	 * @private
	 */
	public override function set color(value:uint):void {
		if ( this.label.textColor == value ) return;
		this.label.textColor = value;
		this.redraw();
	}

	//----------------------------------
	//  progress
	//----------------------------------

	/**
	 * @private
	 */
	private var _progress:Number = 0;

	/**
	 * @private
	 */
	public function get progress():Number {
		return this._progress;
	}

	/**
	 * @private
	 */
	public function set progress(value:Number):void {
		value = Math.min( Math.max( 0, value ), 1 ); 
		if ( this._progress == value ) return;
		this._progress = value;
		this.redraw();
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function redraw():void	{
		var w:Number = this._progress * 100;
		var color:uint = this.label.textColor;
		with ( super.graphics ) {
			clear();
			beginFill( color, 0.5 );
			drawRect( -50, -5, w, 10 );
			endFill();
			lineStyle( 1, color );
			drawRect( -50, -5, 100, 10 );
		}
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ErrorSprite
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Отображалка ошибок. 
 * 
 * @author					BlooDHounD
 */
internal final class ErrorSprite extends TextSprite {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function ErrorSprite(text:String=null, color:uint=0xFFFFFF):void {
		super( color );
		this.label.selectable = true;
		this.label.multiline = true;
		this.label.width = 200;
		this.label.x = -( this.label.width >>> 1 );
		this.text = text;
	}

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 * @private
	 */
	public function get text():String {
		return this.label.text;
	}

	/**
	 * @private
	 */
	public function set text(value:String):void {
		this.label.text = value || '';
		this.label.y = -( this.label.height >>> 1 );
	}

}

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
		super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE, true );
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