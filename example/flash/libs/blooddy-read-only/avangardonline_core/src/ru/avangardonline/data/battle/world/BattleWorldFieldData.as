////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	
	import ru.avangardonline.data.IClonableData;
	import ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent;

	/**
	 * @eventType			ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent.WIDTH_CHANGE
	 */
	[Event( name="widthChange", type="ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent" )]

	/**
	 * @eventType			ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent.HEIGHT_CHANGE
	 */
	[Event( name="heightChange", type="ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 11:22:18
	 */
	public class BattleWorldFieldData extends Data implements IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldFieldData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		private var _width:uint

		public function get width():uint {
			return this._width;
		}

		/**
		 * @private
		 */
		public function set width(value:uint):void {
			if ( this._width == value ) return;
			this._width = value;
			if ( super.hasEventListener( BattleWorldFieldDataEvent.WIDTH_CHANGE ) ) {
				super.dispatchEvent( new BattleWorldFieldDataEvent( BattleWorldFieldDataEvent.WIDTH_CHANGE ) );
			}
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		private var _height:uint

		public function get height():uint {
			return this._height;
		}

		/**
		 * @private
		 */
		public function set height(value:uint):void {
			if ( this._height == value ) return;
			this._height = value;
			if ( super.hasEventListener( BattleWorldFieldDataEvent.HEIGHT_CHANGE ) ) {
				super.dispatchEvent( new BattleWorldFieldDataEvent( BattleWorldFieldDataEvent.HEIGHT_CHANGE ) );
			}
		}

		//----------------------------------
		//  type
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _type:uint
		
		public function get type():uint {
			return this._type;
		}
		
		/**
		 * @private
		 */
		public function set type(value:uint):void {
			if ( this._type == value ) return;
			this._type = value;
			if ( super.hasEventListener( BattleWorldFieldDataEvent.TYPE_CHANGE ) ) {
				super.dispatchEvent( new BattleWorldFieldDataEvent( BattleWorldFieldDataEvent.TYPE_CHANGE ) );
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'width', 'height', 'type' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:BattleWorldFieldData = new BattleWorldFieldData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldFieldData = data as BattleWorldFieldData;
			if ( !target ) throw new ArgumentError();
			this.width = target._width;
			this.height = target._height;
			this.type = target._type;
		}

	}

}