////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassAlias;

	import flash.media.Video;

	//--------------------------------------
	//  Aliases
	//--------------------------------------

	ClassAlias.registerQNameAlias( new QName( blooddy, 'Video' ), BaseVideo );

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 1:12:51 PM
	 */
	public class BaseVideo extends Video {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function BaseVideo(width:int=320, height:int=240) {
			super( width, height );
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