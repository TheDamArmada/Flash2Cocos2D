////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.geom {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					weightmatrix, weight, matrix
	 */
	public final class WeightMatrix {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructior.
		 */
		public function WeightMatrix(width:uint=1, height:uint=1) {
			super();
			if (width<=0 || height<=0) throw new RangeError();
			this._width = width;
			this._height = height;
			var x:uint, y:uint;
			for (x=0; x<width; ++x) {
				this._distanceMatrix[x] = new Array(height);
//				this._pointsMatrix[x] = new Array();
			}
			this.updateMatrix();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private const _distanceMatrix:Array = new Array();

		/**
		 * @private
		 */
		private const _points:Array = new Array();

		/**
		 * @private
		 */
		private var _pointsMatrix:Array = new Array();

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  width
		//----------------------------------

		/**
		 * @private
		 */
		private var _width:uint;

		public function get width():uint {
			return this._width;
		}

		//----------------------------------
		//  height
		//----------------------------------

		/**
		 * @private
		 */
		private var _height:uint;

		public function get height():uint {
			return this._height;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * 
		 * @param	x		
		 * @param	y		
		 * 
		 * @throws	RangeError
		 */
		public function addPoint(x:uint, y:uint):void {
			if (x>=this._width || y>=this._height) throw new RangeError();
			if ( this.hasPoint(x, y) ) return;
			this._points.push( new IntPoint(x, y) );
			this._pointsMatrix = null;
			this.updatePoint(x, y);
		}

		/**
		 * 
		 * @param	x		
		 * @param	y		
		 * 
		 * @throws	RangeError
		 */
		public function removePoint(x:uint, y:uint):void {
			if (x>=this._width || y>=this._height) throw new RangeError();
			var deleted:Boolean = false;
			var p:IntPoint;
			for (var i:Object in this._points) {
				p = this._points[i] as IntPoint;
				if ( p.x == x && p.y == y ) {
					this._points.splice(i as uint, 1);
					deleted = true;
				}
			}
			if (deleted) this.updateMatrix();
		}

		/**
		 * 
		 * @param	x		
		 * @param	y		
		 * 
		 * @return	
		 * 
		 * @throws	RangeError
		 */
		public function hasPoint(x:uint, y:uint):Boolean {
			if (x>=this._width || y>=this._height) throw new RangeError();
			for each (var p:IntPoint in this._points) {
				if ( p.x == x && p.y == y ) return true;
			}
			return false;
		}

		/**
		 * 
		 * @param	x		
		 * @param	y		
		 * 
		 * @return	
		 */
		public function getWeight(x:int, y:int):uint {
			var d:uint = 0;
			if ( x<0)					{	d = -x;								x = 0;					}
			else if ( x>=this._width )	{	d = x-this._width;					x = this._width- 1;		}
			if ( y<0 )					{	d = Math.max(d, -y);				y = 0;					}
			else if ( x>=this._width )	{	d = Math.max(d, y-this._height);	y = this._height - 1;	}
			return ( this._distanceMatrix[x][y] as uint ) + d;
		}

		/**
		 * 
		 * @param	x
		 * @param	y
		 *  
		 * @return 
		 * 
		 */
		public function getPointsAroundPoint(x:int, y:int, radius:uint):Array {
			var weight:uint = this.getWeight(x, y);
			var result:Array = new Array();
			if ( weight <= radius ) { // наш вес меньше. надо выбрать элементы.
				var arr:Array;
				if (!this._pointsMatrix) this._pointsMatrix = new Array();
				if (!this._pointsMatrix[x]) this._pointsMatrix[x] = new Array();
				if (!this._pointsMatrix[x][y]) {
					arr = new Array();
					for each (var p:IntPoint in this._points) {
						weight = uint( Math.max(
							Math.abs( p.x - x ),
							Math.abs( p.y - y )
						) );
						if (!arr[weight]) arr[weight] = new Array();
						arr[weight].push( p );
					}
					this._pointsMatrix[x][y] = arr;
				}
				var scope:Array = ( this._pointsMatrix[x][y] as Array ).slice(0, radius);
				for each (arr in scope) {
					if (!arr) continue;
					result.push.apply(result, arr);
				}
			}
			return result; 
		}

		/**
		 */
		public function toMatrixString(colSeparator:String="\t", rowSeparator:String="\n"):String {
			var result:Array = new Array(), row:Array;
			var x:uint, y:uint, s:String;
			for (y=0; y<this._height; ++y) {
				row = new Array();
				for (x=0; x<this._width; ++x) {
					s = ( Math.round( ( this._distanceMatrix[x][y] as Number ) * 1000 ) / 1000 ).toString();
					if ( s.length <= 4 ) s += "\t";
					row.push( s );
				}
				result.push( row.join(colSeparator) );
			}
			return result.join(rowSeparator);
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function updateMatrix():void {
			var x:uint, y:uint, arr:Array, arr2:Array;
			for (x=0; x<this._width; ++x) {
				arr = this._distanceMatrix[x] as Array;
				for (y=0; y<this._height; ++y) {
					arr[y] = Number.MAX_VALUE;
				}
			}
			for each (var p:IntPoint in this._points) {
				this.updatePoint(p.x, p.y);
			}
			this._pointsMatrix = null;
		}

		/**
		 * @private
		 */
		private function updatePoint(x0:uint, y0:uint):void {

			// в нашей точке, точно 0
			this._distanceMatrix[x0][y0] = 0;

			var radius:uint, x:int, y:int, max:uint;
			var end:Boolean = false;

			// порбежим вверх от точки
			end = false;
			radius = 1;
			for (y=y0-1; y>=0 && !end; y--, ++radius) {
				end = true;
				x = x0 - radius + 1;
				max = Math.min( x + radius * 2, this._width );
				if ( x<0 ) x = 0;
				for (x; x<max; ++x) {
					if ( radius < this._distanceMatrix[x][y] ) {
						this._distanceMatrix[x][y] = radius;
						end = false;
					}
				}
			}

			// порбежим вправо от точки
			end = false;
			radius = 1;
			for (x=x0+1; x<this._width && !end; ++x, ++radius) {
				end = true;
				y = y0 - radius + 1;
				max = Math.min( y + radius * 2, this._height );
				if ( y<0 ) y = 0;
				for (y; y<max; ++y) {
					if ( radius < this._distanceMatrix[x][y] ) {
						this._distanceMatrix[x][y] = radius;
						end = false;
					}
				}
			}

			// порбежим вниз от точки
			end = false;
			radius = 1;
			for (y=y0+1; y<this._height && !end; ++y, ++radius) {
				end = true;
				x = x0 - radius;
				max = Math.min( x + radius * 2, this._width );
				if ( x<0 ) x = 0;
				for (x; x<max; ++x) {
					if ( radius < this._distanceMatrix[x][y] ) {
						this._distanceMatrix[x][y] = radius;
						end = false;
					}
				}
			}

			// порбежим влево от точки
			end = false;
			radius = 1;
			for (x=x0-1; x>=0 && !end; x--, ++radius) {
				end = true;
				y = y0 - radius;
				max = Math.min( y + radius * 2, this._height );
				if ( y<0 ) y = 0;
				for (y; y<max; ++y) {
					if ( radius < this._distanceMatrix[x][y] ) {
						this._distanceMatrix[x][y] = radius;
						end = false;
					}
				}
			}

		}

	}

}