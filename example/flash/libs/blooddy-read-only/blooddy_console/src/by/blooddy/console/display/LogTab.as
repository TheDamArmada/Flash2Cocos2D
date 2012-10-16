package by.blooddy.console.display {

	import by.blooddy.core.display.BaseSprite;
	import by.blooddy.core.display.text.BaseTextField;
	import by.blooddy.core.logging.Logger;
	
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.02.2011 16:40:09
	 */
	public class LogTab extends BaseTextField {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _TEXT_FORMAT:TextFormat = new TextFormat( '_sans', 17, 0xCCCCCC, true );
		_TEXT_FORMAT.align = TextFormatAlign.CENTER;
		
		/**
		 * @private
		 */
		private static const _TEXT_FORMAT_SELECTED:TextFormat = new TextFormat( '_sans', 16, 0xFFFFFF, true );
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LogTab() {
			super();
			super.background = true;
			super.backgroundColor = 0;
			super.multiline = false;
			super.mouseEnabled = true;
			super.selectable = false;
			super.defaultTextFormat = _TEXT_FORMAT;
			super.border = true;
			super.borderColor = 0x444444;
			super.width = 100;
			super.height = 25;
			super.doubleClickEnabled = true;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var logger:Logger;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function select():void {
			super.defaultTextFormat = _TEXT_FORMAT_SELECTED;
			super.setTextFormat( _TEXT_FORMAT_SELECTED );
		}
		
		public function deselect():void {
			super.defaultTextFormat = _TEXT_FORMAT;
			super.setTextFormat( _TEXT_FORMAT );
		}
		
	}

}