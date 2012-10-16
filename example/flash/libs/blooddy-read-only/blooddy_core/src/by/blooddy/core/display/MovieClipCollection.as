////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 *
	 * @keyword					movieclipcollection, movieclip, collection
	 */
	public class MovieClipCollection extends MovieClipEquivalent {

		//--------------------------------------------------------------------------
		//
		//  Namespaces
		//
		//--------------------------------------------------------------------------

		use namespace $protected;

		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		private static const _HASH:Array = new Array(
			null,
			new Array()
		);

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
 		 * Constructor
		 */
		public function MovieClipCollection() {
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
		private var _hash:Array = _HASH[1];

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: MovieClip
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function addChild(child:DisplayObject):DisplayObject {
			child = super.addChild( child );
			if ( child ) this.addedChild( child );
			return child;
		}

		/**
		 * @private
		 */
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject {
			child = super.addChildAt( child, index );
			if ( child ) this.addedChild( child );
			return child;
		}

		/**
		 * @private
		 */
		public override function removeChild(child:DisplayObject):DisplayObject {
			child = super.removeChild( child );
			if ( child ) this.removedChild( child );
			return child;
		}

		/**
		 * @private
		 */
		public override function removeChildAt(index:int):DisplayObject {
			var child:DisplayObject = super.removeChildAt( index );
			if ( child ) this.removedChild( child );
			return child;
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$protected override function $setCurrentFrame(value:int):void {
			var oldFrame:int = this.$currentFrame;
			this.$currentFrame = value;
			// поменяем кадры
			var num:uint = super.numChildren;
			var mc:MovieClip;
			while ( num-- ) {
				mc = super.getChildAt( num ) as MovieClip;
				if ( mc ) {
					mc.gotoAndStop( this.getCurrentFrame( mc.totalFrames ) );
				}
			}
		}

		/**
		 * @private
		 */
		private function setTotalFrame(value:int):void {
			this.$totalFrames = value;
			this._hash = _HASH[ value ];
			if ( !this._hash ) {
				_HASH[ value ] = this._hash = new Array( value );
			}
		}

		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------

		private function getCurrentFrame(totalFrames:uint):uint {
			var arr:Array = this._hash[ totalFrames ];
			if ( !arr ) this._hash[ totalFrames ] = arr = new Array();
			var result:uint = arr[ this.$currentFrame ];
			if ( !result ) {
				if ( totalFrames == this.$totalFrames ) {
					result = this.$currentFrame;
				} else {
					result = Math.round( ( this.$currentFrame - 1 ) / this.$totalFrames * totalFrames ) + 1;
				}
				arr[ this.$currentFrame ] = result;
			}
			return result;
		}

		/**
		 * @private
		 */
		private function addedChild(child:DisplayObject):void {
			if ( child is MovieClip ) {
				var mc:MovieClip = child as MovieClip;
				mc.gotoAndStop( this.getCurrentFrame( mc.totalFrames ) );
				if ( this.$totalFrames < mc.totalFrames ) {
					this.setTotalFrame( mc.totalFrames );
				} 
			} else if ( child is Sprite ) {
				if ( this.$totalFrames == 0 ) this.setTotalFrame( 1 );
			}
		}

		/**
		 * @private
		 */
		private function removedChild(child:DisplayObject):void {
			if ( child is MovieClip ) {
				var mc:MovieClip = child as MovieClip;
				if ( mc.totalFrames == this.$totalFrames ) {
					var num:int = super.numChildren;

					if ( num <= 0 ) {
						this.setTotalFrame( 0 );
						return;
					}

					var totalFrames:uint = 1;

					while ( num-- ) {
						mc = super.getChildAt( num ) as MovieClip;
						if ( mc && totalFrames < mc.totalFrames ) {
							totalFrames = mc.totalFrames;
						} 
					}

					if ( this.$totalFrames != totalFrames ) {
						this.setTotalFrame( totalFrames );
						if ( this.$currentFrame < totalFrames ) {
							this.$setCurrentFrame( totalFrames );
						}
					}
				}
			} else if ( child is Sprite ) {
				if ( super.numChildren <= 0 ) this.setTotalFrame( 0 );
			}
		}

	}

}