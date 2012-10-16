////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils.memory.math;

import by.blooddy.system.Memory;
import by.blooddy.utils.IntUtils;
import flash.Error;
import flash.Lib;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class BigUint {

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline var BASE_RADIX:UInt =	16;

	/**
	 * @private
	 */
	private static inline var BASE:UInt = 0x10000;

	/**
	 * @private
	 */
	private static inline var MASK:UInt = 0xFFFF;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function fromString(p:UInt, value:String):UInt {
		var _lr:UInt = p;
		var i:Int = value.length;
		do {
			Memory.setI16(
				_lr,
				untyped __global__["parseInt"]( value.substring( Math.max( 0, i - 4 ), i ), 16 )
			);
			i -= 4;
			_lr += 2;
		} while ( i > 0 );
		
		_lr -= p;
		_clean( p, _lr );
		
		return _lr;
	}
	
	public static function toString(p:UInt, l:UInt):String {
		if ( l == 0 ) return '0';
		var s:String;
		var i:UInt = p + l - 2;
		var result:String = untyped Memory.getUI16( i ).toString( 16 );
		while ( i > p ) {
			i -= 2;
			s = untyped Memory.getUI16( i ).toString( 16 );
			result += '000'.substr( 0, 4 - s.length ) + s;
		}
		return result;
	}

	/**
	 * if ( v1 > v2 ) {
	 *     return 1;
	 * } else if ( v2 > v1 ) {
	 *     return -1;
	 * } else {
	 *     return 0;
	 * }
	 */
	public static inline function compare(p1:UInt, l1:UInt, p2:UInt, l2:UInt):Int {
		var result:Int = 0;
		if ( l1 > l2 ) result = 1;
		else if ( l2 > l1 ) result = -1;
		else {
			var i:UInt = l1;
			var v1:UInt;
			var v2:UInt;
			do {
				i -= 2;
				v1 = Memory.getUI16( p1 + i );
				v2 = Memory.getUI16( p2 + i );
				if ( v1 > v2 ) {
					result = 1;
					break;
				} else if ( v2 > v1 ) {
					result = -1;
					break;
				}
			} while ( i > 0 );
		}
		return result;
	}

	public static inline function isEven(p:UInt, l:UInt):Bool {
		return false;
	}

	/**
	 * return v1 + v2;
	 */
	public static inline function add(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		if ( l1 == 0 ) {
			_pr = p2;
			_lr = l2;
		} else if ( l2 == 0 ) {
			_pr = p1;
			_lr = l1;
		} else if ( l1 == 2 && l2 == 2 ) {
			var v:UInt = Memory.getUI16( p1 ) + Memory.getUI16( p2 );
			Memory.setI16( _pr, v );
			v >>>= BASE_RADIX;
			if ( v > 0 ) {
				Memory.setI16( _pr + 2, v );
				_lr = 4;
			} else {
				_lr = 2;
			}
		} else {
			var temp:UInt;
			if ( l2 > l1 ) { // TODO: new local var
				temp = p1; p1 = p2; p2 = temp;
				temp = l1; l1 = l2; l2 = temp;
			}
			_lr = 0;
			temp = 0;
			while ( _lr < l2 ) { // прибавляем к первому по 2 байтика от второго
				temp += Memory.getUI16( p1 + _lr ) + Memory.getUI16( p2 + _lr );
				if ( temp >= BASE ) {
					Memory.setI16( _pr + _lr, temp - BASE );
					temp = 1;
				} else {
					Memory.setI16( _pr + _lr, temp );
					temp = 0;
				}
				_lr += 2;
			}
			while ( temp > 0 && _lr < l1 ) { // прибавляем к первому остаток
				temp += Memory.getUI16( p1 + _lr );
				if ( temp >= BASE ) {
					Memory.setI16( _pr + _lr, temp - BASE );
					temp = 1;
				} else {
					Memory.setI16( _pr + _lr, temp );
					temp = 0;
				}
				_lr += 2;
			}
			if ( temp > 0 ) { // если остался остаток, то первое число закончилось
				Memory.setI16( _pr + _lr, temp );
				_lr += 2;
			} else {
				while ( _lr < l1 ) { // запишим остатки первого числа
					Memory.setI16(
						_pr + _lr,
						Memory.getUI16( p1 + _lr )
					);
					_lr += 2;
				}
			}
		}
	}

	/**
	 * if ( v1 > v2 ) {
	 *     return v1 - v2;
	 * } else {
	 *     return v2 - v1;
	 * }
	 */
	public static inline function sub(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		if ( l1 == 0 ) {
			_pr = p2;
			_lr = l2;
		} else if ( l2 == 0 ) {
			_pr = p1;
			_lr = l1;
		} else if ( l1 == 2 && l2 == 2 ) {
			var v1:UInt = Memory.getUI16( p1 );
			var v2:UInt = Memory.getUI16( p2 );
			if ( v1 == v2 ) {
				_lr = 0;
			} else {
				if ( v2 > v1 ) {
					v1 = v2 - v1;
				} else {
					v1 -= v2;
				}
				Memory.setI16( _pr, v1 );
				v1 >>>= BASE_RADIX;
				if ( v1 > 0 ) {
					Memory.setI16( _pr + 2, v1 );
					_lr = 4;
				} else {
					_lr = 2;
				}
			}
		} else {
			var c:Int = compare( p1, l1, p2, l2 );
			if ( c == 0 ) {
				_lr = 0;
			} else {
				var temp:Int;
				if ( c < 0 ) { // TODO: new local var
					temp = p1; p1 = p2; p2 = temp;
					temp = l1; l1 = l2; l2 = temp;
				}
				_lr = 0;
				temp = 0;
				while ( _lr < l2 ) {
					temp += Memory.getUI16( p1 + _lr ) - Memory.getUI16( p2 + _lr );
					if ( temp < 0 ) {
						Memory.setI16( _pr + _lr, temp + BASE );
						temp = -1;
					} else {
						Memory.setI16( _pr + _lr, temp );
						temp = 0;
					}
					_lr += 2;
				}
				while ( temp < 0 && _lr < l1 ) {
					temp += Memory.getUI16( p1 + _lr );
					if ( temp < 0 ) {
						Memory.setI16( _pr + _lr, temp + BASE );
						temp = -1;
					} else {
						Memory.setI16( _pr + _lr, temp );
						temp = 0;
					}
					_lr += 2;
				}
				//if ( temp < 0 ) {
					//Memory.setI16( _pr + _lr, temp );
					//_lr += 2;
				//} else {
					while ( _lr < l1 ) { // запишим остатки первого числа
						Memory.setI16( _pr + _lr, Memory.getUI16( p1 + _lr ) );
						_lr += 2;
					}
				//}
			}
			_clean( _pr, _lr );
		}
	}

	/**
	 * return v1 * v2;
	 */
	public static inline function mult(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		if ( l1 == 0 || l2 == 0 ) {
			_lr = 0;
		} else if ( l1 == 2 || l2 == 2 ) {
			if ( l1 == 2 && l2 == 2 ) {
				var v2:UInt = Memory.getUI16( p2 );
				if ( v2 == 1 ) {
					_pr = p1;
					_lr = l1;
				} else {
					var v1:UInt = Memory.getUI16( p1 );
					if ( v1 == 1 ) {
						_pr = p2;
						_lr = l2;
					} else {
						v1 *= v2;
						Memory.setI16( _pr, v1 );
						v1 >>>= BASE_RADIX;
						if ( v1 > 0 ) {
							Memory.setI16( _pr + 2, v1 );
							_lr = 4;
						} else {
							_lr = 2;
						}
					}
				}
			} else {
				var v:UInt;
				if ( l1 == 2 ) { // TODO: new local var
					v = Memory.getUI16( p1 );
					p1 = p2;
					l1 = l2;
				} else {
					v = Memory.getUI16( p2 );
				}
				_mult_s( p1, l1, v, _pr, _lr );
			}
		} else {
			_mult( p1, l1, p2, l2, _pr, _lr );
		}
	}

	/**
	 * return ( v1 / v2, v1 % v2 );
	 */
	public static inline function divAndMod(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt, _lx:UInt):Void {
		var _r:UInt;
		if ( l2 == 0 ) {
			Error.throwError( ArgumentError, 0 );
		} else if ( l2 > l1 ) {
			_pr = p1;
			_lr = 0;
			_lx = l1;
		} else if ( l2 == 2 ) {
			var v2:UInt = Memory.getUI16( p2 );
			if ( v2 == 1 ) {
				_pr = p1;
				_lr = l1;
				_lx = 0;
			} else if ( l1 == 2 ) {
				var v1:UInt = Memory.getUI16( p1 );
				if ( v1 == v2 ) {
					Memory.setI16( _pr, 1 );
					_lr = 2;
					_lx = 0;
				} else if ( v2 > v1 ) {
					_pr = p1;
					_lr = 0;
					_lx = l1;
				} else {
					_r = untyped v1 / v2;
					if ( _r == 0 ) {
						_lr = 0;
					} else {
						Memory.setI16( _pr, _r );
						_lr = 2;
					}
					_r = v1 % v2;
					if ( _r == 0 ) {
						_lx = 0;
					} else {
						Memory.setI16( _pr + _lr, _r );
						_lx = 2;
					}
				}
			} else {
				_r = 0;
				_div_s( p1, l1, Memory.getUI16( p2 ), _pr, _lr, _r, 3 );
				if ( _r > 0 ) {
					Memory.setI16( _pr + _lr, _r );
					_lx = 2;
				} else {
					_lx = 0;
				}
			}
		} else {
			_div( p1, l1, p2, l2, _pr, _lr, _lx, 3 );
		}
	}

	/**
	 * return v1 / v2;
	 */
	public static inline function div(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		if ( l2 == 0 ) {
			Error.throwError( ArgumentError, 0 );
		} else if ( l2 > l1 ) {
			_lr = 0;
		} else if ( l2 == 2 ) {
			var v2:UInt = Memory.getUI16( p2 );
			if ( v2 == 1 ) {
				_pr = p1;
				_lr = l1;
			} else if ( l1 == 2 ) {
				var v1:UInt = Memory.getUI16( p1 );
				if ( v1 == v2 ) {
					Memory.setI16( _pr, 1 );
					_lr = 2;
				} else if ( v2 > v1 ) {
					_lr = 0;
				} else {
					v1 = untyped v1 / v2;
					if ( v1 == 0 ) {
						_lr = 0;
					} else {
						Memory.setI16( _pr, v1 );
						_lr = 2;
					}
				}
			} else {
				_div_s( p1, l1, Memory.getUI16( p2 ), _pr, _lr );
			}
		} else {
			_div( p1, l1, p2, l2, _pr, _lr );
		}
	}

	/**
	 * r = t % v;
	 *
	 * @return lr;
	 */
	public static inline function mod(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		if ( l2 == 0 ) {
			Error.throwError( ArgumentError, 0 );
		} else if ( l2 > l1 ) {
			_pr = p1;
			_lr = l1;
		} else if ( l2 == 2 ) {
			var v2:UInt = Memory.getUI16( p2 );
			if ( v2 == 1 ) {
				_lr = 0;
			} else if ( l1 == 2 ) {
				var v1:UInt = Memory.getUI16( p1 );
				if ( v1 == v2 ) {
					_lr = 0;
				} else if ( v2 > v1 ) {
					_pr = p1;
					_lr = l1;
				} else {
					v1 = v1 % v2;
					if ( v1 == 0 ) {
						_lr = 0;
					} else {
						Memory.setI16( _pr, v1 );
						_lr = 2;
					}
				}
			} else {
				var _r:UInt = 0;
				_div_s( p1, l1, Memory.getUI16( p2 ), _pr, _lr, _r, 2 );
				if ( _r > 0 ) {
					Memory.setI16( _pr, _r );
					_lr = 2;
				} else {
					_lr = 0;
				}
			}
		} else {
			var _lx:UInt;
			_div( p1, l1, p2, l2, _pr, _lr, _lx, 2 );
			_pr += _lr;
			_lr = _lx;
		}
	}

	//public static inline function modPowInt(p1:UInt, l1:UInt, p2:UInt, l2:UInt, e:UInt, pr:UInt):UInt {
		//if ( e < 256 || isEven( p2, l2 ) ) {
			//return _exp( p1, l1, p2, l2, e, pr, ClassicReduction );
		//} else {
			//return _exp( p1, l1, p2, l2, e, pr, MontgomeryReduction );
		//}
	//}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function _clean(_pr:UInt, _lr:UInt):Void {
		while ( _lr > 0 && Memory.getUI16( _pr + _lr - 2 ) == 0 ) {
			_lr -= 2;
		}
	}

	/**
	 * @private
	 *
	 * return v1 * v2;
	 */
	private static inline function _mult_s(p1:UInt, l1:UInt, v:UInt, _pr:UInt, _lr:UInt):Void {
		var temp:Float = 0;
		_lr = 0;
		do {
			temp += Memory.getUI16( p1 + _lr ) * v;
			Memory.setI16( _pr + _lr, untyped temp );
			_lr += 2;
			temp = Std.int( temp / BASE );
		} while ( _lr < l1 );
		//while ( temp > 0 ) {
		if ( temp > 0 ) {
			Memory.setI16( _pr + _lr, untyped temp );
			_lr += 2;
			//temp = Std.int( temp / BASE );
			//temp = untyped temp >>> BASE_RADIX;
		}
	}
	
	/**
	 * @private
	 *
	 * return v1 * v2;
	 */
	private static inline function _mult(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt):Void {
		var temp:Float;
		var k:UInt;
		var j:UInt;
		var i:UInt = 0;
		do {
			temp = 0;
			j = 0;
			do {
				k = _pr + i + j;
				temp += Memory.getUI16( p1 + i ) * Memory.getUI16( p2 + j ) + Memory.getUI16( k );
				Memory.setI16( k, untyped temp );
				temp = Std.int( temp / BASE );
				j += 2;
			} while ( j < l2 );
			Memory.setI16( _pr + i + j, untyped temp );
			i += 2;
		} while ( i < l1 );
		_lr = i + j;
		_clean( _pr, _lr );
	}

	/**
	 * @private
	 *
	 * return ( v1 / v2, v1 % v2 );
	 */
	private static inline function _div_s(p1:UInt, l1:UInt, v:UInt, _pr:UInt, _lr:UInt, ?_r:UInt=0, ?need:UInt=1):Void {
		_r = 0;
		_lr = l1;
		do {
			_lr -= 2;
			if ( need & 1 == 1 ) {
				_r = Memory.getUI16( p1 + _lr ) | ( _r << BASE_RADIX );
				Memory.setI16( _pr + _lr, untyped _r / v );
				_r %= v;
			} else {
				_r = ( Memory.getUI16( p1 + _lr ) | ( _r << BASE_RADIX ) ) % v;
			}
		} while ( _lr > 0 ) ;
		_lr = l1;
		if ( need & 1 == 1 ) {
			_clean( _pr, _lr );
		}
	}

	/**
	 * @private
	 *
	 * return ( v1 / v2, v1 % v2 );
	 */
	private static inline function _div(p1:UInt, l1:UInt, p2:UInt, l2:UInt, _pr:UInt, _lr:UInt, ?_lx:UInt=0, ?need:UInt=1):Void {

		var p:UInt = _pr;

		var n:Int = l2, m:Int = l1 - l2;
		var i:Int;

		var a:UInt, al:UInt; // rest
		var b:UInt, bl:UInt;

		var scale:Int = untyped BASE / ( Memory.getUI16( p2 + l2 - 2 ) + 1 ); // коэффициент нормализации
		if ( scale > 1 ) {
			// Нормализация
			_mult_s( p1, l1, scale, _pr, _lr );
			a = _pr;
			al = _lr;
			_pr += _lr;
			_mult_s( p2, l2, scale, _pr, _lr );
			b = _pr;
			bl = _lr;
			_pr += _lr;
		} else {
			i = 0;
			do {
				Memory.setI16( _pr + i, Memory.getUI16( p1 + i ) );
				i += 2;
			} while ( i < l1 );
			a = _pr;
			al = l1;
			b = p2;
			bl = l2;
			_pr += l1;
		}

		_lr = m + 2;

		var uJ:Int, vJ:Int;
		var qGuess:Int, r:Float; // догадка для частного и соответствующий остаток
		var borrow:Int, carry:Int; // переносы

		var t1:Float;
		var t2:Float;

		// Главный цикл шагов деления. Каждая итерация дает очередную цифру частного.
		// vJ - текущий сдвиг B относительно U, используемый при вычитании,
		// по совместительству - индекс очередной цифры частного.
		// uJ – индекс текущей цифры U
		vJ = m;
		uJ = n + vJ;
		do {
			t1 = ( uJ < al ? Memory.getUI16( a + uJ ) << BASE_RADIX : 0 ) + Memory.getUI16( a + uJ - 2 );
			t2 = Memory.getUI16( b + n - 2 );
			qGuess = untyped t1 / t2;
			r = untyped t1 % t2;
			// Пока не будут выполнены условия (2) уменьшать частное.
			while ( r < BASE ) {
				t2 = Memory.getUI16( b + n - 4 ) * qGuess;
				t1 = r * BASE + Memory.getUI16( a + uJ - 4 );
				if ( ( t2 > t1 ) || ( qGuess == BASE ) ) {
					// условия не выполнены, уменьшить qGuess
					// и досчитать новый остаток
					--qGuess;
					r += untyped t2;
				} else {
					break;
				}
			}

			// Теперь qGuess - правильное частное или на единицу больше q
			// Вычесть делитель B, умноженный на qGuess из делимого U,
			// начиная с позиции vJ+i
			carry = 0;
			borrow = 0;
			// цикл по цифрам B
			i = 0;
			do {
				// получить в temp цифру произведения B*qGuess
				t1 = Memory.getUI16( b + i ) * qGuess + carry;
				carry = untyped t1 / BASE;
				t1 -= carry << BASE_RADIX;
				// Сразу же вычесть из U
				t2 = untyped Memory.getUI16( a + vJ + i ) - t1 + borrow;
				if ( t2 < 0 ) {
					Memory.setI16( a + vJ + i, untyped t2 + BASE );
					borrow = -1;
				} else {
					Memory.setI16( a + vJ + i, untyped t2 );
					borrow = 0;
				}
				i += 2;
			} while ( i < n );

			// возможно, умноженое на qGuess число B удлинилось.
			// Если это так, то после умножения остался
			// неиспользованный перенос carry. Вычесть и его тоже.
			t2 = Memory.getUI16( a + vJ + i ) - carry + borrow;
			if ( t2 < 0 ) {
				Memory.setI16( a + i + vJ, untyped t2 + BASE );
				borrow = -1;
			} else {
				Memory.setI16( a + i + vJ, untyped t2 );
				borrow = 0;
			}
			// Прошло ли вычитание нормально ?

			if ( borrow == 0 ) { // Да, частное угадано правильно
				if ( need & 1 == 1 ) Memory.setI16( _pr + vJ, qGuess );
			} else { // Нет, последний перенос при вычитании borrow = -1,
				// значит, qGuess на единицу больше истинного частного
				if ( need & 1 == 1 ) Memory.setI16( _pr + vJ, qGuess - 1 );
				// добавить одно, вычтенное сверх необходимого B к U
				carry = 0;
				do {
					t2 = Memory.getUI16( a + vJ + i ) + Memory.getUI16( b + i ) + carry;
					if ( t2 >= BASE ) {
						Memory.setI16( a + vJ + i, untyped t2 - BASE );
						carry = 1;
					} else {
						Memory.setI16( a + vJ + i, untyped t2 );
						carry = 0;
					}
					i += 2;
				} while ( i < n );
				Memory.setI16( a + vJ + i, Memory.getUI16( a + vJ + i ) + carry - BASE );
			}

			// Обновим размер U, который после вычитания мог уменьшиться
			// _clean
			while ( al > 0 && Memory.getUI16( a + al - 2 ) == 0 ) {
				al -= 2;
			}

			vJ -= 2;
			uJ -= 2;
		} while ( vJ >= 0 );

		if ( need & 1 == 1 ) {
			_clean( _pr, _lr );
		}

		if ( need & 2 == 2 ) {
			var lr:UInt = _lr;
			if ( scale > 1 ) {
				_div_s( a, al, scale, _pr + _lr, _lr );
				_lx = _lr;
			} else {
				i = 0;
				do {
					Memory.setI16( _pr + lr + i, Memory.getUI16( a + i ) );
					i += 2;
				} while ( i < al );
				_lx = _lr;
			}
			_lr = lr;
		}

	}

	/**
	 * @private
	 *
	 *
	 */
	private static inline function _exp(p1:UInt, l1:UInt, p2:UInt, l2:UInt, e:UInt, pr:UInt, z:Dynamic):UInt {
		return z.convert( p1, l1, p1, l2, pr );
	}

	///**
	 //* @private
	 //*/
	//private static function multiply():Void {
		//
	//}
	

}