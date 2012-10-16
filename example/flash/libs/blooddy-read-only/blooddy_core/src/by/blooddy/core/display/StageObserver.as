////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.display {

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class StageObserver {

		public function StageObserver(target:DisplayObject) {
			super();
			this._target = target;
			this._target.addEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage, false, int.MAX_VALUE);
			this._target.addEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage, false, int.MAX_VALUE);
		}

		/**
		 * @private
		 */
		private var _target:DisplayObject;

		/**
		 * @private
		 */
		private	const _listeners:Vector.<StageObserverItem> = new Vector.<StageObserverItem>();

		public function registerEventListener(target:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			var item:StageObserverItem;
			for each (item in this._listeners) {
				if (
					item.target === target &&
					item.type == type &&
					item.listener === listener &&
					item.useCapture == useCapture
				) {
					if (item.priority != priority || item.useWeakReference != useWeakReference) {
						item.priority = priority;
						item.useWeakReference = useWeakReference;
						if ( this._target.stage ) item.activate();
					}
					return;
				}
			}
			item = new StageObserverItem(target, type, listener, useCapture, priority, useWeakReference);
			this._listeners.push( item );
			if (this._target.stage) item.activate();
		}

		public function unregisterEventListener(target:IEventDispatcher, type:String, listener:Function, useCapture:Boolean=false):void {
			if (this._target.stage) {
				target.removeEventListener(type, listener, useCapture);
			}
			var item:StageObserverItem;
			for (var i:Object in this._listeners) {
				item = this._listeners[ i ];
				if (
					item.target === target &&
					item.type == type &&
					item.listener === listener &&
					item.useCapture == useCapture
				) {
					this._listeners.splice( i as uint, 1 );
				}
			}
		}

		public function unregisterTarget():void {
			this._target.removeEventListener(Event.ADDED_TO_STAGE, this.handler_addedToStage);
			this._target.removeEventListener(Event.REMOVED_FROM_STAGE, this.handler_removedFromStage);
			this._target = null;
		}

		/**
		 * @private
		 */
		private function handler_addedToStage(event:Event):void {
			for (var i:uint=0; i<this._listeners.length; ++i) {
				( this._listeners[i] as StageObserverItem ).activate();
			}
		}

		/**
		 * @private
		 */
		private function handler_removedFromStage(event:Event):void {
			for (var i:uint=0; i<this._listeners.length; ++i) {
				( this._listeners[i] as StageObserverItem ).deactivate();
			}
		}

	}

}

//==============================================================================
//
//  Inner definitions
//
//==============================================================================

import flash.events.IEventDispatcher;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: StageObserverItem
//
////////////////////////////////////////////////////////////////////////////////

/**
 * @private
 * Вспомогательный класс.
 */
internal final class StageObserverItem {

	public function StageObserverItem(target:IEventDispatcher!, type:String!, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) {
		super();
		if ( !target )			Error.throwError( TypeError, 2007, 'target' );
		if ( !type )			Error.throwError( TypeError, 2007, 'type' );
		if ( listener == null )	Error.throwError( TypeError, 2007, 'listener' );
		this.target = target;
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
		this.priority = priority;
		this.useWeakReference = useWeakReference;
	}

	public var target:IEventDispatcher;
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	public var priority:int;
	public var useWeakReference:Boolean;

	public function activate():void {
		this.target.addEventListener( this.type, this.listener, this.useCapture, this.priority, this.useWeakReference );
	}

	public function deactivate():void {
		this.target.removeEventListener( this.type, this.listener, this.useCapture );
	}

}