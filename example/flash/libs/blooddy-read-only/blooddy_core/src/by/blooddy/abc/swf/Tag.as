package by.blooddy.abc.swf {

	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.utils.IExternalizable;

	public final class Tag implements IExternalizable {

		public static const COMPILED_INFO:uint = 41;

		public static const SWF_METADATA:uint = 77;

		public static const DO_ABC:uint = 72;

		public static const DO_ABC_DEFINE:uint = 82;

		public function Tag() {
			super();
		}

		public var id:uint;

		public var length:uint;

		public function readExternal(input:IDataInput):void {
			var tmp:uint = input.readUnsignedShort();
			this.id = tmp >> 6;
			this.length = tmp & 0x3F;
			if (this.length == 0x3F) {
				this.length = input.readUnsignedInt();
			}
		}

		public function writeExternal(output:IDataOutput):void {
			// TODO: дописать
		}

	}

}