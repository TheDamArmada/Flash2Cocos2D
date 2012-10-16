////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.managers.process {

	import by.blooddy.core.utils.callNextFrame;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import by.blooddy.core.net.loading.ILoadable;
	import by.blooddy.core.net.loading.ILoader;

	//--------------------------------------
	//  Implements events
	//--------------------------------------

	/**
	 * @inheritDoc
	 */
	[Event( name="complete", type="flash.events.Event" )]

	/**
	 * @inheritDoc
	 */
	[Event( name="progress", type="flash.events.ProgressEvent" )]

	/**
	 * Класс предназначен для мониторинга процесса загрузки
	 * нескольких файлов одновременно.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class ProgressDispatcher extends EventDispatcher implements IProgressProcessable {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function ProgressDispatcher() {
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
		private var _toProgress:Boolean = false;

		/**
		 * @private
		 */
		private var _toComplete:Boolean = false;

		/**
		 * @private
		 */
		private const _processes:Vector.<IProcessable> = new Vector.<IProcessable>();

		//--------------------------------------------------------------------------
		//
		//  Implements properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  complete
		//----------------------------------

		/**
		 * @private
		 */
		private var _complete:Boolean = true;

		/**
		 * @inheritDoc
		 */
		public function get complete():Boolean {
			return this._complete;
		}

		//--------------------------------------------------------------------------
		//
		//  Implements properties: IProgressable
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _progress:Number = 1;

		/**
		 * @inheritDoc
		 */
		public function get progress():Number {
			return this._progress;
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public function addProcess(process:IProcessable):void {
			this.$addProcess( process );
		}

		public function removeProcess(process:IProcessable):void {
			this.$removeProcess( process );
		}

		public function hasProcess(process:IProcessable):Boolean {
			return ( this._processes.indexOf( process ) >= 0 );
		}

		public function clear():void {
			while ( this._processes.length > 0 ) {
				this.$removeProcess( this._processes[ this._processes.length - 1 ] as IProcessable, false );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private function $addProcess(process:IProcessable):void {
			if ( this._processes.indexOf( process ) >= 0 ) return; // проверим. может какой-то баран уже дабавил нас сюда.

			// подписываем с минимальными приоритетом. мы контэйнер, и должны отработать последними
			if ( !process.complete ) {
				process.addEventListener( Event.COMPLETE,				this.handler_complete, false, int.MIN_VALUE );
				process.addEventListener( ErrorEvent.ERROR,				this.handler_error, false, int.MIN_VALUE );
				if ( process is IProgressable ) {
					process.addEventListener( ProgressEvent.PROGRESS,	this.handler_progress, false, int.MIN_VALUE );
				}
			}
			if ( process is ILoader ) {
				process.addEventListener( Event.UNLOAD,					this.handler_error, false, int.MIN_VALUE );
			}

			this._processes.push( process );

			this._complete &&= process.complete;
			if ( this._complete && !this._toComplete) {
				this._toComplete = true;
				callNextFrame( this.tryComplete );
			}
		}

		/**
		 * @private
		 */
		private function $removeProcess(process:IProcessable, update:Boolean=true):void {
			process.removeEventListener( Event.COMPLETE,			this.handler_complete );
			process.removeEventListener( ProgressEvent.PROGRESS,	this.handler_progress );
			process.removeEventListener( ErrorEvent.ERROR,			this.handler_error );
			process.removeEventListener( Event.UNLOAD,				this.handler_error );

			var index:int = this._processes.lastIndexOf( process );
			if ( index < 0 ) return; // надо удалить, если такой присутвует...
			this._processes.splice( index, 1 );

			if ( update ) {
				this.updateComplete();
			}

		}

		/**
		 * @private
		 */
		private function updateComplete():void {
			this._complete = true;
			for each ( var process:IProcessable in this._processes ) {
				if ( !process.complete ) {
					this._complete = false;
					break;
				}
			}
			if ( this._complete && !this._toComplete) {
				this._toComplete = true;
				callNextFrame( this.tryComplete );
			}
		}

		/**
		 * @private
		 */
		private function updateProgress():void {
			this._toProgress = false;
			var loaded:uint;
			var total:uint;
			var progress:Number = 0;
			var p:Number;
			var i:uint = 0;
			var j:uint = 0;
			var loader:ILoadable;
			for each ( var process:IProcessable in this._processes ) {
				loader = process as ILoadable;
				if ( process.complete ) {
					++progress;
				} else if ( loader && loader.bytesTotal > 0 ) {
					loaded += loader.bytesLoaded;
					total += loader.bytesTotal;
					++j;
				} else if ( process is IProgressable ) {
					p = ( process as IProgressable ).progress;
					if ( isFinite( p ) ) {
						progress += p;
					}
				}
				++i;
			}
			this._progress = (
				i > 0
				?	( progress + ( total > 0 ? loaded / total * j : 0 ) ) / i
				:	1
			);
			if ( super.hasEventListener( ProgressEvent.PROGRESS ) ) {
				super.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, loaded, total ) );
			}
		}

		/**
		 * @private
		 */
		private function tryComplete():void {
			this._toComplete = false;
			if ( !this._complete ) return;
			this.updateProgress();
			// загрузилось всё. чистимся и вызываемся.
			while ( this._processes.length > 0 ) {
				this.$removeProcess( this._processes[ this._processes.length - 1 ], false );
			}
			super.dispatchEvent( new Event( Event.COMPLETE ) );
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
			this.updateComplete();
		}

		/**
		 * @private
		 */
		private function handler_error(event:Event):void {
			this.$removeProcess( event.target as IProcessable );
		}

		/**
		 * @private
		 */
		private function handler_progress(event:ProgressEvent):void {
			if ( !this._toProgress ) {
				this._toProgress = true;
				callNextFrame( this.updateProgress );
			}
		}

	}

}