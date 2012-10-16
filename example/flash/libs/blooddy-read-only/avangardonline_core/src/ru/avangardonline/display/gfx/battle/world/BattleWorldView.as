////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world {

	import by.blooddy.core.display.StageObserver;
	import by.blooddy.core.display.resource.MainResourceSprite;
	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.utils.enterFrameBroadcaster;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;
	import ru.avangardonline.data.battle.world.BattleWorldData;
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.events.data.battle.world.BattleWorldCoordinateDataEvent;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 19:58:31
	 */
	public class BattleWorldView extends MainResourceSprite {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const CELL_WIDTH:uint = 55;

		public static const CELL_HEIGHT:uint = 55;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function BattleWorldView(data:BattleWorldData, factory:BattleWorldViewFactory) {
			super();
			this._data = data;
			this._factory = factory;
			this._field = new BattleWorldFieldView( data.field );
			this._field.rotationX = 90;
			super.addEventListener( ResourceEvent.ADDED_TO_MANAGER,		this.render,	false, int.MAX_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MANAGER,	this.clear,		false, int.MAX_VALUE, true );
			var observer:StageObserver = new StageObserver( this );
			observer.registerEventListener( data.elements, DataBaseEvent.ADDED,		this.handler_added );
			observer.registerEventListener( data.elements, DataBaseEvent.REMOVED,	this.handler_removed );
			observer.registerEventListener( data.elements, BattleWorldCoordinateDataEvent.COORDINATE_CHANGE,	this.handler_coordinateChange );
			observer.registerEventListener( data.elements, BattleWorldCoordinateDataEvent.MOVING_START,			this.handler_movingStart );
			observer.registerEventListener( data.elements, BattleWorldCoordinateDataEvent.MOVING_STOP,			this.handler_movingStop );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private const _elements:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private const _elements_sorted:Vector.<SortAsset> = new Vector.<SortAsset>();

		/**
		 * @private
		 */
		private const _elements_moved:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		private var _elements_moved_count:uint = 0;

		/**
		 * @private
		 */
		private var _bg:DisplayObject;
		
		/**
		 * @private
		 */
		private var _field:BattleWorldFieldView;

		/**
		 * @private
		 */
		private const _content:Sprite = new Sprite();

		/**
		 * @private
		 */
		private var _factory:BattleWorldViewFactory;

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
		private var _data:BattleWorldData;

		public function get data():BattleWorldData {
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

			var loader:ILoadable = super.loadResourceBundle( 'lib/display/world/bg' + this._data.field.type + '.jpg' );
			if ( !loader.complete ) {
				loader.addEventListener( Event.COMPLETE, this.handler_complete );
				loader.addEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
				loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
				return false;
			}
			
			this._bg = super.getDisplayObject( 'lib/display/world/bg' + this._data.field.type + '.jpg', '' );
			if ( this._bg ) {
				this._bg.x = - this._bg.width / 2;
				this._bg.y = - 320;
				super.addChild( this._bg );
			}
			
			super.addChild( this._field );
			super.addChild( this._content );

			var hash:Dictionary = new Dictionary();

			var elements:Vector.<BattleWorldAbstractElementData> = this._data.elements.getElements();
			for each ( var data:BattleWorldAbstractElementData in elements ) {
				if ( !( data in this._elements ) ) {
					this.addWorldElement( data );
				}
				hash[ data ] = true;
			}

			for ( var o:Object in this._elements ) {
				if ( !( o in hash ) ) this.removeWorldElement( o as BattleWorldAbstractElementData );
			}

			return true;
		}

		/**
		 * @private
		 */
		protected function clear(event:Event=null):Boolean {
			if ( this._bg ) {
				super.trashResource( super.removeChild( this._bg ) );
			}
			for ( var o:Object in this._elements ) {
				this.removeWorldElement( o as BattleWorldAbstractElementData );
			}
			super.removeChild( this._content );
			super.removeChild( this._field );
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function addWorldElement(data:BattleWorldAbstractElementData):void {
			if ( data in this._elements ) throw new ArgumentError();
			var view:BattleWorldElementView = this._factory.getElementView( data );
			if ( !view ) return;
			this._elements_sorted.push( new SortAsset( data ) );
			this._content.addChild( view );
			this._elements[ data ] = view;
			if ( data.moving ) {
				this.moveStartElement( data );
			}
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function removeWorldElement(data:BattleWorldAbstractElementData):void {
			if ( !( data in this._elements ) ) throw new ArgumentError();
			if ( data.coord.moving ) {
				this.moveStopElement( data );
			}
			var view:BattleWorldElementView = this._elements[ data ];
			if ( !view ) return;
			delete this._elements[ data ];
			this._elements_sorted.splice( this._content.getChildIndex( view ), 1 );
			this._content.removeChild( view );
			//view.dispose();
		}

		/**
		 * @private
		 */
		private function moveStartElement(data:BattleWorldAbstractElementData):void {
			this._elements_moved[ data ] = true;
			if ( this._elements_moved_count <= 0 ) {
				enterFrameBroadcaster.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
			this._elements_moved_count++;
		}

		/**
		 * @private
		 */
		private function moveStopElement(data:BattleWorldAbstractElementData):void {
			delete this._elements_moved[ data ];
			this._elements_moved_count--;
			if ( this._elements_moved_count <=0 ) {
				enterFrameBroadcaster.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			}
		}

		/**
		 * @private
		 */
		private function updatePosition(data:BattleWorldAbstractElementData):void {
			var view:BattleWorldElementView = this._elements[ data ];
			if ( !view ) return;
			var x:Number, y:Number;
			if ( data is HeroCharacterData ) {
				y = 2;
				x = ( ( data as HeroCharacterData ).group == 1 ? -1 : 1 ) * 6.5;
			} else {
				x = data.coord.x;
				y = data.coord.y;
			}
			view.x = x * CELL_WIDTH;
			view.z = y * CELL_HEIGHT;

			var i:uint = this._content.getChildIndex( view );
			var lastIndex:uint = i;
			var asset:SortAsset = this._elements_sorted[ i ];
			var sortRating:Number = -data.coord.y;
			if ( asset.sortRating != sortRating ) {
				this._elements_sorted.splice( i, 1 );
				asset.sortRating = sortRating;
				// найдём куда ставить и поставим
				i = this._elements_sorted.length;
				while ( i-- ) {
					if ( -this._elements_sorted[ i ].element.coord.y <= sortRating ) break;
				}
				i++;
				this._elements_sorted.splice( i, 0, asset );
				this._content.setChildIndex( view, i );
			}

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			var loader:ILoadable = event.target as ILoadable;
			loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, this.handler_complete );
			loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.handler_complete );
			this.render( event );
		}
		
		/**
		 * @private
		 */
		private function handler_added(event:DataBaseEvent):void {
			if ( event.target is BattleWorldAbstractElementData ) {
				this.addWorldElement( event.target as BattleWorldAbstractElementData );
			}
		}

		/**
		 * @private
		 */
		private function handler_removed(event:DataBaseEvent):void {
			if ( event.target is BattleWorldAbstractElementData && event.target in this._elements ) {
				this.removeWorldElement( event.target as BattleWorldAbstractElementData );
			}
		}

		/**
		 * @private
		 */
		private function handler_coordinateChange(event:BattleWorldCoordinateDataEvent):void {
			this.updatePosition( event.target as BattleWorldAbstractElementData );
		}

		/**
		 * @private
		 */
		private function handler_movingStart(event:BattleWorldCoordinateDataEvent):void {
			var data:BattleWorldAbstractElementData = event.target as BattleWorldAbstractElementData;
			this.moveStartElement( data );
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function handler_movingStop(event:BattleWorldCoordinateDataEvent):void {
			var data:BattleWorldAbstractElementData = event.target as BattleWorldAbstractElementData;
			this.moveStopElement( data );
			this.updatePosition( data );
		}

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			var data:BattleWorldAbstractElementData;
			for ( var d:Object in this._elements_moved ) {
				this.updatePosition( d as BattleWorldAbstractElementData );
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import ru.avangardonline.data.battle.world.BattleWorldAbstractElementData;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: SortAsset
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 */
internal final class SortAsset {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 * Constructor.
	 */
	public function SortAsset(element:BattleWorldAbstractElementData, sortRating:Number=NaN) {
		super();
		this.element = element;
		this.sortRating = sortRating;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var element:BattleWorldAbstractElementData;

	public var sortRating:Number;

}