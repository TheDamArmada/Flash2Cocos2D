/*
Copyright 2011 Martin Jonasson, grapefrukt games. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY grapefrukt games "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL grapefrukt games OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of grapefrukt games.
 */
package com.grapefrukt.exporter.simple
{
	import com.grapefrukt.exporter.collections.*;
	import com.grapefrukt.exporter.debug.*;
	import com.grapefrukt.exporter.textures.*;
	import flash.display.DisplayObjectContainer;

	/**
	 * @author Chad Stuempges
	 */
	public class FTCSimpleExport extends SimpleExport
	{
		private var _texturesArt : TextureSheetCollection;
		private var _texturesFile : TextureSheetCollection;

		/**
		 * Creates the SimpleExport
		 * @param	root	The GUI elements will be added to this DisplayObjectContainer
		 */
		public function FTCSimpleExport(root : DisplayObjectContainer, id : String = "") : void
		{
			super(root, id);

			_texturesArt = new TextureSheetCollection;
			_texturesFile = new TextureSheetCollection;
			_texture_exporter = new FTCTextureExporter(_queue, _image_serializer, _file_serializer);
		}

		/**
		 * Starts the extracting and compressing of textures 
		 * @param	autoOutput	automatic output once extraction is complete, can't normally be used due to the filereference window that is spawned by output is required to be in respose to a mouse event
		 */
		public override function export(autoOutput : Boolean = false) : void
		{
			_queue.add(function() : void
			{
				// start the exporting of textures (this adds all the texture exports to the queue)
				_texture_exporter.queueCollection(_texturesArt);
				_texture_exporter.queueCollection(_fonts);
			});

			// the function above pushes a whole bunch of things onto the queue, when those are done
			// we initiate the final output phase

			_queue.add(function() : void
			{
				ftcComplete(autoOutput);
			});
		}

		private function ftcComplete(autoOutput : Boolean = true) : void
		{
			_queue.add(function() : void
			{
				// by now, all the actual graphics are already output, but we still need to create the
				// xml file that contains all the sheet data

				if (_texturesFile.size)
				{
					Logger.log("SimpleExport", "exporting sheet xml");

					try
					{
						_file_serializer.serialize(_objectId + "sheets.xml", _data_serializer.serialize(_texturesFile));
					}
					catch (error : Error)
					{
						trace("\tDid not replace existing file: sheets.xml");
					}
				}
				else
				{
					Logger.log("SimpleExport", "no textures to export");
				}
			});

			_queue.add(function() : void
			{
				trace("ANIMATIONS : " + _animations);

				if (_animations.size)
				{
					Logger.log("SimpleExport", "exporting animation xml");

					try
					{
						_file_serializer.serialize(_objectId + "animations.xml", _data_serializer.serialize(_animations));
					}
					catch (error : Error)
					{
						trace("\tDid not replace existing file: animations.xml");
					}
				}
				else
				{
					Logger.log("SimpleExport", "no animations to export");
				}
			});

			_queue.add(function() : void
			{
				if (_fonts.size)
				{
					Logger.log("SimpleExport", "exporting font xml");
					for each (var fontsheet:FontSheet in _fonts.sheets)
					{
						_file_serializer.serialize("fonts/" + fontsheet.fontName + ".xml", _data_serializer.serialize(fontsheet, true));
					}
				}
				else
				{
					Logger.log("SimpleExport", "no fonts to export");
				}
			});

			if (autoOutput)
			{
				_queue.add(function() : void
				{
					output();
				});
			}
		}

		public override function get textures() : TextureSheetCollection
		{
			var combinedCollection : TextureSheetCollection = new TextureSheetCollection();

			var i : int = 0;
			for (;i < _texturesArt.size; i++)
			{
				combinedCollection.add(_texturesArt.getAtIndex(i));
			}
			for (i = 0; i < _texturesFile.size; i++)
			{
				combinedCollection.add(_texturesFile.getAtIndex(i));
			}

			return combinedCollection;
		}

		public function get texturesArt() : TextureSheetCollection
		{
			return _texturesArt;
		}

		public function get texturesFile() : TextureSheetCollection
		{
			return _texturesFile;
		}

		public override function get animations() : AnimationCollection
		{
			return _animations;
		}

		public override function get fonts() : FontSheetCollection
		{
			return _fonts;
		}
	}
}