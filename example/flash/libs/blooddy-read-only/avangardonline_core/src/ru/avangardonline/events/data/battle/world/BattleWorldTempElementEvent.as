////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.events.data.battle.world {

	import by.blooddy.core.events.data.DataBaseEvent;
	
	import flash.events.Event;
	
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					16.09.2009 19:48:23
	 */
	public class BattleWorldTempElementEvent extends DataBaseEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ADD_ELEMENT:String =	'addElement';

		public static const REMOVE_ELEMENT:String =	'removeElement';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldTempElementEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, element:BattleWorldAbstractElementData=null) {
			super( type, bubbles, cancelable );
			this.element = element;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var element:BattleWorldAbstractElementData;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function clone():Event {
			return new BattleWorldTempElementEvent( super.type, super.bubbles, super.cancelable, this.element );
		}

		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( null, 'type', 'bubbles', 'cancelable', 'element' );
		}

	}

}