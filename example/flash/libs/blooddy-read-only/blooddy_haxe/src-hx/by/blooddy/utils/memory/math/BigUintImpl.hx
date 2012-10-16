////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////


package by.blooddy.utils.memory.math;

import by.blooddy.core.utils.ByteArrayUtils;
import by.blooddy.system.Memory;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * @author	BlooDHounD
 * @version	1.0
 */
class BigUintImpl {

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function add(v1:String, v2:String):String {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt;
		BigUint.add( _p1, _l1, _p2, _l2, _pr, _lr );
		var result:String = BigUint.toString( _pr, _lr );
		Memory.memory = mem;
		return result;
	}
	
	public static function subtract(v1:String, v2:String):String {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt;
		BigUint.sub( _p1, _l1, _p2, _l2, _pr, _lr );
		var result:String = BigUint.toString( _pr, _lr );
		Memory.memory = mem;
		return result;
	}
	
	public static function multiply(v1:String, v2:String):String {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt;
		BigUint.mult( _p1, _l1, _p2, _l2, _pr, _lr );
		var result:String = BigUint.toString( _pr, _lr );
		Memory.memory = mem;
		return result;
	}

	public static function divideAndMod(v1:String, v2:String):Array<String> {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt = 0;
		var _lx:UInt = 0;
		BigUint.divAndMod( _p1, _l1, _p2, _l2, _pr, _lr, _lx );
		var result:Array<String> = [ BigUint.toString( _pr, _lr ), BigUint.toString( _pr + _lr, _lx ) ];
		Memory.memory = mem;
		return result;
	}

	public static function divide(v1:String, v2:String):String {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt = 0;
		BigUint.div( _p1, _l1, _p2, _l2, _pr, _lr );
		var result:String = BigUint.toString( _pr, _lr );
		Memory.memory = mem;
		return result;
	}

	public static function mod(v1:String, v2:String):String {
		var mem:ByteArray = Memory.memory;
		Memory.memory = ByteArrayUtils.createByteArray( 1 << 16 );
		var _p1:UInt = 0;
		var _l1:UInt = BigUint.fromString( _p1, v1 );
		var _p2:UInt = _p1 + _l1;
		var _l2:UInt = BigUint.fromString( _p2, v2 );
		var _pr:UInt = _p2 + _l2;
		var _lr:UInt = 0;
		BigUint.mod( _p1, _l1, _p2, _l2, _pr, _lr );
		var result:String = BigUint.toString( _pr, _lr );
		Memory.memory = mem;
		return result;
	}

}