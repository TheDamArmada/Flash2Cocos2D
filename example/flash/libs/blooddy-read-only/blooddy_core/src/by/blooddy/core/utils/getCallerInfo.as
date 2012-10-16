////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.utils {

	/**
	 * @return					XML с описанием вызываемого метода.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public function getCallerInfo():XML {
		var instance:String = ( new Error() ).getStackTrace().match( PATTERN_STACK )[2];
		if ( instance ) {
			var result:Array = instance.match(PATTERN_INSTANCE);
			var node:XML;
			if ( result[9] ) {
				node = <node />;
				node.@name = result[9];
				node.setName( result[6] ? "accessor" : "method" );
				if ( result[8] ) {
					node.@uri = result[8];
				}
			}

			var type:XML;
			if ( result[4] && result[4] != "global" ) {
				type = <type />;
				type.@name = result[4];
				if ( result[3] ) {
					type.@uri = result[3];
				}
				if ( node ) {
					type.appendChild( node );
				}
			}

			if ( type ) return type;
			if ( node ) return node;
		}
		return null;
	}

}

/**
 * @private
 */
internal const PATTERN_STACK:RegExp = /(?<=^\sat\s).+?(?=\(\))/gm;

/**
 * @private
 */
internal const PATTERN_INSTANCE:RegExp = /^(((.+?)::)?(.+?))?(\/(get\s|set\s)?((.+?)::)?(.+?))?$/;