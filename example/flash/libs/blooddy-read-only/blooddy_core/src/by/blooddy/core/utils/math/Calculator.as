////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.math {

	/**
	 * Утилиты для работы со строкавыми выражениями.
	 *
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					calculator, math
	 */
	public final class Calculator {

		//--------------------------------------------------------------------------
		//
		//  Private class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * скобки
		 */
		private static const _constExp:RegExp = /[^\W\d]\w*/g;

		/**
		 * @private
		 * скобки
		 */
		private static const _methodExp:RegExp = /(\w+)\(([^\(\)]*)\)/g;

		/**
		 * @private
		 * скобки
		 */
		private static const _bracketExp:RegExp = /\(([^\(\)]*)\)/g;

		/**
		 * @private
		 * цифери
		 */
		private static const _numberExp:RegExp = /\s*((\-\s*)?\d+(\.\d+)?|NaN)\s*/;

		/**
		 * @private
		 * математические операции
		 */
		private static const _mathExp:Array = new Array(
			new RegExp( _numberExp.source	+ "([\\*\\/])"	+ _numberExp.source, "g" ),
			new RegExp( _numberExp.source	+ "(<<|>>)"		+ _numberExp.source, "g" ),
			new RegExp( _numberExp.source	+ "([\\|\\&])"	+ _numberExp.source, "g" ),
			new RegExp( _numberExp.source	+ "([\\~\\^])"	+ _numberExp.source, "g" ),
			new RegExp( _numberExp.source	+ "([\\+\\-])"	+ _numberExp.source, "g" )
		);

		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @param	expression		Строка, которую надо посчитать.
		 * @param	varibles		Объект для замены переменных.
		 *
		 * @return					Результат выражения.
		 *
		 * @keyword					сalculator.calculate, calculate
		 */
		public static function calculate(expression:String, varibles:Object=null):Number {
			_varibles = varibles;
			expression = "("+expression+")"; // в скобки берём что бы сам вызвал функцию
			var m:Boolean = false;
			while ( ( m = _methodExp.test(expression) ) || _bracketExp.test( expression ) ) {
				if (m) {
					expression = expression.replace(_methodExp, methodPhase);
				} else {
					expression = expression.replace(_bracketExp, bracketPhase);
				}
			}
			return Number(expression);
		}

		//--------------------------------------------------------------------------
		//
		//  Private class variables
		//
		//--------------------------------------------------------------------------

		private static var _varibles:Object;

		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		private static function methodPhase(result:String, methodName:String, params:String, ...uargs):Number {
			var method:Function, scope:Object;
			if ( methodName in Math ) {
				method = Math[methodName] as Function;
				scope = Math;
			} else if ( _varibles && methodName in _varibles ) {
				method = _varibles[methodName] as Function;
				scope = _varibles;
			}
			if (!Boolean(method)) throw new EvalError();
			var args:Array = params.split(/\s*,\s*/);
			var value:String;
			for (var i:Object in args) {
				args[i] = bracketPhase(null, args[i]);
			}
			return Number( method.apply( scope, args ) );
		}

		/**
		 * @private
		 * считаем скобки
		 */
		private static function bracketPhase(result:String, expression:String, ...uargs):Number {
			var exp:String;
			do {
				exp = expression
				expression = expression.replace(_constExp, constPhase);	// константы
			} while ( exp != expression );

			for (var i:uint=0; i<5; ++i) {
				do {
					exp = expression
					expression = expression.replace(_mathExp[i], mathPhase);	// умножение и деление
				} while ( exp != expression );
			}

			return Number(expression);
		}

		/**
		 * @private
		 * считаем математические выражения
		 */
		private static function constPhase(variableName:String, ...uargs):Number {
			if ( _varibles && variableName in _varibles ) {
				return Number( _varibles[variableName] );
			} else if ( variableName in Math ) {
				return Number( Math[variableName] );
			} else if ( variableName in Number ) {
				return Number( Math[variableName] );
			} else if ( variableName in int ) {
				return Number( Math[variableName] );
			} else if ( variableName in uint ) {
				return Number( Math[variableName] );
			}
			throw new EvalError();
		}

		/**
		 * @private
		 * считаем математические выражения
		 */
		private static function mathPhase(result:String, value1:Number, uarg1:*, uarg2:*, sign:String, value2:Number, ...uargs):Number {
			switch (sign) {
				case "*": return value1 * value2;
				case "/": return value1 / value2;
				case "+": return value1 + value2;
				case "-": return value1 - value2;
				case "|": return value1 | value2;
				case "&": return value1 & value2;
				case "^": return value1 ^ value2;
//				case "~": return value1 ~ value2;
				case "<<": return value1 << value2;
				case ">>": return value1 >> value2;
			}
			throw new EvalError();
		}

	}

}