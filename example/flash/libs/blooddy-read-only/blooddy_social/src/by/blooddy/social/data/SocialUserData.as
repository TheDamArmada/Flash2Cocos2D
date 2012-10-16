////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.data {
	
	import by.blooddy.core.data.Data;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					27.05.2010 12:53:30
	 */
	public class SocialUserData extends Data {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function SocialUserData(id:String) {
			super();
			this.id = id;
		}
		
		public var id:String;
		
		public var firstName:String;
		
		public var lastName:String;
		
		public var nickName:String;
		
		public var sex:int = -1;
		
		public var birthday:Date;
		
		public var photo:String;
		
		public var mediumPhoto:String;
		
		public var bigPhoto:String;
		
		public var url:String;
		
	}

}