////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gui.battle {
	
	import by.blooddy.core.display.resource.LoadableResourceSprite;
	import by.blooddy.core.display.text.BaseTextField;
	import by.blooddy.core.events.data.DataBaseEvent;
	
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import ru.avangardonline.data.character.HeroCharacterData;
	import ru.avangardonline.data.items.RuneData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.04.2010 16:56:26
	 */
	public class RunesView extends LoadableResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HINT:BaseTextField = new BaseTextField();
		_HINT.background = true;
		_HINT.backgroundColor = 0xCCCCCC;
		_HINT.border = true;
		_HINT.borderColor = 0x333333;
		_HINT.autoSize = TextFieldAutoSize.LEFT;
		_HINT.defaultTextFormat = new TextFormat( '_sans', 12, 0x333333 );

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function RunesView(leftDirection:Boolean) {
			super();
			this._leftDirection = leftDirection;
			super.addEventListener( MouseEvent.MOUSE_OVER, this.handler_mouseOver, false, int.MAX_VALUE, true );
			super.addEventListener( MouseEvent.MOUSE_OUT, this.handler_mouseOut, false, int.MAX_VALUE, true );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _leftDirection:Boolean;
		
		/**
		 * @private
		 */
		private const _list:Vector.<RuneView> = new Vector.<RuneView>();

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private var _data:HeroCharacterData;

		public function get data():HeroCharacterData {
			return this._data;
		}

		public function set data(value:HeroCharacterData):void {
			if ( this._data === value ) return;
			this._data = value;
			super.invalidate();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		protected override function draw():Boolean {
			if ( !this._data ) return false;
			for each ( var rune:RuneData in this._data.getRunes() ) {
				this.addRune( rune );
			}
			return true;
		}

		/**
		 * @private
		 */
		protected override function clear():Boolean {
			for each ( var v:RuneView in this._list ) {
				this.removeRune( v.data );
			}
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
		private function addRune(data:RuneData):void {
			var view:RuneView = new RuneView( data );
			var l:uint = this._list.push( view );
			view.x = ( this._leftDirection ? 1 : -1 ) * ( l - 1 ) * 40;
			super.addChild( view );
		}

		/**
		 * @private
		 */
		private function removeRune(data:RuneData):void {
			var l:uint = this._list.length;
			var view:RuneView;
			for ( var i:uint = 0; i<l; i++ ) {
				view = this._list[ i ];
				if ( view.data === data ) {
					this._list.splice( i, 1 );
					super.removeChild( view );
					break;
				}
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
		private function handler_added(event:DataBaseEvent):void {
			if ( event.target is RuneData ) {
				this.addRune( event.target as RuneData );
			}
		}

		/**
		 * @private
		 */
		private function handler_removed(event:DataBaseEvent):void {
			if ( event.target is RuneData ) {
				this.removeRune( event.target as RuneData );
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseOver(event:MouseEvent):void {
			var rune:RuneView = event.target as RuneView;
			if ( rune ) {
				_HINT.text = rune.data.name;
				super.addChild( _HINT );
				_HINT.x = rune.x - ( this._leftDirection ? 0 : _HINT.width );
				_HINT.y = 20;
			}
		}

		/**
		 * @private
		 */
		private function handler_mouseOut(event:MouseEvent):void {
			if ( super.contains( _HINT ) ) {
				super.removeChild( _HINT );
			}
		}
		
	}
	
}