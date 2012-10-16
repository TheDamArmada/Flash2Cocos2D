////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	import by.blooddy.core.display.dispose;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					21.02.2010 18:26:29
	 */
	public function dispose(obj:Object, safe:Boolean=true):void {
		if ( !obj ) return;
		if ( obj is IDisposable ) {
			( obj as IDisposable ).dispose();
		} else if ( obj is DisplayObject ) {
			by.blooddy.core.display.dispose( obj as DisplayObject, safe );
		} else if ( obj is BitmapData ) {
			( obj as BitmapData ).dispose();
		} else if ( obj is ByteArray ) {
			( obj as ByteArray ).clear();
		}
	}

}