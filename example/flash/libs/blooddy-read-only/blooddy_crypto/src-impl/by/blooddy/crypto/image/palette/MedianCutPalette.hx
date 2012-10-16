////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette;

import flash.display.BitmapData;
import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
extern class MedianCutPalette implements IPalette {

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function new(image:BitmapData, ?maxColors:UInt):Void;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public function getColors():Vector<UInt>;
	
	public function getIndexByColor(color:UInt):UInt;

}