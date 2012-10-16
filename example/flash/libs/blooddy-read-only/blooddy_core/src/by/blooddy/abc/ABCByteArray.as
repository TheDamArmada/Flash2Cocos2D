package by.blooddy.abc {

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class ABCByteArray extends ByteArray implements IABCInput, IABCOutput {

		public function ABCByteArray() {
			super();
			super.endian = Endian.LITTLE_ENDIAN;
		}

		public function readUInt8():uint {
			return super.readUnsignedByte();
		}

		public function readUInt16():uint {
			return super.readUnsignedShort();
		}

		public function readUInt24():uint {
			return this.$readUInt24();
		}

		public function readUInt32():uint {
			return super.readUnsignedInt();
		}

		public function readUIntDynamic():uint {
			return this.$readUIntDynamic();
		}

		public function readInt8():int {
			return super.readByte();
		}

		public function readInt16():int {
			return super.readShort();
		}

		public function readInt24():int {
			return int( this.$readUInt24() );
		}

		public function readInt32():int {
			return super.readInt();
		}

		public function readIntDynamic():int {
			return int( this.$readUIntDynamic() );
		}

		public function readUTFDynamic():String {
			var i:uint = super.position;
			while ( this[i] ) i+=1;
			var str:String = super.readUTFBytes( i - super.position );
			super.position = i+1;
			return str;
		}

		private function $readUInt24():uint {
			switch (super.endian) {
				case Endian.LITTLE_ENDIAN:
					return super.readUnsignedShort() | super.readUnsignedByte() << 16;
				case Endian.BIG_ENDIAN:
				default:
					return super.readUnsignedShort() << 8 | super.readUnsignedByte();
			}
		}

		private function $readUIntDynamic():uint {
			// читаем да тех пор пока есть 7й бит
			var result:uint = 0;
			var i:uint = 0, byte:uint;
			do {
				byte = super.readUnsignedByte();
				result |= ( byte & 0x7F ) << ( i*7 );
				i+=1;
			} while ( byte & 1<<7 );
			return result;
		}

 		public function writeUInt8(value:uint):void {
 			super.writeByte(value);
 		}

		public function writeUInt16(value:uint):void {
 			super.writeShort(value);
 		}

		public function writeUInt24(value:uint):void {
			this.$writeUInt24( value );
 		}

		public function writeUInt32(value:uint):void {
 			super.writeUnsignedInt(value);
 		}

		public function writeUIntDynamic(value:uint):void {
			this.$writeUIntDynamic( value );
 		}

		public function writeInt8(value:int):void {
 			super.writeByte(value);
 		}

		public function writeInt16(value:int):void {
 			super.writeShort(value);
 		}

		public function writeInt24(value:int):void {
			this.$writeUInt24( uint(value) );
 		}

		public function writeInt32(value:int):void {
			super.writeInt(value);
 		}

		public function writeIntDynamic(value:int):void {
			this.$writeUIntDynamic( uint(value) );
 		}

		public function writeUTFDynamic(value:String):void {
			super.writeUTFBytes(value);
			super.writeByte(0);
		}

		private function $writeUInt24(value:uint):void {
			switch (super.endian) {
				case Endian.LITTLE_ENDIAN:
					super.writeByte( value & 0xFF );
					super.writeShort( value >> 8 );
					break;
				case Endian.BIG_ENDIAN:
				default:
					super.writeShort( value >> 8 );
					super.writeByte( value & 0xFF );
					break;
			}
		}

		private function $writeUIntDynamic(value:uint):void {
			// записываем до тех пор пока есть 7й бит
			var i:uint = 0, byte:uint;
			do {
				byte = value >> ( i*7 );
				if ( byte > 0x7F ) {
					byte = ( byte & 0x7F ) | 1<<7;
				}
				super.writeByte( byte );
				i+=1;
			} while ( byte & 1<<7 );
		}

	}

}