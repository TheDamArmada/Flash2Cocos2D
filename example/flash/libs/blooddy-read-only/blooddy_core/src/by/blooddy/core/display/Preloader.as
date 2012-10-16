////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * @author					etc
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class Preloader extends MovieClip {

		public function Preloader() {
			super();
			super.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage);
			super.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage);
			this._content = this;
			this.update();
		}

		public var percent:TextField;

		public override function get totalFrames():int {
			return this._content === this ? super.totalFrames : this._content.totalFrames;
		}

		public override function get currentFrame():int {
			return this._content === this ? super.currentFrame : this._content.currentFrame;
		}

		/**
		 * @private
		 */
		private var _content:MovieClip;

		public function get content():MovieClip {
			return this._content;
		}

		public function set content(value:MovieClip):void {
			if (this._content === value) return;

			if (this._content && this._content !== this) {
				super.removeChild(this._content);
			}

			this._content = value;

			if (this._content) {
				this.percent = this._content.getChildByName('percent') as TextField;
				super.addChild(this._content);
			} else {
				this._content = this;
			}

			this.update();
		}

		/**
		 * @private
		 */
		private var _progress:Number = 0;

		public override function gotoAndStop(frame:Object, scene:String=null):void {
			if (this._content !== this) {
				this._content.gotoAndStop(frame, scene);
			} else {
				super.gotoAndStop(frame, scene);
			}

			this.update();
		}

		public override function gotoAndPlay(frame:Object, scene:String=null):void {
			if (this._content !== this) {
				this._content.gotoAndPlay(frame, scene);
			} else {
				super.gotoAndPlay(frame, scene);
			}

			this.update();
		}

		/**
		 * @private
		 */
		private function update(event:Event=null):void {
			if (!super.stage || !this.percent) return;
			var mc:MovieClip = this._content;
			var p:Number = mc.currentFrame / mc.totalFrames;
			this._progress += (p - this._progress) / 3;
			this.percent.text = Math.round(this._progress * 100) + '%';
			this.percent.x = -Math.round(this.percent.width / 2);
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			super.addEventListener(Event.ENTER_FRAME, this.update);
			this.update();
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			super.removeEventListener(Event.ENTER_FRAME, this.update);
		}
	}
}