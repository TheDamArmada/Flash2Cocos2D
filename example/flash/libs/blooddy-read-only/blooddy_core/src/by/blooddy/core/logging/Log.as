////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.logging {

	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.time.getTimer;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class Log {

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Object = {
			'<':	'&lt;',
			'>':	'&gt;',
			'&':	'&amp;',
			'"':	'&quot;',
			'\'':	'&apos;'
		};

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function replacer(s:String, ...args):String {
			return _HASH[ s ];
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Log() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public const time:Number = getTimer();

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public function toHTMLString():String {
			return escapeHTML( this.toString() );
		}

		/**
		 * @private
		 */
		public function toString():String {
			return this.formatToString( 'time' );
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected static function escapeHTML(str:String):String {
			return str.replace( /[<>&"']/g, replacer );
		}

		protected final function formatToString(...args):String {
			var result:Array = new Array();
			var length:uint = args.length;
			for (var i:uint =0; i<length; ++i) {
				if ( this[ args[i] ] is String ) result.push( args[i] + '="' + this[ args[i] ] + '"' );
				else result.push( args[i] + '=' + this[ args[i] ].toString() );
			}

			return '[' + ClassUtils.getClassName( this ) + ' ' + result.join( ' ' ) + ']';
		}

	}

}