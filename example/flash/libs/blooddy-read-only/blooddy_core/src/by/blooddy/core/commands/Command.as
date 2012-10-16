////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.commands {

	import by.blooddy.core.utils.ClassUtils;
	import by.blooddy.core.utils.ObjectUtils;

	/**
	 * Класс для хранения комманды в виде обычного массива.
	 * Коммнада по сути это набор упорядоченных аргументов.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					command
	 */
	public dynamic class Command extends Array {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 * @param	name		Имя комманды.
		 */
		public function Command(name:String, arguments:Array=null) {
			super();
			this.name = name;
			if ( arguments && arguments.length > 0 ) {
				super.push.apply( this, arguments );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  name
		//----------------------------------

		/**
		 * Имя комманды.
		 */
		public var name:String;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function call(client:Object, ns:Namespace=null):* {
			// пытаемся выполнить что-нить
			return client[ new QName( ns || '', this.name ) ].apply( client, this );
		}

		/**
		 * Клонирует команду.
		 * 
		 * @return			Возвращает копию данной команды.
		 */
		public function clone():Command {
			return new Command( this.name, this );
		}

		/**
		 * @private
		 */
		public function toString():String {
			return '[' + ClassUtils.getClassName( this ) + ' name="' + this.name + '"' + ( super.length > 0 ? ' arguments=(' + this.argumentsToString() + ')' : '' ) + ']';
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * Формирует из агрументов строку.
		 */
		protected final function argumentsToString():String {
			return arrayToString( this );
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function arrayToString(arr:Array):String {
			var result:Array = new Array();
			var length:uint = arr.length;
			for ( var i:uint = 0; i<length; ++i ) {
				result.push( arr[ i ] is Command ? arr[ i ] : ObjectUtils.toString( arr[ i ] ) );
			}
			return result.join( ',' );
		}

	}

}