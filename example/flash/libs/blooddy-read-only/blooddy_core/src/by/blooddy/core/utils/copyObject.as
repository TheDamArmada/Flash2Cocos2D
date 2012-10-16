////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.utils.Dictionary;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function copyObject(source:Object, target:Object=null):Object {
		return $copyObject( new Dictionary(), source, target );
	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import by.blooddy.core.meta.TypeInfo;
import by.blooddy.core.meta.PropertyInfo;

import flash.utils.Dictionary;
import flash.utils.ByteArray;

/**
 * @private
 */
internal function $copyObject(hash:Dictionary, source:Object, target:Object=null):Object {
	if ( !( source is Object ) ) {
		if ( target is Object ) throw new ArgumentError();
		target = source;
	} else if (
		source is Number ||
		source is String ||
		source is Boolean
	) {
		if ( target != null )  throw new ArgumentError();
		target = source;
	} else if ( source in hash ) {
		target = hash[ source ];
	} else if ( source is ByteArray ) {
		var bytesSource:ByteArray = source as ByteArray;
		var bytesTarget:ByteArray;
		if ( target ) {
			if ( !( target is ByteArray ) ) throw new ArgumentError();
			bytesTarget = target as ByteArray;
		} else {
			target = bytesTarget = new ByteArray()
		}
		hash[ source ] = target; // ADD
		var p:uint = bytesSource.position;
		bytesSource.position = 0;
		bytesTarget.clear();
		bytesSource.readBytes( bytesTarget );
		bytesTarget.position =
		bytesSource.position = p;
	} else if (
		source is XML ||
		source is XMLList
	) {
		if ( target ) throw new ArgumentError();
		target = source.copy();
		hash[ source ] = target; // ADD
	} else {
		if ( !target ) {
			if ( source is Array )	target = new Array();
			else					target = new Object();
		}
		hash[ source ] = target; // ADD
		var key:*, value:*;
		if ( source.constructor === Object ) {
			for ( key in source ) {
				if ( source[ key ] is Function ) continue;
				value = $copyObject( hash, source[ key ] );
				target[ key ] = value;
			}
		} else {
			const props:Object = new Object();
			for each ( var prop:PropertyInfo in TypeInfo.getInfo( source ).getProperties() ) {
				key = prop.name;
				props[ key ] = true;
				try {
					value = $copyObject( hash, source[ key ] );
					target[ key ] = value;
				} catch ( e:* ) {
				}
			}
			for ( key in source ) {
				if ( key in props || source[ key ] is Function ) continue;
				value = $copyObject( hash, source[ key ] );
				target[ key ] = value;
			}
			if ( source is Error ) {
				target.stack = ( source as Error ).getStackTrace();
			}
		}
	}
	return target;
}