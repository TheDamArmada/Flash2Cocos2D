////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.character {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.ResourceDefinition;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.display.gfx.battle.world.animation.Animation;
	import ru.avangardonline.events.data.character.HeroCharacterDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.09.2009 16:13:00
	 */
	public class HeroCharacterView extends CharacterView {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TEXT_FORMAT:TextFormat =		new TextFormat( '_sans', 14, 0xFFFFFF, true, null, null, null, null, 'center' );
		
		/**
		 * @private
		 */
		private static const _TEXT_FILTERS:Array =			new Array( new DropShadowFilter( 2, 45, 0x000000, 1, 3, 3 ) );
		
		/**
		 * @private
		 */
		protected static const _ANIM_LOSE:Animation =		new Animation( 10, 1 );
		
		/**
		 * @private
		 */
		protected static const _ANIM_VICTORY:Animation =	new Animation( 11, 1 );
		
		/**
		 * @private
		 */
		protected static const _ANIM_CAST:Animation =	new Animation( 5, 1 );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function HeroCharacterView(data:HeroCharacterData) {
			super( data );
			this._data = data;
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, HeroCharacterDataEvent.CAST,		this.handler_cast );
			observer.registerEventListener( data, HeroCharacterDataEvent.VICTORY,	this.handler_victory );
			observer.registerEventListener( data, HeroCharacterDataEvent.LOSE,		this.handler_lose );
			observer.registerEventListener( data, HeroCharacterDataEvent.NORMALIZE,	this.handler_normalize );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:HeroCharacterData;

		/**
		 * @private
		 */
		private var _nick:TextField;
		
		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		protected override function draw():Boolean {
			if ( !super.draw() ) return false;
			
			this._nick = new TextField();
			this._nick.width = 120;
			this._nick.multiline = true;
			this._nick.wordWrap = true;
			this._nick.autoSize = TextFieldAutoSize.LEFT;
			this._nick.defaultTextFormat = _TEXT_FORMAT;
			this._nick.filters = _TEXT_FILTERS;
			this._nick.selectable = false;
			this._nick.text = this._data.name;
			super.addChild( this._nick );
			
			this._nick.x = -60;
			this._nick.y = -135 - this._nick.textHeight;

			return true;
		}

		protected override function clear():Boolean {
			if ( !super.clear() ) return false;

			if ( this._nick ) {
				super.removeChild( this._nick );
				this._nick = null;
			}
			
			return true;
		}

		/**
		 * @private
		 */
		protected override function getAnimationDefinition():ResourceDefinition {
			var race:String = this._data.race.toString();
			while ( race.length < 2 ) race = '0' + race;
			var sex:String = ( this._data.sex ? '01' : '00' );
			return new ResourceDefinition( 'lib/display/character/h' + race + sex + '.swf', 'x' );
		}

		protected override function getAnimationKey():String {
			return 'h' + String.fromCharCode( this._data.race, int( this._data.sex ), this.currentAnim.id );
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_cast(event:HeroCharacterDataEvent):void {
			this.setAnimation( _ANIM_CAST );
		}
		
		/**
		 * @private
		 */
		private function handler_victory(event:HeroCharacterDataEvent):void {
			this.setAnimation( _ANIM_VICTORY );
		}
		
		/**
		 * @private
		 */
		private function handler_lose(event:HeroCharacterDataEvent):void {
			this.setAnimation( _ANIM_LOSE );
		}

		/**
		 * @private
		 */
		private function handler_normalize(event:HeroCharacterDataEvent):void {
			this.setAnimation( _ANIM_IDLE );
		}
		
	}

}