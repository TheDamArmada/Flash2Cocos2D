////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package ru.avangardonline.data {

	import by.blooddy.core.data.Data;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.11.2009 12:47:19
	 */
	public interface IClonableData {
		
		function clone():Data;

		function copyFrom(data:Data):void;

	}
	
}