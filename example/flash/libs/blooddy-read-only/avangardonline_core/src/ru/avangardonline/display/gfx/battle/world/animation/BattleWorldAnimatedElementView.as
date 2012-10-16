////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world.animation {

	import by.blooddy.core.display.resource.ResourceDefinition;
	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.utils.time.FrameTimer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import ru.avangardonline.data.battle.turns.BattleTurnData;
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.display.gfx.battle.world.BattleWorldElementView;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.08.2009 11:45:10
	 */
	public class BattleWorldAnimatedElementView extends BattleWorldElementView {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldAnimatedElementView(data:BattleWorldAbstractElementData!) {
			super( data );
			this._data = data;
			this._timer.addEventListener( TimerEvent.TIMER,	this.drawFrame, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldAbstractElementData;

		/**
		 * @private
		 */
		private const _timer:FrameTimer = new FrameTimer( 0 );

		/**
		 * @private
		 */
		private var _startTime:uint;

		/**
		 * @private
		 */
		private var _animation:MovieClip;

		/**
		 * @private
		 */
		private var _currentAnim_count:uint = 0;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _currentAnim:Animation;

		protected function get currentAnim():Animation {
			return this._currentAnim;
		}

		/**
		 * @private
		 */
		private var _animationSpeed:Number = 1;
		
		protected function getAnimationSpeed():Number {
			return ( this._data.moving ? this._data.speed : 1 );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function getResourceBundles():Array {
			var definition:ResourceDefinition = this.getAnimationDefinition();
			if ( definition ) {
				return new Array( definition.bundleName );
			}
			return null;
		}

		/**
		 * @private
		 */
		protected override function draw():Boolean {
			if ( !super.stage || !this._currentAnim ) return false;
			var t:Boolean = true;
			super.lockResourceBundle( this.getAnimationDefinition().bundleName );
			this.$element = this.getAnimation();
			this._data.world.time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
			if ( this.$element ) {
				super.addChild( this.$element );
				if ( this.$element is MovieClip && ( this.$element as MovieClip ).totalFrames > 1 ) {
					this._data.world.time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
					this._animation = this.$element as MovieClip;
					this._animationSpeed = this.getAnimationSpeed();
					if ( this._animationSpeed > 0 ) {
						this.updateDelay();
						this._timer.start();
					}
					this.drawFrame();
					t = false;
				}
				super.updateRotation();
			}
			if ( t && this._currentAnim.repeatCount > 0 ) { // если текущая не вечна
				super.dispatchEvent( new Event( Event.COMPLETE ) );
			}
			return true;
		}

		/**
		 * @private
		 */
		protected override function clear():Boolean {
			super.unlockResourceBundle( this.getAnimationDefinition().bundleName );
			this._data.world.time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
			if ( this.$element ) {
				this.trashResource( this.$element );
				this.$element = null;
			}
			this._timer.stop();
			return true;
		}
		
		protected virtual function getAnimationDefinition():ResourceDefinition {
			throw new IllegalOperationError();
		}

		protected function getAnimation():DisplayObject {
			var definition:ResourceDefinition = this.getAnimationDefinition();
			return super.getDisplayObject( definition.bundleName, definition.resourceName + this._currentAnim.id );
		}

		protected function setAnimation(anim:Animation):void {
			if ( this._currentAnim && anim && this._currentAnim.priority > anim.priority ) return;
			this._currentAnim = anim;
			this._startTime = this._data.world.time.currentTime;
			if ( super.hasManager() ) super.invalidate();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handler
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function drawFrame(event:Event=null):Boolean {
			
			if ( !this._animation ) throw new IllegalOperationError();
			
			var totalFrames:int = this._animation.totalFrames;
			var time:Number = BattleTurnData.TURN_LENGTH / ( this._animationSpeed || 1 );
			
			var currentTime:Number = this._data.world.time.currentTime;
			if ( currentTime < this._startTime ) this._startTime = currentTime;
			
			var timesCount:Number = ( currentTime - this._startTime ) / time;
			var currentFrame:uint = Math.round( timesCount * ( totalFrames - 1 ) ) % totalFrames + 1;
			
			this._currentAnim_count = timesCount;
			
			this._animation.gotoAndStop( currentFrame );
			
			// если текущая анимация закончилась
			if ( this._currentAnim.repeatCount > 0 && this._currentAnim_count >= this._currentAnim.repeatCount ) {
				this._data.world.time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.updateDelay );
				this._currentAnim = null;
				this._currentAnim_count = 0;
				this._timer.stop();
				this._animation.gotoAndStop( this._animation.totalFrames );
				super.dispatchEvent( new Event( Event.COMPLETE ) );
			}			
			
			return true;
		}

		/**
		 * @private
		 */
		private function updateDelay(event:Event=null):void {
			if ( this._animationSpeed > 0 && this.$element is MovieClip && ( this.$element as MovieClip ).totalFrames > 1 ) {
				this._timer.delay = BattleTurnData.TURN_LENGTH / this._animationSpeed / ( this.$element as MovieClip ).totalFrames * 0.7;
			}
		}

	}

}