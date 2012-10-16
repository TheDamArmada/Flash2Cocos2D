////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.utils.time.FrameTimer;
	import by.blooddy.core.utils.time.getTimer;
	import by.blooddy.core.utils.ui.ContextMenuUtils;

	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final class SimpleActivityListener extends Sprite {

		//--------------------------------------------------------------------------
		//
		//  Private constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Формат текстовых палей.
		 */
		private static const TF:TextFormat = new TextFormat( '_sans', 10 );

		/**
		 * @private
		 */
		private static const DEFAULT_BG_COLOR:uint = 0x80000000;

		/**
		 * @private
		 */
		private static const DEFAULT_FPS_COLOR:uint = 0xFFFFFF;

		/**
		 * @private
		 */
		private static const DEFAULT_MEMORY_COLOR:uint = 0xFFFF00;

		/**
		 * @private
		 */
		private static const DEFAULT_WIDTH:Number = 100;

		/**
		 * @private
		 */
		private static const DEFAULT_HEIGHT:Number = 60;

		/**
		 * @private
		 */
		private static const GRAPH_OFFSET_Y:Number = 42;

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Возвращает новое текстовое поле с задаными свойствами.
		 */
		private static function getNewTextField():TextField {
			var txt:TextField = new TextField();
			txt.selectable = false;
			txt.defaultTextFormat = TF;
			txt.autoSize = TextFieldAutoSize.LEFT;
			return txt;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function SimpleActivityListener() {
			super();
			// дефолтные значения
			super.scrollRect = this._scrollRect;
			super.tabChildren = false;
			super.tabEnabled = false;
			super.mouseChildren = false;
			super.mouseEnabled = true;
			// установим цвета
			this.bgColor32 =	DEFAULT_BG_COLOR;		// создаёт заодно и габариты
			this.fpsColor =		DEFAULT_FPS_COLOR;
			this.memoryColor =	DEFAULT_MEMORY_COLOR;
			// переварачиваем шэйпы
				this._shape_MEM.scaleX =
				this._shape_FPS.scaleX = - 1;
			// фигачим текстовые поля
			this._txt_FPS_label.text = 'FPS:';
			this._txt_MEM_label.text = 'MEM:';
			this._txt_MEM_value.x =
			this._txt_FPS_value.x = 35;
			this._txt_MEM_max.x =
			this._txt_FPS_max.x = 75;
			this._txt_MEM_max.y =
			this._txt_MEM_value.y =
			this._txt_MEM_label.y = 12;
			// добавляем всё это
			super.addChild( this._shape_BG );
			super.addChild( this._shape_FPS );
			super.addChild( this._shape_MEM );
			super.addChild( this._txt_FPS_label );
			super.addChild( this._txt_FPS_value );
			super.addChild( this._txt_FPS_max );
			super.addChild( this._txt_MEM_label );
			super.addChild( this._txt_MEM_value );
			super.addChild( this._txt_MEM_max );
			// меняем размеры
			this.width =	DEFAULT_WIDTH;
			this.height =	DEFAULT_HEIGHT;
			// вешаем листенеры
			super.addEventListener( Event.ADDED_TO_STAGE, this.handler_addToStage, false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE, this.handler_removeFromStage, false, int.MAX_VALUE, true );
			// стартуем отрисовку
			this.refreshTime = 97;
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/override_EventDispatcher.as";
		include "../../../../includes/override_InteractiveObject.as";
		include "../../../../includes/override_DisplayObjectContainer.as";
		include "../../../../includes/override_Sprite.as";

		//--------------------------------------------------------------------------
		//
		//  DisplayObjects
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Фон.
		 */
		private const _shape_BG:Shape = new Shape();

		/**
		 * @private
		 */
		private const _shape_FPS:Shape = new Shape();

		/**
		 * @private
		 */
		private const _shape_MEM:Shape = new Shape();

		/**
		 * @private
		 */
		private const _graphics_FPS:Graphics = ( _shape_FPS ).graphics;

		/**
		 * @private
		 */
		private const _graphics_MEM:Graphics = ( _shape_MEM ).graphics;

		/**
		 * @private
		 */
		private const _txt_FPS_label:TextField = getNewTextField();

		/**
		 * @private
		 */
		private const _txt_FPS_value:TextField = getNewTextField();

		/**
		 * @private
		 */
		private const _txt_FPS_max:TextField = getNewTextField();

		/**
		 * @private
		 */
		private const _txt_MEM_label:TextField = getNewTextField();

		/**
		 * @private
		 */
		private const _txt_MEM_value:TextField = getNewTextField();

		/**
		 * @private
		 */
		private const _txt_MEM_max:TextField = getNewTextField();

		//--------------------------------------------------------------------------
		//
		//  Variblies
		//
		//--------------------------------------------------------------------------

		private const _scrollRect:Rectangle = new Rectangle();

		/**
		 * @private
		 * Таймер для обновления экрана.
		 */
		private const _TIMER:FrameTimer = new FrameTimer( 0 );

		/**
		 * @private
		 * Массив для записи времнной шкалы.
		 */
		private const _TIMES:Array = new Array();

		/**
		 * @private
		 * Массив фпсов для отрисовки.
		 */
		private const _FPS:Array = new Array();

		/**
		 * @private
		 * Предыдущее время.
		 */
		private var _prevTime:uint = 0;

		/**
		 * @private
		 * Предыдущее время.
		 */
		private var _frameRate:uint;

		/**
		 * @private
		 * Использование памяти.
		 */
		private const _MEM:Array = new Array();

		/**
		 * @private
		 * Максимально занято памяти, для отрисовки графика.
		 */
		private var _memMax:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Override properties: DisplayObject
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		public override function get width():Number {
			return this._scrollRect.width;
		}

		/**
		 * @private
		 */
		public override function set width(value:Number):void {
			if ( isNaN( value ) )	throw new ArgumentError();
			else if ( value < 70 )	value = 70;
			if ( this._scrollRect.width == value ) return;
			// меняем ширину
			this._scrollRect.width = value;
			super.scrollRect = this._scrollRect;
			this._shape_BG.width = value;
			// перемещаем зависимые элементы
			this._shape_MEM.x =
			this._shape_FPS.x = value;
			// проверяем видимость
			this._txt_FPS_max.visible =
			this._txt_MEM_max.visible = ( value >= 100 );
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		public override function get height():Number {
			return this._scrollRect.height;
		}

		/**
		 * @private
		 */
		public override function set height(value:Number):void {
			if ( isNaN( value ) )				throw new ArgumentError();
			else if ( value < GRAPH_OFFSET_Y )	value = GRAPH_OFFSET_Y;
			if ( this._scrollRect.height == value ) return;
			// меняем высоту
			this._scrollRect.height = value;
			super.scrollRect = this._scrollRect;
			this._shape_BG.height = value;
			// перемещаем
			this._shape_MEM.y =
			this._shape_FPS.y = value;
			// меняем масштаб
			this._shape_FPS.scaleY = -( value - GRAPH_OFFSET_Y ) / this._frameRate;
			this._shape_MEM.scaleY = -( value - GRAPH_OFFSET_Y ) / ( ( int( this._memMax / 1024 / 1024 / 5 ) + 1 ) * 5 );
			// проверяем видимость
			this._shape_MEM.visible =
			this._shape_FPS.visible = ( value >= 60 );
		}

		//----------------------------------
		//  scaleX
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scaleX():Number {
			return this._shape_BG.scaleX;
		}

		/**
		 * @private
		 */
		public override function set scaleX(value:Number):void {
			this.width = DEFAULT_WIDTH * value;
		}

		//----------------------------------
		//  scaleY
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scaleY():Number {
			return this._shape_BG.scaleY;
		}

		/**
		 * @private
		 */
		public override function set scaleY(value:Number):void {
			this.height = DEFAULT_HEIGHT * value;
		}

		//----------------------------------
		//  opaqueBackground
		//----------------------------------

		/**
		 * @private
		 */
		public override function set opaqueBackground(value:Object):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//----------------------------------
		//  scale9Grid
		//----------------------------------

		/**
		 * @private
		 */
		public override function set scale9Grid(innerRectangle:Rectangle):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//----------------------------------
		//  scrollRect
		//----------------------------------

		/**
		 * @private
		 */
		public override function get scrollRect():Rectangle {
			return null;
		}

		/**
		 * @private
		 */
		public override function set scrollRect(value:Rectangle):void {
			Error.throwError( IllegalOperationError, 3008 );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  refreshTime
		//----------------------------------

		/**
		 * @private
		 */
		private var _refreshTime:uint = 0;

		/**
		 * Скорость обновления экрана в милисикундах.
		 * 
		 * @keyword				activitylistener.refreshtime, refreshtime, refresh, time, delay
		 */
		public function get refreshTime():uint {
			return this._refreshTime;
		}

		/**
		 * @private
		 */
		public function set refreshTime(time:uint):void {
			if ( this._refreshTime == time ) return;
			this._refreshTime = time;
			if ( time > 0 ) {
				this._TIMER.delay = time;
				this._TIMER.start();
				this._TIMER.addEventListener( TimerEvent.TIMER, this.handler_timer );
			} else {
				this._TIMER.removeEventListener( TimerEvent.TIMER, this.handler_timer );
				this._TIMER.stop();
			}
		}

		//----------------------------------
		//  fpsColor
		//----------------------------------

		/**
		 * @private
		 */
		private var _fpsColor:Number = NaN;

		/**
		 * Цвет FPS.
		 * 
		 * @keyword				activitylistener.fpscolor, fpscolor, fps, color
		 */
		public function get fpsColor():uint {
			return this._fpsColor;
		}

		/**
		 * @private
		 */
		public function set fpsColor(value:uint):void {
			if ( this._fpsColor == value ) return;
			this._fpsColor = value;
			this._txt_FPS_label.textColor = value;
			this._txt_FPS_value.textColor = value;
			this._txt_FPS_max.textColor = value;
		}

		//----------------------------------
		//  memoryColor
		//----------------------------------

		/**
		 * @private
		 */
		private var _memColor:Number = NaN;

		/**
		 * Цвет памяти.
		 * 
		 * @keyword				activitylistener.memorycolor, memorycolor, memory, color
		 */
		public function get memoryColor():uint {
			return this._memColor;
		}

		/**
		 * @private
		 */
		public function set memoryColor(value:uint):void {
			if ( this._memColor == value ) return;
			this._memColor = value;
			this._txt_MEM_label.textColor = value;
			this._txt_MEM_value.textColor = value;
			this._txt_MEM_max.textColor = value;
		}

		//----------------------------------
		//  bgColor32
		//----------------------------------

		/**
		 * @private
		 */
		private var _bgColor:Number = NaN;

		/**
		 * Цвет Фона в 32 бита.
		 * 
		 * @keyword				activitylistener.bgcolor32, bgcolor32, color
		 */
		public function get bgColor32():uint {
			return this._bgColor;
		}

		/**
		 * @private
		 */
		public function set bgColor32(value:uint):void {
			if ( this._bgColor == value ) return;
			var alpha:uint = value >> 24 & 0xFF;	// альфа
			var color:uint = value & 0xFFFFFF;		// цвет
			// рисуем бг
			var g:Graphics = this._shape_BG.graphics;
			g.clear();
			g.beginFill( color, alpha / 255 );
			g.drawRect( 0, 0, DEFAULT_WIDTH, DEFAULT_HEIGHT );
			g.endFill();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addToStage(event:Event):void {
			super.mouseEnabled = this.loaderInfo.loaderURL.indexOf( 'file:///' ) != 0;
			// создаём свою менюшку
			// найдём первое родительское меню
			var contextMenu:ContextMenu = ContextMenuUtils.getContextMenu( this, true );
			if ( !contextMenu ) {
				contextMenu = new ContextMenu();
				contextMenu.hideBuiltInItems();
			}
			// вставляем наши элементы
			var item1:ContextMenuItem = new ContextMenuItem( 'ActivityListener' );
			var item2:ContextMenuItem = new ContextMenuItem( '@ 2007 BlooDHounD' );
			item2.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, this.handler_menuItemSelect );
			contextMenu.customItems.unshift( item1, item2 );
			super.contextMenu = contextMenu;
			// найдём сперва тут менюшку что есть выше
			this._prevTime = getTimer();
			super.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @private
		 */
		private function handler_removeFromStage(event:Event):void {
			super.contextMenu = null;
			super.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @private
		 * Обновлялка состояния
		 */
		private function handler_enterFrame(event:Event):void {
			// обработаем FPS
			var time:uint = getTimer();
			this._TIMES.push( time );

			var fps:Number = 1E3 / ( time - this._prevTime );
			this._FPS.push( fps );

			var mem:Number = System.totalMemory / 1024 / 1024;
			this._MEM.push( mem );

			this._prevTime = time;

			// изменился фрэймрайт
			if ( this._frameRate != super.stage.frameRate ) {
				this._frameRate = super.stage.frameRate;
				this._shape_FPS.scaleY = - ( this.height - GRAPH_OFFSET_Y ) / this._frameRate;
				this._txt_FPS_max.text = String( this._frameRate );
			}

			// изменился максимуми памяти
			if ( this._memMax < mem ) {
				this._memMax = mem = ( int( mem / 5 ) + 1 ) * 5;
				this._shape_MEM.scaleY = -( this.height-GRAPH_OFFSET_Y ) / mem;
				this._txt_MEM_max.text = String( mem );
			}

		}

		/**
		 * @private
		 * Обновлялка графики.
		 */
		private function handler_timer(event:TimerEvent):void {
			var time:uint = getTimer();
			// выкинем лишнее из временного интервала
			var l:uint = 0;
			var d:Number = this._scrollRect.width * 10 + 500;
			while ( this._TIMES[l] + d <= time ) {
				++l;
			}
			if ( l>1 ) {
				this._TIMES.splice( 0, l );
				this._FPS.splice( 0, l );
				this._MEM.splice( 0, l );
			} else if ( l>0 ) {
				this._TIMES.shift();
				this._FPS.shift();
				this._MEM.shift();
			}
			// считаем длинну
			l = this._TIMES.length;
			// напишем текста
			this._txt_FPS_value.text = String( uint( this._FPS[l-1] * 10 ) / 10 );
			this._txt_MEM_value.text = String( uint( this._MEM[l-1] * 100 ) / 100 );
			// рисуем графики
			var t:Number;
			var gF:Graphics = this._graphics_FPS;
			var gM:Graphics = this._graphics_MEM;
			gF.clear();
			gM.clear();
			gF.lineStyle( 1, this._fpsColor, 1, false, LineScaleMode.NONE );
			gM.lineStyle( 1, this._memColor, 1, false, LineScaleMode.NONE );
			t = ( time - this._TIMES[0] ) / 10;
			gF.moveTo( t, this._FPS[0] );
			gM.moveTo( t, this._MEM[0] );
			for ( var i:uint = 1; i<l; ++i ) {
				t = ( time - this._TIMES[i] ) / 10;
				gF.lineTo( t, this._FPS[i] );
				gM.lineTo( t, this._MEM[i] );
			}
			gF.lineTo( -5, this._FPS[l-1] );
			gM.lineTo( -5, this._MEM[l-1] );
		}

		/**
		 * @private
		 * Обрабатывался менюшки.
		 */
		private function handler_menuItemSelect(event:ContextMenuEvent):void {
			navigateToURL( new URLRequest( 'http://www.blooddy.by' ), '_blank' );
		}

	}

}