////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.css {

	import by.blooddy.code.css.definition.CSSRule;
	import by.blooddy.code.css.definition.CSSMedia;
	import by.blooddy.code.css.definition.values.CSSValue;
	import by.blooddy.code.css.definition.values.ComplexValue;
	import by.blooddy.code.css.definition.values.AbstractCollectionValue;
	import by.blooddy.code.css.definition.values.CollectionValue;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					14.05.2010 0:25:46
	 */
	public class CSSOptimizer {
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		public static function optimize(medias:Vector.<CSSMedia>, mediaNames:Vector.<String>=null):Vector.<CSSRule> {

			if ( mediaNames ) {
				var l:uint = mediaNames.length;
				var i:uint;
				for ( i=0; i<l; ++i ) {
					mediaNames[ i ] = mediaNames[ i ].toLowerCase();
				}
			} else {
				mediaNames = new Vector.<String>();
			}
			if ( mediaNames.indexOf( 'all' ) < 0 ) {
				mediaNames.push( 'all' );
			}
			
			var result:Vector.<CSSRule> = new Vector.<CSSRule>();
			var rule:CSSRule;
			for each ( var media:CSSMedia in medias ) {
				if ( !media.name || mediaNames.indexOf( media.name.toLowerCase() ) >= 0 ) {
					for each ( rule in media.rules ) {
						result.push( optimizeRule( rule ) );
					}
					
				}
			}
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private class methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static function optimizeRule(rule:CSSRule):CSSRule {
			var result:Object = new Object();
			var v:CSSValue, v2:CSSValue;
			var values:Vector.<CSSValue>;
			var i:uint, l:uint;
			var h:Boolean, h2:Boolean;
			for ( var n:String in rule.declarations ) {
				v = rule.declarations[ n ];
				if ( v is ComplexValue ) {
					v2 = ComplexValueFactory.getValue( v as ComplexValue );
					if ( v2 !== v ) { // если значение новое то надо поставить флаг о изменениях
						v = v2;
						h = true;
					}
				} else if ( v is CollectionValue ) {
					values = ( v as CollectionValue ).values.slice();
					l = values.length;
					h2 = false;
					for ( i=0; i<l; ++i ) {
						v2 = values[ i ];
						if ( v2 is ComplexValue ) {
							values[ i ] = ComplexValueFactory.getValue( v2 as ComplexValue );
							h2 = true;
						}
					}
					if ( h2 ) {
						v = new CollectionValue( values );
						h = true;
					}
				}
				result[ n ] = v;
			}
			return ( h ? new CSSRule( rule.selector, result ) : rule );
		}
		
	}
	
}