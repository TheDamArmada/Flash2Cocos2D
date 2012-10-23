package com.grapefrukt.exporter.textures
{
	import com.grapefrukt.exporter.settings.Settings;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	/**
	 * @author Chad Stuempges
	 */
	public class FTCBitmapTexture extends BitmapTexture
	{
		public var fileSuffix : String = "";

		public function FTCBitmapTexture(name : String, bitmap : BitmapData, bounds : Rectangle, zIndex : int, isMask : Boolean = false)
		{
			super(name, bitmap, bounds, zIndex, isMask);
		}

		public function getFilenameWithPathAndSuffix() : String
		{
			return sheet.name + Settings.directorySeparator + name + fileSuffix + extension;
		}
	}
}
