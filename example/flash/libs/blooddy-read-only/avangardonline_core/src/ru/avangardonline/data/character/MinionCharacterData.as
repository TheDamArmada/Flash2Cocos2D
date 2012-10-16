////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.character {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataLinker;
	import by.blooddy.core.utils.time.setTimeout;
	
	import ru.avangardonline.data.PointsData;
	import ru.avangardonline.data.battle.world.BattleWorldArrowData;
	import ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent;
	import ru.avangardonline.events.data.character.CharacterInteractionDataEvent;
	import ru.avangardonline.events.data.character.MinionCharacterDataEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="liveChange", type="ru.avangardonline.events.data.character.MinionCharacterDataEvent" )]
	[Event( name="bowAtack", type="ru.avangardonline.events.data.character.CharacterInteractionDataEvent" )]
	[Event( name="addElement", type="ru.avangardonline.events.data.battle.world.BattleWorldTempElementEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.08.2009 22:13:38
	 */
	public class MinionCharacterData extends CharacterData {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public const TYPE_LANCER:uint =		1;
		
		public const TYPE_ARCHER:uint =		2;

		public const TYPE_SWORDSMAN:uint =	3;

		public const TYPE_CAVALRY:uint =	4;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MinionCharacterData(id:uint) {
			super( id );
			DataLinker.link( this, this.health, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Proeprties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  group
		//----------------------------------

		/**
		 * @private
		 */
		private var _type:uint;

		public function get type():uint {
			return this._type;
		}

		/**
		 * @private
		 */
		public function set type(value:uint):void {
			if ( this._type == value ) return;
			this._type = value;
		}

		//----------------------------------
		//  health
		//----------------------------------

		public const health:PointsData = new PointsData();

		//----------------------------------
		//  live
		//----------------------------------

		/**
		 * @private
		 */
		private var _live:Boolean = true;

		public function get live():Boolean {
			return this._live;
		}

		/**
		 * @private
		 */
		public function set live(value:Boolean):void {
			if ( this._live == value ) return;
			this._live = value;
			super.dispatchEvent( new MinionCharacterDataEvent( MinionCharacterDataEvent.LIVE_CHANGE ) );
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'id', 'group', 'type', 'live' );
		}

		public override function clone():Data {
			var result:MinionCharacterData = new MinionCharacterData( super.id );
			result.copyFrom( this );
			return result;
		}

		public override function copyFrom(data:Data):void {
			var target:MinionCharacterData = data as MinionCharacterData;
			if ( !target ) throw new ArgumentError();
			super.copyFrom( target );
			this.type = target._type;
			this.health.copyFrom( target.health );
			this.live = target._live;
		}

		public override function atack(targetID:uint):void {
			super.atack( targetID );
			if ( this._type == TYPE_ARCHER ) {
				setTimeout(
					super.dispatchEvent,
					300,
					new BattleWorldTempElementEvent(
						BattleWorldTempElementEvent.ADD_ELEMENT,
						true,
						false,
						new BattleWorldArrowData( super.id, targetID )
					)
				);
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function changeLiveStatus(live:Boolean):void {
			this.live = live;
		}

		public function incHealth(health:int):void {
			this.health.current += health;
		}

	}

}