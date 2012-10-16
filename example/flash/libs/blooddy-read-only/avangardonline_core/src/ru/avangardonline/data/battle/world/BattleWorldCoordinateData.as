////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.events.time.TimeEvent;
	import by.blooddy.core.net.loading.IProgressable;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	import by.blooddy.core.utils.time.Time;
	
	import flash.events.Event;
	
	import ru.avangardonline.data.IClonableData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	import ru.avangardonline.events.data.battle.world.BattleWorldDataEvent;

	//--------------------------------------
	//  Events
	//--------------------------------------

	[Event( name="coordinateChange", type="ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent" )]
	[Event( name="movingStart", type="ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent" )]
	[Event( name="movingStop", type="ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * @created					06.08.2009 21:19:36
	 */
	public class BattleWorldCoordinateData extends BattleWorldAssetData implements IProgressable, IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		public function BattleWorldCoordinateData() {
			super();
			super.addEventListener( BattleWorldDataEvent.ADDED_TO_WORLD,		this.handler_addedToWorld,		false, int.MAX_VALUE, true );
			super.addEventListener( BattleWorldDataEvent.REMOVED_FROM_WORLD,	this.handler_removedFromWorld,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _time:Time;

		/**
		 * @private
		 */
		private var _time_start:Number;

		/**
		 * @private
		 */
		private var _time_range:Number;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _moving:Boolean = false;

		public function get moving():Boolean {
			return this._moving;
		}

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _direction:Number = 360 * Math.random();

		public function get direction():Number {
			return this._direction;
		}

		//----------------------------------
		//  speed
		//----------------------------------

		/**
		 * @private
		 */
		private var _speed:Number = 0;

		public function get speed():Number {
			return this._speed;
		}

		//----------------------------------
		//  x
		//----------------------------------

		/**
		 * @private
		 */
		private var _x_range:Number;

		/**
		 * @private
		 */
		private var _x_start:Number;

		/**
		 * @private
		 */
		private var _x:Number = 0;

		public function get x():Number {
			return this._x;
		}

		/**
		 * @private
		 */
		public function set x(value:Number):void {
			this.stop();
			if ( this._x == value ) return;
			this._x = value;
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE ) );
		}

		//----------------------------------
		//  y
		//----------------------------------

		/**
		 * @private
		 */
		private var _y_range:Number;

		/**
		 * @private
		 */
		private var _y_start:Number;

		/**
		 * @private
		 */
		private var _y:Number = 0;

		public function get y():Number {
			return this._y;
		}

		/**
		 * @private
		 */
		public function set y(value:Number):void {
			this.stop();
			if ( this._y == value ) return;
			this._y = value;
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE ) );
		}

		//----------------------------------
		//  distance
		//----------------------------------

		/**
		 * @private
		 */
		private var _distance:Number;
		
		public function get distance():Number {
			return this._distance;
		}
		
		//----------------------------------
		//  progress
		//----------------------------------

		/**
		 * @private
		 */
		private var _progress:Number = 1;
		
		public function get progress():Number {
			return this._progress;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:BattleWorldCoordinateData = new BattleWorldCoordinateData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldCoordinateData = data as BattleWorldCoordinateData;
			if ( !target ) throw new ArgumentError();
			this.setValues( target._x, target._y );
			if ( target._moving ) {
				this._x_start =		target._x_start;
				this._y_start =		target._y_start;
				this._time_start =	target._time_start;
				this.$moveTo(
					this._x_start + target._x_range,
					this._y_start + target._y_range,
					this._time_start + target._time_range
				);
			}
		}

		public function setValues(x:Number, y:Number):void {
			this.stop();
			if ( this._x == x && this._y == y ) return;
			this._x = x;
			this._y = y;
			super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.COORDINATE_CHANGE ) );
		}

		public override function toLocaleString():String {
			return super.formatToString( 'x', 'y' );
		}

		public function moveTo(x:Number, y:Number, time:Number):void {
			this._time_start =	this._time.currentTime;
			if ( this._time_start < time ) {
				if ( this._x != x || this._y != y ) {
					this._x_start =		this._x;
					this._y_start =		this._y;
					this.$moveTo( x, y, time );
				}
			} else {
				this.setValues( x, y );
			}
		}

		/**
		 * @private
		 */
		private function $moveTo(x:Number, y:Number, time:Number):void {
			if ( !this._time ) throw new ArgumentError();

			// подписываемся на собтиео бновления
			this._time.addEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );

			enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.update, false, int.MAX_VALUE );

			this._x_range =		x -		this._x_start;
			this._y_range =		y -		this._y_start;
			this._time_range =	time -	this._time_start;

			this._distance =	Math.sqrt( this._x_range * this._x_range + this._y_range * this._y_range );
			this._speed =		this._distance / ( this._time_range / 1E3 );

			if ( this._speed > 0 ) {
				this._direction =	Math.atan2( this._y_range, this._x_range ) * 180 / Math.PI % 360;
				if ( this._direction < 0 ) this._direction += 360;
			}

			if ( !this._moving ) {
				this._moving = true;
				super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.MOVING_START ) );
			}

			this.update();

		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function stop():void {
			if ( this._moving ) {
				this._distance = 0;
				this._speed = 0;
				this._moving = false;
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.update );
				this._time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
				super.dispatchEvent( new BattleWorldCoordinateDataEvent( BattleWorldCoordinateDataEvent.MOVING_STOP ) );
			}
		}

		/**
		 * @private
		 */
		private function update(event:Event=null):void {
			this._progress = Math.min( Math.max( 0, ( this._time.currentTime - this._time_start ) / this._time_range ), 1 );
			this._x = this._x_start + this._x_range * this._progress;
			this._y = this._y_start + this._y_range * this._progress;
			if ( this._progress == 1 ) this.stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToWorld(event:BattleWorldDataEvent):void {
			this._time = super.world.time;
		}

		/**
		 * @private
		 */
		private function handler_removedFromWorld(event:BattleWorldDataEvent):void {
			this._time.removeEventListener( TimeEvent.TIME_RELATIVITY_CHANGE, this.handler_timeRelativityChange );
			this._time = null;
		}

		/**
		 * @private
		 */
		private function handler_timeRelativityChange(event:TimeEvent):void {
			this._time_start += event.delta;
			if ( this._moving ) this.update( event );
		}

	}

}