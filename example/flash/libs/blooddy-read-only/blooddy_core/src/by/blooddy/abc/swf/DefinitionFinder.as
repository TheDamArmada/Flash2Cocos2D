////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package platform.utils {
	import flash.utils.ByteArray;

	/**
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class DefinitionFinder {

		/**
		 * @private
		 */
		private static const TAG_DO_ABC:uint = 72;

		/**
		 * @private
		 */
		private static const TAG_DO_ABC_DEFINE:uint = 82;

		/**
		 * @private
		 */
		private static const VERSION_MINOR:uint = 0x0010;

		/**
		 * @private
		 */
		private static const VERSION_MAJOR:uint = 0x002E;

		public function DefinitionFinder(bytes:ByteArray) {
			super();
			this._data = new SWFByteArray(bytes);
		}

		/**
		 * @private
		 */
		private var _data:SWFByteArray;

		/**
		 * @private
		 */
		private var _stringTable:Array;

		/**
		 * @private
		 */
		private var _namespaceTable:Array;

		/**
		 * @private
		 */
		private var _multinameTable:Array;

		public function getDefinitionNames():Array {
			var definitions:Array = new Array();
			this._data.position = 13;
			var length:uint = this.findTag();
			var pos:uint;

			while (length) {
				pos = this._data.position;
				definitions.push.apply(definitions, this.getDefinitionNamesInTag());
				this._data.position = pos+length;
				length = this.findTag();
			}

			return definitions;
		}

		/**
		 * @private
		 */
		private function findTag():uint {
			var tag:uint;
			var id:uint;
			var length:uint;
			var minorVersion:uint;
			var majorVersion:uint;

			while (this._data.bytesAvailable) {
				tag = this._data.readUnsignedShort();
				id = tag >> 6;
				length = tag & 0x3F;
				length = (length == 0x3F) ? this._data.readUnsignedInt() : length;

				switch (id) {
					case DefinitionFinder.TAG_DO_ABC:
					case DefinitionFinder.TAG_DO_ABC_DEFINE:

						if (id == DefinitionFinder.TAG_DO_ABC_DEFINE) {
							this._data.position += 4;
							this._data.readString(); // identifier
						}

						minorVersion = this._data.readUnsignedShort();
						majorVersion = this._data.readUnsignedShort();

						if (minorVersion == DefinitionFinder.VERSION_MINOR && majorVersion == DefinitionFinder.VERSION_MAJOR) {
							return length;
						} else {
							this._data.position += length;
						}
					break;
					default:
						this._data.position += length;
				}
			}

			return 0;
		}

		/**
		 * @private
		 */
		private function getDefinitionNamesInTag():Array {
			var count:int;
			var kind:uint;
			var id:uint;
			var flags:uint;
			var counter:uint;
			var ns:uint;
			var names:Array = new Array();
			this._stringTable = new Array();
			this._namespaceTable = new Array();
			this._multinameTable = new Array();

			// int table
			count = this._data.readASInt()-1;

			while (count > 0 && count--) {
				this._data.readASInt();
			}

			// uint table
			count = this._data.readASInt()-1;

			while (count > 0 && count--) {
				this._data.readASInt();
			}

			// Double table
			count = this._data.readASInt()-1;

			while (count > 0 && count--) {
				this._data.readDouble();
			}

			// String table
			count = this._data.readASInt()-1;
			id = 1;

			while (count > 0 && count--) {
				this._stringTable[id] = this._data.readUTFBytes(this._data.readASInt());
				id++;
			}

			// Namespace table
			count = this._data.readASInt()-1;
			id = 1;

			while (count > 0 && count--) {
				this._data.readUnsignedByte();
				this._namespaceTable[id] = this._data.readASInt();
				id++;
			}

			// NsSet table
			count = this._data.readASInt()-1;

			while (count > 0 && count--) {
				 counter = this._data.readUnsignedByte();
				 while (counter--) this._data.readASInt();
			}

			// Multiname table
			count = this._data.readASInt()-1;
			id = 1;

			while (count > 0 && count--) {
				kind = this._data.readASInt();

				switch (kind) {
					case 0x07:
					case 0x0D:
						ns =  this._data.readASInt();
						this._multinameTable[id] = [ns, this._data.readASInt()];
						break;
					case 0x0F:
					case 0x10:
						this._multinameTable[id] = [0, this._stringTable[this._data.readASInt()]];
						break;
					case 0x11:
					case 0x12:
						break;
					case 0x09:
					case 0x0E:
						this._multinameTable[id] = [0, this._stringTable[this._data.readASInt()]];
						this._data.readASInt();
						break;	
					case 0x1B:
					case 0x1C:
						this._data.readASInt();
						break;	
				}

				id++;
			}

			// Method table
			count = this._data.readASInt();

			while (count > 0 && count--) {
				var paramsCount:int = this._data.readASInt();
				counter = paramsCount;
				this._data.readASInt();
				while (counter--) this._data.readASInt();
				this._data.readASInt();
				flags = this._data.readUnsignedByte();

				if (flags & 0x08) {
					counter = this._data.readASInt();

					while (counter--) {
						this._data.readASInt();
						this._data.readASInt();
					}
				}

				if (flags & 0x80) {
					counter = paramsCount;
					while (counter--) this._data.readASInt();
				}
			}

			// Metadata table
			count = this._data.readASInt();

			while (count > 0 && count--) {
				this._data.readASInt();
				counter = this._data.readASInt();

				while (counter--) {
					this._data.readASInt();
					this._data.readASInt();
				}
			}

			// Instance table
			count = this._data.readASInt();
			var nss:uint;

			while (count > 0 && count--) {
				id = this._data.readASInt();
				this._data.readASInt();
				flags = this._data.readUnsignedByte();
				if (flags & 0x08) nss = this._data.readASInt();
				counter = this._data.readASInt();
				while (counter--) this._data.readASInt();
				this._data.readASInt();
				var traitCount:uint = this._data.readASInt();

				while (traitCount--) {
					this._data.readASInt();
					kind = this._data.readUnsignedByte();
					var upperBits:uint = kind >> 4;
					var lowerBits:uint = kind & 0xF;

					switch (lowerBits) {
						case 0x00:
						case 0x06:
							this._data.readASInt();
							this._data.readASInt();
							if (this._data.readASInt()) this._data.readUnsignedByte();		
						break;
						default:
							this._data.readASInt();
							this._data.readASInt();
					}

					if (upperBits & 0x04) {
						counter = this._data.readASInt();
						while (counter--) this._data.readASInt();
					}
				}

				ns = this._multinameTable[id][0];
				var nameSpace:String = this._stringTable[this._namespaceTable[ns]];

				if (flags & 0x08 && !this._namespaceTable[ns]) {
					//names.push(this._stringTable[this._namespaceTable[nss]].replace(':','::')); // exclude private classes
				} else names.push((nameSpace ? nameSpace+'::' : '') + this._stringTable[this._multinameTable[id][1]]);
			}

			return names;
		}
	}
}