////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils.validators {

	/**
	 * Проверяет корректность мылника.
	 * 
	 * @param	value			Строка на проверку.
	 * 
	 * @return					true, если валиден.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function validateEmail(email:String):Boolean {
		return Boolean(email_pattern.exec(email));
	}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper variable: email_pattern
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Специаьельный регэксп для проверки на валидность мыла.
 */
internal const email_pattern:RegExp = /^[\w.-]+@[\w.-]+\.\w{2,4}$/;