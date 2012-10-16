package by.blooddy.abc {

	import flash.utils.IDataInput;

	public interface IABCInput {

		function get bytesAvailable():uint;
		function get endian():String;

		function readUInt8():uint;
		function readUInt16():uint;
		function readUInt24():uint;
		function readUInt32():uint;
		function readUIntDynamic():uint;

		function readInt8():int;
		function readInt16():int;
		function readInt24():int;
		function readInt32():int;
		function readIntDynamic():int;

		function readFloat():Number;
		function readDouble():Number;

		function readUTFBytes(length:uint):String;
		function readUTF():String;
		function readUTFDynamic():String;

	}

}