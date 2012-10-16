////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.crypto.image.palette;

import flash.Vector;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
extern interface IPalette {

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	function getColors():Vector<UInt>;
	
	function getIndexByColor(color:UInt):UInt;
	
}