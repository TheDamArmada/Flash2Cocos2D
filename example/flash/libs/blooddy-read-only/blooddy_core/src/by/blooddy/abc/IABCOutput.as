package by.blooddy.abc {

	import flash.utils.IDataOutput;

	public interface IABCOutput {

		function get endian():String;

		function writeUInt8(value:uint):void;
		function writeUInt16(value:uint):void;
		function writeUInt24(value:uint):void;
		function writeUInt32(value:uint):void;
		function writeUIntDynamic(value:uint):void;

		function writeInt8(value:int):void;
		function writeInt16(value:int):void;
		function writeInt24(value:int):void;
		function writeInt32(value:int):void;
		function writeIntDynamic(value:int):void;

		function writeFloat(value:Number):void;
		function writeDouble(value:Number):void;

		function writeUTFBytes(value:String):void;
		function writeUTF(value:String):void;
		function writeUTFDynamic(value:String):void;

	}

}