////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.display.gfx.battle.world.animation {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.08.2009 12:31:28
	 */
	public class Animation {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function Animation(id:uint=0, repeatCount:uint=0, priority:int=0) {
			super();
			this.id = id;
			this.repeatCount = repeatCount;
			this.priority = priority;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var id:uint;

		public var repeatCount:uint = 0;

		public var priority:int = 0;

	}

}