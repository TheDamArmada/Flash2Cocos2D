////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.style.meta {
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					25.08.2010 14:10:00
	 */
	public class CollectionStyle extends AbstractStyle {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function CollectionStyle() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public const styles:Vector.<String> = new Vector.<String>();
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function toXML(local:Boolean=false):XML {
			var xml:XML = <proxy />;
			for each ( var n:String in this.styles ) {
				xml.appendChild( <style name={ n } /> );
			}
			return xml;
		}

	}
	
}