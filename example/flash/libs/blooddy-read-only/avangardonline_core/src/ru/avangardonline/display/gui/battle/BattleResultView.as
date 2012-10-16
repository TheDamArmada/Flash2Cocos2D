////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gui.battle {
	
	import by.blooddy.core.display.resource.LoadableResourceSprite;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import ru.avangardonline.data.battle.result.BattleResultData;
	import ru.avangardonline.data.battle.result.BattleResultElementData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.11.2009 17:30:23
	 */
	public class BattleResultView extends LoadableResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleResultView(result:BattleResultData, hero:HeroCharacterData=null, type:uint=0) {
			super();
			this._type = type;
			this._hero = hero
			this._result = result;
		}

		//--------------------------------------------------------------------------
		//
		//  Private variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _type:uint;
		
		/**
		 * @private
		 */
		private var _hero:HeroCharacterData;

		/**
		 * @private
		 */
		private var _result:BattleResultData;

		/**
		 * @private
		 */
		private var _element:DisplayObject;

		/**
		 * @private
		 */
		private var _img:MovieClip;
		
		/**
		 * @private
		 */
		private var _txt_result:TextField;

		/**
		 * @private
		 */
		private var _txt_exp:TextField;
		
		/**
		 * @private
		 */
		private var _txt_v1:TextField;
		
		/**
		 * @private
		 */
		private var _txt_v2:TextField;
		
		/**
		 * @private
		 */
		private var _txt_v3:TextField;

		/**
		 * @private
		 */
		private var _btn_replay:InteractiveObject;
		
		/**
		 * @private
		 */
		private var _btn_continue:InteractiveObject;
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function getResourceBundles():Array {
			return new Array( 'lib/display/gui/battle_result.swf' );
		}

		/**
		 * @private
		 */
		protected override function draw():Boolean {

			this._element = super.getDisplayObject( 'lib/display/gui/battle_result.swf', 'result_' + this._type );
			if ( this._element ) {
				if ( this._element is DisplayObjectContainer ) {
					var cont:DisplayObjectContainer = this._element as DisplayObjectContainer;
					this._img =				cont.getChildByName( 'img' ) as MovieClip;
					this._txt_result =		cont.getChildByName( 'txt_result' ) as TextField;
					this._txt_exp =			cont.getChildByName( 'txt_exp' ) as TextField;
					this._txt_v1 =			cont.getChildByName( 'txt_v1' ) as TextField;
					this._txt_v2 =			cont.getChildByName( 'txt_v2' ) as TextField;
					this._txt_v3 =			cont.getChildByName( 'txt_v3' ) as TextField;
					this._btn_replay =		cont.getChildByName( 'btn_replay' ) as InteractiveObject;
					this._btn_continue =	cont.getChildByName( 'btn_continue' ) as InteractiveObject;
				}
				var rect:Rectangle = super.getBounds( null );
				this._element.x = super.stage.stageWidth / 2 + rect.x - rect.width / 2;
				this._element.y = super.stage.stageHeight / 2 + rect.y - rect.height / 2;
				super.addChild( this._element );
			}

			if ( this._hero ) {
				if ( this._img ) {
					this._img.gotoAndStop( ( this._hero.race - 1 ) * 3 + ( this._result.group == this._hero.group ? 0 : 1 ) + 1 );
				}
				if ( this._txt_result ) {
					this._txt_result.text = ( this._result.group == this._hero.group ? 'ВЫ ПОБЕДИЛИ !' : 'ВЫ ПРОИГРАЛИ !' );
				}
				var element:BattleResultElementData = this._result.getElement( this._hero.group );
				if ( element ) {
					if ( this._txt_exp )		this._txt_exp.text = ( element.experience > 0 ? '+' : '' ) + element.experience;
					if ( this._txt_v1 )			this._txt_v1.text = ( element.values[0] > 0 ? '+' : '' ) + element.values[0];
					if ( this._txt_v2 )			this._txt_v2.text = ( element.values[1] > 0 ? '+' : '' ) + element.values[1];
					if ( this._txt_v3 )			this._txt_v3.text = ( element.values[2] > 0 ? '+' : '' ) + element.values[2];
				}
			} else {
				if ( this._img ) {
					this._img.visible = false;
				}
				if ( this._txt_result ) {
					this._txt_result.text = 'БОЙ ОКОНЧЕН';
				}
			}
			if ( this._btn_continue )	this._btn_continue.addEventListener( MouseEvent.CLICK, this.handler_continue_click );
			if ( this._btn_replay )		this._btn_replay.addEventListener( MouseEvent.CLICK, this.handler_replay_click );

			return true;
		}
		
		/**
		 * @private
		 */
		protected override function clear():Boolean {
			if ( this._element ) {
				if ( this._img )			this._img.visible = true;
				if ( this._txt_exp )		this._txt_exp.text = '';
				if ( this._txt_v1 )			this._txt_v1.text = '';
				if ( this._txt_v2 )			this._txt_v2.text = '';
				if ( this._txt_v3 )			this._txt_v3.text = '';
				if ( this._btn_continue )	this._btn_continue.removeEventListener( MouseEvent.CLICK, this.handler_continue_click );
				if ( this._btn_replay )		this._btn_replay.removeEventListener( MouseEvent.CLICK, this.handler_replay_click );
				this._txt_result =		null;
				this._txt_exp =			null;
				this._txt_v1 =			null;
				this._txt_v2 =			null;
				this._txt_v3 =			null;
				this._btn_replay =		null;
				this._btn_continue =	null;
				this.trashResource( this._element );
				this._element = null;
			}
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
		private function handler_continue_click(event:MouseEvent):void {
			super.dispatchEvent( new Event( 'continue' ) );
		}
		
		/**
		 * @private
		 */
		private function handler_replay_click(event:MouseEvent):void {
			super.dispatchEvent( new Event( 'replay' ) );
		}

	}
	
}