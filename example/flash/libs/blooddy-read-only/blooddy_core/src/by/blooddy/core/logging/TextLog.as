////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class TextLog extends Log {

		public function TextLog(text:String) {
			super();
			this._text = text;
		}

		private var _text:String;

		public function get text():String {
			return this._text;
		}

		public override function toString():String {
			return this._text;
		}

	}

}