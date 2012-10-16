////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.BitmapMovieClip;
	import by.blooddy.core.display.StageObserver;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import ru.avangardonline.data.character.CharacterData;
	import ru.avangardonline.display.gfx.battle.world.animation.Animation;
	import ru.avangardonline.display.gfx.battle.world.animation.BattleWorldAnimatedElementView;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	import ru.avangardonline.events.data.character.CharacterInteractionDataEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 22:10:59
	 */
	public class CharacterView extends BattleWorldAnimatedElementView {

		//--------------------------------------------------------------------------
		//
		//  Class variable
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH_ANIM:Object = new Object();

		/**
		 * @private
		 */
		private static const _HASH_USAGE:Object = new Object();
		
		/**
		 * @private
		 */
		protected static const _ANIM_IDLE:Animation =		new Animation();

		/**
		 * @private
		 */
		protected static const _ANIM_MOVE:Animation =		new Animation( 1, 0 );

		/**
		 * @private
		 */
		protected static const _ANIM_ATACK:Animation =		new Animation( 3, 1, 2 );

		/**
		 * @private
		 */
		protected static const _ANIM_DEFENCE:Animation =	new Animation( 4, 1, 1 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function CharacterView(data:CharacterData!) {
			super( data );
			super.addEventListener( Event.COMPLETE, this.handler_complete, false, int.MIN_VALUE, true );
			this._data = data;
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, CharacterInteractionDataEvent.ATACK,				this.handler_atack );
			observer.registerEventListener( data, CharacterInteractionDataEvent.DEFENCE,			this.handler_defence );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_START,		this.handler_movingStart );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_STOP,		this.handler_movingStop );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.handler_coordinateChange );
			this.setAnimation( _ANIM_IDLE );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:CharacterData;

		/**
		 * @private
		 */
		private var _key:String;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function getAnimation():DisplayObject {
			this._key = this.getAnimationKey();
			var result:BitmapMovieClip;
			if ( this._key in _HASH_ANIM ) {
				result = _HASH_ANIM[ this._key ] as BitmapMovieClip;
				if ( result ) {
					result = result.clone();
					_HASH_USAGE[ this._key ]++;
				}
			} else {
				var resource:DisplayObject = super.getAnimation();
				if ( resource ) {
					result = BitmapMovieClip.getAsMovieClip( resource );
					super.trashResource( resource );
				}
				_HASH_ANIM[ this._key ] = result;
				_HASH_USAGE[ this._key ] = 1;
			}
			return result;
		}

		protected virtual function getAnimationKey():String {
			throw new ArgumentError();
		}

		/**
		 * @private
		 */
		protected override function clear():Boolean {
			if ( this.$element ) {
				super.removeChild( this.$element );
				_HASH_USAGE[ this._key ]--;
				if ( !_HASH_USAGE[ this._key ] ) {
					//delete _HASH_USAGE[ this._key ];
					//delete _HASH_ANIM[ this._key ];
					//( this.$element as BitmapMovieClip ).dispose();
				}
				this.$element = null;
			}
			if ( !super.clear() ) return false;
			return true;
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
			this.setAnimation( _ANIM_IDLE );
		}

		/**
		 * @private
		 */
		private function handler_atack(event:CharacterInteractionDataEvent):void {
			this.setAnimation( _ANIM_ATACK );
		}

		/**
		 * @private
		 */
		private function handler_defence(event:CharacterInteractionDataEvent):void {
			this.setAnimation( _ANIM_DEFENCE );
		}

		/**
		 * @private
		 */
		private function handler_movingStart(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_MOVE );
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_IDLE );
		}

		/**
		 * @private
		 */
		private function handler_coordinateChange(event:BattleWorldCoordinateDataEvent):void {
			this.setAnimation( _ANIM_IDLE );
		}

	}

}