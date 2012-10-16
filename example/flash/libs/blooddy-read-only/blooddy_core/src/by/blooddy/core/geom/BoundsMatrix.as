package by.blooddy.core.geom {

	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class BoundsMatrix {

		public function BoundsMatrix(width:Number, height:Number) {
			super();
			this.width = width;
			this.height = height;
		}

		public var width:Number = 0;

		public var height:Number = 0;

		public function getOffsets(bounds:Rectangle):IntRectangle {
			var x:Number = bounds.x / this.width;
			var y:Number = bounds.y / this.height;
			return new IntRectangle(
				x, y,
				Math.ceil( ( ( x % this.width ) + bounds.width ) / this.width ),
				Math.ceil( ( ( y % this.height ) + bounds.height ) / this.height )
			);
		}

	}

}