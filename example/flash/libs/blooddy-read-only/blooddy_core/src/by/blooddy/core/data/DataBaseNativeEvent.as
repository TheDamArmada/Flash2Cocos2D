////////////////////////////////////////////////////////////////////////////////
//
//  © 2007 BlooDHounD
//
////////////////////////////////////////////////////////////////////////////////

package by.blooddy.core.data {

	import by.blooddy.core.events.data.DataBaseEvent;
	import by.blooddy.core.utils.ClassUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	//--------------------------------------
	//  Namespaces
	//--------------------------------------
	
	use namespace $internal;
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------

	[Exclude( kind="property", name="$stopped" )]
	[Exclude( kind="property", name="$canceled" )]
	[Exclude( kind="property", name="$target" )]
	[Exclude( kind="property", name="$eventPhase" )]

	[ExcludeClass]
	/**
	 * @private
	 * Класс прослойка для создания события бублинга.
	 * Происходит переопределения target и eventPhase, для создания
	 * всплывающих событи.
	 * 
	 * @author					BlooDHounD
	 * @version					1.0
	 * @playerversion			Flash 9
	 * @langversion				3.0
	 */
	public class DataBaseNativeEvent extends Event {

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * Constructor.
		 * 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function DataBaseNativeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			if ( !( this is DataBaseEvent ) ) {
				Error.throwError( IllegalOperationError, 2012, ClassUtils.getClassName( this ) );
			}
			super( type, bubbles, cancelable );
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		$internal var $stopped:Boolean = false;

		/**
		 * @private
		 */
		$internal var $canceled:Boolean = false;

		//--------------------------------------------------------------------------
		//
		//  Overriden properties: Event
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  target
		//----------------------------------

		/**
		 * @private
		 */
		$internal var $target:Object;

		/**
		 * @private
		 * Сцылка на таргет.
		 */
		public override function get target():Object {
			return this.$target || super.target;
		}

		//----------------------------------
		//  eventPhase
		//----------------------------------

		/**
		 * @private
		 */
		$internal var $eventPhase:uint;

		/**
		 * @private
		 * Фаза.
		 */
		public override function get eventPhase():uint {
			return this.$eventPhase || super.eventPhase;
		}

		//--------------------------------------------------------------------------
		//
		//  Overriden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		public override function formatToString(className:String, ...args):String {
			if ( !className ) className = ClassUtils.getClassName( this );
			args.unshift( className );
			return super.formatToString.apply( this, args );
		}

		/**
		 * @private
		 */
		public override function stopImmediatePropagation():void {
			super.stopImmediatePropagation();
			this.$stopped = true;
		}

		/**
		 * @private
		 */
		public override function stopPropagation():void {
			this.$stopped = true;
		}

		/**
		 * @private
		 */
		public override function preventDefault():void {
			if ( super.cancelable ) {
				super.preventDefault();
				this.$canceled = true;
			}
		}

		/**
		 * @private
		 */
		public override function isDefaultPrevented():Boolean {
			return this.$canceled;
		}

		/**
		 * @private
		 */
		public override function clone():Event {
			var c:Class = ( this as Object ).constructor as Class;
			return new c( super.type, super.bubbles, super.cancelable );
		}
		
		/**
		 * @private
		 */
		public override function toString():String {
			return super.formatToString( ClassUtils.getClassName( this ), 'type', 'bubbles', 'cancelable' );
		}
		
	}

}