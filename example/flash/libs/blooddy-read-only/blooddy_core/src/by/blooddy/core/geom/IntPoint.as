package by.blooddy.core.geom {

	public class IntPoint {

		public function IntPoint(x:int, y:int) {
			super();
			this.x = x;
			this.y = y;
		}

		public var x:int;

		public var y:int;

		public function clone():IntPoint {
			return new IntPoint( this.x, this.y );
		}

		public function toString():String {
			return "(x="+this.x+", y="+this.y+")";
		}

	}

}