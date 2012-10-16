package by.blooddy.core.geom {

	import flash.geom.Point;
	import by.blooddy.core.utils.ClassUtils;

	public class PolarPoint {

		public function PolarPoint(length:Number=0, angle:Number=0) {
			super();
			this.length = length;
			this.angle = angle;
		}

		public var length:Number = 0;

		public var angle:Number = 0;

		public function clone():PolarPoint {
			return new PolarPoint( this.length, this.angle );
		}

		public function toPoint():Point {
			return Point.polar( this.length, this.angle );
		}

		public function toString():String {
			return '(length=' + this.length + ', angle=' + this.angle + ')';
		}

	}

}