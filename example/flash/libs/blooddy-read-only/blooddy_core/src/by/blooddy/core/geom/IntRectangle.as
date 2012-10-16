package by.blooddy.core.geom {

	public class IntRectangle {

		public function IntRectangle(x:int, y:int, width:int, height:int) {
			super();
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		public var x:int;

		public var y:int;

		public var width:int;

		public var height:int;

		public function clone():IntRectangle {
			return new IntRectangle( this.x, this.y, this.width, this.height );
		}

		public function toString():String {
			return "(x="+this.x+", y="+this.y+", w="+this.width+", h="+this.height+")";
		}

	}

}