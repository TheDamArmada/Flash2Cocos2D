////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.ProgressBar;
	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.ResourceDefinition;
	
	import flash.events.Event;
	
	import ru.avangardonline.data.character.MinionCharacterData;
	import ru.avangardonline.display.gfx.battle.world.animation.Animation;
	import ru.avangardonline.events.data.character.MinionCharacterDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.08.2009 12:40:03
	 */
	public class MinionCharacterView extends CharacterView {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected static const _ANIM_DEAD:Animation = new Animation( 2, 1, 3 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function MinionCharacterView(data:MinionCharacterData) {
			super( data );
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MAX_VALUE, true );
			this._data = data;
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, MinionCharacterDataEvent.LIVE_CHANGE, this.handler_liveChange );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:MinionCharacterData;

		/**
		 * @private
		 */
		private var _health:ProgressBar;

		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function draw():Boolean {
			if ( !super.draw() ) return false;
			
			this._health = new ProgressBar();
			this._health.indicatorColor32 = new Array( 0xFFFF0000, 0xFFFF0000, 0xFFFFFF00 );
			this._health.width = 30;
			this._health.height = 3;
			this._health.bgColor32 = 0x55000000;
			this._health.x = -Math.round( this._health.width / 2 );
			this._health.y = -90;//15;
			this._health.progressDispatcher = this._data.health;
			this._health.visible = this._data.live;
			super.addChild( this._health );

			return true;
		}

		protected override function clear():Boolean {
			if ( !super.clear() ) return false;

			if ( this._health ) {
				super.removeChild( this._health );
				this._health.progressDispatcher = null;
				this._health = null;
			}

			return true;
		}

		/**
		 * @private
		 */
		protected override function getAnimationDefinition():ResourceDefinition {
			var race:String = this._data.race.toString();
			while ( race.length < 2 ) race = '0' + race;
			var type:String = this._data.type.toString();
			while ( type.length < 2 ) type = '0' + type;
			return new ResourceDefinition( 'lib/display/character/c' + race + type + '.swf', 'x' );
		}

		protected override function getAnimationKey():String {
			return 'c' + String.fromCharCode( this._data.race, this._data.type, this.currentAnim.id );
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
			if ( !this._data.live ) {
				event.stopImmediatePropagation();
			}
		}
		
		/**
		 * @private
		 */
		private function handler_liveChange(event:MinionCharacterDataEvent):void {
			this.setAnimation( this._data.live ? _ANIM_IDLE : _ANIM_DEAD );
			if ( this._health ) {
				this._health.visible = this._data.live;
			}
		}

	}

}
