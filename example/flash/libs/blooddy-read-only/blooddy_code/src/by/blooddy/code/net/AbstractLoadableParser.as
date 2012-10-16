////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.code.net {
	
	import by.blooddy.code.AbstractParser;
	import by.blooddy.core.managers.process.IProcessable;
	import by.blooddy.core.managers.process.ProgressDispatcher;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					28.04.2010 18:33:50
	 */
	public class AbstractLoadableParser extends AbstractParser {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function AbstractLoadableParser() {
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:IProcessable; 

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected function get loaded():Boolean {
			return !this._loader;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function onLoad():void {
		}

		protected final function addLoader(loader:IProcessable):void {
			if ( loader.complete ) return;
			var loaderDispatcher:ProgressDispatcher = this._loader as ProgressDispatcher;
			if ( loaderDispatcher ) {
				loaderDispatcher.addProcess( loader );
			} else if ( this._loader ) {
				this._loader.removeEventListener( Event.COMPLETE,	this.handler_complete );
				this._loader.removeEventListener( ErrorEvent.ERROR,	this.handler_complete );
				loaderDispatcher = new ProgressDispatcher();
				loaderDispatcher.addProcess( this._loader );
				loaderDispatcher.addProcess( loader );
				this._loader = loaderDispatcher;
				this._loader.addEventListener( Event.COMPLETE,		this.handler_complete, false, int.MIN_VALUE );
				this._loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete, false, int.MIN_VALUE );
			} else {
				this._loader = loader;
				this._loader.addEventListener( Event.COMPLETE,		this.handler_complete, false, int.MIN_VALUE );
				this._loader.addEventListener( ErrorEvent.ERROR,	this.handler_complete, false, int.MIN_VALUE );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			this._loader.removeEventListener( Event.COMPLETE,		this.handler_complete );
			this._loader.removeEventListener( ErrorEvent.ERROR,		this.handler_complete );
			this._loader = null;
			this.onLoad();
		}

	}
	
}