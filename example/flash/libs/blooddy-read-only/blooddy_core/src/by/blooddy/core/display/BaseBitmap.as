////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.blooddy;
	import by.blooddy.core.utils.ClassAlias;

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	//--------------------------------------
	//  Aliases
	//--------------------------------------

	ClassAlias.registerQNameAlias( new QName( blooddy, 'Bitmap' ), BaseBitmap );

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 1, 2010 12:06:35 PM
	 */
	public class BaseBitmap extends Bitmap {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function BaseBitmap(bitmapData:BitmapData=null, pixelSnapping:String='auto', smoothing:Boolean=false) {
			super( bitmapData, pixelSnapping, smoothing );
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