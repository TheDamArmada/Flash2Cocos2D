////////////////////////////////////////////////////////////////////////////////
//
//  (C) 2009 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.events.managers {

	import by.blooddy.core.managers.drag.DragObject;
	import by.blooddy.core.utils.ClassUtils;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 10
	 * @langversion				3.0
	 */
	public class DragEvent extends MouseEvent {

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		public static const DRAG_START:String =	'dragStart';

		public static const DRAG_MOVE:String =	'dragMove';

		public static const DRAG_STOP:String =	'dragStop';

		public static const DRAG_FAIL:String =	'dragFail';

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function DragEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=0, localY:Number=0, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0, dragSource:DisplayObject=null, dragObject:DragObject=null, dropTarget:DisplayObject = null) {
			super( type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta );
			this.dragObject = dragObject;
			this.dragSource = dragSource;
			this.dropTarget = dropTarget;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		public var dragObject:DragObject;

		public var dragSource:DisplayObject;

		public var dropTarget:DisplayObject;

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------

		public override function clone():Event {
			return new DragEvent( super.type, super.bubbles, super.cancelable, super.localX, super.localY, super.relatedObject, super.ctrlKey, super.altKey, super.shiftKey, super.buttonDown, super.delta, this.dragSource, this.dragObject, this.dropTarget );
		}

		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable', 'localX', 'localY', 'relatedObject', 'ctrlKey', 'altKey', 'shiftKey', 'buttonDown', 'delta', 'dragSource', 'dragObject', 'dropTarget' );
		}

	}

}