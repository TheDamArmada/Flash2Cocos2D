////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.social.api {
	
	import by.blooddy.core.commands.Command;
	import by.blooddy.core.net.AbstractRemoter;
	import by.blooddy.social.commands.InputSocialAPICommands;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.05.2010 18:12:54
	 */
	public class SocialAPI extends AbstractRemoter {
		
		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace social;

		use namespace social;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function SocialAPI() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected override function $callOutputCommand(command:Command):* {
			return command.call( this, social );
		}

		//--------------------------------------------------------------------------
		//
		//  Social methods
		//
		//--------------------------------------------------------------------------

		social function requestAppInstall():void {
			this.$call( InputSocialAPICommands.RESPONSE_APP_INSTALL_ERROR );
		}
		
		social function requestAppSettings():void {
			this.$call( InputSocialAPICommands.RESPONSE_APP_SETTINGS_ERROR );
		}
		
		social function requestUsers(...usersID):void {
			this.$call( InputSocialAPICommands.RESPONSE_USERS_ERROR );
		}

		social function requestUserFriends():void {
			this.$call( InputSocialAPICommands.RESPONSE_USER_FRIENDS_ERROR );
		}
		
		social function requestUserAppFriends():void {
			this.$call( InputSocialAPICommands.RESPONSE_USER_APP_FRIENDS_ERROR );
		}

		social function requestUserBalance():void {
			this.$call( InputSocialAPICommands.RESPONSE_USER_BALANCE_ERROR );
		}

		social function showAppInstall():void {
			this.$call( InputSocialAPICommands.SHOW_APP_INSTALL_ERROR );
		}

		social function showAppSettings(settings:uint=0):void {
			this.$call( InputSocialAPICommands.SHOW_APP_SETTINGS_ERROR );
		}

		social function showUserFriendsInvite(excludeIDs:Array=null):void {
			this.$call( InputSocialAPICommands.SHOW_USER_FRIENDS_INVITE_ERROR );
		}

		social function showUserBalance(votes:uint=0):void {
			this.$call( InputSocialAPICommands.SHOW_USER_BALANCE_ERROR );
		}

		social function postWallMessage(test:String, imgID:String=null):void {
			this.$call( InputSocialAPICommands.SHOW_USER_BALANCE_ERROR );
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $call(commandName:String, ...parameters):void {
			super.$invokeCallInputCommand( new Command( commandName, parameters ) );
		}
		
	}

}