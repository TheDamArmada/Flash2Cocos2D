////////////////////////////////////////////////////////////////////////////////
//
//  © 2010 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display.resource {

	import by.blooddy.core.events.display.resource.ResourceEvent;
	import by.blooddy.core.managers.process.IProgressProcessable;
	import by.blooddy.core.managers.process.IProgressable;
	import by.blooddy.core.managers.process.ProgressDispatcher;
	import by.blooddy.core.net.loading.ILoadable;
	
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;

	[Event( name="draw", type="flash.events.Event" )]
	[Event( name="clear", type="flash.events.Event" )]

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 * @created					Feb 18, 2010 1:43:19 PM
	 */
	public class LoadableResourceSprite extends ResourceSprite {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function LoadableResourceSprite() {
			super();
			super.addEventListener( ResourceEvent.ADDED_TO_MAIN,		this.handler_addedToMain,		false, int.MIN_VALUE, true );
			super.addEventListener( ResourceEvent.REMOVED_FROM_MAIN,	this.handler_removedFromMain,	false, int.MAX_VALUE, true );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _loader:IProgressProcessable;

		/**
		 * @private
		 */
		private var _isDrawed:Boolean = false;

		/**
		 * @private
		 */
		private var _hasStage:Boolean = false;

		/**
		 * @private
		 */
		private var _invalidated:int = 0;

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		protected function isDrawed():Boolean {
			return this._isDrawed;
		}
		
		protected final function invalidate(immediately:Boolean=false):void {

			if ( this._invalidated == 2 ) {

				throw new IllegalOperationError( 'recursive "ivalidate" call' );

			} else if ( this._invalidated == 0 && super.hasManager() ) {

				if ( !immediately && stage ) {
	
					this._invalidated = 1;

					stage.addEventListener( Event.ENTER_FRAME,	this.handler_render );
					stage.addEventListener( Event.RENDER,		this.handler_render );
					stage.invalidate();

				} else {

					this.$invalidate();

				}

			}
		}

		protected function getResourceBundles():Array {
			return null;
		}

		protected function drawPreloader(loader:IProgressable):Boolean {
			return super.hasManager();
		}

		protected function clearPreloader(loader:IProgressable):Boolean {
			return true;
		}

		protected function draw():Boolean {
			return super.hasManager();
		}

		protected function clear():Boolean {
			return true;
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $invalidate():void {

			if ( this._invalidated == 2 ) {
				throw new IllegalOperationError( 'recursive "ivalidate" call' );
			}
			this._invalidated = 2;

			if ( this._isDrawed ) {
				this.$clear();
			}
			if ( this._loader ) {
				this.$clearLoader();
			}

			if ( !this._hasStage ) return; // манагер может быть, а сцены - нет

			var resources:Array = this.getResourceBundles();
			var loader:ILoadable;
			if ( resources ) {
				if ( resources.length == 1 ) {
					
					if ( resources[ 0 ] ) {
						loader = super.loadResourceBundle( resources[ 0 ] );
						if ( !loader.complete ) {
							this._loader = loader;
						}
					}
					
				} else {
					
					var loaderDispatcher:ProgressDispatcher;
					
					for each ( var bundleName:String in resources ) {
						if ( bundleName ) {
							loader = super.loadResourceBundle( bundleName );
							if ( !loader.complete ) {
								if ( loaderDispatcher ) {
									
									loaderDispatcher.addProcess( loader );
									
								} else if ( this._loader ) {
									
									if ( this._loader !== loader ) {
										
										loaderDispatcher = new ProgressDispatcher();
										loaderDispatcher.addProcess( this._loader );
										loaderDispatcher.addProcess( loader );
										this._loader = loaderDispatcher;
										
									}
									
								} else {
									
									this._loader = loader;
									
								}
							}
						}
					}
					
				}
			}
			if ( this._loader ) {
				this._loader.addEventListener( Event.COMPLETE, this.handler_complete );
				if ( !( this._loader is ProgressDispatcher ) ) {
					this._loader.addEventListener( ErrorEvent.ERROR, this.handler_complete );
				}
			}
			
			if ( this._hasStage ) {
				this.$draw();
			}

			this._invalidated = 0;

		}

		/**
		 * @private
		 */
		private function $clearLoader():void {
			if ( this._loader is ProgressDispatcher ) {
				( this._loader as ProgressDispatcher ).clear();
			} else {
				this._loader.removeEventListener( ErrorEvent.ERROR, this.handler_complete );
			}
			this._loader.removeEventListener( Event.COMPLETE, this.handler_complete );
			this._loader = null;
		}
		
		/**
		 * @private
		 */
		private function $draw():void {
			this._isDrawed = true;
			if ( this._loader ) {
				if ( this.drawPreloader( this._loader ) ) {
					
				} else {
					this.clearPreloader( this._loader );
					this._isDrawed = false;
				}
			} else {
				if ( this.draw() ) {
					if ( super.hasEventListener( 'draw' ) ) {
						super.dispatchEvent( new Event( 'draw' ) );
					}
				} else {
					this.clear();
					this._isDrawed = false;
				}
			}
		}

		/**
		 * @private
		 */
		private function $clear():void {
			if ( this._loader ) {
				this.clearPreloader( this._loader );
			} else {
				this.clear();
				if ( super.hasEventListener( 'clear' ) ) {
					super.dispatchEvent( new Event( 'clear' ) );
				}
			}
			this._isDrawed = false;
		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function handler_addedToMain(event:ResourceEvent):void {
			this._hasStage = true;
			super.addEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage );
			super.addEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage );
			this.$invalidate();
		}
		
		/**
		 * @private
		 */
		private function handler_removedFromMain(event:ResourceEvent):void {
			if ( this._isDrawed ) {
				this.$clear();
			}
			super.removeEventListener( Event.REMOVED_FROM_STAGE,	this.handler_removedFromStage );
			super.removeEventListener( Event.ADDED_TO_STAGE,		this.handler_addedToStage );
			if ( this._loader ) {
				this.$clearLoader();
			}
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			this._hasStage = true;
			if ( !this._isDrawed ) {
				this.$invalidate();
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			this._hasStage = false;
		}
		
		/**
		 * @private
		 */
		private function handler_complete(event:Event):void {
			if ( this._isDrawed ) {
				this.$clear();
			}
			this.$clearLoader();
			if ( this._hasStage ) {
				this.$draw();
			}
		}

		/**
		 * @private
		 */
		private function handler_render(event:Event):void {
			event.target.removeEventListener( Event.RENDER,			this.handler_render );
			event.target.removeEventListener( Event.ENTER_FRAME,	this.handler_render );
			this.$invalidate();
		}

	}

}