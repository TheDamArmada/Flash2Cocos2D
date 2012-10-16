////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gui.battle {
	
	import by.blooddy.core.display.resource.LoadableResourceSprite;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	import ru.avangardonline.data.items.RuneData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.04.2010 18:13:21
	 */
	public class RuneView extends LoadableResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function RuneView(data:RuneData) {
			super();
			this._data = data;
			super.mouseEnabled = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _img:DisplayObject;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _data:RuneData;

		public function get data():RuneData {
			return this._data;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function getResourceBundles():Array {
			return new Array( this.getResourceBundle() );
		}

		protected override function draw():Boolean {
			super.graphics.beginFill( 0x333333 );
			super.graphics.drawRect( -17, -17, 34, 34 );
			super.graphics.endFill();
			this._img = this.getDisplayObject( this.getResourceBundle() );
			if ( this._img ) {
				if ( this._img is Bitmap ) {
					( this._img as Bitmap ).smoothing = true;
				}
				this._img.y =
				this._img.x = -16;
				this._img.scaleY =
				this._img.scaleX = 32 / Math.max( this._img.width, this._img.height );
				super.addChild( this._img );
			}
			return false;
		}

		protected override function clear():Boolean {
			if ( this._img ) {
				super.trashResource( this._img );
			}
			super.graphics.clear();
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		private function getResourceBundle():String {
			return '/i/items/item_' + this._data.type + '.png';
		}

	}
	
}