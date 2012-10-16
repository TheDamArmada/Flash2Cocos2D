/*!
 * blooddy/social_api/user.js
 * © 2009 BlooDHounD
 * @author BlooDHounD <http://www.blooddy.by>
 */

if ( !window.blooddy ) throw new Error( '"blooddy" not initialized' );

blooddy.require( 'blooddy.SocialApi' );

if ( !blooddy.SocialApi.User ) {

	/**
	 * @property
	 * @final
	 * @namespace	blooddy.SocialApi
	 * @extends		blooddy.SocialApi
	 * @author		BlooDHounD	<http://www.blooddy.by>
	 */
	blooddy.SocialApi.User = ( function() {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @constructor
		 */
		var User = new Function(),
			UserPrototype = User.prototype;

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.id = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.firstName = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.lastName = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.nickName = null;

		/**
		 * @property
		 * @type	{Number}
		 */
		UserPrototype.sex = -1;

		/**
		 * @property
		 * @type	{Date}
		 */
		UserPrototype.birthday = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.avatarBig = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.avatarMedium = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.avatarSmall = null;

		/**
		 * @property
		 * @type	{String}
		 */
		UserPrototype.uri = null;

		/**
		 * @method
		 * @override
		 * @return	{String}
		 */
		UserPrototype.toString = function() {
			return '[User id="' + this.id + '"]';
		};

		return User;

	}() );

}