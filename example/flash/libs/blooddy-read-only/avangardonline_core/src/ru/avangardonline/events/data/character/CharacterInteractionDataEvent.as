////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.events.data.character {

	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.09.2009 14:15:33
	 */
	public class CharacterInteractionDataEvent extends HeroCharacterDataEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const ATACK:String =		'atack';

		public static const DEFENCE:String =	'defence';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterInteractionDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, targetID:uint=0) {
			super( type, bubbles, cancelable );
			this.targetID = targetID;
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public var targetID:uint;

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new CharacterInteractionDataEvent( super.type, super.bubbles, super.cancelable, this.targetID );
		}

		public override function toString():String {
			return super.formatToString( null, 'type', 'bubbles', 'cancelable', 'targetID' );
		}

	}

}