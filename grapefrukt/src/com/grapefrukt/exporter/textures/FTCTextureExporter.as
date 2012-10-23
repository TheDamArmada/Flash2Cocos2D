package com.grapefrukt.exporter.textures
{
	import com.grapefrukt.exporter.debug.Logger;
	import com.grapefrukt.exporter.misc.FunctionQueue;
	import com.grapefrukt.exporter.serializers.files.IFileSerializer;
	import com.grapefrukt.exporter.serializers.images.IImageSerializer;

	/**
	 * @author Chad Stuempges
	 */
	public class FTCTextureExporter extends TextureExporter
	{
		public function FTCTextureExporter(queue : FunctionQueue, imageSerializer : IImageSerializer, fileSerializer : IFileSerializer, vectorSerializer : IImageSerializer = null)
		{
			super(queue, imageSerializer, fileSerializer, vectorSerializer);
		}

		public override function queue(texture : TextureBase, serializer : IImageSerializer) : void
		{
			_queue.add(function() : void
			{
				texture.extension = serializer.extension;

				var fileName : String;

				if (texture is FTCBitmapTexture)
					fileName = FTCBitmapTexture(texture).getFilenameWithPathAndSuffix();
				else
					fileName = texture.filenameWithPath;

				Logger.log("FTCTextureExporter", "compressing: " + fileName, "", Logger.NOTICE);
				_file_serializer.serialize(fileName, serializer.serialize(texture));
			});
		}
	}
}
