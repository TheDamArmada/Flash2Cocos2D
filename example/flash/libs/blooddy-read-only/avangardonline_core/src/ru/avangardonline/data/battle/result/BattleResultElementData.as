////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.result {
	
	import by.blooddy.core.data.Data;
	
	import ru.avangardonline.data.IClonableData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.11.2009 22:46:25
	 */
	public class BattleResultElementData extends Data implements IClonableData {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function BattleResultElementData(group:uint) {
			super();
			this._group = group;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  group
		//----------------------------------

		/**
		 * @private
		 */
		private var _group:uint = 0;

		public function get group():uint {
			return this._group;
		}

		//----------------------------------
		//  experience
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _experience:uint = 0;
		
		public function get experience():uint {
			return this._experience;
		}
		
		/**
		 * @private
		 */
		public function set experience(value:uint):void {
			if ( this._experience == value ) return;
			this._experience = value;
		}
		
		//----------------------------------
		//  experience
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _values:Vector.<int>;
		
		public function get values():Vector.<int> {
			return ( this._values ? this._values.slice() : null );
		}
		
		/**
		 * @private
		 */
		public function set values(value:Vector.<int>):void {
			if ( this._values == value ) return;
			this._values = ( value ? value.slice() : null );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'group', 'experience', 'values' );
		}

		public function clone():Data {
			var result:BattleResultElementData = new BattleResultElementData( this._group );
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleResultElementData = data as BattleResultElementData;
			if ( !target ) throw new ArgumentError();
			this.experience = target._experience;
			this.values = target._values;
		}

	}
	
}