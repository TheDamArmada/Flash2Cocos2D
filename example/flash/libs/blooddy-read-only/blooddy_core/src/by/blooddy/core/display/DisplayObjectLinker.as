////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					04.08.2009 20:53:02
	 */
	public class DisplayObjectLinker {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function link(container:DisplayObjectContainer!, child:DisplayObject!, strict:Boolean=false):DisplayObjectLinker {
			return new DisplayObjectLinker( container, child, strict );
		}

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DisplayObjectLinker(container:DisplayObjectContainer!, child:DisplayObject!, strict:Boolean=false) {
			super();
			this._container = container;
			this._child = child;
			this._strict = strict;
			if ( !container.contains( child ) ) container.addChild( child );
			child.addEventListener( Event.REMOVED, this.handler_removed, false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _child:DisplayObject;

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		/**
		 * @private
		 */
		private var _strict:Boolean;

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_removed(event:Event):void {
			if ( event.target === this._child ) {
				this._container.addChild( this._child );
				if ( this._strict ) throw new IllegalOperationError();
			}
		}

	}

}