////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.world {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.utils.HashArray;
	
	import ru.avangardonline.data.IClonableData;
	import ru.avangardonline.data.character.CharacterData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					29.07.2009 21:16:56
	 */
	public class BattleWorldElementCollectionData extends BattleWorldAssetDataContainer implements IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldElementCollectionData() {
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
		private const _hash:Object = new Object();

		/**
		 * @private
		 */
		private const _list:Vector.<BattleWorldAbstractElementData> = new Vector.<BattleWorldAbstractElementData>();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:BattleWorldElementCollectionData = new BattleWorldElementCollectionData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:BattleWorldElementCollectionData = data as BattleWorldElementCollectionData;
			if ( !target ) throw new ArgumentError();
			var hash:Object = new Object();
			var c:BattleWorldAbstractElementData;
			var c1:BattleWorldElementData;
			var c2:BattleWorldElementData;
			var id:uint;
			for each ( c in target._list ) {
				if ( c is BattleWorldElementData ) {
					c1 = c as BattleWorldElementData;
					id = c1.id;
					c2 = this._hash[ id ];
				} else {
					c1 = null;
					c2 = null;
				}
				if ( c2 ) c2.copyFrom( c1 );
				else super.addChild( c.clone() );
				hash[ id ] = true;
			}
			for each ( c in this._list ) {
				if ( !( c is BattleWorldElementData ) || !( ( c as BattleWorldElementData ).id in hash ) ) {
					super.removeChild( c );
				}
			}
		}

		public function getElement(id:uint):BattleWorldElementData {
			return this._hash[ id ];
		}

		public function getElements():Vector.<BattleWorldAbstractElementData> {
			return this._list.slice();
		}

		public function getElementAt(x:int, y:int):BattleWorldAbstractElementData {
			for each ( var character:CharacterData in this._list ) {
				if ( int( character.coord.x ) == x && int( character.coord.y ) == y ) return character;
			}
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function addChild_before(child:Data):void {
			super.addChild_before( child );
			if ( child is BattleWorldAbstractElementData ) {
				if ( child is BattleWorldElementData ) {
					var element:BattleWorldElementData = child as BattleWorldElementData;
					if ( this._hash[ element.id ] ) throw new ArgumentError();
					this._hash[ element.id ] = child;
				}
				this._list.push( child as BattleWorldAbstractElementData );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			super.removeChild_before( child );
			if ( child is BattleWorldAbstractElementData ) {
				if ( child is BattleWorldElementData ) {
					delete this._hash[ ( child as BattleWorldElementData ).id ];
				}
				var i:int = this._list.indexOf( child );
				if ( i >= 0 ) this._list.splice( i, 1 );
			}
		}

	}

}