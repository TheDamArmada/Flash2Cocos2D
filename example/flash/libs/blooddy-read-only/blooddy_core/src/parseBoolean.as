////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package {

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 * 
	 * @keyword					text, bool, boolean
	 */
	public function parseBoolean(s:String):Boolean {
		if ( !s ) return false;
		s = s.toLowerCase();
		return s && !(
			s == 'false' ||
			s == 'nan' ||
			s == 'no' ||
			parseFloat(s) == 0
		)
	}

}