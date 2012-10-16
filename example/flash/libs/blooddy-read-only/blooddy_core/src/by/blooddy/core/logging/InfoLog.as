////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.utils.DateUtils;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class InfoLog extends TextLog {

		public static const INFO:uint = 0;

		public static const WARN:uint = 1;

		public static const ERROR:uint = 2;

		public static const FATAL:uint = 3;

		public static const DEBUG:uint = uint.MAX_VALUE;
		
		public function InfoLog(text:String, type:uint=0) {
			super( text );
			this._type = type;
		}

		private var _type:uint;

		public function get type():uint {
			return this._type;
		}
		
		public override function toHTMLString():String {
			var result:String = this.toString();
			var cl:String;
			switch ( this._type ) {
				case INFO:	cl = 'info';	break;
				case WARN:	cl = 'warn';	break;
				case ERROR:	cl = 'error';	break;
				case FATAL:	cl = 'fatal';	break;
				case DEBUG: cl = 'debug';	break;
			}
			if ( result.length > 1024 ) {
				result = result.substr( 0, 1024 ) + '...';
			}
			result = escapeHTML( result );
			if ( cl ) {
				result = '<span class="' + cl + '">' + result + '</span>';
			}
			return result;
		}

		/**
		 * @private
		 */
		public override function toString():String {
			var d:Date = new Date( super.time );
			return DateUtils.timeToString( super.time, true, ':', true, true ) + '@ ' + super.text;
		}

	}

}