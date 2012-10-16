////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.net {

	import flash.system.Capabilities;
	import flash.net.LocalConnection;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Mar 12, 2010 6:00:18 PM
	 */
	public const domain:String = (
		Capabilities.playerType == 'Desktop' || Capabilities.playerType == 'StandAlone'
		?	'localhost'
		:	( new LocalConnection() ).domain
	);

}