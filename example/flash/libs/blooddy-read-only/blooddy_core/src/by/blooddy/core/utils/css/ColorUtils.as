////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.css {

	/**
	 * Класс с утилитами для StyleSheet.
	 * 
	 * @author etc
	 */	
	public class ColorUtils	{

		/**
		 * @private
		 */
		private static const _COLORS:Object = {
			alicemblue:				0xFFF0F8FF,
			antiquewhite:			0xFFFAEBD7,
			aqua:					0xFF00FFFF,
			aquamarine:				0xFF7FFFD4,
			azure:					0xFFF0FFFF,
			beige:					0xFFF5F5DC,
			bisque:					0xFFFFE4C4,
			black:					0xFF000000,
			blanchedalmond:			0xFFFFEBCD,
			blue:					0xFF0000FF,
			blueviolet:				0xFF8A2BE2,
			brown:					0xFFA52A2A,
			burlywood:				0xFFDEB887,
			cadetblue:				0xFF5F9EA0,
			chartreuse:				0xFF7FFF00,
			chocolate:				0xFFD2691E,
			coral:					0xFFFF7F50,
			cornflowerblue:			0xFF6495ED,
			cornsilk:				0xFFFFF8DC,
			crimson:				0xFFDC143C,
			cyan:					0xFF00FFFF,
			darkblue:				0xFF00008B,
			darkcyan:				0xFF008B8B,
			darkgoldenrod:			0xFFB8860B,
			darkgray:				0xFFA9A9A9,
			darkgreen:				0xFF006400,
			darkkhaki:				0xFFBDB76B,
			darkmagenta:			0xFF8B008B,
			darkolivegreen:			0xFF556B2F,
			darkorange:				0xFFFF8C00,
			darkochid:				0xFF9932CC,
			darkred:				0xFF8B0000,
			darksalmon:				0xFFE9967A,
			darkseagreen:			0xFF8FBC8F,
			darkslateblue:			0xFF483D8B,
			darkslategray:			0xFF2F4F4F,
			darkturquoise:			0xFF00CED1,
			darkviolet:				0xFF9400D3,
			deeppink:				0xFFFF1493,
			deepskyblue:			0xFF00BFFF,
			dimgray:				0xFF696969,
			dodgerblue:				0xFF1E90FF,
			firebrick:				0xFFB22222,
			floralwhite:			0xFFFFFAF0,
			forestgreen:			0xFF228B22,
			fushsia:				0xFFFF00FF,
			gainsboro:				0xFFDCDCDC,
			ghostwhite:				0xFFF8F8FF,
			gold:					0xFFFFD700,
			goldenrod:				0xFFDAA520,
			gray:					0xFF808080,
			green:					0xFF008000,
			greenyellow:			0xFFADFF2F,
			honeydew:				0xFFF0FFF0,
			hotpink:				0xFFFF69B4,
			indiandred:				0xFFCD5C5C,
			indigo:					0xFF4B0082,
			ivory:					0xFFFFFFF0,
			khaki:					0xFFF0E68C,
			lavender:				0xFFE6E6FA,
			lavenderblush:			0xFFFFF0F5,
			lawngreen:				0xFF7CFC00,
			lemonchiffon:			0xFFFFFACD,
			ligtblue:				0xFFADD8E6,
			lightcoral:				0xFFF08080,
			lightcyan:				0xFFE0FFFF,
			lightgoldenrodyellow:	0xFFFAFAD2,
			lightgreen:				0xFF90EE90,
			lightgrey:				0xFFD3D3D3,
			lightpink:				0xFFFFB6C1,
			lightsalmon:			0xFFFFA07A,
			lightseagreen:			0xFF20B2AA,
			lightscyblue:			0xFF87CEFA,
			lightslategray:			0xFF778899,
			lightsteelblue:			0xFFB0C4DE,
			lightyellow:			0xFFFFFFE0,
			lime:					0xFF00FF00,
			limegreen:				0xFF32CD32,
			linen:					0xFFFAF0E6,
			magenta:				0xFFFF00FF,
			maroon:					0xFF800000,
			mediumaquamarine:		0xFF66CDAA,
			mediumblue:				0xFF0000CD,
			mediumorchid:			0xFFBA55D3,
			mediumpurple:			0xFF9370DB,
			mediumseagreen:			0xFF3CB371,
			mediumslateblue:		0xFF7B68EE,
			mediumspringgreen:		0xFF00FA9A,
			mediumturquoise:		0xFF48D1CC,
			mediumvioletred:		0xFFC71585,
			midnightblue:			0xFF191970,
			mintcream:				0xFFF5FFFA,
			mistyrose:				0xFFFFE4E1,
			moccasin:				0xFFFFE4B5,
			navajowhite:			0xFFFFDEAD,
			navy:					0xFF000080,
			oldlace:				0xFFFDF5E6,
			olive:					0xFF808000,
			olivedrab:				0xFF6B8E23,
			orange:					0xFFFFA500,
			orengered:				0xFFFF4500,
			orchid:					0xFFDA70D6,
			palegoldenrod:			0xFFEEE8AA,
			palegreen:				0xFF98FB98,
			paleturquose:			0xFFAFEEEE,
			palevioletred:			0xFFDB7093,
			papayawhop:				0xFFFFEFD5,
			peachpuff:				0xFFFFDAB9,
			peru:					0xFFCD853F,
			pink:					0xFFFFC0CB,
			plum:					0xFFDDA0DD,
			powderblue:				0xFFB0E0E6,
			purple:					0xFF800080,
			red:					0xFFFF0000,
			rosybrown:				0xFFBC8F8F,
			royalblue:				0xFF4169E1,
			saddlebrown:			0xFF8B4513,
			salmon:					0xFFFA8072,
			sandybrown:				0xFFF4A460,
			seagreen:				0xFF2E8B57,
			seashell:				0xFFFFF5EE,
			sienna:					0xFFA0522D,
			silver:					0xFFC0C0C0,
			skyblue:				0xFF87CEEB,
			slateblue:				0xFF6A5ACD,
			slategray:				0xFF708090,
			snow:					0xFFFFFAFA,
			springgreen:			0xFF00FF7F,
			steelblue:				0xFF4682B4,
			tan:					0xFFD2B48C,
			teal:					0xFF008080,
			thistle:				0xFFD8BFD8,
			tomato:					0xFFFF6347,
			turquose:				0xFF40E0D0,
			violet:					0xFFEE82EE,
			wheat:					0xFFF5DEB3,
			white:					0xFFFFFFFF,
			whitesmoke:				0xFFF5F5F5,
			yellow:					0xFFFFFF00,
			yellowgreen:			0xFF9ACD32
		};

		/**
		 * Преобразовывает строку с цветом в число. Строка может быть вида #xxxxxx, #xyz (=#xxyyzz) или просто xxxxxx;
		 * 
		 * @param	color	Строка с цветом.
		 * 
		 * @return			Число.
		 * 
		 */
		public static function parseColor(color:String):Number {
			if (!color) return 0;
			var float:Boolean = false;

			if (color in _COLORS) {
				return _COLORS[color];
			} else 	{
				float = color.indexOf('0x') < 0 && color.indexOf('#') < 0;
				if (!float) {
					color = color.replace(/#/g,'');

					if (!float && color.length <= 3) {
						color = color.replace(/([\da-f])/ig, "$1$1");
					}
				}
			}

			var result:Number = float ? parseFloat(color) : parseInt(color, 16);
			return isNaN(result) ? 0 : result;
		}

		public static function hexToCSS(hex:String):String {
			while (hex.length<6) hex = "0"+hex;
			return "#"+hex;
		}

		public static function colorToCSS(color:uint):String {
			return hexToCSS(color.toString(16));
		}

		public static function getGradientColor(position:Number, colors:Array):uint {
			var l:uint = colors.length;
			var index:Number = l * position;
			if ( index <= 0 ) return colors[0];
			else if ( index >= l-1 ) return colors[l-1];
			else {
				var ratio:Number = index % 1;
				if (!ratio) return colors[ int( index ) ];
				else {
					var start:uint = colors[ int( index ) ];
					var end:uint = colors[ int( index ) + 1 ];
					return	( ( ( start >> 0  ) & 0xFF ) * ( 1 - ratio ) + ( ( end >> 0  ) & 0xFF ) * ratio << 0  ) |
							( ( ( start >> 8  ) & 0xFF ) * ( 1 - ratio ) + ( ( end >> 8  ) & 0xFF ) * ratio << 8  ) |
							( ( ( start >> 16 ) & 0xFF ) * ( 1 - ratio ) + ( ( end >> 16 ) & 0xFF ) * ratio << 16 ) |
							( ( ( start >> 24 ) & 0xFF ) * ( 1 - ratio ) + ( ( end >> 24 ) & 0xFF ) * ratio << 24 ) ;
				}

			}
			return 0;
		}

	}

}