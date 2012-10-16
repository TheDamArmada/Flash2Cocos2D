////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * Имеет в наличии дополнительные методы для чтения некоторых типов данных
	 * 
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					readASInt, readSignedInt24, bytearray, swfbytearray
	 */
	public class SWFByteArray extends ByteArray {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * Начало несжатого SWF, первый тег.
		 */
		public static const TAG_SWF:String = "FWS";

		/**
		 * Начало сжатого SWF, первый тег.
		 */
		public static const TAG_SWF_COMPRESSED:String = "CWS";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 * 
		 * @param	bytes			ByteArray, автоматически считывается в SWFByteArray и распаковывается, если SWF сжат. 
		 */
		public function SWFByteArray(bytes:ByteArray=null) {
			super();
			this.endian = Endian.LITTLE_ENDIAN;
			if (bytes) {
				var pos:uint = bytes.position;
				bytes.position = 0;
				if (bytes is SWFByteArray) {
					bytes.readBytes(this);
					this._version = ( bytes as SWFByteArray ).version;
					this._tagsStartPosition = (bytes as SWFByteArray)._tagsStartPosition;
				} else {
					var endian:String = bytes.endian;
					bytes.endian = Endian.LITTLE_ENDIAN;

					if (bytes.bytesAvailable > 26) {
						var type:String = bytes.readUTFBytes(3);
						this._version = bytes.readUnsignedByte();
						if (type == TAG_SWF_COMPRESSED || type == TAG_SWF) {
							bytes.readUnsignedInt();
							bytes.readBytes(this);
							if (type == TAG_SWF_COMPRESSED) {
								this.uncompress();
							}

							this.readHeader();
							this._tagsStartPosition = super.position;
						}
					} else {
						super.position = 0;
					}

					bytes.endian = endian;
				}

				bytes.position = pos;
				// this.position = 0;
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _tagsStartPosition:uint;

		/**
		 * @private
		 */
		private var _bitIndex:uint;

		//----------------------------------
		//  version
		//----------------------------------

		/**
		 * @private
		 */
		private var _version:uint;

		/**
		 * Версия SWF.
		 */
		public function get version():uint {
			return this._version;
		}

		/**
		 * @private
		 */
		private var _frameRate:Number;

		public function get frameRate():Number {
			return this._frameRate;	
		}

		/**
		 * @private
		 */
		private var _rect:Rectangle;

		public function get rect():Rectangle {
			return this._rect;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function rewind():void {
			super.position = this._tagsStartPosition;			
		}

		/**
		 * Читает signed int (u30, нефиксированная длина, от 1 до 5-ти байт)
		 */
		public function readASInt():int {
			/*var pos:uint = super.position;
			var out:int = 0;
			var i:uint = 0;
			var byte:uint = this[pos];

			if (!(byte & 0x80)) {
				super.position = pos+1;
				return byte;
			}

			pos += 1;

			while ((byte & 0x80)) {
				out |= (byte ^ 0x80) << (i * 7);
				i += 1;
				byte = this[pos];
				pos += 1;
			}

			out |= (byte << (i * 7)); 
			super.position = pos;
			return out;*/
			var result:uint = 0;
			var i:uint = 0, byte:uint;
			do {
				byte = super.readUnsignedByte();
				result |= ( byte & 0x7F ) << ( i*7 );
				i+=1;
			} while ( byte & 1<<7 );
			return result;			
		}

		/**
		 * Читает signed 24-bit число (фиксированной длины, 3 байта)
		 */
		public function readSignedInt24():int {
			var pos:uint = super.position;
			var out:int = (this[pos] << 16);
			out += (this[pos+=1] << 8);
			out += this[pos+=1]; 

			if (out >= 0x808080) {
				out -= 0xFFFFFF;
			}

			super.position = pos+1;
			return out;
		}

		public function readUnsignedInt64():Number {
			var n1:Number = super.readUnsignedInt();
			var n2:Number = super.readUnsignedInt();
			return n2 * 0x100000000 + n1;	
		}

		public function readString():String {
			var i:uint = super.position;
			while (this[i] && (i+=1)) {};
			var str:String = super.readUTFBytes(i - super.position);
			super.position = i+1; 
			return str;
		}

		public function readRect():Rectangle {
			var pos:uint = super.position;
			var byte:uint = this[pos];
			var bits:uint = byte >> 3;
			var xMin:Number = this.readBits(bits, 5)/20;
			var xMax:Number = this.readBits(bits)/20;
			var yMin:Number = this.readBits(bits)/20;
			var yMax:Number = this.readBits(bits)/20;
			super.position = pos + Math.ceil(((bits * 4) - 3) / 8) + 1;
			return new Rectangle(xMin, yMin, xMax - xMin, yMax - yMin);
		}

		public function readBits(length:uint, start:int = -1):Number {
			if (start < 0) start = this._bitIndex;
			this._bitIndex = start;
			var byte:uint = this[super.position];
			var out:Number = 0;
			var shift:Number = 0;
			var currentByteBitsLeft:uint = 8 - start;
			var bitsLeft:Number = length - currentByteBitsLeft;

			if (bitsLeft > 0) {
				++super.position;
				out = this.readBits(bitsLeft, 0) | ((byte & ((1 << currentByteBitsLeft) - 1)) << (bitsLeft));
			} else {
				out = (byte >> (8 - length - start)) & ((1 << length) - 1);
				this._bitIndex = (start + length) % 8;
				if (start + length > 7) ++super.position;
			}

			return out;
		}

		/**
		 * @private
		 */
		private function readFrameRate():void {
			if (this._version < 8) {
				this._frameRate = super.readUnsignedShort();
			} else {
				var fixed:Number = super.readUnsignedByte()/0xFF;
				this._frameRate = super.readUnsignedByte()+fixed;
			}
		}

		/**
		 * @private
		 */
		private function readHeader():void {
			this._rect = this.readRect();
			this.readFrameRate();		
			super.readShort(); // num of frames
		}
	}
}