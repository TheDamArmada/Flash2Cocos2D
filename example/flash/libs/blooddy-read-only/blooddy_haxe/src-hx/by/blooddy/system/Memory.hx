////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.system;

import flash.Error;
import flash.Lib;
import flash.utils.ByteArray;
import flash.system.ApplicationDomain;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class Memory {

	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------

	public static inline var memory( get_memory, set_memory ):ByteArray;

	public static inline var MIN_SIZE:UInt = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static inline function setByte(address:UInt, value:Int):Void {
		untyped __vmem_set__( 0, address, value );
	}

	public static inline function setI16(address:UInt, value:Int):Void {
		untyped __vmem_set__( 1, address, value );
	}

	public static inline function setI32(address:UInt, value:Int):Void {
		untyped __vmem_set__( 2, address, value );
	}

	public static inline function setFloat(address:UInt, value:Float):Void {
		untyped __vmem_set__( 3, address, value );
	}

	public static inline function setDouble(address:UInt, value:Float):Void {
		untyped __vmem_set__( 4, address, value );
	}

	public static inline function getByte(address:UInt):UInt {
		return untyped __vmem_get__( 0, address );
	}

	public static inline function getUI16(address:UInt):UInt {
		return untyped __vmem_get__( 1, address );
	}

	public static inline function getI32(address:UInt):Int {
		return untyped __vmem_get__( 2, address );
	}

	public static inline function getFloat(address:UInt):Float {
		return untyped __vmem_get__( 3, address );
	}

	public static inline function getDouble(address:UInt):Float {
		return untyped __vmem_get__( 4, address );
	}

	public static inline function signExtend1(value:Int):Int {
		return untyped __vmem_sign__( 0, value );
	}

	public static inline function signExtend8(value:Int):Int {
		return untyped __vmem_sign__( 1, value );
	}

	public static inline function signExtend16(value:Int):Int {
		return untyped __vmem_sign__( 2, value );
	}

	public static inline function fill(start:UInt, end:UInt, ?value:Int=0):Void {
		_fill( start, end, end - start, value );
	}

	public static inline function fill2(start:UInt, len:UInt, ?value:Int = 0):Void {
		_fill( start, start + len, len, value );
	}

	public static inline function setBI32(address:UInt, value:Int):Void {
		setByte( address + 0, value >> 24 );
		setByte( address + 1, value >> 16 );
		setByte( address + 2, value >>  8 );
		setByte( address + 3, value       );
	}

	//--------------------------------------------------------------------------
	//
	//  Private class methods
	//
	//--------------------------------------------------------------------------

	/**
	 * @private
	 */
	private static inline function get_memory():ByteArray {
		return ApplicationDomain.currentDomain.domainMemory;
	}

	/**
	 * @private
	 */
	private static inline function set_memory(value:ByteArray):ByteArray {
		return ApplicationDomain.currentDomain.domainMemory = value;
	}

	/**
	 * @private
	 */
	private static inline function _fill(start:UInt, end:UInt, len:UInt, value:Int):Void {
		var i:UInt = start;
		if ( len >= 12 ) {
			var v:UInt;
			if ( value == 0 ) {
				v = 0;
			} else {
				v = value & 0xFF;
				v |= ( v << 8 ) | ( v << 16 ) | ( v << 24 );
			}
			var e:UInt = end - ( len & 3 );
			do {
				setI32( i, v );
				i += 4;
			} while ( i < e ) ;
		} else {
			end = start + i;
		}
		while ( i < end ) {
			setByte( i++, value );
		}
	}

}