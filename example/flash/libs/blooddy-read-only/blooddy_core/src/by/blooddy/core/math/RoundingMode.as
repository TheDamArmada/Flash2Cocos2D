package by.blooddy.core.math {

	public final /*abstract*/ class RoundingMode {

		public function RoundingMode() {
			super();
			throw new ArgumentError();
		}

		public static const UP:uint =			0;

		public static const DOWN:uint =			1;

		public static const CEILING:uint =		2;

		public static const FLOOR:uint =		3;

		public static const HALF_UP:uint =		4;

		public static const HALF_DOWN:uint =	5;

		public static const HALF_EVEN:uint =	6;

		public static const UNNECESSARY:uint =	7;

	}

}