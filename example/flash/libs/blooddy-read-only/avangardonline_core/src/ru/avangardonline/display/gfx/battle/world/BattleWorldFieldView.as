////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.ResourceSprite;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	
	import flash.events.Event;
	
	import ru.avangardonline.data.battle.world.BattleWorldFieldData;
	import ru.avangardonline.events.data.battle.world.BattleWorldFieldDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					05.08.2009 21:32:04
	 */
	public class BattleWorldFieldView extends ResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldFieldView(data:BattleWorldFieldData) {
			super();
			this._data = data;
			super.addEventListener( ResourceEvent.ADDED_TO_MANAGER,		this.render,	false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER,	this.clear,		false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data, BattleWorldFieldDataEvent.WIDTH_CHANGE,	this.render );
			observer.registerEventListener( data, BattleWorldFieldDataEvent.HEIGHT_CHANGE,	this.render );
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  data
		//----------------------------------

		/**
		 * @private
		 */
		private var _data:BattleWorldFieldData;

		public function get data():BattleWorldFieldData {
			return this._data;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected function render(event:Event=null):Boolean {
			if ( !super.stage ) return false;

			/*
			var width:uint = this._data.width;
			var height:uint = this._data.height;

			var xMin:int = -width / 2;
			var xMax:int = xMin + width - 1;

			var yMin:int = 0;
			var yMax:int = height - 1;

			var cell:BattleFieldCellView;

			var x:int;
			var y:int;

			for ( y=yMin; y<=yMax; y++ ) {
				for ( x=xMin; x<=xMax; x++ ) {
					cell = new BattleFieldCellView();
					cell.x = x * BattleWorldView.CELL_WIDTH;
					cell.y = y * BattleWorldView.CELL_HEIGHT;
					super.addChild( cell );
				}
			}

			cell = new BattleFieldCellView();
			cell.x = ( xMin - 1.5 )				* BattleWorldView.CELL_WIDTH;
			cell.y = int( yMin + height / 2 )	* BattleWorldView.CELL_HEIGHT;
			super.addChild( cell );

			cell = new BattleFieldCellView();
			cell.x = ( xMax + 1.5 )				* BattleWorldView.CELL_WIDTH;
			cell.y = int( yMin + height / 2 )	* BattleWorldView.CELL_HEIGHT;
			super.addChild( cell );
*/
			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			return true;
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.display.LineScaleMode;
import flash.display.Shape;

import ru.avangardonline.display.gfx.battle.world.BattleWorldView;

/**
 * @private
 */
internal final class BattleFieldCellView extends Shape {

	/**
	 * @private
	 */
	private static const _PROTO:Shape = new Shape();

	/*static*/ {
		_PROTO.graphics.lineStyle( 3, 0xFFFFFF, 1, false, LineScaleMode.NORMAL );
		_PROTO.graphics.beginFill( 0xFFFFFF, 0.1 );
		_PROTO.graphics.drawRect( -BattleWorldView.CELL_WIDTH / 2, -BattleWorldView.CELL_HEIGHT / 2, BattleWorldView.CELL_WIDTH, BattleWorldView.CELL_HEIGHT );
		_PROTO.graphics.drawCircle( 0, 0, 3 );
		_PROTO.graphics.endFill();
	}

	public function BattleFieldCellView() {
		super();
		super.graphics.copyFrom( _PROTO.graphics );
	}

}