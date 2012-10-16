////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.gui.parser.component {

	import by.blooddy.gui.style.StyleApplyer;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					26.04.2010 22:44:55
	 */
	public class ComponentDefinition {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function ComponentDefinition() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var name:String;

		public var controller:Class;

		public const preload:Vector.<String> = new Vector.<String>();

		public var applyer:StyleApplyer;
		
	}

}