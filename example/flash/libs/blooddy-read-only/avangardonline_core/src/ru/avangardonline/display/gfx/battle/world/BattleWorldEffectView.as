////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import ru.avangardonline.data.battle.world.BattleWorldEffectData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					30.07.2010 3:25:46
	 */
	public class BattleWorldEffectView extends BattleWorldElementView {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleWorldEffectView(data:BattleWorldEffectData) {
			super( data );
			this._data = data;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _data:BattleWorldEffectData;
		
		//--------------------------------------------------------------------------
		//
		//  Protected overriden methods
		//
		//--------------------------------------------------------------------------
		
		protected override function getResourceBundles():Array {
			return new Array( 'lib/display/world/e' + this._data.type + '.swf' );
		}
		
		/**
		 * @private
		 */
		protected override function draw():Boolean {
			this.$element = super.getDisplayObject( 'lib/display/world/e' + this._data.type + '.swf', 'effect' );
			if ( this.$element ) {
				super.addChild( this.$element );
				super.updateRotation();
				if ( this.$element is MovieClip ) {
					super.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
				}
			}
			return true;
		}
		
		/**
		 * @private
		 */
		protected override function clear():Boolean {
			if ( this.$element ) {
				if ( this.$element is MovieClip ) {
					super.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
				}
				super.trashResource( this.$element );
				this.$element = null;
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
		private function handler_enterFrame(event:Event):void {
			var mc:MovieClip = this.$element as MovieClip;
			if ( mc.currentFrame == mc.totalFrames ) {
				this.clear();
			}
		}
		
	}
	
}