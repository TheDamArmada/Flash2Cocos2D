////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.external.net.connection.filters {

	import by.blooddy.core.net.NetCommand;
	import by.blooddy.core.net.connection.filters.TextSocketFilter;
	import by.blooddy.crypto.serialization.JSON;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					19.09.2010 14:16:58
	 */
	public class JSONSocketFilter extends TextSocketFilter {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function JSONSocketFilter() {
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		public override function decodeCommand(data:String, io:String=NetCommand.INPUT):NetCommand {
			var o:* = JSON.decode( data );
			if ( o is Array ) {
				return new NetCommand( o.shift(), io, o );
			}
			return null;
		}

		public override function encodeCommand(command:NetCommand):String {
			var arr:Array = command.slice();
			arr.unshift( command.name );
			return JSON.encode( arr );
		}

	}
	
}