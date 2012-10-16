////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import by.blooddy.core.managers.process.IProgressable;

	/**
	 * Интерфейс прогресс бара.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public interface IProgressBar {

		function get progress():Number;
		function set progress(value:Number):void;

		function get progressDispatcher():IProgressable;
		function set progressDispatcher(value:IProgressable):void;

	}

}