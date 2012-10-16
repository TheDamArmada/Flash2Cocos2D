////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.system.Capabilities;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public final class DateUtils {

		public static function timeToString(time:Number, useUTC:Boolean=true, sep:String=":", seconds:Boolean=true, milliseconds:Boolean=false):String {
			var d:Date = new Date( time );
			return	formatNumber( useUTC ? d.getUTCHours() : d.getHours() ) + sep +
					formatNumber( useUTC ? d.getUTCMinutes() : d.getMinutes() ) +
					( seconds ?
						sep + formatNumber( useUTC ? d.getUTCSeconds() : d.getSeconds() ) +
							( milliseconds ?
								"." + formatNumber( useUTC ? d.getUTCMilliseconds() : d.getMilliseconds(), 3 ) :
								""
							) :
						""
					);
		}

		public static function dateToString(time:Number, useUTC:Boolean=true, sep:String="/"):String {
			var d:Date = new Date( time );
			return	formatNumber( useUTC ? d.getUTCDate() : d.getDate() ) + sep +
					formatNumber( ( useUTC ? d.getUTCMonth() : d.getMonth() ) + 1 ) + sep +
					formatNumber( useUTC ? d.getUTCFullYear() : d.getFullYear() ); 
		}

		public static function fullDateToString(time:Number, useUTC:Boolean=true, sep:String=", ", dateSep:String=".", timeSep:String=":", seconds:Boolean=true, milliseconds:Boolean=false):String {
			return dateToString( time, useUTC, dateSep ) + sep + timeToString( time, useUTC, timeSep, seconds, milliseconds );
		}

		private static function formatNumber(num:Number, length:uint=2):String {
			var result:String = num.toString();
			while ( result.length < length ) {
				result = "0" + result;
			}
			return result;
		}

		public static function differenceToRemain(time:Number):String {
			var text:String = '';

			if (time > 3600*99*1E3) {
				text = Math.round(time/(3600*24*1E3))+'d';
			} else {
				var date:Date = new Date(time);

				if (date.hoursUTC >= 1) {
					time = date.minutesUTC/60;
					text = Math.round(date.hoursUTC+time)+'h';
				} else if (date.minutesUTC >= 1) {
					time = date.secondsUTC/60;
					text = Math.round(date.minutesUTC+time)+'m'
				} else {
					time = date.millisecondsUTC/1000;
					text = Math.round(date.secondsUTC+time)+'s';
				}
			}

			if (time < 0) text = '-' + text;
			return text;
		}

