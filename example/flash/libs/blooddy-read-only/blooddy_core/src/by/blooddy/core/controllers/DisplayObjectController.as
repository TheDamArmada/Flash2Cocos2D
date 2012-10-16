////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.controllers {

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.display.Stage;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					09.08.2009 18:11:00
	 */
	public class DisplayObjectController extends AbstractController {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DisplayObjectController(controller:IBaseController, container:DisplayObjectContainer, sharedObjectKey:String=null) {
			super( controller, sharedObjectKey );
			this._container = container;
			this._container.addEventListener( Event.ADDED_TO_STAGE,			this.handler_addedToStage,		false, int.MIN_VALUE, true );
			this._container.addEventListener( Event.REMOVED_FROM_STAGE,		this.handler_removedFromStage,	false, int.MIN_VALUE, true );
			if ( this._container.stage ) {
				this._container.addEventListener( Event.ENTER_FRAME,		this.handler_enterFrame );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  container
		//----------------------------------

		/**
		 * @private
		 */
		private var _container:DisplayObjectContainer;

		public function get container():DisplayObjectContainer {
			return this._container;
		}

		//----------------------------------
		//  constructed
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _constructed:Boolean = false;

		public function get constructed():Boolean {
			return this._constructed;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected virtual function construct():void {
		}

		protected virtual function destruct():void {
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_enterFrame(event:Event):void {
			this._container.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
			if ( !this._constructed && this._container.stage ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			if ( !this._constructed ) {
				this._constructed = true;
				this.construct();
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			if ( this._constructed ) {
				this._constructed = false;
				this.destruct();
			}
		}

	}

}