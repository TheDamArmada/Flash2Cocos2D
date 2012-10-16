////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassAlias;

	import flash.display.MovieClip;

	//--------------------------------------
	//  Aliases
	//--------------------------------------

	ClassAlias.registerQNameAlias( new QName( blooddy, 'MovieClip' ), BaseMovieClip );

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 1:43:46 PM
	 */
	public class BaseMovieClip extends MovieClip {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function BaseMovieClip() {
			super();
			super.mouseEnabled = false;
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