/**
a  	Ante meridiem или Post meridiem в нижнем регистре  	am или pm
A 	Ante meridiem или Post meridiem в верхнем регистре 	AM или PM
B 	Время в стадарте Swatch Internet 	От 000 до 999
c 	Дата в формате ISO 8601 (добавлено в PHP 5) 	2004-02-12T15:19:21+00:00
d 	День месяца, 2 цифры с ведущими нулями 	от 01 до 31
D 	Сокращенное наименование дня недели, 3 символа 	от Mon до Sun
F 	Полное наименование месяца, например January или March 	от January до December
g 	Часы в 12-часовом формате без ведущих нулей 	От 1 до 12
G 	Часы в 24-часовом формате без ведущих нулей 	От 0 до 23
h 	Часы в 12-часовом формате с ведущими нулями 	От 01 до 12
H 	Часы в 24-часовом формате с ведущими нулями 	От 00 до 23
i 	Минуты с ведущими нулями 	00 to 59
I 	Признак летнего времени 	1, если дата соответствует летнему времени, иначе 0 otherwise.
j 	День месяца без ведущих нулей 	От 1 до 31
l 	Полное наименование дня недели 	От Sunday до Saturday
L 	Признак високосного года 	1, если год високосный, иначе 0.
m 	Порядковый номер месяца с ведущими нулями 	От 01 до 12
M 	Сокращенное наименование месяца, 3 символа 	От Jan до Dec
n 	Порядковый номер месяца без ведущих нулей 	От 1 до 12
O 	Разница с временем по Гринвичу в часах 	Например: +0200
r 	Дата в формате » RFC 2822 	Например: Thu, 21 Dec 2000 16:01:07 +0200
s 	Секунды с ведущими нулями 	От 00 до 59
S 	Английский суффикс порядкового числительного дня месяца, 2 символа 	st, nd, rd или th. Применяется совместно с j
t 	Количество дней в месяце 	От 28 до 31
T 	Временная зона на сервере 	Примеры: EST, MDT ...
U 	Количество секунд, прошедших с начала Эпохи Unix (The Unix Epoch, 1 января 1970, 00:00:00 GMT) 	См. также time()
w 	Порядковый номер дня недели 	От 0 (воскресенье) до 6 (суббота)
W 	Порядковый номер недели года по ISO-8601, первый день недели - понедельник (добавлено в PHP 4.1.0) 	Например: 42 (42-я неделя года)
Y 	Порядковый номер года, 4 цифры 	Примеры: 1999, 2003
y 	Номер года, 2 цифры 	Примеры: 99, 03
z 	Порядковый номер дня в году (нумерация с 0) 	От 0 до 365
Z 	Смещение временной зоны в секундах. Для временных зон западнее UTC это отрицательное число, восточнее UTC - положительное. 	От -43200 до 43200
*/
		public static function format(time:Number, format:String="", useUTC:Boolean=true):String { // Thu Oct 30 12:40:58 GMT+0300 2008
			var result:String = "";
			var l:uint = format.length;
			var char:String;
			var d:Date = new Date( time );
			var tmp:uint;
			for ( var i:uint = 0; i<l; ++i ) {
				char = format.charAt( i );
				if ( char == '\\' ) {
					char = format.charAt( ++i );
				}
				switch ( char ) {
					case "a":	result += ( ( useUTC ? d.getUTCHours() : d.getHours() ) >= 12 ? "pm" : "am" );						break;
					case "A":	result += ( ( useUTC ? d.getUTCHours() : d.getHours() ) >= 12 ? "PM" : "AM" );						break;

					case "B":	result += uint( ( time % DAY ) / DAY_BEAT );														break;

					case "c":	throw new ArgumentError();

					case "D":	result += DAY_LOCALE_SHORT	[ useUTC ? d.getUTCDate() : d.getDay() ];					break;
					case "l":	result += DAY_LOCALE		[ useUTC ? d.getUTCDate() : d.getDay() ];					break;
					case "d":	result += formatNumber( useUTC ? d.getUTCDate() : d.getDate() );									break;
					case "j":	result += ( useUTC ? d.getUTCDate() : d.getDate() );												break; 
					case "S":	if ( format.charAt( i-1 ) == "j" ) {
									throw new ArgumentError();
								} else {
									result += "S";
								}																									break;

					case "F":	result += MONTH_LOCALE		[ useUTC ? d.getUTCMonth()  : d.getMonth()  ];				break;
					case "M":	result += MONTH_LOCALE_SHORT[ useUTC ? d.getUTCMonth()  : d.getMonth()  ];				break;
					case "m":	result += formatNumber( useUTC ? d.getUTCMonth() + 1 : d.getMonth() + 1 );							break;
					case "n":	result += ( useUTC ? d.getUTCMonth() + 1 : d.getMonth() + 1);										break;

					case "h":	result += formatNumber( ( useUTC ? d.getUTCHours() : d.getHours() ) % 12 || 12 );					break;
					case "g":	result += ( useUTC ? d.getUTCHours() : d.getHours() ) % 12 || 12;									break;

					case "H":	result += formatNumber( useUTC ? d.getUTCHours() : d.getHours() );									break;
					case "G":	result += ( useUTC ? d.getUTCHours() : d.getHours() );												break;

					case "i":	result += formatNumber( useUTC ? d.getUTCMinutes() : d.getMinutes() );								break;
					case "I":	throw new ArgumentError();

					case "L":	tmp = ( useUTC ? d.getUTCFullYear() : d.getFullYear() );
								result += ( tmp % 4 && !( tmp % 100 ) ? 1 : 2 );													break;

					case "O":	tmp = d.getTimezoneOffset();
								result += ( tmp < 0 ? "-" : "+" ) + formatNumber( Math.abs( tmp ), 4 );								break;

					case "r":	throw new ArgumentError();

					case "s":	result += formatNumber( useUTC ? d.getUTCSeconds() : d.getSeconds() );								break;

					case "t":	throw new ArgumentError();
					case "T":	throw new ArgumentError();
					case "U":	result += uint( ( new Date() ).getTime() / 1E3 );													break;
					case "w":	result += ( ( useUTC ? d.getUTCDay() : d.getDay() ) + 1 ) % 7;										break;
					case "W":	throw new ArgumentError();
					case "y":	result += formatNumber( ( useUTC ? d.getUTCFullYear() : d.getFullYear() ) % 100 );					break;
					case "Y":	result += ( useUTC ? d.getUTCFullYear() : d.getFullYear() );										break;
					case "z":	throw new ArgumentError();
					case "Z":	result += -( d.getTimezoneOffset() * 60 * 60 );														break;
					default:
						result += char;
						break;
				}
			}
			return result;
		}

		private static const DAY_BEAT:uint = 60 * 60 * 24;

		private static const DAY:uint = DAY_BEAT * 1E3;

		private static const MONTH_LOCALE:Array =
			new Array(	"January",	"February",	"March",	"April",	"May",		"June",		"July",		"August",	"September",	"October",	"November",	"December"	);

		private static const MONTH_LOCALE_SHORT:Array =
			new Array(	"Jan",		"Feb",		"Mar",		"Apr",		"May",		"Jun",		"Jul",		"Aug",		"Sep",			"Oct",		"Nov",		"Dec"		);

		private static const DAY_LOCALE:Object =
			new Array(	"Monday",	"Tuesday",	"Wednesday","Thursday",	"Friday",	"Saturday",	"Sunday"	);

		private static const DAY_LOCALE_SHORT:Object =
			new Array(	"Mon",		"Tue",		"Wed",		"Thu",		"Fri",		"Sat",		"Sun"		);

	}

}