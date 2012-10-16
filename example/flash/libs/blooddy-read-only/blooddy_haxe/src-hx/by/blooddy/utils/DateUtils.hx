////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.utils;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class DateUtils {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function now():Date {
		return untyped __new__( __global__['Date'] );
	}
	
	public static inline function getTime():Float {
		return now().getTime();
	}

}