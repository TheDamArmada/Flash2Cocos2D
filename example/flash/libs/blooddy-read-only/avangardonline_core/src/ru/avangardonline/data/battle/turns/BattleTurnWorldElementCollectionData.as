////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data.battle.turns {

	import by.blooddy.core.data.Data;
	import by.blooddy.core.data.DataContainer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					20.08.2009 21:51:23
	 */
	public class BattleTurnWorldElementCollectionData extends DataContainer {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleTurnWorldElementCollectionData() {
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
		private const _collections:Vector.<BattleTurnWorldElementContainerData> = new Vector.<BattleTurnWorldElementContainerData>();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  numTurns
		//----------------------------------

		public function get numTurns():uint {
			return this._collections.length;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public override function toLocaleString():String {
			return super.formatToString( 'numTurns' );
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function getCollection(num:uint):BattleTurnWorldElementContainerData {
			return this._collections[ num ];
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
			if ( child is BattleTurnWorldElementContainerData ) {
				var data:BattleTurnWorldElementContainerData = child as BattleTurnWorldElementContainerData;
				if ( data.turnNum != this._collections.length ) throw new ArgumentError();
				this._collections.push( data );
			}
		}

		/**
		 * @private
		 */
		protected override function removeChild_before(child:Data):void {
			if ( child is BattleTurnWorldElementContainerData ) {
				var data:BattleTurnWorldElementContainerData = child as BattleTurnWorldElementContainerData;
				if ( data.turnNum != this._collections.length-1 ) throw new ArgumentError();
				if ( this._collections[ data.turnNum ] !== data ) throw new ArgumentError();
				this._collections.pop();
			}
		}

	}

}