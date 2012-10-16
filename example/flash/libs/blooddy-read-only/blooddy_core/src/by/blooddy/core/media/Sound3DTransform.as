////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.media {

	import flash.media.SoundTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					sound, transform
	 */
	public final class Sound3DTransform {

		public static function getTransform(point:Point, bounds:Rectangle, volome:Number=1):SoundTransform {

			/*

			+--------+--------+--------|--------+
			|        |        |        |        |
			|        |        |        |        |
			|        +--------|--------+        |
			|        |        |        |        |
			|        |        |        |        |
			+--------+--------+--------+--------+
			|        |        |        |        |
			|        |        |        |        |
			|        +--------|--------+        |
			|        |        |        |        |
			|        |        |        |        |
			+--------+--------+--------+--------+

			*/
			var result:SoundTransform = new SoundTransform();

			// относительные параметры

			var x:Number = ( point.x - bounds.x ) / bounds.width * 2 - 1;
			var y:Number = ( point.y - bounds.y ) / bounds.height * 2 - 1;

			if ( x < 0 ) { // лева
				result.rightToLeft = Math.min( Math.abs( x ), 1 );
				result.rightToRight = 1 - result.rightToLeft;
			} else if ( x > 0) {
				result.leftToRight = Math.min( Math.abs( x ), 1 );
				result.leftToLeft = 1 - result.leftToRight;
			}

			result.volume = Math.min( 2 - Math.min( Math.sqrt( x*x + y*y ), 2 ), 1 ) * volome;

			return result;

		}

	}

}