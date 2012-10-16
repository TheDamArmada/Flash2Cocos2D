////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events {

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import by.blooddy.core.meta.TypeInfo;

	/**
	 * Функция проверяет произвольное событие произвольным экземпляром ксласса. 
	 * 
	 * @param	dispatcher		экземпляр
	 * @param	event			событие
	 * 
	 * @return					true, если событие диспатчится, false, если нет.
	 * 
	 * @author					BlooDHounD
	 */
	public function isIntrinsicEvent(dispatcher:IEventDispatcher, event:Event):Boolean {
		var info:EventDispatcherInfo = EventDispatcherInfo.getInfo( TypeInfo.getInfo( dispatcher ) );
		if ( info ) return info.hasEvent( event );
		return false;
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.meta.TypeInfo;

import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: EventDispatcherInfo
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
internal final class EventDispatcherInfo {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public static function getInfo(info:TypeInfo):EventDispatcherInfo {
		var result:EventDispatcherInfo;
		if ( result ) {
			result = _HASH[ info ];
			if ( !result ) {
				_HASH[ info ] = result = new EventDispatcherInfo();
				result.parseInfo( info );
			}
		}
		return result;
	}

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
	private static const _NAME_EVENT_DISPATCHER:String = getQualifiedClassName( IEventDispatcher );

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor
	 */
	public function EventDispatcherInfo() {
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
	private const _events:Object = new Object();

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	public function hasEvent(event:Event):Boolean {
		return event.type in this._events;
	}

	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private function parseInfo(info:TypeInfo):void {
		if ( info.parent && info.parent.hasInterface( _NAME_EVENT_DISPATCHER ) ) {
			var events:Object = getInfo( info.parent )._events;
			for ( var key:Object in events ) {
				this._events[ key ] = true;
			}
		}
		var list:XMLList = info.getMetadata( true ).( @name == 'Event' );
		var arg:XML, name:String;
		for each ( var xml:XML in list ) {
			list = xml.arg;
			arg = list.( @key == 'name' );
			if ( arg.length() > 0 ) {
				name = arg[ 0 ].@value.toString();
				if ( name ) {
					this._events[ name ] = true;
				}
			}
		}
	}

}