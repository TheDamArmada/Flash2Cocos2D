////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data {

	import by.blooddy.core.data.Data;
	import by.blooddy.game.data.PointsData;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					06.09.2009 17:05:45
	 */
	public class PointsData extends by.blooddy.game.data.PointsData implements IClonableData {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function PointsData() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------

		public function clone():Data {
			var result:ru.avangardonline.data.PointsData = new ru.avangardonline.data.PointsData();
			result.copyFrom( this );
			return result;
		}

		public function copyFrom(data:Data):void {
			var target:ru.avangardonline.data.PointsData = data as ru.avangardonline.data.PointsData;
			if ( !target ) throw new ArgumentError();
			this.min =		target.min;
			this.max =		target.max;
			this.current =	target.current;
		}

	}

}