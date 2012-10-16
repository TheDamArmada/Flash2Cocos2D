////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="namespace", name="$protected" )]

	[Exclude( kind="method", name="$totalFrames" )]
	[Exclude( kind="method", name="$currentFrame" )]

	[Exclude( kind="method", name="addFrameScript" )]
	[Exclude( kind="method", name="setCurrentFrame" )]

	[ExcludeClass]
	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					movieclipcollectionasset, movieclip, collection
	 */
	public class MovieClipEquivalent extends BaseMovieClip {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		protected namespace $protected;

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function MovieClipEquivalent() {
			super();
			this.play();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private var _running:Boolean = false;

		/**
		 * @private
		 */
		private var _frameScripts:Object;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: MovieClip
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected var $totalFrames:int = 0;

		/**
		 * @private
		 */
		public override function get totalFrames():int {
			return this.$totalFrames;
		}

		/**
		 * @private
		 */
		$protected var $currentFrame:int = 0;

		/**
		 * @private
		 */
		public override function get currentFrame():int {
			return this.$currentFrame;
		}

		/**
		 * @private
		 */
		$protected function $setCurrentFrame(value:int):void {
			this.$currentFrame = value;
		}

		/**
		 * @private
		 */
		public override function get framesLoaded():int {
			return this.$totalFrames;
		} 

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function play():void {
			this._running = true;
			super.addEventListener( Event.ENTER_FRAME, this.handler_enterFrame, false, int.MAX_VALUE, true );
		}

		/**
		 * @private
		 */
		public override function stop():void {
			this._running = false;
			super.removeEventListener( Event.ENTER_FRAME, this.handler_enterFrame );
		}

		/**
		 * @private
		 */
		public override function nextFrame():void {
			if ( this.$currentFrame < this.$totalFrames ) {
				this.$setCurrentFrame( this.$currentFrame + 1 );
			}
		}

		/**
		 * @private
		 */
		public override function prevFrame():void {
			if ( this.$currentFrame > 1 ) {
				this.$setCurrentFrame( this.$currentFrame - 1 );
			}
		}

		/**
		 * @private
		 */
		public override function gotoAndPlay(frame:Object, scene:String=null):void {
			var f:int = int( Number( frame ) );
			if ( this.$currentFrame != f && f>0 && f <= this.$totalFrames ) {
				this.$setCurrentFrame( f );
			}
			if ( !this._running ) this.play();
		}

		/**
		 * @private
		 */
		public override function gotoAndStop(frame:Object, scene:String=null):void {
			var f:int = int( Number(frame) );
			if ( this.$currentFrame != f && f>0 && f <= this.$totalFrames ) {
				this.$setCurrentFrame( f );
			}
			if ( this._running ) this.stop();
		}

		[Deprecated( message="метод не используется" )]
		public override function addFrameScript(...args):void {
			throw new IllegalOperationError();
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
			this.$setCurrentFrame( this.$currentFrame == this.$totalFrames ? 1 : this.$currentFrame + 1 );
		}

	}

}