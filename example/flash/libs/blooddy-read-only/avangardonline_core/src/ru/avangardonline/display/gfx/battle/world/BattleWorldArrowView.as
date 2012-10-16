////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import ru.avangardonline.data.battle.world.BattleWorldArrowData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.09.2009 15:51:11
	 */
	public class BattleWorldArrowView extends BattleWorldElementView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldArrowView(data:BattleWorldArrowData!) {
			super( data );
			this._data = data;
			super.addEventListener( ResourceEvent.ADDED_TO_MANAGER,		this.handler_addedToManager, false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER,	this.handler_removedFromManager, false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_START, this.handler_movingStart );
			observer.registerEventListener( data, BattleWorldCoordinateDataEvent.MOVING_STOP, this.handler_movingStop );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldArrowData;
		
		//--------------------------------------------------------------------------
		//
		//  Protected overriden methods
		//
		//--------------------------------------------------------------------------

		protected override function getResourceBundles():Array {
			return new Array( 'lib/display/world/arrow.swf' );
		}
		
		/**
		 * @private
		 */
		protected override function draw():Boolean {
			this.$element = super.getDisplayObject( 'lib/display/world/arrow.swf', 'arrow' );
			if ( this.$element ) {
				super.addChild( this.$element );
				super.updateRotation();
			}
			return true;
		}

		/**
		 * @private
		 */
		protected override function clear():Boolean {
			if ( this.$element ) {
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
		private function handler_addedToManager(event:Event):void {
			if ( this._data.moving ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromManager(event:Event):void {
			if ( this._data.moving ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}
		
		/**
		 * @private
		 */
		private function handler_movingStart(event:BattleWorldCoordinateDataEvent):void {
			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			if ( !this.$element ) return;
			if ( this.$element is MovieClip ) {
				var mc:MovieClip = this.$element as MovieClip;
				mc.gotoAndStop( Math.round( this._data.coord.progress * ( mc.totalFrames - 1 ) ) + 1 );
			}
			var p:Number = ( this._data.coord.progress - 0.5 ) * 2;
			this.$element.y = -60 - 20 * ( this._data.coord.distance - 1 ) * ( 1 - p * p );
		}
		
	}

}