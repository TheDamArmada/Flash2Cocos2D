package by.blooddy.core.math {

	import by.blooddy.core.utils.MathUtils;

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	// TODO: местами было бы неплохо заменить parseInt на parseFloat
	// FIXME: пересмотреть увличение dig до 16;
	public class BigInt {

		public static const UINT64_MAX_VALUE:BigInt =	new BigInt( "10000000000000000", BASE_RADIX );
		public static const INT64_MAX_VALUE:BigInt =	new BigInt( "8000000000000000",  BASE_RADIX );

		public static const ZERO:BigInt =				new BigInt();
		public static const ONE:BigInt =				new BigInt( 1 );

		private static const JUNK:Array = new Array();

		public function BigInt(...args) {
			super();
			if ( args.length > 0 ) {
				this._arr.splice( 0, this._arr.length );
				var value:* = args[0];
				if ( value != null ) {
					if ( value is Number ) {
						this.setNumber( value as Number );
					} else if ( value is String ) { // пришла строка
						this.setString(
							value as String,
							uint( args[1] is String ? parseInt( args[1] ) : args[1] )
						);
					} else if ( value is BigInt ) {
						this.setBigInt( value as BigInt );
					} else if ( value is ByteArray ) {
						this.setBytes( value as ByteArray );
					} else {
						throw new ArgumentError();
					}
					$cleanArray( this._arr );
				}
			}
		}

		private const _arr:Array = new Array();

		private var _positive:Boolean = true;

		public function get positive():Boolean {
			return this._positive;
		}

//		public function getValue():Object {
//			if ( this._arr.length > 0 ) {
//				if ( this._arr.length <= 2 ) {
//					return this.toNumber();
//				} else {
//					return this.toString();
//				}
//			} else {
//				return 0;
//			}
//		}

		private static const BASE_DIG:uint =	4;
		private static const BASE_RADIX:uint =	16;
		private static const BASE:uint =		Math.pow( BASE_RADIX, BASE_DIG );

		private function setNumber(value:Number):void {
			if ( !isFinite( value ) ) {
				throw new ArgumentError();
			} else if ( value > uint.MAX_VALUE || value < int.MIN_VALUE ) { // не влазим в пределы точности
				this.setString( value.toString( BASE_RADIX ), BASE_RADIX );
			} else {
				this._positive = ( value >= 0 );
				var u:uint = Math.abs( value );
				do {
					this._arr.push( u % BASE );
					u /= BASE;
				} while ( u > 0 );
			}
		}

		private static const RADIX_LENGTH_TABLE:Array = new Array(); // TODO

//		{
//			for ( var radix:uint = 2; i<=36; ++radix ) {
//				RADIX_LENGTH_TABLE[ radix ] = int.MAX_VALUE.toString( radix ).length - 1;
//			}
//		}

		private function setString(value:String, radix:uint=0):void {
			var e:Boolean = false;
			if (
				radix == 0 && value.length <= 9 &&
				value.lastIndexOf("e") < 0 && value.lastIndexOf("E") < 0
			) { // подходит под описание int
				this.setNumber( parseInt( value ) );
			} else if (
				radix != 0 && value.length <= int.MAX_VALUE.toString( radix ).length - 1 && (
					radix != 10 || (
						value.lastIndexOf("e") < 0 && value.lastIndexOf("E") < 0
					)
				)
			) { // может число коротковато, что запустать неибаццо-какой алгоритм
				this.setNumber( parseInt( value, radix ) );
			} else { // слишком длинное число
				if ( value.charAt( 0 ) == "-" ) { // вычисляем знак
					value = value.substr( 1 );
					this._positive = false;
				} else {
					this._positive = true;
				}
				if ( radix == 0 ) { // проводим анализ radix
					if ( value.charAt( 0 ) == "0" ) {
						if (
							value.charAt( 1 ) == "x" ||
							value.charAt( 1 ) == "X"
						) {
							value = value.substr( 2 );
							radix = 16;
						}
					}
					if ( radix == 0 ) radix = 10;
				}
				if ( radix == 10 ) { // посмотрим, есть ли всякие E
					var i:int;
					if (
						( i = value.lastIndexOf( "e" ) ) >= 0 ||
						( i = value.lastIndexOf( "E" ) ) >= 0
					) {
						var v:int = parseInt( value.substr( i+1 ), 10 ); // степень десятки
						value = value.substring( 0, i );
						// найдём плавующую точку
						i = value.lastIndexOf(".");
						if ( i >= 0 ) {
							value = value.substring( 0, i ) + value.substr( i + 1 );
							v += i - value.length;
						}
						if ( v >= 0 ) {
							/*
							if ( BASE_RADIX == 10 ) {
								while ( v > BASE_DIG ) {
									v -= BASE_DIG;
									this._arr.push( 0 );
								}
							}
							*/
							while ( v-- > 0 ) value += "0";
						} else {
							if ( -v >= value.length ) return; // меньше 0
							value = value.substring( 0, value.length + v );
						}
					}
				} else {
					if ( radix < 2 || radix > 36 ) {
						throw new RangeError( "Error #1003: The radix argument must be between 2 and 36; got " + radix + "." );
					}
				}
				while ( value.charAt( 0 ) == "0" ) {
					value = value.substr( 1 );
				}
				value = MathUtils.convertRadix( value, radix, BASE_RADIX );
				i = value.length;
				var n:Number;
				while ( ( i -= BASE_DIG ) > 0 ) {
					n = parseInt( value.substr( i, BASE_DIG ), BASE_RADIX );
					if ( isNaN( n ) ) throw new ArgumentError();
					this._arr.push( n );
				}
				if ( i <= 0 ) {
					n = parseInt( value.substr( 0, BASE_DIG+i ), BASE_RADIX );
					if ( isNaN( n ) ) throw new ArgumentError();
					this._arr.push( n );
				}
			}
		}

		private function setBytes(value:ByteArray):void {
			this._positive = true;
			var pos:uint = value.position;
			value.position = 0;
			if ( value.endian == Endian.BIG_ENDIAN ) {
				while ( value.bytesAvailable >= 2 ) {
					this._arr.unshift( value.readUnsignedShort() );
				}
				if ( value.bytesAvailable > 0 ) {
					this._arr.unshift( value.readUnsignedByte() );
				}
			} else {
				while ( value.bytesAvailable >= 2 ) {
					this._arr.push( value.readUnsignedShort() );
				}
				if ( value.bytesAvailable > 0 ) {
					this._arr.push( value.readUnsignedByte() );
				}
			}
			value.position = pos;
		}

		private function setBigInt(value:BigInt):void {
			this._positive = value._positive;
			this._arr.push.apply( null, value._arr );
		}

		public function clone():BigInt {
			var result:BigInt = new BigInt();
			result.setBigInt( this );
			return result;
		}

		public function toNumber():Number {
			switch ( this._arr.length ) { // вырожденные случаи
				case 0:	return 0;
				case 1: return this._arr[ 0 ];
				case 2: return this._arr[ 0 ] | ( this._arr[ 1 ] << 16 );
			}
			var result:Number = this._arr[ 0 ];
			for ( var i:uint = 1; i<this._arr.length; ++i ) {
				result += this._arr[ i ] * Math.pow( BASE, i );
			}
			if ( !this._positive ) result *= -1;
			return result;
		}

		private static function _toString(arr:Array):String {
			var l:int = arr.length;
			if ( l <= 0 ) return "0";
			var result:String = arr[--l].toString( BASE_RADIX );
			var s:String;
			while ( l-- ) {
				s = arr[l].toString( BASE_RADIX );
				result += "000".substr( 0, 4-s.length ) + s;
			}
			return result;
		}

		public function toString(radix:uint=10):String {
			if ( radix < 2 || radix > 36 ) {
				throw new RangeError( "Error #1003: The radix argument must be between 2 and 36; got " + radix + "." );
			}
			var l:int = this._arr.length;
			if ( l <= 0 ) return "0";
			var result:String = this._arr[--l].toString( BASE_RADIX );
			var s:String;
			while ( l-- ) {
				s = this._arr[l].toString( BASE_RADIX );
				result += "000".substr( 0, 4-s.length ) + s;
			}
			if ( radix != BASE_RADIX ) {
				return MathUtils.convertRadix( result, BASE_RADIX, radix );
			}
			return ( !this._positive ? "-" : "" ) + result;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods: math operations
		//
		//--------------------------------------------------------------------------

		/**
		 * <	 -1
		 * >	  1
		 * ==	 0
		 */
		public function compare(value:Object):int {
			var v:BigInt;
			if ( !( value is BigInt ) ) {
				if ( value is Number ) {
					if ( !isFinite( value as Number ) ) {
						return ( value > 0 ? -1 : 1 );
					}
				}
				if ( this._arr.length <= 2 ) {
					value = verifyObject( value, 2 );
					if ( value is Number ) {
						var n:Number = this.toNumber();
						if ( n == value ) return 0;
						return ( n > value ? -1 : 1 );
					}
				}
				v = new BigInt( value );
			} else {
				v = value as BigInt;
			}
			if ( this._positive ) {
				if ( v._positive )							return $compare( this._arr, v._arr );
				else										return 1;
			} else {
				if ( v._positive )							return -1;
				else										return $compare( v._arr, this._arr );
			}
		}

		/**
		 * Math.abs( this )
		 */
		public function abs():BigInt {
			if ( this._positive ) {
				return this;
			} else {
				var result:BigInt = this.clone();
				result._positive = true;
				return result;
			}
		}

		/**
		 * Math.pow( this, value )
		 */
		public function pow(value:uint):BigInt {
			if ( value == 1 ) {
				return this;
			} else if ( value == 0 ) {
				return ONE;
			} else {

				var result:BigInt = new BigInt();

				var resultArr:Array = new Array( 1 );

				var arr1:Array = this._arr;
				var arr2:Array = new Array();

				for ( var i:uint = 1; i<value; i<<=1 ) {
					if ( i & value ) {
						$multiply( resultArr, arr1, arr2 );
						resultArr = arr2.slice();
					}
					$multiply( arr1, arr1, arr2 );
					arr1 = arr2;
				}

				result._arr.push.apply( result._arr, resultArr );
				if ( !this._positive && value & 1 ) result._positive = false;
				return result;
			}
		}

		private static function verifyBigInt(value:Object):BigInt {
			if ( value is BigInt )	return value as BigInt;
			else					return new BigInt( value );
		}

		private static function verifyObject(value:Object, maxLength:uint=1):Object {
			if ( value is String ) {
				var s:String = value as String;
				if (
					s.length <= 9 &&
					s.lastIndexOf("e") < 0 && s.lastIndexOf("E") < 0
				) {														// вырожденный случай: строка достаточно котороткая
					return parseInt( s );
				}
			} else if ( value is BigInt ) {
				if ( ( value as BigInt )._arr.length <= maxLength ) {		// вырожденный случай: прибавляемый BigInt достаточно коротокий
					return ( value as BigInt ).toNumber();
				}
			}
			if ( value is Number ) {
				var n:Number = value as Number;
				if ( !isFinite( n ) ) {
					throw new ArgumentError();
				} else if ( n > uint.MAX_VALUE || n < int.MIN_VALUE ) {
					value = new BigInt();
					( value as BigInt ).setNumber( value as Number );
				}
			}
			return value;
		}

		/**
		 * this + value
		 */
		public function add(value:Object):BigInt {
			if ( this._arr.length <= 0 ) {								// вырожденный случай: мы ровны 0
				return verifyBigInt( value );
			}
			value = verifyObject( value );
			var result:BigInt;
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: добавляемое число == 0
					return this;
				} else {
					if ( this._arr.length <= 1 ) {						// вырожденный случай: оба числа достаточно коротки
						result = new BigInt();
						result.setNumber( this.toNumber() + ( value as Number ) );
						return result;
					} else if ( value <= BASE && value >= -BASE ) {
						result = new BigInt();
						if ( this._positive == ( value > 0 ) ) {		// вырожденный случай: оба числа имею одинаковый знак
							$add_s( this._arr, Math.abs( value as Number ), result._arr );
							result._positive = this._positive;
						} else {
							$subtract_s( this._arr, Math.abs( value as Number ), result._arr );
							result._positive = this._positive;
						}
						return result;
					}
				}
			} else if ( !( value is BigInt ) ) {
				result = new BigInt( value );
				if ( result._arr.length <= 0 ) {
					return this;
				}
			} else {
				result = value as BigInt;
			}
			// если мы до седова дошли, значит вырожденые случаи не прокатили
			var temp:int = $compare( this._arr, result._arr );
			if ( result._positive != this._positive ) { // у нас разные знаки на самом деле надо отнимать
				if ( temp > 0 ) {
					$subtract( this._arr, result._arr, result._arr );
					result._positive = this._positive;
				} else {
					$subtract( result._arr, this._arr, result._arr );
					result._positive = !this._positive;
				}
			} else {
				if ( temp > 0 ) {
					$add( this._arr, result._arr, result._arr );
				} else {
					$add( result._arr, this._arr, result._arr );
				}
			}
			return result;
		}

		/**
		 * this - value
		 */
		public function subtract(value:Object):BigInt {
			if ( this._arr.length <= 0 ) {								// вырожденный случай: мы ровны 0
				value = new BigInt( value );
				( value as BigInt )._positive = !( value as BigInt )._positive;
				return value as BigInt;
			}
			value = verifyObject( value );
			var result:BigInt;
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: добавляемое число == 0
					return this;
				} else {
					if ( this._arr.length <=1 ) {						// вырожденный случай: оба числа достаточно коротки
						result = new BigInt();
						result.setNumber( this.toNumber() - ( value as Number ) );
						return result;
					} else if ( value <= BASE && value >= -BASE ) {
						result = new BigInt();
						if ( this._positive != ( value > 0 ) ) {		// вырожденный случай: оба числа имею одинаковый знак
							$add_s( this._arr, Math.abs( value as Number ), result._arr );
							result._positive = this._positive;
						} else {
							$subtract_s( this._arr, Math.abs( value as Number ), result._arr );
							result._positive = this._positive;
						}
						return result;
					}
				}
			} else if ( !( value is BigInt ) ) {
				result = new BigInt( value );
				if ( result._arr.length <= 0 ) {
					return this;
				}
			} else {
				result = value as BigInt;
			}
			var temp:int = $compare( this._arr, result._arr );
			if ( result._positive != this._positive ) { // у нас разные знаки на самом деле надо складывать
				if ( temp > 0 ) {
					$add( this._arr, result._arr, result._arr );
				} else {
					$add( result._arr, this._arr, result._arr );
				}
				result._positive = this._positive;
			} else {
				if ( temp > 0 ) {
					$subtract( this._arr, result._arr, result._arr );
					result._positive = this._positive;
				} else {
					$subtract( result._arr, this._arr, result._arr );
					result._positive = !this._positive;
				}
			}
			return result;
		}

		/**
		 * this * value
		 */
		public function multiply(value:Object):BigInt {
			if ( this._arr.length <= 0 ) {								// вырожденный случай: мы ровны 0
				return ZERO;
			}
			value = verifyObject( value );
			var result:BigInt;
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: второе число == 0
					return ZERO;
				} else {
					result = new BigInt();
					if ( this._arr.length <=1 ) {						// вырожденный случай: оба числа достаточно коротки
						result.setNumber( this.toNumber() * ( value as Number ) );
						return result;
					} else {											// вырожденный случай: множитель достаточно короткий
						$multiply_s( this._arr, Math.abs( value as Number ), result._arr );
						result._positive = ( this._positive == ( value >= 0 ) );
					}
					return result;
				}
			} else if ( !( value is BigInt ) ) {
				result = new BigInt( value );
				if ( result._arr.length <= 0 ) {
					return ZERO;
				}
			} else {
				result = value as BigInt;
			}
			result = new BigInt();
			$multiply( this._arr, ( value as BigInt )._arr, result._arr );
			result._positive = ( this._positive == value._positive );
			return result;
		}

		/**
		 * this / value
		 */
		public function divide(value:Object, roundMode:uint=1):BigInt {
			return this.divideAndRemainder( value, roundMode )[0] as BigInt;
		}

		/**
		 * this / value, this % value
		 */
		public function divideAndRemainder(value:Object, roundMode:uint=1):Array { // [ BigInt, BigInt ]
			if ( roundMode > RoundingMode.UNNECESSARY ) throw new ArgumentError("Invalid rounding mode");
			value = verifyObject( value );
			var result:BigInt;
			var rest:BigInt;
			result = new BigInt();
			rest = new BigInt();
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: второе число == 0
					throw new ArgumentError();
				} else if ( value == 1 ) {
					return new Array( this, ZERO );
				} else if ( this._arr.length <= 0 ) {					// вырожденный случай: мы равны 0
					return new Array( ZERO, ZERO );
				} else {
					if ( this._arr.length <=1 ) {						// вырожденный случай: оба числа достаточно коротки
						var num:Number = this.toNumber();
						rest.setNumber( num % ( value as Number ) );
						num /= ( value as Number );
						if ( rest._arr.length > 0 ) {
							switch ( roundMode ) {
								// если остача есть, то жопа!
								case RoundingMode.UNNECESSARY:	throw new VerifyError();	break;
								case RoundingMode.UP:
																if ( num < 0 )	num = Math.floor( num );
																else			num = Math.ceil( num );
																break;
								// всё и так заебца
								case RoundingMode.DOWN:			
																if ( num < 0 )	num = Math.round( num );
																else			num = Math.ceil( num );
																break;
								case RoundingMode.CEILING:		num = Math.ceil( num );		break;
								case RoundingMode.FLOOR:		num = Math.floor( num );	break;
								case RoundingMode.HALF_UP:
																if ( num < 0 )	num = -Math.round( -num );
																else			num = Math.round( num );
																break;
								case RoundingMode.HALF_DOWN:
																if ( num < 0 )	num = Math.round( num );
																else			num = -Math.round( -num );
																break;
								case RoundingMode.HALF_EVEN:
																if ( ( value as Number ) % 2 ) {
																	if ( num < 0 )	num = Math.round( num );
																	else			num = -Math.round( -num );
																} else {
																	if ( num < 0 )	num = Math.round( num );
																	else			num = -Math.round( -num );
																}
																break;
							}
						}
						result.setNumber( num );
					} else {											// вырожденный случай: множитель достаточно короткий
						$divide_s( this._arr, Math.abs( value as Number ), result._arr, rest._arr );
						rest._positive =
						result._positive = ( this._positive == ( value >= 0 ) );
					}
					return new Array( result, rest );
				}
			} else if ( !( value is BigInt ) ) {
				value = new BigInt( value );
				if ( ( value as BigInt )._arr.length <= 0 ) {
					throw new ArgumentError();
				}
			}

			if ( this._arr.length <= 0 ) {								// вырожденный случай: мы равны 0
				return new Array( ZERO, ZERO );
			}

			rest = new BigInt();

			$divide( this._arr, ( value as BigInt )._arr, result._arr, rest._arr );
			rest._positive =
			result._positive = ( this._positive == value._positive );

			if ( rest._arr.length > 0 ) {

				switch ( roundMode ) {
					case RoundingMode.UNNECESSARY:
						// если остача есть, то жопа!
						throw new VerifyError(); // ArithmeticException
						break;
					case RoundingMode.UP:
						// надо прибавить единичку
						$add_s( result._arr, 1, result._arr );
						break;
					case RoundingMode.DOWN:
						break; // всё и так заебца
					case RoundingMode.CEILING:
						if ( result._positive ) {
							$add_s( result._arr, 1, result._arr );
						}
						break;
					case RoundingMode.FLOOR:
						if ( !result._positive ) {
							$add_s( result._arr, 1, result._arr );
						}
						break;
					case RoundingMode.HALF_UP:
						$subtract( ( value as BigInt )._arr, rest._arr, JUNK );
						if ( $compare( rest._arr, JUNK ) >= 0 ) {
							$add_s( result._arr, 1, result._arr );
						}
						break;
					case RoundingMode.HALF_DOWN:
						$subtract( ( value as BigInt )._arr, rest._arr, JUNK );
						if ( $compare( rest._arr, JUNK ) <= 0 ) {
							$add_s( result._arr, 1, result._arr );
						}
						break;
					case RoundingMode.HALF_EVEN:
						$subtract( ( value as BigInt )._arr, rest._arr, JUNK );
						var c:int = $compare( rest._arr, JUNK );
						if ( c < 0 ) {
							$add_s( result._arr, 1, result._arr );
						} else if ( c == 0 ) {
							var tmp:Array = result._arr;
							if ( tmp[ tmp.length - 1 ] & 1 ) {
								$add_s( tmp, 1, tmp );
							}
						}
						break;
				}

			}
			return new Array( result, rest );
		}

		/**
		 * this % value
		 */
		public function remainder(value:Object):BigInt {
			value = verifyObject( value );
			var rest:BigInt;
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: второе число == 0
					throw new ArgumentError();
				} else if ( value == 1 ) {
					return ZERO;
				} else if ( this._arr.length <= 0 ) {					// вырожденный случай: мы равны 0
					return ZERO;
				} else {
					rest = new BigInt();
					if ( this._arr.length <=1 ) {						// вырожденный случай: оба числа достаточно коротки
						rest.setNumber( this.toNumber() % ( value as Number ) );
					} else {											// вырожденный случай: множитель достаточно короткий
						$divide_s( this._arr, Math.abs( value as Number ), JUNK, rest._arr );
						rest._positive = ( this._positive == ( value >= 0 ) );
					}
					return rest;
				}
			} else if ( !( value is BigInt ) ) {
				value = new BigInt( value );
				if ( ( value as BigInt )._arr.length <= 0 ) {
					throw new ArgumentError();
				}
			}

			if ( this._arr.length <= 0 ) {								// вырожденный случай: мы равны 0
				return ZERO;
			}

			$divide( this._arr, ( value as BigInt )._arr, JUNK, rest._arr );
			return rest;
		}

		/**
		 * ~this
		 */
		public function not():BigInt {
			var result:BigInt = new BigInt();
			if ( this._positive ) {
				$add_s( this._arr, 1, result._arr );
				result._positive = false;
			} else {
				$subtract_s( this._arr, 1, result._arr );
				result._positive = true;
			}
			return result;
		}

		/**
		 * this | value
		 */
		public function or(value:Object):BigInt {
			if ( this._arr.length < 0 ) {
				return verifyBigInt( value );
			}
			value = verifyObject( value );
			var result:BigInt;
			if ( value is Number ) {
				if ( value == 0 ) {										// вырожденный случай: второе число == 0
					return this;
				} else {
					result = new BigInt();
					if ( this._arr.length <=1 ) {						// вырожденный случай: оба числа достаточно коротки
						result.setNumber( this.toNumber() | ( value as Number ) );
					} else {											// вырожденный случай: множитель достаточно короткий
						$or_s( this._arr, value as Number, result._arr );
						result._positive = ( this._positive == ( value >= 0 ) );
					}
					return result;
				}
			} else if ( !( value is BigInt ) ) {
				value = new BigInt( value );
				if ( ( value as BigInt )._arr.length <= 0 ) {
					throw new ArgumentError();
				}
			}

			if ( this._arr.length <= 0 ) {						// вырожденный случай: мы равны 0
				return ZERO;
			}
			return null;
		}

		/**
		 * this & value
		 */
		public function and(value:Object):BigInt {
			return null;
		}

		/**
		 * this & ~value
		 */
		public function andNot(value:BigInt):BigInt {
			return null;
		}

		/**
		 * this ^ value
		 */
		public function xor(value:BigInt):BigInt {
			return null;
		}

		/**
		 * if ( value > 0 ) {
		 *	 this << value
		 * } else {
		 *	 this >> value
		 * }
		 */
		public function shift(value:int):BigInt {
			if ( value == 0 || this._arr.length <= 0 ) return this;
			var result:BigInt = this.clone();
			if ( value > 0 ) {
				$shiftLeft( result._arr, value );
			} else {
				$shiftRight( result._arr, Math.abs( value ) );
			}
			return result;
		}

		/**
		 * this | ( 1 << value );
		 */
		public function setBit(value:uint):BigInt {
			if ( this.testBit( value ) ) return this;
			var result:BigInt = this.clone();
			if ( result._positive ) {
				$setBit( result._arr, value );
			} else {
				$subtract_s( result._arr, 1, result._arr );
				$clearBit( result._arr, value );
				$add_s( result._arr, 1, result._arr );
			}
			return result;
		}

		public function clearBit(value:uint):BigInt {
			if ( !this.testBit( value ) ) return this;
			var result:BigInt = this.clone();
			if ( result._positive ) {
				$clearBit( result._arr, value );
			} else {
				$subtract_s( result._arr, 1, result._arr );
				$setBit( result._arr, value );
				$add_s( result._arr, 1, result._arr );
			}
			return result;
		}

		public function testBit(index:uint):Boolean {
			var i:uint = index / 16;
			if ( this._arr.length > i ) {
				return (
					this._positive == Boolean(
						this._arr[i] &
						( 1 << ( index % 16 ) )
					)
				);
			} else {
				return !this._positive;
			}
			return false;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods: math operations
		//
		//--------------------------------------------------------------------------

		private static function $compare_infinite(sign1:Boolean, sign2:Boolean):int {
			if ( sign1 == sign2 ) return 0;
			return ( sign1 ? 1 : -1 );
		}

		private static function $compare(a:Array, b:Array):int {
			var al:uint = a.length;
			var bl:uint = b.length;
			if ( al > bl ) return 1;
			else if ( al < bl ) return -1;
			else {
				for ( var i:int = al; i>=0; i-- ) {
					if ( a[i] > b[i] )		return 1;
					else if ( a[i] < b[i] )	return -1;
				}
			}
			return 0;
		}

		private static function $add_s(a:Array, value:uint, result:Array):void {
			var al:uint = a.length;
			var i:uint;
			var temp:uint = 0;
			temp += value;
			for ( i=0; i<al && temp > 0; ++i ) {
				temp += a[i];
				result[i] = temp % BASE;
				temp /= BASE;
			}
			for ( ; i<al; ++i ) {
				result[i] = a[i];
			}
			var cl:uint = result.length;
			if ( i < cl ) {
				result.splice( i, cl - i );
				cl -= i;
			}
			while ( temp > 0 ) {
				result.push( temp % BASE );
				temp /= BASE;
			}
		}

		private static function $add(a:Array, b:Array, result:Array):void {
			var al:uint = a.length;
			var bl:uint = b.length;
			var temp:uint = 0;
			var i:uint;
			for ( i=0; i<bl; ++i ) {
				temp += a[i] + b[i];
				if ( temp >= BASE ) {
					result[i] = temp - BASE;
					temp = 1;
				} else {
					result[i] = temp;
					temp = 0;
				}
			}
			if ( temp > 0 ) {
				temp += uint( a[i] );
				if ( temp >= BASE ) {
					result[i] = temp - BASE;
					temp = 1;
				} else {
					result[i] = temp;
					temp = 0;
				}
				++i;
			}
			for ( ; i<al; ++i ) {
				result[i] = a[i];
			}
			var cl:uint = result.length;
			if ( i < cl ) {
				result.splice( i, cl - i );
				cl -= i;
			}
		}

		private static function $subtract_s(a:Array, value:uint, result:Array):void {
			var al:uint = a.length;
			var i:uint;
			var temp:Number = -value; 
			for ( i=0; i<al && temp<0; ++i ) {
				temp += a[i];
				if ( temp < 0 ) {
					result[i] = BASE + temp % BASE;
					temp = Math.floor( temp / BASE );
				} else {
					result[i] = temp;
				}
			}
			for ( ; i<al; ++i ) {
				result[i] = a[i];
			}
			var cl:uint = result.length;
			if ( i < cl ) {
				result.splice( i, cl - i );
				cl -= i;
			}
			$cleanArray( result );
		}

		private static function $subtract(a:Array, b:Array, result:Array):void {
			var al:uint = a.length;
			var bl:uint = b.length;
			var i:uint;
			var temp:int = 0;
			for ( i=0; i<bl; ++i ) {
				temp += a[i] - b[i];
				if ( temp < 0 ) {
					result[i] = temp + BASE;
					temp = -1;
				} else {
					result[i] = temp;
					temp = 0;
				}
			}
			for ( ; i<al && temp; ++i ) {
				temp += a[i];
				if ( temp < 0 ) {
					result[i] = temp + BASE;
					temp = -1;
				} else {
					result[i] = temp;
					temp = 0;
				}
			}
			for ( ; i<al; ++i ) {
				result[i] = a[i];
			}
			var cl:uint = result.length;
			if ( i < cl ) {
				result.splice( i, cl - i );
				cl -= i;
			}
			$cleanArray( result );
		}

		private static function $multiply_s(a:Array, value:uint, result:Array):void {
			var al:uint = a.length;
			var temp:Number = 0;
			for ( var i:uint = 0; i<al; ++i ) {
				temp += a[i] * value;
				result[i] = temp % BASE;
				temp = uint( temp / BASE );

			}
			if ( temp > 0 ) {
				// Число удлинилось за счет переноса нового разряда
				result[ i ] = temp;
			}
		}

		private static function $multiply(a:Array, b:Array, result:Array):void {
			result.splice( 0, result.length );
			var al:uint = a.length;
			var bl:uint = b.length;
			var i:uint, j:uint;
			var temp:Number = 0;
			for ( i=0; i<al; ++i ) {
				temp = 0;
				// вычисление временного результата с одновременным прибавлением
				// его к c[i+j] (делаются переносы)
				for ( j=0; j<bl; ++j ) {
					temp += a[i] * b[j] + uint( result[i+j] );
					result[i+j] = temp % BASE;
					temp = uint( temp / BASE );
				}
				result[i+j] = temp;
			}
//			$cleanArray( result );
		}

		private static function $divide_s(a:Array, value:uint, result:Array, rest:Array):void {
			var al:int = a.length;
			var i:int;
			var temp:Number = 0;
			for ( i=al-1; i>=0; i-- ) {
				temp = ( a[i] || 0 ) + temp * BASE;	// идти по A, начиная от старшего разряда
											// rest – остаток от предыдущего деления
											// вначале rest=0, потом текущая цифра A с
											// учетом перенесенного остатка

				result[i] = uint( temp / value );		// i-я цифра частного

				temp %= value;				// остаток примет участие в вычислении
											// следующей цифры частного
			}
			$cleanArray( result );

			if ( temp > 0 ) {
				rest.splice( 0, rest.length, temp );
			} else if ( rest.length > 0 ) {
				rest.splice( 0, rest.length );
			}
		}

		private static function $divide(a:Array, b:Array, result:Array, _rest:Array):void { // TODO: оптимизировать

			var xxx:BigInt, yyy:BigInt;
			xxx = new BigInt();
			xxx._arr.push.apply( null, a );
			yyy = new BigInt();
			yyy._arr.push.apply( null, b );
			trace( xxx.toString( 16 ), yyy.toString( 16 ) );

			var rest:Array = new Array();
			rest.push.apply( rest, a );

			var n:int = b.length, m:int = a.length - b.length;
			var uJ:int, vJ:int, i:int;
			var temp1:Number, temp2:Number, temp:uint;
			var scale:int; // коэффициент нормализации
			var qGuess:int, r:int; // догадка для частного и соответствующий остаток
			var borrow:int, carry:int; // переносы
			// Нормализация
			scale = BASE / ( b[n-1] + 1 );
			trace( scale );
			if ( scale > 1 ) {
				var tmp:Array;
				tmp = new Array();
				$multiply_s( rest, scale, tmp );
				rest = tmp;
				tmp = new Array();
				$multiply_s( b, scale, tmp );
				b = tmp;
			}

			xxx = new BigInt();
			xxx._arr.push.apply( null, rest );
			yyy = new BigInt();
			yyy._arr.push.apply( null, b );
			trace( xxx.toString( 16 ), yyy.toString( 16 ) );
			rest.push( 0 );
			// Главный цикл шагов деления. Каждая итерация дает очередную цифру частного.
			// vJ - текущий сдвиг B относительно U, используемый при вычитании,
			// по совместительству - индекс очередной цифры частного.
			// uJ – индекс текущей цифры U
			for (vJ = m, uJ=n+vJ; vJ>=0; --vJ, --uJ) {
				qGuess = ( rest[uJ] * BASE + rest[uJ-1] ) / b[n-1];
				r = ( rest[uJ] * BASE + rest[uJ-1] ) % b[n-1];
				
//				trace( 't', rest[uJ] * BASE + rest[uJ-1], b[n-1] );
//				trace( 'q', qGuess, r );
				
				// Пока не будут выполнены условия (2) уменьшать частное.
				while ( r < BASE ) {
					temp2 = b[n-2] * qGuess;
					temp1 = r * BASE + rest[uJ-2];

					if ( ( temp2 > temp1 ) || ( qGuess == BASE ) ) {
						// условия не выполнены, уменьшить qGuess
						// и досчитать новый остаток
						--qGuess;
						r += b[n-1];
					} else break;
				}
//				trace( '	q', qGuess, r );
				// Теперь qGuess - правильное частное или на единицу больше q
				// Вычесть делитель B, умноженный на qGuess из делимого U,
				// начиная с позиции vJ+i
				carry = 0; borrow = 0;
				//uShift = u.slice( vJ );
				// цикл по цифрам B
				for ( i=0; i<n; ++i ) {
					// получить в temp цифру произведения B*qGuess
					temp1 = b[i] * qGuess + carry;
					carry = temp1 / BASE;
					temp1 -= carry * BASE;
					// Сразу же вычесть из U
					temp2 = rest[ i + vJ ] - temp1 + borrow;
//					trace( 't3', temp1, temp2 );
					if ( temp2 < 0 ) {
						rest[ i + vJ ] = temp2 + BASE;
						borrow = -1;
					} else {
						rest[ i + vJ ] = temp2;
						borrow = 0;
					}
				}
				// возможно, умноженое на qGuess число B удлинилось.
				// Если это так, то после умножения остался
				// неиспользованный перенос carry. Вычесть и его тоже.
				temp2 = rest[ i + vJ ] - carry + borrow;
//				trace( 't3', temp1, temp2 );
				if ( temp2 < 0 ) {
					rest[ i + vJ ] = temp2 + BASE;
					borrow = -1;
				} else {
					rest[ i + vJ ] = temp2;
					borrow = 0;
				}
//				trace( 'borrow', borrow );
				// Прошло ли вычитание нормально ?
				if ( borrow == 0 ) { // Да, частное угадано правильно
					result[vJ] = qGuess;
				} else { // Нет, последний перенос при вычитании borrow = -1,
					// значит, qGuess на единицу больше истинного частного
					result[vJ] = qGuess-1;
					// добавить одно, вычтенное сверх необходимого B к U
					carry = 0;
					for ( i=0; i<n; ++i ) {
						temp = rest[ i + vJ ] + b[i] + carry;
						if ( temp >= BASE ) {
							rest[ i + vJ ] = temp - BASE;
							carry = 1;
						} else {
							rest[ i + vJ ] = temp;
							carry = 0;
						}
					}
					rest[ i + vJ ] += carry - BASE;
				}
//				trace( 'result', result[ vJ ] );
			}

			$cleanArray( rest );
			$cleanArray( result );

			if ( scale > 1 ) {
				$divide_s( rest, scale, _rest, JUNK );
			} else {
				_rest.push.apply( null, rest );
			}
			
		}

		private static function $cleanArray(a:Array):void {
			var l:uint = a.length;
			while ( a[ --l ] == 0 ) a.pop();
		}

		private static function $or_s(a:Array, value:Number, result:Array):void {

		}

		private static function $shiftRight(a:Array, value:uint):void {
			var c:int = Math.abs( value / 16 );
			if ( c > 0 ) {
				a.splice( 0, Math.min( c, a.length ) );
				value %= 16;
			}
			var l:int = a.length;
			if ( value != 0 && l > 0 ) {
				for ( c=0; c<l; ++c ) {
					a[ c ] = ( ( a[ c ] >> value ) | ( a[ c+1 ] << value ) ) & 0xFFFF;
				}
				$cleanArray( a );
			}
		}

		private static function $shiftLeft(a:Array, value:uint):void {
			var c:int = Math.abs( value / 16 );
			value %= 16;
			if ( value != 0 ) {
				var l:int = a.length;
				var r:uint = a[ l-1 ] >> value;
				if ( r > 0 ) {
					a.push( r );
				}
				while ( l-- > 1 ) {
					a[ l ] = ( ( a[ l ] << value ) | ( a[ l-1 ] >>> value ) ) & 0xFFFF;
				}
				a[ 0 ] <<= value;
			}
			if ( c > 0 ) {
				while ( c-- > 0 ) {
					a.unshift( 0 );
				}
			}
		}

		private static function $setBit(a:Array, value:uint):void {
			var i:uint = value / 16;
			while ( a.length <= i ) a.push( 0 ); // добавляем разряды
			a[i] |= 1 << ( value % 16 );
		}

		private static function $clearBit(a:Array, value:uint):void {
			var i:uint = value / 16;
			while ( a.length <= i ) a.push( 0 ); // добавляем разряды
			value = 1 << ( value % 16 );
			if ( a[i] & value ) {
				a[i] ^= value;
			}
			$cleanArray( a );
		}

	}

}