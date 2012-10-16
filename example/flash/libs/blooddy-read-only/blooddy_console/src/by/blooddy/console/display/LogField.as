////////////////////////////////////////////////////////////////////////////////
//
//  © 2011 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.console.display {
	
	import by.blooddy.core.display.text.BaseTextField;
	import by.blooddy.core.events.logging.LogEvent;
	import by.blooddy.core.logging.Log;
	import by.blooddy.core.logging.Logger;
	import by.blooddy.crypto.serialization.JSON;
	
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					01.02.2011 13:52:07
	 */
	public class LogField extends BaseTextField {
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
//		private static const _FORMAT:TextFormat = new TextFormat( '_sans', 12, 0xFFFFFF );

		/**
		 * @private
		 */
		private static const _STYLE_SHEET:StyleSheet = new StyleSheet();
		_STYLE_SHEET.parseCSS(
		'	span {							' +
		'		color: #777777;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.cmd_in {						' +
		'		color: #9999FF;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.cmd_out {						' +
		'		color: #66FF66;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.info {							' +
		'		color: #CCCCFF;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.warn {							' +
		'		color: #FFFF00;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.error {						' +
		'		color: #FF9900;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.fatal {						' +
		'		color: #FF0000;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								' +
		'	.debug {						' +
		'		color: #CCCCCC;				' +
		'		font-family: _sans;			' +
		'		font-size: 14px;			' +
		'	}								'
		);

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function LogField() {
			super();
			super.background = true;
			super.backgroundColor = 0;
			super.multiline = true;
			super.mouseEnabled = true;
			super.styleSheet = _STYLE_SHEET;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _logger:Logger;

		public function get logger():Logger {
			return this._logger;
		}

		/**
		 * @private
		 */
		public function set logger(value:Logger):void {
			if ( this._logger === value ) return;
			if ( this._logger ) {
				this._logger.removeEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
				super.htmlText = '';
			}
			this._logger = value;
			if ( this._logger ) {
				this._logger.addEventListener( LogEvent.ADDED_LOG, this.handler_addedLog );
				var text:String = '';
				for each ( var log:Log in this._logger.getList() ) {
					text += log.toHTMLString() + '<br />';
				}
				super.htmlText = text;
				super.scrollV = super.maxScrollV;
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
		private function handler_addedLog(event:LogEvent):void {
			var scroll:int = super.scrollV;
			super.htmlText = super.htmlText + event.log.toHTMLString() + '<br />';
			super.scrollV = ( scroll == super.maxScrollV - 1 ? super.maxScrollV : scroll );
		}
		
	}
	
}