////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers {

	import by.blooddy.core.utils.ClassUtils;
	
	import flash.display.InteractiveObject;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.KeyLocation;
	import flash.utils.Dictionary;

	//--------------------------------------
	//  Events
	//--------------------------------------

	/**
	 * Транслируется, при опускании кнопки.
	 *
	 * @eventType			flash.events.KeyboardEvent.KEY_DOWN
	 */
	[Event( name="keyDown", type="flash.events.KeyboardEvent" )]

	/**
	 * Транслируется, при подъёме кнопки.
	 *
	 * @eventType			flash.events.KeyboardEvent.KEY_UP
	 */
	[Event( name="keyUp", type="flash.events.KeyboardEvent" )]

	/**
	 * Глобальный следитель, за нажиманием и отпусканием клавиш.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					keyboardmanager, keyboard, manager
	 */
	public class KeyboardManager extends EventDispatcher {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static var _privateCall:Boolean = false;

		/**
		 * @private
		 */
		private static const _HASH:Dictionary = new Dictionary( true );
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		public static function getManager(container:InteractiveObject):KeyboardManager {
			var manager:KeyboardManager = _HASH[ container ];
			if ( !manager ) {
				_privateCall = true;
				_HASH[ container ] = manager = new KeyboardManager( container );
			}
			return manager;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Преобразовывает нажатые клавиши в уникальный код.
		 *  
		 * @param	type				Тип евента.
		 * @param	keyCode				Код клавишы.
		 * @param	keyLocation			Часть клавы.
		 * @param	ctrlKey				Зажат ти контрол?
		 * @param	altKey				Зажат ти альт?
		 * @param	shiftKey			Зажат ти шифт?
		 * 
		 * @return						Код события.
		 * 
		 * @keyword						keyboardmanager.getkeyeventcode, getkeyeventcode
		 */
		private static function getKeyEventCode(type:String, keyCode:uint, keyLocation:uint=0, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false):uint {
			var eventCode:uint =				keyCode;
			if ( shiftKey )						eventCode |= 1 << 8;
			if ( altKey )						eventCode |= 1 << 9;
			if ( ctrlKey )						eventCode |= 1 << 10;
			switch ( type ) {
				case KeyboardEvent.KEY_DOWN:	eventCode |= 1 << 11;	break;
			}
			switch ( keyLocation ) {
				case KeyLocation.NUM_PAD:		eventCode |= 1 << 12;	break;
				case KeyLocation.LEFT:			eventCode |= 1 << 13;	break;
				case KeyLocation.RIGHT:			eventCode |= 1 << 14;	break;
			}
			return eventCode;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Constructor
		 * @param	control				Объект для слежки нажатий вяких кнопочек.
		 */
		public function KeyboardManager(control:InteractiveObject) {
			if ( !_privateCall ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super();
			_privateCall = false;
			control.addEventListener( KeyboardEvent.KEY_DOWN, this.$dispatchEvent, false, int.MAX_VALUE );
			control.addEventListener( KeyboardEvent.KEY_UP, this.$dispatchEvent, false, int.MAX_VALUE );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Сюда сохроняем предыщий код, что бы при удержании клавиши, событие не
		 * транслировалось постоянно.
		 */
		private var _prev:uint;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: EventDispatcher
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Если надо транслировать KeyboardEvent, то делаем хук и транслируем 2 события.
		 */
		public override function dispatchEvent(event:Event):Boolean {
			return this.$dispatchEvent( event );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Вешает событие, на нажатие комбинаций клавиш.
		 * 
		 * @param	type				Тип евента.
		 * @param	listener			Функа для добавления в таблицу.
		 * @param	useCapture			Капчуфаза.
		 * @param	priority			Приоритет.
		 * @param	useWeakReference	Мягкая привязка.
		 * @param	keyCode				Код клавишы.
		 * @param	keyLocation			Часть клавы.
		 * @param	ctrlKey				Зажат ти контрол?
		 * @param	altKey				Зажат ти альт?
		 * @param	shiftKey			Зажат ти шифт?
		 * 
		 * @keyword						keyboardmanager.addkeyboardeventlistener, addkeyboardeventlistener
		 * 
		 * @see							#addEventListener()
		 */
		public function addKeyboardEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false, keyCode:uint=0, keyLocation:uint=0, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false):void {
			var eventCode:String = getKeyEventCode( type, keyCode, keyLocation, ctrlKey, altKey, shiftKey ).toString();
			super.addEventListener( eventCode, listener, useCapture, priority, useWeakReference );
		}

		/**
		 * Удаляет событие, на нажатие комбинаций клавиш.
		 * 
		 * @param	type				Тип евента.
		 * @param	listener			Функа для удаления из таблицы.
		 * @param	keyCode				Код клавишы.
		 * @param	keyLocation			Часть клавы.
		 * @param	ctrlKey				Зажат ли контрол?
		 * @param	altKey				Зажат ли альт?
		 * @param	shiftKey			Зажат ли шифт?
		 * 
		 * @keyword						keyboardmanager.removekeyboardeventlistener, removekeyboardeventlistener
		 * 
		 * @see							flash.events.EventDispatcher#removeEventListener()
		 */
		public function removeKeyboardEventListener(type:String, listener:Function, useCapture:Boolean=false, keyCode:uint=0, keyLocation:uint=0, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false):void {
			var eventCode:String = getKeyEventCode( type, keyCode, keyLocation, ctrlKey, altKey, shiftKey ).toString();
			super.removeEventListener( eventCode, listener, useCapture );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Если надо транслировать KeyboardEvent, то делаем хук и транслируем 2 события.
		 */
		private function $dispatchEvent(event:Event):Boolean {
			if ( event is KeyboardEvent ) {
				var e:KeyboardEvent = event as KeyboardEvent;
				var eventCode:uint = getKeyEventCode( e.type, e.keyCode, e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey );
				if ( event.target is InteractiveObject && this._prev == eventCode ) return true; // ну скока можно???
				this._prev = eventCode;
				var type:String = eventCode.toString();
				if ( super.hasEventListener( type ) ) {
					return super.dispatchEvent( new $KeyboardEvent( type, e.bubbles, e.cancelable, e.charCode ) );
				}
			}
			return super.dispatchEvent( event );
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.KeyLocation;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: $KeyboardEvent
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 * 
 * Создаёт KeyboardEvent из числового кода.
 * type - Хук на числовой тип.
 * 
 * @author					BlooDHounD
 */
internal final class $KeyboardEvent extends KeyboardEvent {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
		 * Constructor
	 */
	public function $KeyboardEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, charCode:uint=0) {
		var eventCode:uint = parseInt( type );
		// конструкруируем
		super( type, bubbles, cancelable, charCode,
			// keyCode
			eventCode & 255,
			// keyLocation
			( eventCode & 1 << 12 ? KeyLocation.NUM_PAD :
				( eventCode & 1 << 13 ? KeyLocation.LEFT :
					( eventCode & 1 << 14 ? KeyLocation.RIGHT : 
						KeyLocation.STANDARD
					)
				)
			),
			// ctrlKey
			Boolean( eventCode & 1 << 10 ),
			// altKey
			Boolean( eventCode & 1 << 9 ),
			// shiftKey
			Boolean( eventCode & 1 << 8 )
		);
		// сохроняем тип для переопределения
		this._type = ( eventCode & 1 << 11 ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP );
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private var _type:String;

	/**
	 * @private
	 * Переопределяем тип, для того что бы в евенте мы видели настоящий тип, а не числовой код.
	 */
	public override function get type():String {
		return this._type;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public override function clone():Event {
		return new $KeyboardEvent( super.type, super.bubbles, super.cancelable, super.charCode );
	}

}