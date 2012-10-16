////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassAlias;

	import flash.display.Shape;

	//--------------------------------------
	//  Aliases
	//--------------------------------------

	ClassAlias.registerQNameAlias( new QName( blooddy, 'Shape' ), BaseShape );

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 12:42:58 PM
	 */
	public class BaseShape extends Shape {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function BaseShape() {
			super();
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage,		false, int.MAX_VALUE, true );
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Includes
		//
		//--------------------------------------------------------------------------

		include "../../../../includes/implements_BaseDisplayObject.as";

	}

}