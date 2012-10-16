////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.result {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;
	
	import ru.avangardonline.data.IClonableData;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.11.2009 22:44:31
	 */
	public class BattleResultData extends DataContainer implements IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleResultData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _elements:Vector.<BattleResultElementData> = new Vector.<BattleResultElementData>();

		/**
		 * @private
		 */
		private const _hash:Object = new Object();

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

		/**
		 * @private
		 */
		public function set group(value:uint):void {
			if ( this._group == value ) return;
			this._group = value;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getElements():Vector.<BattleResultElementData> {
			return this._elements.slice();
		}

		public function getElement(group:uint):BattleResultElementData {
			return this._hash[ group ];
		}

		public override function toLocaleString():String {
			return super.formatToString( 'group', 'experience', 'values' );
		}
		
		public function clone():Data {
			var result:BattleResultData = new BattleResultData();
			result.copyFrom( this );
			return result;
		}
		
		public function copyFrom(data:Data):void {
			var target:BattleResultData = data as BattleResultData;
			if ( !target ) throw new ArgumentError();
			this.group = target._group;
			var hash:Object = new Object();
			var e1:BattleResultElementData;
			var e2:BattleResultElementData;
			for each ( e1 in target._elements ) {
				e2 = this._hash[ e1.group ];
				if ( e2 )	e2.copyFrom( e1 );
				else		super.addChild( e1.clone() );
				hash[ e1.group ] = true;
			}
			for each ( e2 in target._elements ) {
				if ( !( e2.group in this._hash[ e1.group ] ) ) {
					super.removeChild( e2 );
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overriden protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			if ( child is BattleResultElementData ) {
				this._elements.push( child );
				this._hash[ ( child as BattleResultElementData ).group ] = child;
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleResultElementData ) {
				delete this._hash[ ( child as BattleResultElementData ).group ];
				var index:int = this._elements.indexOf( child );
				if ( index >= 0 ) this._elements.splice( index, 1 );
			}
		}

	}

}